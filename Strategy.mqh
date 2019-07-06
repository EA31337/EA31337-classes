//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

// Includes.
#include "Indicator.mqh"
#include "String.mqh"
#include "Trade.mqh"

/**
 * Base class for strategy features.
 */
#ifndef STRATEGY_MQH
#define STRATEGY_MQH
class Strategy {

  // Enums.
  enum ENUM_OPEN_METHOD {
    OPEN_METHOD1  =    1, // Method #1.
    OPEN_METHOD2  =    2, // Method #2.
    OPEN_METHOD3  =    4, // Method #3.
    OPEN_METHOD4  =    8, // Method #4.
    OPEN_METHOD5  =   16, // Method #5.
    OPEN_METHOD6  =   32, // Method #6.
    OPEN_METHOD7  =   64, // Method #7.
    OPEN_METHOD8  =  128, // Method #8.
    OPEN_METHOD9  =  256, // Method #9.
    OPEN_METHOD10 =  512, // Method #10.
    OPEN_METHOD11 = 1024  // Method #11.
  };
  enum ENUM_STRATEGY_STATS_PERIOD {
    EA_STATS_DAILY,
    EA_STATS_WEEKLY,
    EA_STATS_MONTHLY,
    EA_STATS_TOTAL,
    FINAL_ENUM_STRATEGY_STATS_PERIOD
  };
  // Structs.
  struct StgParams {
    // Strategy config parameters.
    bool             enabled;              // State of the strategy (enabled or disabled).
    bool             suspended;            // State of the strategy.
    ulong            magic_no;             // Magic number of the strategy.
    double           weight;               // Weight of the strategy.
    double           signal_level1;        // 1st open signal level to consider the trade.
    double           signal_level2;        // 2nd open signal level to consider the trade.
    long             signal_base_method;   // Base signal method to check.
    long             signal_open_method1;  // 1st open signal method on top of base signal.
    long             signal_open_method2;  // 2nd open signal method on top of base signal.
    long             signal_close_method1; // 1st close method.
    long             signal_close_method2; // 2nd close method.
    double           lot_size;             // Lot size to trade.
    double           lot_size_factor;      // Lot size multiplier factor.
    double           max_spread;           // Maximum spread to trade (in pips).
    ENUM_INDICATOR_TYPE indi_tp_method;    // Take profit method.
    ENUM_INDICATOR_TYPE indi_sl_method;    // Stop loss method.
    uint             tp_max;               // Hard limit on maximum take profit (in pips).
    uint             sl_max;               // Hard limit on maximum stop loss (in pips).
    datetime         refresh_time;         // Order refresh frequency (in sec).
    Trade            *trade;               // Pointer to Trade class.
    Indicator        *data;                // Pointer to Indicator class.
    Strategy         *sl, *tp;             // Pointers to Strategy class (stop-loss and profit-take).
    // Constructor.
    StgParams(Trade *_trade = NULL, Indicator *_data = NULL, Strategy *_sl = NULL, Strategy *_tp = NULL) :
      trade(_trade),
      data(_data),
      sl(_sl),
      tp(_tp),
      enabled(true),
      suspended(false),
      weight(0),
      max_spread(0)
    {}
    // Deconstructor.
    ~StgParams() {
    }
    // Struct methods.
    void SetTf(ENUM_TIMEFRAMES _tf, string _symbol = NULL) {
      trade = new Trade(_tf, _symbol);
    }
    void SetSignals(long _base, long _open1, long _open2, long _close1, long _close2, double _level1, double _level2)
    {
      signal_base_method = _base;
      signal_open_method1 = _open1;
      signal_open_method2 = _open2;
      signal_close_method1 = _close1;
      signal_close_method2 = _close2;
      signal_level1 = _level1;
      signal_level2 = _level2;
    }
    void DeleteObjects() {
      delete data;
      delete sl;
      delete tp;
      delete trade;
    }
  } params;

  // Strategy statistics.
  struct StgStats {
    uint    orders_open;        // Number of current opened orders.
    uint    errors;             // Count reported errors.
  } stats;

