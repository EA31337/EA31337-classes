//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                            Copyright 2016, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

// Includes.
#include "Indicator.mqh"
#include "Log.mqh"
#include "Market.mqh"
#include "Order.mqh"
#include "Orders.mqh"
#include "Timeframe.mqh"

/**
 * Base class for strategy features.
 */
class Strategy {

protected:
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
  struct StrategyParams {
    // Strategy config parameters.
    bool             enabled;            // State of the strategy (enabled or disabled).
    bool             suspended;          // State of the strategy.
    uint             magic_no;           // Magic number of the strategy.
    double           weight;             // Weight of the strategy.
    int              signal_base_method; // Base signal method to check.
    int              signal_open_method; // Open signal method on top of base signal.
    double           signal_level;       // Open signal level to consider the trade.
    double           lot_size;           // Lot size to trade.
    double           lot_size_factor;    // Lot size multiplier factor.
    double           spread_limit;       // Spread limit to trade (in pips).
    ENUM_S_INDICATOR indi_tp_method;     // Take profit method.
    ENUM_S_INDICATOR indi_sl_method;     // Stop loss method.
    uint             tp_max;             // Hard limit on maximum take profit (in pips).
    uint             sl_max;             // Hard limit on maximum stop loss (in pips).
    datetime         refresh_time;       // Order refresh frequency (in sec).
  };
  // Strategy statistics.
  struct StrategyStats {
    uint    orders_open;        // Number of current opened orders.
    uint    errors;             // Count reported errors.
  };
  // Strategy statistics per period.
  struct StrategyStatsPeriod {
    // Statistics variables.
    uint    orders_total;       // Number of total opened orders.
    uint    orders_won;         // Number of total won orders.
    uint    orders_lost;        // Number of total lost orders.
    double  profit_factor;      // Profit factor.
    double  avg_spread;         // Average spread.
    double  net_profit;         // Total net profit.
    double  gross_profit;       // Total gross profit.
    double  gross_loss;         // Total gross profit.
  };
  /*
  struct StrategyTradeRequest {
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
  // Struct variables.
  StrategyParams      params;
  StrategyStats       stats;
  StrategyStatsPeriod stats_period[FINAL_ENUM_STRATEGY_STATS_PERIOD];
  // Other variables.
  string   name;            // Name of the strategy.
  int    filter_method[];   // Filter method to consider the trade.
  int    open_condition[];  // Open conditions.
  int    close_condition[]; // Close conditions.
  // Date time variables.
  // Class variables.
  Log *logger;
  Indicator *data, *sl, *tp;
  Market *market;
  Timeframe *tf;

public:

  /* State checkers */

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
    return market;
  }

  /**
   * Returns strategy's indicator class.
   */
  Indicator *Indicator() {
    return data;
  }

  /**
   * Returns strategy's log class.
   */
  Log *Log() {
    return logger;
  }

  /**
   * Returns strategy's timeframe class.
   */
  Timeframe *Timeframe() {
    return tf;
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
    return tf.GetTf();
  }

  /**
   * Get strategy's signal base method.
   */
  int GetSignalBaseMethod() {
    // @todo: Check overrides.
    return params.signal_base_method;
  }

  /**
   * Get strategy's signal open method.
   */
  int GetSignalOpenMethod() {
    // @todo: Check overrides.
    return params.signal_open_method;
  }

  /**
   * Get strategy's signal level.
   */
  double GetSignalLevel() {
    // @todo: Check overrides.
    return params.signal_level;
  }

  /**
   * Get strategy's take profit indicator method.
   */
  ENUM_S_INDICATOR GetTpMethod() {
    return params.indi_tp_method;
  }

  /**
   * Get strategy's stop loss indicator method.
   */
  ENUM_S_INDICATOR GetSlMethod() {
    return params.indi_sl_method;
  }

  /**
   * Get strategy's order comment.
   */
  string GetOrderComment() {
    return StringFormat("%s:%s; spread %gpips",
      name, tf.GetTf(), market.GetSpreadInPips()
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
      if (market.GetSymbol() == Order::OrderSymbol() && params.magic_no == Order::OrderMagicNumber()) {
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
    return market.GetSpreadInPips();
  }

public:

  /**
   * Convert timeframe constant to index value.
   */
  uint TfToIndex(ENUM_TIMEFRAMES _tf) {
    return Timeframe::TfToIndex(_tf);
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
   * Class constructor.
   */
  void Strategy(string _name, StrategyParams &_params, Market *_market = NULL, Timeframe *_tf = NULL, Log *_log = NULL)
    :
      name(_name),
      market(_market != NULL ? _market : new Market),
      tf(_tf != NULL ? _tf : new Timeframe),
      logger(_log != NULL ? _log : new Log)
    {
    params = _params;

    // Statistics variables.
    UpdateOrderStats(EA_STATS_DAILY);
    UpdateOrderStats(EA_STATS_WEEKLY);
    UpdateOrderStats(EA_STATS_MONTHLY);
    UpdateOrderStats(EA_STATS_TOTAL);

    // Assign class variables.
    logger = new Log(V_INFO);
    market = new Market();
  }

  /**
   * Class deconstructor.
   */
  void ~Strategy() {
    // Remove class variables.
    delete logger;
    delete data;
    delete sl;
    delete tp;
    delete market;
    delete tf;
  }

  /**
   * Initialize strategy.
   */
  bool Init() {
    if (!tf.ValidTf()) {
      logger.Warning(StringFormat("Could not initialize %s since %s timeframe is not active!", name, tf.TfToString()), __FUNCTION__ + ": ");
      return false;
    }
    return true;
  }

  /* Virtual methods */

  /**
   * Checks strategy's trade signal.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   _base_method (int) - base signal method
   *   _open_method (int) - open signal method to use by using bitwise AND operation
   *   _level (double) - signal level to consider the signal
   */
  virtual bool Signal(ENUM_ORDER_TYPE _cmd, int _base_method, int _open_method, double _level);
  virtual bool Signal(ENUM_ORDER_TYPE _cmd);

};
