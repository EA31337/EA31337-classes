//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Prevents processing this includes file for the second time.
#ifndef STRATEGY_MQH
#define STRATEGY_MQH

// Includes.
#include "Action.enum.h"
#include "Condition.enum.h"
#include "Dict.mqh"
#include "Indicator.mqh"
#include "Object.mqh"
#include "Strategy.enum.h"
#include "Strategy.struct.h"
#include "String.mqh"
#include "Task.mqh"

// Defines.
#ifndef __noinput__
#define INPUT extern
#else
#define INPUT static
#endif

/**
 * Implements strategy class.
 */
class Strategy : public Object {

 protected:
  Dict<int, double> ddata;
  Dict<int, float> fdata;
  Dict<int, int> idata;
  DictStruct<short, TaskEntry> tasks;
  StgParams sparams;
  StgProcessResult sresult;

 private:
  // Strategy statistics.
  StgStats stats;
  StgStatsPeriod stats_period[FINAL_ENUM_STRATEGY_STATS_PERIOD];

 protected:
  // Base variables.
  string name;
  // Other variables.
  int filter_method[];    // Filter method to consider the trade.
  int open_condition[];   // Open conditions.
  int close_condition[];  // Close conditions.

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  Strategy(const StgParams &_sparams, string _name = "") {
    // Assign struct.
    // We don't want objects which were instantiated by default.
    sparams.DeleteObjects();
    sparams = _sparams;

    // Initialize variables.
    name = _name;

    // Link log instances.
    Logger().Link(sparams.trade.Logger());

    // Statistics variables.
    UpdateOrderStats(EA_STATS_DAILY);
    UpdateOrderStats(EA_STATS_WEEKLY);
    UpdateOrderStats(EA_STATS_MONTHLY);
    UpdateOrderStats(EA_STATS_TOTAL);

    // Call strategy's OnInit method.
    Strategy::OnInit(); // @fixme: Call strategy's method implementing this class instead.
  }

  /**
   * Class copy constructor.
   */
  Strategy(const Strategy &_strat) {
    // @todo
    sparams = _strat.GetParams();
    // ...
  }

  /**
   * Class deconstructor.
   */
  ~Strategy() { sparams.DeleteObjects(); }

  /* Processing methods */

  /**
   * Process strategy's signals.
   *
   * @return
   *   Returns StgProcessResult struct.
   */
  StgProcessResult ProcessSignals() {
    float _boost_factor = 1.0, _lot_size = 0;
    sresult.pos_opened = sresult.pos_closed = 0;
    if (SignalOpen(ORDER_TYPE_BUY, sparams.signal_open_method, sparams.signal_open_level) &&
        SignalOpenFilter(ORDER_TYPE_BUY, sparams.signal_open_filter)) {
      _boost_factor = sparams.IsBoosted() ? SignalOpenBoost(ORDER_TYPE_BUY, sparams.signal_open_boost) : 1.0f;
      _lot_size = sparams.GetLotSizeWithFactor();
      if (OrderOpen(ORDER_TYPE_BUY, _lot_size * _boost_factor, GetOrderOpenComment("SignalOpen"))) {
        sresult.pos_opened++;
      }
    }
    sresult.ProcessLastError();
    if (SignalOpen(ORDER_TYPE_SELL, sparams.signal_open_method, sparams.signal_open_level) &&
        SignalOpenFilter(ORDER_TYPE_SELL, sparams.signal_open_filter)) {
      _boost_factor = sparams.IsBoosted() ? SignalOpenBoost(ORDER_TYPE_SELL, sparams.signal_open_boost) : 1.0f;
      _lot_size = sparams.GetLotSizeWithFactor();
      if (OrderOpen(ORDER_TYPE_SELL, _lot_size * _boost_factor, GetOrderOpenComment("SignalOpen"))) {
        sresult.pos_opened++;
      }
    }
    if (sparams.trade.HasActiveOrders()) {
      sresult.ProcessLastError();
      if (SignalClose(ORDER_TYPE_BUY, sparams.signal_close_method, sparams.signal_close_level)) {
        if (sparams.trade.OrdersCloseViaCmd(ORDER_TYPE_BUY, GetOrderCloseComment("SignalClose")) > 0) {
          sresult.pos_closed++;
        }
      }
      sresult.ProcessLastError();
      if (SignalClose(ORDER_TYPE_SELL, sparams.signal_close_method, sparams.signal_close_level)) {
        if (sparams.trade.OrdersCloseViaCmd(ORDER_TYPE_SELL, GetOrderCloseComment("SignalClose")) > 0) {
          sresult.pos_closed++;
        }
      }
    }
    sresult.ProcessLastError();
    return sresult;
  }

