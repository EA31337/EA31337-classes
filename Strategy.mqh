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
#include "Market.mqh"
#include "Object.mqh"
#include "Strategy.enum.h"
#include "Strategy.struct.h"
#include "String.mqh"
#include "Task.mqh"
#include "Trade.mqh"

// Defines.
// Primary inputs.
#ifdef __input__
#define INPUT input
#ifndef __MQL4__
#define INPUT_GROUP(name) input group #name
#else
#define INPUT_GROUP(name) static input string;  // #name
#endif
#else
#define INPUT static
#define INPUT_GROUP(name) static string
#endif
// Secondary inputs.
#ifdef __input2__
#define INPUT2 input
#ifndef __MQL4__
#define INPUT2_GROUP(name) input group #name
#else
#define INPUT2_GROUP(name) static input string;  // #name
#endif
#else
#define INPUT2 static
#define INPUT2_GROUP(name) static string
#endif
// Tertiary inputs.
#ifdef __input3__
#define INPUT3 input
#ifndef __MQL4__
#define INPUT3_GROUP(name) input group #name
#else
#define INPUT3_GROUP(name) static input string;  // #name
#endif
#else
#define INPUT3 static
#define INPUT3_GROUP(name) static string
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
  DictStruct<int, Ref<IndicatorBase>> indicators;  // Indicators list.
  DictStruct<short, TaskEntry> tasks;
  Log logger;  // Log instance.
  MqlTick last_tick;
  StgProcessResult sresult;
  Strategy *strat_sl, *strat_tp;  // Strategy pointers for stop-loss and profit-take.
  Trade trade;                    // Trade instance.
                                  // TradeSignalEntry last_signal;    // Last signals.

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
    logger.Link(trade.GetLogger());

    // Statistics variables.
    // UpdateOrderStats(EA_STATS_DAILY);
    // UpdateOrderStats(EA_STATS_WEEKLY);
    // UpdateOrderStats(EA_STATS_MONTHLY);
    // UpdateOrderStats(EA_STATS_TOTAL);

    // Call strategy's OnInit method.
    Strategy::OnInit();
  }

  Log *GetLogger() { return GetPointer(logger); }

  /**
   * Class deconstructor.
   */
  ~Strategy() {}

  /* Processing methods */

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
   * Returns handler to the strategy's indicator class.
   */
  IndicatorBase *GetIndicator(int _id = 0) {
    if (indicators.KeyExists(_id)) {
      return indicators[_id].Ptr();
    }

    Alert("Missing indicator id ", _id);
    return NULL;
  }

  /**
   * Returns strategy's indicators.
   */
  DictStruct<int, Ref<IndicatorBase>> GetIndicators() { return indicators; }

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
   * Gets a trade state value.
   */
  template <typename T>
  T Get(ENUM_TRADE_STATE _prop) {
    return trade.Get<T>(_prop);
  }

  /**
   * Gets strategy entry.
   */
  StgEntry GetEntry() {
    StgEntry _entry = {};
    for (ENUM_STRATEGY_STATS_PERIOD _p = EA_STATS_DAILY; _p < FINAL_ENUM_STRATEGY_STATS_PERIOD; _p++) {
      _entry.SetStats(stats_period[(int)_p], _p);
    }
    return _entry;
  }

  /**
   * Gets pointer to strategy's stop-loss strategy.
   */
  Strategy *GetStratSl() { return strat_sl; }

  /**
   * Gets pointer to strategy's take-profit strategy.
   */
  Strategy *GetStratTp() { return strat_tp; }

  /**
   * Get strategy's name.
   */
  string GetName() { return name; }

  /**
   * Get strategy's ID.
   */
  virtual long GetId() { return sparams.id; }

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
    // @todo: Add spread.
    // return StringFormat("%s%s[%s];s:%gp%s", _prefix != "" ? _prefix + ": " : "", name, trade.chart.TfToString(),
    // GetCurrSpread(), _suffix != "" ? "| " + _suffix : "");

    return StringFormat("%s%s[%s]%s", _prefix, name, ChartTf::TfToString(trade.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF)),
                        _suffix);
  }

  /**
   * Get strategy's order close comment.
   */
  string GetOrderCloseComment(string _prefix = "", string _suffix = "") {
    // @todo: Add spread.
    return StringFormat("%s%s[%s]%s", _prefix, name, ChartTf::TfToString(trade.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF)),
                        _suffix);
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
    return stats_period[(int)_period].orders_total;
  }

  /**
   * Gets strategy orders won.
   */
  uint GetOrdersWon(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[(int)_period].orders_won;
  }

  /**
   * Gets strategy orders lost.
   */
  uint GetOrdersLost(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[(int)_period].orders_lost;
  }

  /**
   * Gets strategy net profit.
   */
  double GetNetProfit(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[(int)_period].net_profit;
  }

  /**
   * Gets strategy gross profit.
   */
  double GetGrossProfit(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[(int)_period].gross_profit;
  }

  /**
   * Gets strategy gross loss.
   */
  double GetGrossLoss(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[(int)_period].gross_loss;
  }

  /**
   * Gets the average spread of the strategy (in pips).
   */
  double GetAvgSpread(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    // UpdateOrderStats(_period);
    return stats_period[(int)_period].avg_spread;
  }

  /* Setters */

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

  /**
   * Sets reference to indicator.
   */
  void SetIndicator(IndicatorBase *_indi, int _id = 0) {
    Ref<IndicatorBase> _ref = _indi;
    indicators.Set(_id, _ref);
  }

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
    bool _result = false;
    long arg_size = ArraySize(_args);
    long _arg1l = ArraySize(_args) > 0 ? DataParamEntry::ToInteger(_args[0]) : WRONG_VALUE;
    long _arg2l = ArraySize(_args) > 1 ? DataParamEntry::ToInteger(_args[1]) : WRONG_VALUE;
    long _arg3l = ArraySize(_args) > 2 ? DataParamEntry::ToInteger(_args[2]) : WRONG_VALUE;
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
        GetLogger().Error(StringFormat("Invalid EA condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        break;
    }
    return _result;
  }
  bool CheckCondition(ENUM_STRATEGY_CONDITION _cond, long _arg1) {
    ARRAY(DataParamEntry, _args);
    DataParamEntry _param1 = _arg1;
    ArrayPushObject(_args, _param1);
    return Strategy::CheckCondition(_cond, _args);
  }
  bool CheckCondition(ENUM_STRATEGY_CONDITION _cond, long _arg1, long _arg2) {
    ARRAY(DataParamEntry, _args);
    DataParamEntry _param1 = _arg1;
    DataParamEntry _param2 = _arg2;
    ArrayPushObject(_args, _param1);
    ArrayPushObject(_args, _param2);
    return Strategy::CheckCondition(_cond, _args);
  }
  bool CheckCondition(ENUM_STRATEGY_CONDITION _cond) {
    ARRAY(DataParamEntry, _args);
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
    bool _result = false;
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
          DataParamEntry _sargs[];
          ArrayResize(_sargs, ArraySize(_args) - 1);
          for (int i = 0; i < ArraySize(_sargs); i++) {
            _sargs[i] = _args[i + 1];
          }
          _result = trade.ExecuteAction((ENUM_TRADE_ACTION)_args[0].integer_value, _sargs);
          /* @fixme
          if (_result) {
            Order *_order = trade.GetOrderLast();
            switch ((ENUM_TRADE_ACTION)_args[0].integer_value) {
              case TRADE_ACTION_ORDERS_CLOSE_BY_TYPE:
                // OnOrderClose();// @todo
                break;
              case TRADE_ACTION_ORDER_OPEN:
                // @fixme: Operation on the structure copy.
                OnOrderOpen(_order.GetParams());
                break;
            }
          }
          */
        }
        return _result;
      case STRAT_ACTION_UNSUSPEND:
        sparams.Suspended(false);
        return true;
      default:
        GetLogger().Error(StringFormat("Invalid Strategy action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        break;
    }
    return _result;
  }
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action, long _arg1) {
    ARRAY(DataParamEntry, _args);
    DataParamEntry _param1 = _arg1;
    ArrayPushObject(_args, _param1);
    return Strategy::ExecuteAction(_action, _args);
  }
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action, long _arg1, long _arg2) {
    ARRAY(DataParamEntry, _args);
    DataParamEntry _param1 = _arg1;
    DataParamEntry _param2 = _arg2;
    ArrayPushObject(_args, _param1);
    ArrayPushObject(_args, _param2);
    return Strategy::ExecuteAction(_action, _args);
  }
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action, long _arg1, long _arg2, long _arg3) {
    ARRAY(DataParamEntry, _args);
    DataParamEntry _param1 = _arg1;
    DataParamEntry _param2 = _arg2;
    DataParamEntry _param3 = _arg3;
    ArrayPushObject(_args, _param1);
    ArrayPushObject(_args, _param2);
    ArrayPushObject(_args, _param3);
    return Strategy::ExecuteAction(_action, _args);
  }
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action) {
    ARRAY(DataParamEntry, _args);
    return Strategy::ExecuteAction(_action, _args);
  }

  /* Printers methods */

  /**
   * Prints strategy's details.
   */
  string const ToString() { return StringFormat("%s: %s", GetName(), sparams.ToString()); }

  /* Virtual methods */

  /**
   * Event on order close.
   */
  virtual void OnOrderClose(ENUM_ORDER_TYPE _cmd) {}

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
   *   _oparams Order parameters to update before the open.
   */
  virtual void OnOrderOpen(OrderParams &_oparams) {
    int _index = 0;
    ENUM_TIMEFRAMES _stf = Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF);
    unsigned int _stf_secs = ChartTf::TfToSeconds(_stf);
    if (sparams.order_close_time != 0) {
      long _close_time_arg = sparams.order_close_time > 0 ? sparams.order_close_time * 60
                                                          : (int)round(-sparams.order_close_time * _stf_secs);
      _oparams.Set(ORDER_PARAM_COND_CLOSE, ORDER_COND_LIFETIME_GT_ARG, _index);
      _oparams.Set(ORDER_PARAM_COND_CLOSE_ARG_VALUE, _close_time_arg, _index);
      _index++;
    }
    if (sparams.order_close_loss != 0.0f) {
      float _loss_limit = sparams.order_close_loss;
      _oparams.Set(ORDER_PARAM_COND_CLOSE, ORDER_COND_IN_LOSS, _index);
      _oparams.Set(ORDER_PARAM_COND_CLOSE_ARG_VALUE, _loss_limit, _index);
      _index++;
    }
    if (sparams.order_close_profit != 0.0f) {
      float _profit_limit = sparams.order_close_profit;
      _oparams.Set(ORDER_PARAM_COND_CLOSE, ORDER_COND_IN_PROFIT, _index);
      _oparams.Set(ORDER_PARAM_COND_CLOSE_ARG_VALUE, _profit_limit, _index);
      _index++;
    }
    _oparams.Set(ORDER_PARAM_UPDATE_FREQ, _stf_secs);
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
#ifndef __optimize__
      if (Terminal::IsRealtime()) {
        logger.Flush();
      }
