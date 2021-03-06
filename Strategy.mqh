//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

// Forward declaration.
class Trade;

// Includes.
#include "Data.struct.h"
#include "Dict.mqh"
#include "Indicator.mqh"
#include "Object.mqh"
#include "Strategy.enum.h"
#include "Strategy.struct.h"
#include "String.mqh"
#include "Task.mqh"
#include "Trade.mqh"

// Defines.
#ifdef __input__
#define INPUT input
#else
#define INPUT static
#endif
#ifdef __input2__
#define INPUT2 input
#else
#define INPUT2 static
#endif
#ifdef __input3__
#define INPUT3 input
#else
#define INPUT3 static
#endif
#ifdef __optimize__
#define OINPUT input
#else
#define OINPUT static
#endif

/**
 * Implements strategy class.
 */
class Strategy : public Object {
 public:
  StgParams sparams;

 protected:
  Dict<int, double> ddata;
  Dict<int, float> fdata;
  Dict<int, int> idata;
  DictStruct<short, TaskEntry> tasks;
  Log logger;  // Log instance.
  MqlTick last_tick;
  StgProcessResult sresult;
  Strategy *strat_sl, *strat_tp;  // Strategy pointers for stop-loss and profit-take.
  StrategySignal last_signals;    // Last signals.
  Trade trade;                    // Trade instance.

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
  Strategy(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : sparams(_sparams), trade(_tparams, _cparams), Object(GetPointer(this), __LINE__) {
    // Initialize variables.
    name = _name;
    MqlTick _tick = {0};
    last_tick = _tick;

    // Link log instances.
    // logger.Link(trade.Logger()); // @todo

    // Statistics variables.
    // UpdateOrderStats(EA_STATS_DAILY);
    // UpdateOrderStats(EA_STATS_WEEKLY);
    // UpdateOrderStats(EA_STATS_MONTHLY);
    // UpdateOrderStats(EA_STATS_TOTAL);

    // Call strategy's OnInit method.
    Strategy::OnInit();
  }

  /**
   * Class copy constructor.
   */
  /*
  Strategy(const Strategy &_strat) {
    // @todo
    sparams = _strat.GetParams();
    // ...
  }
  */

  /**
   * Class deconstructor.
   */
  ~Strategy() { sparams.DeleteObjects(); }

  /* Processing methods */

  /**
   * Process strategy's signals.
   *
   * @param bool _should_open
   *   True if method should open the orders, otherwise only process the signals.
   * @param bool _should_close
   *   True if method should close the orders, otherwise only process the signals.
   * @param int _shift
   *   Bar shift.
   *
   * @return
   *   Returns StrategySignal struct.
   */
  StrategySignal ProcessSignals(bool _trade_allowed = true, int _shift = -1) {
    // float _bf = 1.0;
    // float _ls = 0;
    float _scl = sparams.signal_close_level;
    int _scm = sparams.signal_close_method;
    int _ss = _shift >= 0 ? _shift : sparams.shift;
    StrategySignal _signal;
    if (_trade_allowed) {
      float _sol = sparams.signal_open_level;
      int _sob = sparams.signal_open_boost;
      int _sof = sparams.signal_open_filter;
      int _som = sparams.signal_open_method;
      // Process boost factor and lot size.
      // sresult.SetBoostFactor(sparams.IsBoosted() ? SignalOpenBoost(ORDER_TYPE_BUY, _sob) : 1.0f);
      // sresult.SetLotSize(sparams.GetLotSizeWithFactor());
      // Process open signals when trade is allowed.
      _signal.SetSignal(STRAT_SIGNAL_BUY_OPEN, SignalOpen(ORDER_TYPE_BUY, _som, _sol, _ss));
      _signal.SetSignal(STRAT_SIGNAL_BUY_PASS, SignalOpenFilter(ORDER_TYPE_BUY, _sof));
      _signal.SetSignal(STRAT_SIGNAL_SELL_OPEN, SignalOpen(ORDER_TYPE_SELL, _som, _sol, _ss));
      _signal.SetSignal(STRAT_SIGNAL_SELL_PASS, SignalOpenFilter(ORDER_TYPE_SELL, _sof));
    }
    // Process close signals.
    _signal.SetSignal(STRAT_SIGNAL_BUY_CLOSE, SignalClose(ORDER_TYPE_BUY, _scm, _scl, _ss));
    _signal.SetSignal(STRAT_SIGNAL_SELL_CLOSE, SignalClose(ORDER_TYPE_SELL, _scm, _scl, _ss));
    last_signals = _signal;
    return _signal;
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
    Order *_order;
    DictStruct<long, Ref<Order>> *_orders_active = trade.GetOrdersActive();
    for (DictStructIterator<long, Ref<Order>> iter = _orders_active.Begin(); iter.IsValid(); ++iter) {
      _order = iter.Value().Ptr();
      if (_order.IsOpen()) {
        OrderData _odata = _order.GetData();
        Strategy *_strat_sl = strat_sl;
        Strategy *_strat_tp = strat_tp;
        _order.Update();
        if (_strat_sl != NULL && _strat_tp != NULL) {
          float _psl = _strat_sl.Get<float>(STRAT_PARAM_PSL);
          float _ppl = _strat_tp.Get<float>(STRAT_PARAM_PPL);
          int _ppm = _strat_tp.Get<int>(STRAT_PARAM_PPM);
          int _psm = _strat_sl.Get<int>(STRAT_PARAM_PSM);
          sl_new = _strat_sl.PriceStop(_odata.type, ORDER_TYPE_SL, _psm, _psl);
          tp_new = _strat_tp.PriceStop(_odata.type, ORDER_TYPE_TP, _ppm, _ppl);
          sl_new = trade.NormalizeSL(sl_new, _odata.type);
          tp_new = trade.NormalizeTP(tp_new, _odata.type);
          sl_valid = trade.IsValidOrderSL(sl_new, _odata.type, _odata.sl, _psm > 0);
          tp_valid = trade.IsValidOrderTP(tp_new, _odata.type, _odata.tp, _ppm > 0);
          if (sl_valid && tp_valid) {
            if (!_order.OrderModify(sl_new, tp_new)) {
              _order.Logger().Flush();
            }
          }
          sresult.stops_invalid_sl += (unsigned short)sl_valid;
          sresult.stops_invalid_tp += (unsigned short)tp_valid;
        } else {
          logger.Error("Error loading SL/TP objects!", __FUNCTION_LINE__);
        }
      } else {
        trade.OrderMoveToHistory(_order);
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
    last_signals = ProcessSignals();
    if (_periods_started > 0) {
      ProcessOrders();
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
      sresult.tasks_processed += (unsigned short)_is_processed;
      sresult.tasks_processed_not += (unsigned short)!_is_processed;
    }
  }

  /* State checkers */

  /**
   * Check state of the strategy.
   */
  bool IsEnabled() { return sparams.IsEnabled(); }

  /**
   * Check suspension status of the strategy.
   */
  bool IsSuspended() { return sparams.IsSuspended(); }

  /**
   * Checks if the current price is in trend given the order type.
   */
  bool IsTrend(ENUM_ORDER_TYPE _cmd) {
    bool _result = false;
    double _tvalue = TrendStrength();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = _tvalue > sparams.trend_threshold;
        break;
      case ORDER_TYPE_SELL:
        _result = _tvalue < -sparams.trend_threshold;
        break;
    }
    return _result;
  }

  /**
   * Check state of the strategy.
   */
  bool IsBoostEnabled() { return sparams.IsBoosted(); }

  /* Class getters */

  /**
   * Returns access to Chart information.
   */
  // Chart *GetChart() { return trade.GetChart(); }

  /**
   * Returns handler to the strategy's indicator class.
   */
  Indicator *GetIndicator(int _id = 0) { return sparams.GetIndicator(_id); }

  /* Struct getters */

  /**
   * Gets result of the last signal processing.
   */
  StgProcessResult GetProcessResult() { return sresult; }

  /* Getters */

  /**
   * Gets a strategy parameter value.
   */
  template <typename T>
  T Get(ENUM_STRATEGY_PARAM _param) {
    return sparams.Get<T>(_param);
  }

  /**
   * Gets a trade parameter value.
   */
  template <typename T>
  T Get(ENUM_TRADE_PARAM _param) {
    return trade.Get<T>(_param);
  }

  /**
   * Gets strategy entry.
   */
  StgEntry GetEntry() {
    StgEntry _entry = {};
    for (ENUM_STRATEGY_STATS_PERIOD _p = EA_STATS_DAILY; _p < FINAL_ENUM_STRATEGY_STATS_PERIOD; _p++) {
      _entry.SetStats(stats_period[_p], _p);
    }
    return _entry;
  }

  /**
   * Get strategy's last signals.
   */
  StrategySignal GetLastSignals() { return last_signals; }

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
   * Get strategy's timeframe.
   */
  // ENUM_TIMEFRAMES GetTf() { return trade.GetChart().GetTf(); }

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
   * Get strategy's price stop method.
   */
  int GetPriceStopMethod() { return sparams.signal_close_method; }

  /**
   * Get strategy's price stop level.
   */
  double GetPriceStopLevel() { return sparams.signal_close_level; }

  /**
   * Get strategy's order open comment.
   */
  string GetOrderOpenComment(string _prefix = "", string _suffix = "") {
    // @todo
    // return StringFormat("%s%s[%s];s:%gp%s", _prefix != "" ? _prefix + ": " : "", name, trade.chart.TfToString(),
    // GetCurrSpread(), _suffix != "" ? "| " + _suffix : "");

    return StringFormat("%s%s[%s]%s", _prefix, name, ChartTf::TfToString(trade.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF)),
                        _suffix);
  }

  /**
   * Get strategy's order close comment.
   */
  string GetOrderCloseComment(string _prefix = "", string _suffix = "") {
    // @todo: Add spread and timeframe.
    // return StringFormat("%s%s[%s];s:%gp%s", _prefix != "" ? _prefix + ": " : "", name, trade.GetChart().TfToString(),
    // GetCurrSpread(), _suffix != "" ? "| " + _suffix : "");
    return StringFormat("%s%s;%s", _prefix != "" ? _prefix + ": " : "", name, _suffix != "" ? "| " + _suffix : "");
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
    // UpdateOrderStats(_period);
    return stats_period[_period].orders_total;
  }

  /**
   * Gets strategy orders won.
   */
  uint GetOrdersWon(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[_period].orders_won;
  }

  /**
   * Gets strategy orders lost.
   */
  uint GetOrdersLost(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[_period].orders_lost;
  }

  /**
   * Gets strategy net profit.
   */
  double GetNetProfit(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[_period].net_profit;
  }

  /**
   * Gets strategy gross profit.
   */
  double GetGrossProfit(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[_period].gross_profit;
  }

  /**
   * Gets strategy gross loss.
   */
  double GetGrossLoss(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[_period].gross_loss;
  }

  /**
   * Gets the average spread of the strategy (in pips).
   */
  double GetAvgSpread(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[_period].avg_spread;
  }

  /* Setters */

  /* Getters */

  /**
   * Sets a strategy parameter value.
   */
  template <typename T>
  void Set(ENUM_STRATEGY_PARAM _param, T _value) {
    sparams.Set<T>(_param, _value);
  }

  /**
   * Sets a trade parameter value.
   */
  template <typename T>
  void Set(ENUM_TRADE_PARAM _param, T _value) {
    trade.Set<T>(_param, _value);
  }

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
   * Sets strategy's stops.
   */
  void SetStops(Strategy *_strat_sl = NULL, Strategy *_strat_tp = NULL) {
    strat_sl = _strat_sl != NULL ? _strat_sl : strat_sl;
    strat_tp = _strat_tp != NULL ? _strat_tp : strat_tp;
  }

  /**
   * Sets strategy's weight.
   */
  void SetWeight(float _weight) { sparams.weight = _weight; }

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
   * Sets strategy's price stop method.
   */
  void SetPriceStopMethod(int _method) { sparams.signal_close_method = _method; }

  /**
   * Sets strategy's price stop level.
   */
  void SetPriceStopLevel(float _level) { sparams.signal_close_level = _level; }

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
  /* @todo: Refactor.
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
      if (GetMarket().GetSymbol() == Order::OrderSymbol() && trade.tparams.GetMagicNo() == Order::OrderMagicNumber()) {
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
  */

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
  // double GetCurrSpread() { return trade.chart.GetSpreadInPips(); }

  /**
   * Convert timeframe constant to index value.
   */
  uint TfToIndex(ENUM_TIMEFRAMES _tf) { return ChartTf::TfToIndex(_tf); }

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
    if (!trade.IsValid()) {
      /* @fixme
      logger.Warning(StringFormat("Could not initialize %s on %s timeframe!", GetName(),
                                    trade.GetChart().TfToString()),
                       __FUNCTION__ + ": ");
      */
      return false;
    }
    return true;
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
  bool CheckCondition(ENUM_STRATEGY_CONDITION _cond, DataParamEntry &_args[]) {
    bool _result = true;
    long arg_size = ArraySize(_args);
    long _arg1l = ArraySize(_args) > 0 ? Convert::MqlParamToInteger(_args[0]) : WRONG_VALUE;
    long _arg2l = ArraySize(_args) > 1 ? Convert::MqlParamToInteger(_args[1]) : WRONG_VALUE;
    long _arg3l = ArraySize(_args) > 2 ? Convert::MqlParamToInteger(_args[2]) : WRONG_VALUE;
    switch (_cond) {
      case STRAT_COND_IS_ENABLED:
        return sparams.IsEnabled();
      case STRAT_COND_IS_SUSPENDED:
        return sparams.IsSuspended();
      case STRAT_COND_IS_TREND:
        _arg1l = _arg1l != WRONG_VALUE ? _arg1l : 0;
        return IsTrend((ENUM_ORDER_TYPE)_arg1l);
      case STRAT_COND_SIGNALOPEN: {
        ENUM_ORDER_TYPE _cmd = ArraySize(_args) > 1 ? (ENUM_ORDER_TYPE)_args[0].integer_value : ORDER_TYPE_BUY;
        int _method = ArraySize(_args) > 1 ? (int)_args[1].integer_value : 0;
        float _level = ArraySize(_args) > 2 ? (float)_args[2].double_value : 0;
        return SignalOpen(_cmd, _method, _level);
      }
      case STRAT_COND_TRADE_COND:
        // Args:
        // 1st (i:0) - Trade's enum condition to check.
        // 2rd... (i:1) - Optionally trade's arguments to pass.
        if (arg_size > 0) {
          DataParamEntry _sargs[];
          ArrayResize(_sargs, ArraySize(_args) - 1);
          for (int i = 0; i < ArraySize(_sargs); i++) {
            _sargs[i] = _args[i + 1];
          }
          _result = trade.CheckCondition((ENUM_TRADE_CONDITION)_arg1l, _sargs);
        }
        return _result;
      default:
        logger.Error(StringFormat("Invalid EA condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool CheckCondition(ENUM_STRATEGY_CONDITION _cond, long _arg1) {
    DataParamEntry _args[] = {{TYPE_LONG}};
    _args[0].integer_value = _arg1;
    return Strategy::CheckCondition(_cond, _args);
  }
  bool CheckCondition(ENUM_STRATEGY_CONDITION _cond, long _arg1, long _arg2) {
    DataParamEntry _args[] = {{TYPE_LONG}, {TYPE_LONG}};
    _args[0].integer_value = _arg1;
    _args[1].integer_value = _arg2;
    return Strategy::CheckCondition(_cond, _args);
  }
  bool CheckCondition(ENUM_STRATEGY_CONDITION _cond) {
    DataParamEntry _args[] = {};
    return CheckCondition(_cond, _args);
  }

  /**
   * Execute Strategy action.
   *
   * @param ENUM_STRATEGY_ACTION _action
   *   Strategy action to execute.
   * @param MqlParam _args
   *   Strategy action arguments.
   * @return
   *   Returns true when the action has been executed successfully.
   */
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action, DataParamEntry &_args[]) {
    bool _result = true;
    double arg1d = EMPTY_VALUE;
    double arg2d = EMPTY_VALUE;
    double arg3d = EMPTY_VALUE;
    long arg1i = EMPTY;
    long arg2i = EMPTY;
    long arg3i = EMPTY;
    long arg_size = ArraySize(_args);
    if (arg_size > 0) {
      arg1d = _args[0].type == TYPE_DOUBLE ? _args[0].double_value : EMPTY_VALUE;
      arg1i = _args[0].type == TYPE_INT ? _args[0].integer_value : EMPTY;
      if (arg_size > 1) {
        arg2d = _args[1].type == TYPE_DOUBLE ? _args[1].double_value : EMPTY_VALUE;
        arg2i = _args[1].type == TYPE_INT ? _args[1].integer_value : EMPTY;
      }
      if (arg_size > 2) {
        arg3d = _args[2].type == TYPE_DOUBLE ? _args[2].double_value : EMPTY_VALUE;
        arg3i = _args[2].type == TYPE_INT ? _args[2].integer_value : EMPTY;
      }
    }
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
      case STRAT_ACTION_TRADE_EXE:
        // Args:
        // 1st (i:0) - Trade's enum action to execute.
        // 2rd (i:1) - Trade's argument to pass.
        if (arg_size > 0) {
          MqlParam _sargs[];
          ArrayResize(_sargs, ArraySize(_args) - 1);
          for (int i = 0; i < ArraySize(_sargs); i++) {
            _sargs[i] = _args[i + 1];
          }
          _result = trade.ExecuteAction((ENUM_TRADE_ACTION)_args[0].integer_value, _sargs);
          if (_result) {
            switch ((ENUM_TRADE_ACTION)_args[0].integer_value) {
              case TRADE_ACTION_ORDER_OPEN:
                OnOrderOpen(trade.GetOrderLast());
                break;
            }
          }
        }
        return _result;
      case STRAT_ACTION_UNSUSPEND:
        sparams.Suspended(false);
        return true;
      default:
        logger.Error(StringFormat("Invalid Strategy action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
    }
    return _result;
  }
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action, long _arg1) {
    DataParamEntry _args[] = {{TYPE_INT}};
    _args[0].integer_value = _arg1;
    return Strategy::ExecuteAction(_action, _args);
  }
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action, long _arg1, long _arg2) {
    DataParamEntry _args[] = {{TYPE_INT}, {TYPE_INT}};
    _args[0].integer_value = _arg1;
    _args[1].integer_value = _arg2;
    return Strategy::ExecuteAction(_action, _args);
  }
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action, long _arg1, long _arg2, long _arg3) {
    DataParamEntry _args[] = {{TYPE_INT}, {TYPE_INT}, {TYPE_INT}};
    _args[0].integer_value = _arg1;
    _args[1].integer_value = _arg2;
    _args[2].integer_value = _arg3;
    return Strategy::ExecuteAction(_action, _args);
  }
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action) {
    DataParamEntry _args[] = {};
    return Strategy::ExecuteAction(_action, _args);
  }