  /**
   * Process strategy's orders.
   *
   * @return
   *   Returns StgProcessResult struct.
   */
  StgProcessResult ProcessOrders() {
    bool sl_valid, tp_valid;
    double sl_new, tp_new;
    Ref<Order> _order;
    DictStruct<long, Ref<Order>> *_orders_active = sparams.trade.GetOrdersActive();
    for (DictStructIterator<long, Ref<Order>> iter = _orders_active.Begin(); iter.IsValid(); ++iter) {
      _order = iter.Value();
      if (_order.Ptr().IsOpen()) {
        sl_new =
            PriceLimit(_order.Ptr().OrderType(), ORDER_TYPE_SL, sparams.price_limit_method, sparams.price_limit_level);
        tp_new =
            PriceLimit(_order.Ptr().OrderType(), ORDER_TYPE_TP, sparams.price_limit_method, sparams.price_limit_level);
        sl_new = Market().NormalizeSLTP(sl_new, _order.Ptr().GetRequest().type, ORDER_TYPE_SL);
        tp_new = Market().NormalizeSLTP(tp_new, _order.Ptr().GetRequest().type, ORDER_TYPE_TP);
        sl_valid = sparams.trade.ValidSL(sl_new, _order.Ptr().GetRequest().type);
        tp_valid = sparams.trade.ValidTP(tp_new, _order.Ptr().GetRequest().type);
        _order.Ptr().OrderModify(
            sl_valid && sl_new > 0 ? Market().NormalizePrice(sl_new) : _order.Ptr().GetStopLoss(),
            tp_valid && tp_new > 0 ? Market().NormalizePrice(tp_new) : _order.Ptr().GetTakeProfit());
        sresult.stops_invalid_sl += (unsigned short)sl_valid;
        sresult.stops_invalid_tp += (unsigned short)tp_valid;
      } else {
        sparams.trade.OrderMoveToHistory(_order.Ptr());
      }
    }
    sresult.ProcessLastError();
    return sresult;
  }

  /**
   * Process strategy's signals and orders.
   *
   * @param ushort _periods_started
   *   Periods which started.
   *
   * @return
   *   Returns StgProcessResult struct.
   */
  StgProcessResult Process(unsigned short _periods_started = DATETIME_NONE) {
    sresult.last_error = ERR_NO_ERROR;
    ProcessSignals();
    ProcessOrders();
    if (_periods_started > 0) {
      ProcessTasks();
    }
    return sresult;
  }

  /* Tasks */

  /**
   * Add task.
   */
  void AddTask(TaskEntry &_entry) {
    if (_entry.IsValid()) {
      if (_entry.GetAction().GetType() == ACTION_TYPE_STRATEGY) {
        _entry.SetActionObject(GetPointer(this));
      }
      if (_entry.GetCondition().GetType() == COND_TYPE_STRATEGY) {
        _entry.SetConditionObject(GetPointer(this));
      }
      tasks.Push(_entry);
    }
  }

  /**
   * Process strategy's tasks.
   *
   * @return
   *   Returns StgProcessResult struct.
   */
  void ProcessTasks() {
    for (DictStructIterator<short, TaskEntry> iter = tasks.Begin(); iter.IsValid(); ++iter) {
      bool _is_processed = false;
      TaskEntry _entry = iter.Value();
      _is_processed = Task::Process(_entry);
      sresult.tasks_processed += (unsigned short) _is_processed;
      sresult.tasks_processed_not += (unsigned short) !_is_processed;
    }
  }

  /* State checkers */

  /**
   * Validate strategy's timeframe and parameters.
   *
   * @return
   *   Returns true when strategy params are valid, otherwise false.
   */
  bool IsValid() {
    return Object::IsValid(sparams.trade) && Object::IsValid(sparams.GetChart()) && sparams.GetChart().IsValidTf();
  }