  // Strategy statistics per period.
  struct StgStatsPeriod {
    // Statistics variables.
    uint    orders_total;       // Number of total opened orders.
    uint    orders_won;         // Number of total won orders.
    uint    orders_lost;        // Number of total lost orders.
    double  profit_factor;      // Profit factor.
    double  avg_spread;         // Average spread.
    double  net_profit;         // Total net profit.
    double  gross_profit;       // Total gross profit.
    double  gross_loss;         // Total gross profit.
  } stats_period[FINAL_ENUM_STRATEGY_STATS_PERIOD];
  /*
  struct StgTradeRequest {
    Strategy                     *strategy;         // Strategy pointer.
    ENUM_TRADE_REQUEST_ACTIONS    action;           // Trade operation type.
    ulong                         magic;            // Expert Advisor ID (magic number).
    ulong                         order;            // Order ticket.
    String                       *symbol;           // Trade symbol.
    double                        volume;           // Requested volume for a deal in lots.
    double                        price;            // Price.
    double                        stoplimit;        // StopLimit level of the order.
    double                        sl;               // Stop Loss level of the order.
    double                        tp;               // Take Profit level of the order.
    ulong                         deviation;        // Maximal possible deviation from the requested price.
    ENUM_ORDER_TYPE               type;             // Order type.
    ENUM_ORDER_TYPE_FILLING       type_filling;     // Order execution type.
    ENUM_ORDER_TYPE_TIME          type_time;        // Order expiration type.
    datetime                      expiration;       // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type.
    String                       *comment;          // Order comment.
    ulong                         position;         // Position ticket.
    ulong                         position_by;      // The ticket of an opposite position.
  };
  */

  protected:

  // Base variables.
  string name;
  // Other variables.
  int    filter_method[];   // Filter method to consider the trade.
  int    open_condition[];  // Open conditions.
  int    close_condition[]; // Close conditions.
  // Date time variables.
  // Includes.
  // Class variables.

  public:

  /**
   * Class constructor.
   */
  void Strategy(const StgParams &_params, string _name = "") {
    // Assign struct.
    params.DeleteObjects();
    params = _params;

    // Initialize variables.
    name = _name;

    // Statistics variables.
    UpdateOrderStats(EA_STATS_DAILY);
    UpdateOrderStats(EA_STATS_WEEKLY);
    UpdateOrderStats(EA_STATS_MONTHLY);
    UpdateOrderStats(EA_STATS_TOTAL);
  }

  /**
   * Class deconstructor.
   */
  void ~Strategy() {
    // Remove class variables.
    params.DeleteObjects();
  }

  /* State checkers */

  /**
   * Validate strategy's timeframe and parameters.
   *
   * @return
   *   Returns true when strategy params are valid, otherwise false.
   */
  bool IsValid() {
    return Object::IsValid(params.trade)
      && this.Chart().IsValidTf();
  }

  /**
   * Check state of the strategy.
   */
  bool IsEnabled() {
    return params.enabled;
  }

  /**
   * Check suspension status of the strategy.
   */
  bool IsSuspended() {
    return params.suspended;
  }

  /* Class getters */

  /**
   * Returns strategy's market class.
   */
  Market *Market() {
    return params.trade.Market();
  }

  /**
   * Returns strategy's indicator class.
   */
  Indicator *IndicatorInfo() {
    return params.data;
  }

  /**
   * Returns strategy's log class.
   */
  Log *Logger() {
    return (Log *) params.trade.Logger();
  }

  /**
   * Returns handler to the strategy's trading class.
   */
  Trade *Trade() {
    return params.trade;
  }

  /**
   * Returns access to Chart information.
   */
  Chart *Chart() {
    return params.trade.Chart();
  }

  /**
   * Returns handler to the strategy's indicator class.
   */
  Indicator *Indicator() {
    return params.data;
  }

  /* Variable getters */

  /**
   * Get strategy's name.
   */
  string GetName() {
    return name;
  }

  /**
   * Get strategy's weight.
   */
  double GetWeight() {
    return params.weight;
  }

  /**
   * Get strategy's magic number.
   */
  ulong GetMagicNo() {
    return params.magic_no;
  }

  /**
   * Get strategy's timeframe.
   */
  ENUM_TIMEFRAMES GetTimeframe() {
    return this.Chart().GetTf();
  }

  /**
   * Get 1st strategy's signal level.
   */
  double GetSignalLevel1() {
    // @todo: Check overrides.
    return params.signal_level1;
  }

  /**
   * Get 2nd strategy's signal level.
   */
  double GetSignalLevel2() {
    // @todo: Check overrides.
    return params.signal_level2;
  }