  /* Printers methods */

  /**
   * Prints strategy's details.
   */
  string ToString() { return StringFormat("%s: %s", GetName(), sparams.ToString()); }

  /* Virtual methods */

  /**
   * Event on order close.
   */
  virtual void OnOrderClose(Order *_order) {}

  /**
   * Event on strategy's init.
   */
  virtual void OnInit() {
    SetStops(GetPointer(this), GetPointer(this));
    // trade.SetStrategy(&this); // @fixme
  }

  /**
   * Event on strategy's order open.
   *
   * @param
   *   _order Order Instance of order which got opened.
   */
  virtual void OnOrderOpen(Order &_order) {
    if (logger.GetLevel() >= V_INFO) {
      // logger.Info(_order.ToString(), (string)_order.GetTicket()); // @fixme: memory leaks.
      ResetLastError();
    }
    if (sparams.order_close_time != 0) {
      /* @fixme
      long _close_time_arg = sparams.order_close_time > 0
              ? sparams.order_close_time * 60
              : (int)round(-sparams.order_close_time * trade.chart.GetPeriodSeconds());
      _order.Set(ORDER_PARAM_COND_CLOSE, ORDER_COND_LIFETIME_GT_ARG);
      _order.Set(ORDER_PARAM_COND_CLOSE_ARGS, _close_time_arg);
      */
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
  virtual void OnPeriod(unsigned int _periods = DATETIME_NONE) {
    if ((_periods & DATETIME_MINUTE) != 0) {
      // New minute started.
      logger.Flush();
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
    bool _res = _method >= 0;
    bool _val;
    if (_method != 0) {
      if (METHOD(_method, 0)) {  // 1
        // Process on every minute.
        _val = _tick.time % 60 < last_tick.time % 60;
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method, 1)) {  // 2
        // Process low and high ticks of a bar.
        _val = _tick.bid >= trade.GetChart().GetHigh() || _tick.bid <= trade.GetChart().GetLow();
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method, 2)) {  // 4
        // Process only peak prices of each minute.
        static double _peak_high = _tick.bid, _peak_low = _tick.bid;
        if (_tick.time % 60 < last_tick.time % 60) {
          // Resets peaks each minute.
          _peak_high = _peak_low = _tick.bid;
        } else {
          // Sets new peaks.
          _peak_high = _tick.bid > _peak_high ? _tick.bid : _peak_high;
          _peak_low = _tick.bid < _peak_low ? _tick.bid : _peak_low;
        }
        _val = (_tick.bid == _peak_high) || (_tick.bid == _peak_low);
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method, 3)) {  // 8
        // Process only unique ticks (avoid duplicates).
        _val = _tick.bid != last_tick.bid && _tick.ask != last_tick.ask;
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method, 4)) {  // 16
        // Process ticks in the middle of the bar.
        _val = (trade.GetChart().GetBarTime() +
                (ChartTf::TfToSeconds(trade.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF)) / 2)) == TimeCurrent();
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method, 5)) {  // 32
        // Process bar open price ticks.
        _val = last_tick.time < trade.GetChart().GetBarTime();
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method, 6)) {  // 64
        // Process every 10th of the bar.
        _val = TimeCurrent() % (int)(ChartTf::TfToSeconds(trade.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF)) / 10) == 0;
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method, 7)) {  // 128
        // Process tick on every 10 seconds.
        _val = _tick.time % 10 < last_tick.time % 10;
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      last_tick = _tick;
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
  virtual bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) = NULL;

  /**
   * Returns strength of strategy's open signal.
   *
   * @param
   *   _method - signal method to open a trade (bitwise AND operation)
   *   _level  - signal level to open a trade (bitwise AND operation)
   *
   * @result float
   *   Returns value strength of strategy's open signal ranging from -1 to 1.
   *   Buy signal is when value is positive.
   *   Sell signal is when value is negative.
   */
  virtual float SignalOpen(int _method = 0, float _level = 0.0f, int _shift = 0);

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
      if (METHOD(_method, 0)) _result &= !trade.HasBarOrder(_cmd);
      if (METHOD(_method, 1)) _result &= IsTrend(_cmd);
      if (METHOD(_method, 2)) _result &= trade.IsPivot(_cmd);
      if (METHOD(_method, 3)) _result &= DateTimeStatic::IsPeakHour();
      if (METHOD(_method, 4)) _result &= trade.IsPeak(_cmd);
      if (METHOD(_method, 5)) _result &= !trade.HasOrderBetter(_cmd);
      // if (METHOD(_method, 5)) _result &= Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 6)) _result &= Trade().IsHedging(_cmd);
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
  virtual bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
  }

  /**
   * Gets price stop value.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _mode   - mode for price stop value (ORDER_TYPE_TP or ORDER_TYPE_SL)
   *   _method - method to calculate the price stop
   *   _level  - level value to use for calculation
   *
   * @result bool
   *   Returns current stop loss value when _mode is ORDER_TYPE_SL
   *   and profit take when _mode is ORDER_TYPE_TP.
   */
  virtual float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f) {
    double _result = 0;
    float _trade_dist = trade.GetTradeDistanceInValue();
    int _count = (int)fmax(fabs(_level), fabs(_method));
    int _direction = Order::OrderDirection(_cmd, _mode);
    Chart *_chart = trade.GetChart();
    Indicator *_indi = GetIndicator();
    StrategyPriceStop _psm(_method);
    _psm.SetChartParams(_chart.GetParams());
    if (Object::IsValid(_indi)) {
      int _ishift = _direction > 0 ? _indi.GetHighest<double>(_count) : _indi.GetLowest<double>(_count);
      _ishift = fmax(0, _ishift);
      _psm.SetIndicatorPriceValue(_indi.GetValuePrice<float>(_ishift, 0, PRICE_CLOSE));
      /*
      //IndicatorDataEntry _data[];
      if (_indi.CopyEntries(_data, 3, 0)) {
        _psm.SetIndicatorDataEntry(_data);
        _psm.SetIndicatorParams(_indi.GetParams());
      }
      */
      _result = _psm.GetValue(_ishift, _direction, _trade_dist);
    } else {
      int _pshift = _direction > 0 ? _chart.GetHighest(_count) : _chart.GetLowest(_count);
      _result = _psm.GetValue(_pshift, _direction, _trade_dist);
    }
    return (float)_result;
  }

  /**
   * Gets trend strength value.
   *
   * @param
   *   _tf - timeframe to use for trend calculation
   *
   * @result bool
   *   Returns trend strength value from -1 (strong bearish) to +1 (strong bullish).
   *   Value closer to 0 indicates a neutral trend.
   */
  virtual float TrendStrength(ENUM_TIMEFRAMES _tf = PERIOD_D1, int _shift = 1) {
    float _result = 0;
    Chart *_c = trade.GetChart();
    if (_c.IsValidShift(_shift)) {
      ChartEntry _bar1 = _c.GetEntry(_tf, _shift);
      float _range = _bar1.bar.ohlc.GetRange();
      if (_range > 0) {
        float _open = (float)_c.GetOpen(_tf);
        float _pp = _bar1.bar.ohlc.GetPivot();
        _result = 1 / _range * (_open - _pp);
        _result = fmin(1, fmax(-1, _result));
      }
    }
    return _result;
  };

  /* Serializers */

  /**
   * Returns serialized representation of the object instance.
   */
  SerializerNodeType Serialize(Serializer &_s) {
    _s.PassStruct(this, "strat-params", sparams);
    _s.PassStruct(this, "strat-results", sresult, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.PassStruct(this, "strat-signals", last_signals, SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE);
    return SerializerNodeObject;
  }
};
#endif  // STRATEGY_MQH