  /**
   * Check state of the strategy.
   */
  bool IsEnabled() { return sparams.IsEnabled(); }

  /**
   * Check suspension status of the strategy.
   */
  bool IsSuspended() { return sparams.IsSuspended(); }

  /**
   * Check state of the strategy.
   */
  bool IsBoostEnabled() { return sparams.IsBoosted(); }

  /* Class getters */

  /**
   * Returns strategy's market class.
   */
  Market *Market() { return sparams.trade.Market(); }

  /**
   * Returns strategy's indicator data class.
   */
  Indicator *Data() { return sparams.data; }

  /**
   * Returns strategy's log class.
   */
  Log *Logger() { return sparams.logger.Ptr(); }

  /**
   * Returns handler to the strategy's trading class.
   */
  Trade *Trade() { return sparams.trade; }

  /**
   * Returns access to Chart information.
   */
  Chart *Chart() { return sparams.GetChart(); }

  /**
   * Returns handler to the strategy's indicator class.
   */
  Indicator *Indicator() { return sparams.data; }

  /* Struct getters */

  /**
   * Gets result of the last signal processing.
   */
  StgProcessResult GetProcessResult() { return sresult; }

  /* Getters */

  /**
   * Gets strategy entry.
   */
  StgEntry GetEntry() {
    StgEntry _entry = {};
    for (ENUM_STRATEGY_STATS_PERIOD _p = EA_STATS_DAILY;
         _p < FINAL_ENUM_STRATEGY_STATS_PERIOD;
         _p++) {
      _entry.SetStats(stats_period[_p], _p);
    }
    return _entry;
  }

  /**
   * Get strategy's name.
   */
  string GetName() { return name; }

  /**
   * Get strategy's ID.
   */
  virtual long GetId() { return sparams.id; }

  /**
   * Get strategy's weight.
   *
   * Note: Implementation of inherited method.
   */
  virtual double GetWeight() { return sparams.weight; }

  /**
   * Get strategy's magic number.
   */
  unsigned long GetMagicNo() { return sparams.magic_no; }

  /**
   * Get strategy's timeframe.
   */
  ENUM_TIMEFRAMES GetTf() { return sparams.GetChart().GetTf(); }

  /**
   * Get strategy's signal open method.
   */
  int GetSignalOpenMethod() { return sparams.signal_open_method; }

  /**
   * Get strategy's signal open level.
   */
  double GetSignalOpenLevel() { return sparams.signal_open_level; }

  /**
   * Get strategy's signal close method.
   */
  int GetSignalCloseMethod() { return sparams.signal_close_method; }

  /**
   * Get strategy's signal close level.
   */
  double GetSignalCloseLevel() { return sparams.signal_close_level; }

  /**
   * Get strategy's price limit method.
   */
  int GetPriceLimitMethod() { return sparams.signal_close_method; }

  /**
   * Get strategy's price limit level.
   */
  double GetPriceLimitLevel() { return sparams.signal_close_level; }

  /**
   * Get strategy's order open comment.
   */
  string GetOrderOpenComment(string _prefix = "", string _suffix = "") {
    return StringFormat("%s%s[%s];s:%gp%s", _prefix != "" ? _prefix + ": " : "", name, sparams.GetChart().TfToString(),
                        GetCurrSpread(), _suffix != "" ? "| " + _suffix : "");
  }

  /**
   * Get strategy's order close comment.
   */
  string GetOrderCloseComment(string _prefix = "", string _suffix = "") {
    return StringFormat("%s%s[%s];s:%gp%s", _prefix != "" ? _prefix + ": " : "", name, sparams.GetChart().TfToString(),
                        GetCurrSpread(), _suffix != "" ? "| " + _suffix : "");
  }

  /**
   * Get strategy orders currently open.
   */
  uint GetOrdersOpen() {
    // UpdateOrderStats(EA_STATS_TOTAL);
    // @todo
    return stats.orders_open;
  }

  /**
   * Get strategy's params.
   */
  StgParams GetParams() const { return sparams; }

  /**
   * Gets custom data.
   */
  Dict<int, double> *GetDataD() { return &ddata; }
  Dict<int, float> *GetDataF() { return &fdata; }
  Dict<int, int> *GetDataI() { return &idata; }

  /* Statistics */