#endif
    }
    if ((_periods & DATETIME_HOUR) != 0) {
      // New hour started.
    }
    if ((_periods & DATETIME_DAY) != 0) {
      // New day started.
#ifndef __optimize__
      GetLogger().Flush();
#endif
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
   *   _tick Tick to use for filtering.
   *   _method Signal method to filter a tick (bitwise AND operation).
   *
   * @result bool
   *   Returns true when tick should be processed, otherwise false.
   */
  virtual bool TickFilter(const MqlTick &_tick, const int _method) {
    bool _res = _method >= 0;
    bool _val;
    int _method_abs = fabs(_method);
    if (_method_abs != 0) {
      if (METHOD(_method_abs, 0)) {  // 1
        // Process on every minute.
        _val = _tick.time % 60 < last_tick.time % 60;
        _res = _method > 0 ? _res & _val : _res | _val;
        last_tick = _tick;
      }
      if (METHOD(_method_abs, 1)) {  // 2
        // Process low and high ticks of a bar.
        _val = _tick.bid >= trade.GetChart().GetHigh() || _tick.bid <= trade.GetChart().GetLow();
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method_abs, 2)) {  // 4
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
      if (METHOD(_method_abs, 3)) {  // 8
        // Process only unique ticks (avoid duplicates).
        _val = _tick.bid != last_tick.bid && _tick.ask != last_tick.ask;
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method_abs, 4)) {  // 16
        // Process ticks in the middle of the bar.
        _val = (trade.GetChart().GetBarTime() +
                (ChartTf::TfToSeconds(trade.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF)) / 2)) == TimeCurrent();
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method_abs, 5)) {  // 32
        // Process bar open price ticks.
        _val = last_tick.time < trade.GetChart().GetBarTime(); // @todo: Improve performance.
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method_abs, 6)) {  // 64
        // Process every 10th of the bar.
        _val = TimeCurrent() % (int)(ChartTf::TfToSeconds(trade.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF)) / 10) == 0;
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (METHOD(_method_abs, 7)) {  // 128
        // Process tick on every 10 seconds.
        _val = _tick.time % 10 < last_tick.time % 10;
        _res = _method > 0 ? _res & _val : _res | _val;
      }
      if (_res) {
        last_tick = _tick;
      }
    }
    return _res;
  }
  virtual bool TickFilter(const MqlTick &_tick) { return TickFilter(_tick, sparams.Get<int>(STRAT_PARAM_TFM)); }

  /**
   * Checks strategy's trade open signal.
   *
   * @param
   *   _cmd Ttype of trade order command.
   *   _method Signal method to open a trade (bitwise AND operation).
   *   _level Signal level to open a trade.
   *   _shift Signal shift relative to the current bar.
   *
   * @result bool
   *   Returns true when trade should be opened, otherwise false.
   */
  virtual bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) = NULL;

  /**
   * Returns strength of strategy's open signal.
   *
   * @param
   *   _method Signal method to open a trade (bitwise AND operation).
   *   _level Signal level to open a trade.
   *   _shift Signal shift relative to the current bar.
   *
   * @result float
   *   Returns value strength of strategy's open signal ranging from -1 to 1.
   *   Buy signal is when value is positive.
   *   Sell signal is when value is negative.
   */
  virtual float SignalOpen(int _method = 0, float _level = 0.0f, int _shift = 0) {
    // @todo
    return 0.0f;
  };

  /**
   * Checks strategy's trade's open signal method filter.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - method to filter a trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true when trade should be opened, otherwise false.
   */
  virtual bool SignalOpenFilterMethod(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      if (METHOD(_method, 0)) _result &= !trade.HasBarOrder(_cmd);           // 1
      if (METHOD(_method, 1)) _result &= IsTrend(_cmd);                      // 2
      if (METHOD(_method, 2)) _result &= trade.IsPivot(_cmd);                // 4
      if (METHOD(_method, 3)) _result &= !trade.HasOrderOppositeType(_cmd);  // 8
      if (METHOD(_method, 4)) _result &= trade.IsPeak(_cmd);                 // 16
      if (METHOD(_method, 5)) _result &= !trade.HasOrderBetter(_cmd);        // 32
      if (METHOD(_method, 6))
        _result &= !trade.CheckCondition(
            TRADE_COND_ACCOUNT, _method > 0 ? ACCOUNT_COND_EQUITY_01PC_LOW : ACCOUNT_COND_EQUITY_01PC_HIGH);  // 64
      // if (METHOD(_method, 5)) _result &= Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 6)) _result &= Trade().IsHedging(_cmd);
      _method = _method > 0 ? _method : !_method;
    }
    return _result;
  }

  /**
   * Checks strategy's trade's close signal time filter.
   *
   * @param
   *   _method - method to filter a closing trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true if trade should be closed, otherwise false.
   */
  virtual bool SignalCloseFilterTime(int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      MarketTimeForex _mtf(::TimeGMT());
      _result &= _mtf.CheckHours(_method);         // 0-127
      _method = _method > 0 ? _method : !_method;  // -127-127
    }
    return _result;
  }

  /**
   * Checks strategy's trade's open signal time filter.
   *
   * @param
   *   _method - method to filter a trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true if trade should be opened, otherwise false.
   */
  virtual bool SignalOpenFilterTime(int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      MarketTimeForex _mtf(::TimeGMT());
      _result &= _mtf.CheckHours(_method);         // 0-127
      _method = _method > 0 ? _method : !_method;  // -127-127
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
   * Checks strategy's trade close signal additional filter.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - signal method to filter a trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true when trade should be closed, otherwise false.
   */
  virtual bool SignalCloseFilter(ENUM_ORDER_TYPE _cmd, int _method = 0, int _shift = 0) {
    bool _result = _method == 0;
    if (_method != 0) {
      if (METHOD(_method, 0)) _result |= _result || !trade.HasBarOrder(_cmd);  // 1
      if (METHOD(_method, 1)) _result |= _result || !IsTrend(_cmd);            // 2
      if (METHOD(_method, 2)) _result |= _result || !trade.IsPivot(_cmd);      // 4
      if (METHOD(_method, 3))
        _result |= _result || Open[_shift] > High[_shift + 1] || Open[_shift] < Low[_shift + 1];  // 8
      if (METHOD(_method, 4)) _result |= _result || trade.IsPeak(_cmd);                           // 16
      if (METHOD(_method, 5)) _result |= _result || trade.HasOrderBetter(_cmd);                   // 32
      if (METHOD(_method, 6))
        _result |=
            _result || trade.CheckCondition(TRADE_COND_ACCOUNT, _method > 0 ? ACCOUNT_COND_EQUITY_01PC_HIGH
                                                                            : ACCOUNT_COND_EQUITY_01PC_LOW);  // 64
      // if (METHOD(_method, 7)) _result |= _result || Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 8)) _result |= _result || Trade().IsHedging(_cmd);
      _method = _method > 0 ? _method : !_method;
    }
    return _result;
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
  virtual float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f,
                          short _bars = 4) {
    float _result = 0;
    if (_method == 0) {
      // Ignores calculation when method is 0.
      return (float)_result;
    }
    float _trade_dist = trade.GetTradeDistanceInValue();
    int _count = (int)fmax(fabs(_level), fabs(_method));
    int _direction = Order::OrderDirection(_cmd, _mode);
    Chart *_chart = trade.GetChart();
    IndicatorBase *_indi = GetIndicators().Begin().Value().Ptr();
    StrategyPriceStop _psm(_method);
    _psm.SetChartParams(_chart.GetParams());
    if (Object::IsValid(_indi)) {
      int _ishift = 12;  // @todo: Make it dynamic or as variable.
      float _value = _indi.GetValuePrice<float>(_ishift, 0, _direction > 0 ? PRICE_HIGH : PRICE_LOW);
      _value = _value + (float)Math::ChangeByPct(fabs(_value - _chart.GetCloseOffer(0)), _level) * _direction;
      _psm.SetIndicatorPriceValue(_value);
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
    _s.PassStruct(THIS_REF, "strat-params", sparams);
    _s.PassStruct(THIS_REF, "strat-results", sresult, SERIALIZER_FIELD_FLAG_DYNAMIC);
    return SerializerNodeObject;
  }
};
#endif  // STRATEGY_MQH