  /**
   * Get strategy's signal base method.
   */
  long GetSignalBaseMethod() {
    // @todo: Check overrides.
    return params.signal_base_method;
  }

  /**
   * Get 1st strategy's signal open method.
   */
  long GetSignalOpenMethod1() {
    // @todo: Check overrides.
    return params.signal_open_method1;
  }

  /**
   * Get 2nd strategy's signal open method.
   */
  long GetSignalOpenMethod2() {
    // @todo: Check overrides.
    return params.signal_open_method2;
  }

  /**
   * Get 1st strategy's signal close method.
   */
  long GetSignalCloseMethod1() {
    // @todo: Check overrides.
    return params.signal_close_method1;
  }

  /**
   * Get 2nd strategy's signal close method.
   */
  long GetSignalCloseMethod2() {
    // @todo: Check overrides.
    return params.signal_close_method2;
  }

  /**
   * Get strategy's take profit indicator method.
   */
  ENUM_INDICATOR_TYPE GetTpMethod() {
    return params.indi_tp_method;
  }

  /**
   * Get strategy's stop loss indicator method.
   */
  ENUM_INDICATOR_TYPE GetSlMethod() {
    return params.indi_sl_method;
  }

  /**
   * Get strategy's order comment.
   */
  string GetOrderComment() {
    return StringFormat("%s:%s; spread %gpips",
      GetName(), GetTimeframe(), GetCurrSpread()
    );
  }

  /**
   * Get strategy's lot size.
   */
  double GetLotSize() {
    return params.lot_size;
  }

  /**
   * Get strategy's lot size factor.
   */
  double GetLotSizeFactor() {
    return params.lot_size_factor;
  }

  /**
   * Get strategy orders currently open.
   */
  uint GetOrdersOpen() {
    // UpdateOrderStats(EA_STATS_TOTAL);
    // @todo
    return stats.orders_open;
  }

  /* Statistics */