  /**
   * Gets strategy orders total opened.
   */
  uint GetOrdersTotal(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].orders_total;
  }

  /**
   * Gets strategy orders won.
   */
  uint GetOrdersWon(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].orders_won;
  }

  /**
   * Gets strategy orders lost.
   */
  uint GetOrdersLost(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].orders_lost;
  }

  /**
   * Gets strategy net profit.
   */
  double GetNetProfit(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].net_profit;
  }

  /**
   * Gets strategy gross profit.
   */
  double GetGrossProfit(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].gross_profit;
  }

  /**
   * Gets strategy gross loss.
   */
  double GetGrossLoss(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].gross_loss;
  }

  /**
   * Gets the average spread of the strategy (in pips).
   */
  double GetAvgSpread(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].avg_spread;
  }

  /* Setters */

  /**
   * Sets strategy's name.
   */
  void SetName(string _name) { name = _name; }

  /**
   * Sets strategy's ID.
   */
  void SetId(long _id) {
    sparams.id = _id;
    ((Object *)GetPointer(this)).SetId(_id);
  }

  /**
   * Sets strategy's weight.
   */
  void SetWeight(float _weight) { sparams.weight = _weight; }

  /**
   * Sets strategy's magic number.
   */
  void SetMagicNo(unsigned long _magic_no) { sparams.magic_no = _magic_no; }

  /**
   * Sets strategy's signal open method.
   */
  void SetSignalOpenMethod(int _method) { sparams.signal_open_method = _method; }

  /**
   * Sets strategy's signal open level.
   */
  void SetSignalOpenLevel(float _level) { sparams.signal_open_level = _level; }

  /**
   * Sets strategy's signal close method.
   */
  void SetSignalCloseMethod(int _method) { sparams.signal_close_method = _method; }

  /**
   * Sets strategy's signal close level.
   */
  void SetSignalCloseLevel(float _level) { sparams.signal_close_level = _level; }

  /**
   * Sets strategy's price limit method.
   */
  void SetPriceLimitMethod(int _method) { sparams.signal_close_method = _method; }

  /**
   * Sets strategy's price limit level.
   */
  void SetPriceLimitLevel(float _level) { sparams.signal_close_level = _level; }

  /**
   * Enable/disable the strategy.
   */
  void Enabled(bool _enable = true) { sparams.Enabled(_enable); }

  /**
   * Suspend the strategy.
   */
  void Suspended(bool _suspended = true) { sparams.Suspended(_suspended); }

  /**
   * Sets custom data.
   */
  void SetData(Dict<int, double> *_ddata) { ddata = _ddata; }
  void SetData(Dict<int, float> *_fdata) { fdata = _fdata; }
  void SetData(Dict<int, int> *_idata) { idata = _idata; }

  /* Static setters */

  /**
   * Sets initial params based on the timeframe.
   */
  template <typename T>
  static void SetParamsByTf(T &_result, ENUM_TIMEFRAMES _tf, T &_m1, T &_m5, T &_m15, T &_m30, T &_h1, T &_h4, T &_h8) {
    switch (_tf) {
      case PERIOD_M1: {
        _result = _m1;
        break;
      }
      case PERIOD_M5: {
        _result = _m5;
        break;
      }
      case PERIOD_M15: {
        _result = _m15;
        break;
      }
      case PERIOD_M30: {
        _result = _m30;
        break;
      }
      case PERIOD_H1: {
        _result = _h1;
        break;
      }
      case PERIOD_H4: {
        _result = _h4;
        break;
      }
      case PERIOD_H8: {
        _result = _h8;
        break;
      }
    }
  }

  /* Calculation methods */

  /**
   * Get lot size factor.
   */
  double UpdateLotSizeFactor() { return 1.0; }

  /**
   * Update order stat variables.
   */
  void UpdateOrderStats(ENUM_STRATEGY_STATS_PERIOD _period) {
    // @todo: Implement support for _period.
    static datetime _last_update = TimeCurrent();
    if (_last_update > TimeCurrent() - sparams.refresh_time) {
      return;  // Do not update too often.
    }
    unsigned int _total = 0, _won = 0, _lost = 0, _open = 0;
    int i;
    double _gross_profit = 0, _gross_loss = 0, _net_profit = 0, _order_profit = 0;
    datetime _order_datetime;
    for (i = 0; i < Trade::OrdersTotal(); i++) {
      // @todo: Select order.
      if (Market().GetSymbol() == Order::OrderSymbol() && sparams.magic_no == Order::OrderMagicNumber()) {
        _total++;
        _order_profit = Order::OrderProfit() - Order::OrderCommission() - Order::OrderSwap();
        _net_profit += _order_profit;
        if (Order::OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
          _open++;
        } else {
          _order_datetime = (datetime)OrderGetInteger(ORDER_TIME_DONE);
          // s_daily_net_profit += @todo;
          // s_weekly_net_profit += @todo;
          // s_monhtly_net_profit += @todo;
          if (_order_profit > 0) {
            _won++;
            _gross_profit += _order_profit;
          } else {
            _lost++;
            _gross_loss += _order_profit;
          }
        }
      }
    }
    // stats.orders_open = _open;
    stats_period[_period].orders_won = _won;
    stats_period[_period].orders_lost = _lost;
    stats_period[_period].orders_total = _total;
    stats_period[_period].net_profit = _net_profit;
    stats_period[_period].gross_profit = _gross_loss;
    stats_period[_period].gross_loss = _gross_profit;
    // stats_period[_period].profit_factor = _profit_factor;
    _last_update = TimeCurrent();
  }

  /**
   * Get profit factor of the strategy.
   */
  double GetProfitFactor() {
    // @todo
    return 0.0;
  }

  /**
   * Get current spread (in pips).
   */
  double GetCurrSpread() { return sparams.GetChart().GetSpreadInPips(); }

  /**
   * Convert timeframe constant to index value.
   */
  uint TfToIndex(ENUM_TIMEFRAMES _tf) { return Chart::TfToIndex(_tf); }

  /**
   * Class constructor.
   */
  /*
  bool Strategy() {

    // Trading variables.
    s_lot_size = si_lot_size;
    s_lot_factor = GetLotSizeFactor();
    s_avg_spread = GetCurrSpread();
    s_tp_max = 0;
    s_sl_max = 0;

    // Statistics variables.
    s_orders_open         = GetOrdersOpen();
    s_orders_total        = GetOrdersTotal();
    s_orders_won          = GetOrdersWon();
    s_orders_lost         = GetOrdersLost();
    s_profit_factor       = GetProfitFactor();
    s_avg_spread          = GetAvgSpread();
    s_total_net_profit    = GetTotalNetProfit();
    s_total_gross_profit  = GetTotalGrossProfit();
    s_total_gross_loss    = GetTotalGrossLoss();
    s_daily_net_profit    = GetDailyNetProfit();
    s_weekly_net_profit   = GetWeeklyNetProfit();
    s_monhtly_net_profit  = GetMonthlyNetProfit();

    // Other variables.
    s_refresh_time        = 10;
  }
  */

  /**
   * Initialize strategy.
   */
  bool Init() {
    if (!sparams.GetChart().IsValidTf()) {
      Logger().Warning(StringFormat("Could not initialize %s since %s timeframe is not active!", GetName(),
                                    sparams.GetChart().TfToString()),
                       __FUNCTION__ + ": ");
      return false;
    }
    return true;
  }

  /* Orders methods */

  /**
   * Open an order.
   */
  bool OrderOpen(ENUM_ORDER_TYPE _cmd, double _lot_size = 0, string _comment = "") {
    bool _result = false;
    // Prepare order request.
    MqlTradeRequest _request = {0};
    _request.action = TRADE_ACTION_DEAL;
    _request.comment = _comment;
    _request.deviation = 10;
    _request.magic = GetMagicNo();
    _request.price = Market().GetOpenOffer(_cmd);
    _request.symbol = Market().GetSymbol();
    _request.type = _cmd;
    _request.type_filling = Order::GetOrderFilling(_request.symbol);
    _request.volume = _lot_size > 0 ? _lot_size : fmax(sparams.GetLotSize(), Market().GetVolumeMin());
    ResetLastError();
    // Prepare order parameters.
    OrderParams _oparams;
    if (sparams.order_close_time != 0) {
      MqlParam _cond_args[] = {{TYPE_INT, 0}};
      _cond_args[0].integer_value = sparams.order_close_time > 0
        ? sparams.order_close_time * 60
        : sparams.order_close_time * PeriodSeconds();
      _oparams.SetConditionClose(ORDER_COND_LIFETIME_GT_ARG, _cond_args);
    }
    // Create new order.
    Order *_order = new Order(_request, _oparams);
    _result = sparams.trade.OrderAdd(_order);
    if (_result) {
      OnOrderOpen(_order);
    }
    return _result;
  }

  /* Conditions and actions */

  /**
   * Checks for Strategy condition.
   *
   * @param ENUM_STRATEGY_CONDITION _cond
   *   Strategy condition.
   * @return
   *   Returns true when the condition is met.
   */
  bool CheckCondition(ENUM_STRATEGY_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      case STRAT_COND_IS_ENABLED:
        return sparams.IsEnabled();
      case STRAT_COND_IS_SUSPENDED:
        return sparams.IsSuspended();
      default:
        Logger().Error(StringFormat("Invalid EA condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }

  /**
   * Execute Strategy action.
   *
   * @param ENUM_STRATEGY_ACTION _action
   *   Strategy action to execute.
   * @param MqlParam _args
   *   Trade action arguments.
   * @return
   *   Returns true when the action has been executed successfully.
   */
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action, MqlParam &_args[]) {
    bool _result = true;
    switch (_action) {
      case STRAT_ACTION_DISABLE:
        sparams.Enabled(false);
        return true;
      case STRAT_ACTION_ENABLE:
        sparams.Enabled(true);
        return true;
      case STRAT_ACTION_SUSPEND:
        sparams.Suspended(true);
        return true;
      case STRAT_ACTION_UNSUSPEND:
        sparams.Suspended(false);
        return true;
      default:
        Logger().Error(StringFormat("Invalid Strategy action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
    }
    return _result;
  }
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action) {
    MqlParam _args[] = {};
    return Strategy::ExecuteAction(_action, _args);
  }

  /* Printers methods */

  /**
   * Prints strategy's details.
   */
  string ToString() { return StringFormat("%s: %s", GetName(), sparams.ToString()); }

  /* Virtual methods */

  /**
   * Event on strategy's init.
   */
  virtual void OnInit() {}

  /**
   * Event on strategy's order open.
   *
   * @param
   *   _order Order Instance of order which got opened.
   */
  virtual void OnOrderOpen(const Order &_order) {
    if (Logger().GetLevel() >= V_INFO) {
      Logger().Info(_order.ToString(), (string)_order.GetTicket());
    }
  }

  /**
   * Event on new time periods.
   *
   * Example:
   *   unsigned short _periods = (DATETIME_MINUTE | DATETIME_HOUR);
   *   OnPeriod(_periods);
   *
   * @param
   *   _periods unsigned short
   *   List of periods which started. See: ENUM_DATETIME_UNIT.
   */
  virtual void OnPeriod(unsigned short _periods = DATETIME_NONE) {
    if ((_periods & DATETIME_MINUTE) != 0) {
      // New minute started.
    }
    if ((_periods & DATETIME_HOUR) != 0) {
      // New hour started.
    }
    if ((_periods & DATETIME_DAY) != 0) {
      // New day started.
    }
    if ((_periods & DATETIME_WEEK) != 0) {
      // New week started.
    }
    if ((_periods & DATETIME_MONTH) != 0) {
      // New month started.
    }
    if ((_periods & DATETIME_YEAR) != 0) {
      // New year started.
    }
  }

  /**
   * Filters strategy's market tick.
   *
   * @param
   *   _method - signal method to filter a tick (bitwise AND operation)
   *
   * @result bool
   *   Returns true when tick should be processed, otherwise false.
   */
  virtual bool TickFilter(const MqlTick &_tick, const int _method) {
    bool _res = _method == 0;
    if (_method != 0) {
      static MqlTick _last_tick = {0};
      if (METHOD(_method, 0)) {  // 1
        // Process on every minute.
        _res |= _tick.time % 60 < _last_tick.time % 60;
      }
      if (METHOD(_method, 1)) {  // 2
        // Process low and high ticks of a bar.
        _res |= _tick.bid >= sparams.GetChart().GetHigh() || _tick.bid <= sparams.GetChart().GetLow();
      }
      if (METHOD(_method, 2)) {  // 4
        // Process only peak prices of each minute.
        static double _peak_high = _tick.bid, _peak_low = _tick.bid;
        if (_tick.time % 60 < _last_tick.time % 60) {
          // Resets peaks each minute.
          _peak_high = _peak_low = _tick.bid;
        } else {
          // Sets new peaks.
          _peak_high = _tick.bid > _peak_high ? _tick.bid : _peak_high;
          _peak_low = _tick.bid < _peak_low ? _tick.bid : _peak_low;
        }
        _res |= (_tick.bid == _peak_high) || (_tick.bid == _peak_low);
      }
      if (METHOD(_method, 3)) {  // 8
        // Process only unique ticks (avoid duplicates).
        _res |= _tick.bid != _last_tick.bid && _tick.ask != _last_tick.ask;
      }
      if (METHOD(_method, 4)) {  // 16
        // Process ticks in the middle of the bar.
        _res |= (sparams.GetChart().iTime() + (sparams.GetChart().GetPeriodSeconds() / 2)) == TimeCurrent();
      }
      if (METHOD(_method, 5)) {  // 32
        // Process bar open price ticks.
        _res |= _last_tick.time < sparams.GetChart().GetBarTime();
      }
      if (METHOD(_method, 6)) {  // 64
        // Process every 10th of the bar.
        _res |= TimeCurrent() % (int)(sparams.GetChart().GetPeriodSeconds() / 10) == 0;
      }
      if (METHOD(_method, 7)) {  // 128
        // Process tick on every 10 seconds.
        _res |= _tick.time % 10 < _last_tick.time % 10;
      }
      _last_tick = _tick;
    }
    return _res;
  }
  virtual bool TickFilter(const MqlTick &_tick) { return TickFilter(_tick, sparams.tick_filter_method); }

  /**
   * Checks strategy's trade open signal.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - signal method to open a trade (bitwise AND operation)
   *   _level  - signal level to open a trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true when trade should be opened, otherwise false.
   */
  virtual bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f) = NULL;

  /**
   * Checks strategy's trade open signal additional filter.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - signal method to filter a trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true when trade should be opened, otherwise false.
   */
  virtual bool SignalOpenFilter(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      if (METHOD(_method, 0)) _result &= !sparams.trade.HasBarOrder(_cmd);
      // if (METHOD(_method, 0)) _result &= Trade().IsTrend(_cmd);
      // if (METHOD(_method, 1)) _result &= Trade().IsPivot(_cmd);
      // if (METHOD(_method, 2)) _result &= Trade().IsPeakHours(_cmd);
      // if (METHOD(_method, 3)) _result &= Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 4)) _result &= Trade().IsHedging(_cmd);
      // if (METHOD(_method, 5)) _result &= Trade().IsPeakBar(_cmd);
    }
    return _result;
  }

  /**
   * Gets strategy's lot size boost for the open signal.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - boost method (bitwise AND operation)
   *
   * @result double
   *   Returns lot size multiplier (0.0 = normal, 0.1 = 1/10, 1.0 = normal, 2.0 = 2x).
   *   Range: between 0.0 and (max_risk * 2).
   */
  virtual float SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    float _result = 1.0;
    if (_method != 0) {
      // if (METHOD(_method, 0)) if (Trade().IsTrend(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 1)) if (Trade().IsPivot(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 2)) if (Trade().IsPeakHours(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 3)) if (Trade().IsRoundNumber(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 4)) if (Trade().IsHedging(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 5)) if (Trade().IsPeakBar(_cmd)) _result *= 1.1;
    }
    return _result;
  }

  /**
   * Checks strategy's trade close signal.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - signal method to close a trade (bitwise AND operation)
   *   _level  - signal level to close a trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true when trade should be closed, otherwise false.
   */
  virtual bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _mode   - mode for price limit value (ORDER_TYPE_TP or ORDER_TYPE_SL)
   *   _method - method to calculate the price limit
   *   _level  - level value to use for calculation
   *
   * @result bool
   *   Returns current stop loss value when _mode is ORDER_TYPE_SL and profit take when _mode is ORDER_TYPE_TP.
   */
  virtual float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0,
                           float _level = 0.0f) = NULL;
};
#endif  // STRATEGY_MQH