  /**
   * Get strategy orders total opened.
   */
  uint GetOrdersTotal(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].orders_total;
  }

  /**
   * Get strategy orders won.
   */
  uint GetOrdersWon(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].orders_won;
  }

  /**
   * Get strategy orders lost.
   */
  uint GetOrdersLost(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].orders_lost;
  }

  /**
   * Get strategy net profit.
   */
  double GetNetProfit(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].net_profit;
  }

  /**
   * Get strategy gross profit.
   */
  double GetGrossProfit(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].gross_profit;
  }

  /**
   * Get strategy gross loss.
   */
  double GetGrossLoss(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].gross_loss;
  }

  /**
   * Get the average spread of the strategy (in pips).
   */
  double GetAvgSpread(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].avg_spread;
  }

  /* Setters */

  /**
   * Get strategy's name.
   */
  void SetName(string _name) {
    name = _name;
  }

  /**
   * Set strategy's weight.
   */
  void SetWeight(double _weight) {
    params.weight = _weight;
  }

  /**
   * Set strategy's magic number.
   */
  void SetMagicNo(ulong _magic_no) {
    params.magic_no = _magic_no;
  }

  /**
   * Set 1st strategy's signal level.
   */
  void SetSignalLevel1(double _signal_level) {
    params.signal_level1 = _signal_level;
  }

  /**
   * Set 2nd strategy's signal level.
   */
  void SetSignalLevel2(double _signal_level) {
    params.signal_level2 = _signal_level;
  }

  /**
   * Set strategy's signal base method.
   */
  void SetSignalBaseMethod(long _base_method) {
    params.signal_base_method = _base_method;
  }

  /**
   * Set 1st strategy's signal open method.
   */
  void SetSignalOpenMethod1(long _open_method) {
    params.signal_open_method1 = _open_method;
  }

  /**
   * Set 2nd strategy's signal open method.
   */
  void SetSignalOpenMethod2(long _open_method) {
    params.signal_open_method2 = _open_method;
  }

  /**
   * Set 1st strategy's signal close method.
   */
  void SetSignalCloseMethod1(long _close_method) {
    params.signal_close_method1 = _close_method;
  }

  /**
   * Set 2nd strategy's signal close method.
   */
  void SetSignalCloseMethod2(long _close_method) {
    params.signal_close_method2 = _close_method;
  }

  /**
   * Set strategy's take profit indicator method.
   */
  void SetTpMethod(ENUM_INDICATOR_TYPE _tp_method) {
    params.indi_tp_method = _tp_method;
  }

  /**
   * Set strategy's stop loss indicator method.
   */
  void SetSlMethod(ENUM_INDICATOR_TYPE _sl_method) {
    params.indi_sl_method = _sl_method;
  }

  /**
   * Enable the strategy.
   */
  void Enable() {
    params.enabled = true;
  }

  /**
   * Disable the strategy.
   */
  void Disable() {
    params.enabled = false;
  }

  /**
   * Resume suspended strategy.
   */
  void Resume() {
    params.suspended = false;
  }

  /**
   * Suspend the strategy.
   */
  void Suspend() {
    params.suspended = true;
  }

  /* Calculations */

  /**
   * Get lot size factor.
   */
  double UpdateLotSizeFactor() {
    return 1.0;
  }

  /**
   * Update order stat variables.
   */
  void UpdateOrderStats(ENUM_STRATEGY_STATS_PERIOD _period) {
    // @todo: Implement support for _period.
    static datetime _last_update = TimeCurrent();
    if (_last_update > TimeCurrent() - params.refresh_time) {
      return; // Do not update too often.
    }
    uint _total = 0, _won = 0, _lost = 0, _open = 0;
    double _gross_profit = 0, _gross_loss = 0, _net_profit = 0, _order_profit = 0;
    datetime _order_datetime;
    for (uint i = 0; i < Orders::OrdersTotal(); i++) {
      // @todo: Select order.
      if (this.Market().GetSymbol() == Order::OrderSymbol() && params.magic_no == Order::OrderMagicNumber()) {
        _total++;
        _order_profit = Order::OrderProfit() - Order::OrderCommission() - Order::OrderSwap();
        _net_profit += _order_profit;
        if (Order::OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
          _open++;
        } else {
          _order_datetime = (datetime) OrderGetInteger(ORDER_TIME_DONE);
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
    stats_period[_period].gross_loss   = _gross_profit;
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
  double GetCurrSpread() {
    return this.Chart().GetSpreadInPips();
  }

  /**
   * Convert timeframe constant to index value.
   */
  uint TfToIndex(ENUM_TIMEFRAMES _tf) {
    return Chart::TfToIndex(_tf);
  }

  /**
   * Class constructor.
   */
  /*
  bool Strategy(
      string si_name,
      int si_magic_no,
      double si_lot_size,
      double si_weight = 1.0,
      int si_spread_limit = 10.0,
      string si_symbol = NULL
      ) {

    // Basic strategy variables.
    s_name = si_name;
    s_magic_no = si_magic_no;
    s_weight = si_weight;
    s_enabled = true;
    s_suspended = false;

    // Trading variables.
    s_symbol = si_symbol != NULL ? si_symbol : Symbol();
    s_lot_size = si_lot_size;
    s_lot_factor = GetLotSizeFactor();
    s_avg_spread = GetCurrSpread();
    s_spread_limit = si_spread_limit;
    s_pattern_method = 0;
    s_open_level = 0.0;
    s_tp_method = 0;
    s_sl_method = 0;
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
    if (!this.Chart().IsValidTf()) {
      Logger().Warning(StringFormat("Could not initialize %s since %s timeframe is not active!", GetName(), this.Chart().TfToString()), __FUNCTION__ + ": ");
      return false;
    }
    return true;
  }

  /* Virtual methods */

  /**
   * Checks strategy's trade open signal.
   *
   * @param
   *   _cmd (ENUM_ORDER_TYPE) - type of trade order command
   *   _base_method (long)     - base signal method (bitwise AND operation)
   *   _signal_level1 (double) - 1st signal level to use (bitwise AND operation)
   *   _signal_level2 (double) - 2nd signal level to use (bitwise AND operation)
   */
  virtual bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _base_method = 0, double _signal_level1 = 0, double _signal_level2 = 0) = NULL;

  /**
   * Checks strategy's trade close signal.
   *
   * @param
   *   _cmd (ENUM_ORDER_TYPE) - type of trade order command
   *   _close_method1 (long)    - 1st close signal method to use (bitwise AND operation)
   *   _close_method2 (long)    - 2nd close signal method to use (bitwise AND operation)
   */
  //virtual bool SignalClose(ENUM_ORDER_TYPE _cmd, long _close_method1, long _close_method2) = NULL;

};
#endif
