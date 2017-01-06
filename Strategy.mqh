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

// Includes.
#include "Indicator.mqh"
#include "Log.mqh"
#include "Market.mqh"
#include "Order.mqh"
#include "Orders.mqh"
#include "Timeframe.mqh"

// Properties.
#property strict

/**
 * Base class for strategy features.
 */
class Strategy {

protected:

  // Basic variables.
  string s_name;        // Name of the strategy.
  bool s_enabled;       // State of the strategy (enabled or disabled).
  bool s_suspended;     // State of the strategy.
  uint s_magic_no;      // Magic number of the strategy.
  double  s_weight;     // Weight of the strategy.
  ENUM_TIMEFRAMES s_tf; // Operating timeframe of the strategy.
  // Trading variables.
  string s_symbol;            // Symbol to trade.
  ENUM_TIMEFRAMES tf;         // Timeframe to trade.
  double s_lot_size;          // Base lot size to trade.
  double s_lot_factor;        // Multiply lot size factor.
  double s_spread_limit;      // Spread limit to trade (in pips).
  int    s_pattern_method;    // Base pattern method to consider the trade.
  //int    s_signal_method;   // Signal method on top of pattern.
  int    s_filter_method[];   // Filter method to consider the trade.
  double s_open_level;        // Signal level to consider the trade.
  int    s_tp_method;         // Take profit method.
  int    s_sl_method;         // Stop loss method.
  int    s_tp_max;            // Hard limit on maximum take profit (in pips).
  int    s_sl_max;            // Hard limit on maximum stop loss (in pips).
  int    s_open_condition[];  // Open conditions.
  int    s_close_condition[]; // Close conditions.
  // Custom variables (e.g. for indicator).
  double s_conf_dbls[];
  int    s_conf_ints[];
  // Statistics variables.
  uint    s_orders_open;       // Number of current opened orders.
  uint    s_orders_total;      // Number of total opened orders.
  uint    s_orders_won;        // Number of total won orders.
  uint    s_orders_lost;       // Number of total lost orders.
  uint    s_errors;            // Count reported errors.
  double s_profit_factor;      // Profit factor.
  double s_avg_spread;         // Average spread.
  double s_total_net_profit;   // Total net profit.
  double s_total_gross_profit; // Total gross profit.
  double s_total_gross_loss;   // Total gross profit.
  double s_daily_net_profit;   // Daily net profit.
  double s_weekly_net_profit;  // Weekly net profit.
  double s_monhtly_net_profit; // Monthly net profit.
  // Date time variables.
  datetime   s_refresh_time;   // Order refresh frequency (in sec).
  // Class variables.
  Log *logger;
  Indicator *data;
  Market *market;
  Timeframe *timeframe;

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

public:

  /* Getters */

  /**
   * Check state of the strategy.
   */
  bool IsEnabled() {
    return s_enabled;
  }

  /**
   * Check suspension status of the strategy.
   */
  bool IsSuspended() {
    return s_suspended;
  }

  /**
   * Get timeframe of the strategy.
   */
  ENUM_TIMEFRAMES GetTimeframe() {
    return s_tf;
  }

  /**
   * Get lot size of the strategy.
   */
  double GetLotSize() {
    return s_lot_size;
  }

  /**
   * Get strategy orders currently open.
   */
  uint GetOrdersOpen() {
    UpdateOrderStats();
    return s_orders_open;
  }

  /**
   * Get strategy orders total opened.
   */
  uint GetOrdersTotal() {
    UpdateOrderStats();
    return s_orders_total;
  }

  /**
   * Get strategy orders won.
   */
  uint GetOrdersWon() {
    UpdateOrderStats();
    return s_orders_won;
  }

  /**
   * Get strategy orders lost.
   */
  uint GetOrdersLost() {
    UpdateOrderStats();
    return s_orders_lost;
  }

  /**
   * Get total net profit.
   */
  double GetTotalNetProfit() {
    UpdateOrderStats();
    return s_total_net_profit;
  }

  /**
   * Get total gross profit.
   */
  double GetTotalGrossProfit() {
    UpdateOrderStats();
    return s_total_gross_profit;
  }

  /**
   * Get total gross loss.
   */
  double GetTotalGrossLoss() {
    UpdateOrderStats();
    return s_total_gross_loss;
  }

  /**
   * Get daily net profit.
   */
  double GetDailyNetProfit() {
    // @todo
    return 0.0;
  }

  /**
   * Get weekly net profit.
   */
  double GetWeeklyNetProfit() {
    // @todo
    return 0.0;
  }

  /**
   * Get monthly net profit.
   */
  double GetMonthlyNetProfit() {
    // @todo
    return 0.0;
  }

  /**
   * Get average spread of the strategy (in pips).
   */
  double GetAvgSpread() {
    return s_avg_spread;
  }

  /* Setters */

  /**
   * Enable the strategy.
   */
  void Enable() {
    s_enabled = true;
  }

  /**
   * Disable the strategy.
   */
  void Disable() {
    s_enabled = false;
  }

  /**
   * Resume suspended strategy.
   */
  void Resume() {
    s_suspended = false;
  }

  /**
   * Suspend the strategy.
   */
  void Suspend() {
    s_suspended = true;
  }

  /* Calculations */

  /**
   * Get lot size factor.
   */
  double GetLotSizeFactor() {
    return 1.0;
  }

  /**
   * Update order stat variables.
   */
  void UpdateOrderStats() {
    static datetime _last_update = TimeCurrent();
    if (_last_update > TimeCurrent() - s_refresh_time) {
      return; // Do not update too often.
    }
    uint _total = 0, _won = 0, _lost = 0, _open = 0;
    double _gross_profit = 0, _gross_loss = 0, _net_profit = 0, _order_profit = 0;
    datetime _order_datetime;
    s_daily_net_profit = 0; s_weekly_net_profit = 0; s_monhtly_net_profit = 0;
    for (uint i = 0; i < Orders::OrdersTotal(); i++) {
      // @todo: Select order.
      if (s_symbol == Order::OrderSymbol() && s_magic_no == Order::OrderMagicNumber()) {
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
    s_orders_open = _open;
    s_orders_won = _won;
    s_orders_lost = _lost;
    s_orders_total = _total;
    s_total_net_profit = _net_profit;
    s_total_gross_profit = _gross_loss;
    s_total_gross_loss   = _gross_profit;
    // s_profit_factor = _profit_factor;
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
  void Strategy(
    string _name,
    ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
    uint _magic_no = 31337,
    ENUM_LOG_LEVEL _log_level = V_INFO,
    double _lot_size = 0.0,
    double _weight = 1.0,
    int _spread_limit = 10.0,
    string _symbol = NULL
    ) :
      s_enabled(true),
      s_suspended(false),
      s_name(_name),
      s_magic_no(_magic_no),
      s_lot_size(_lot_size),
      s_weight(_weight),
      s_spread_limit(_spread_limit),
      s_symbol(_symbol != NULL ? _symbol : _Symbol),
      s_pattern_method(0),
      s_open_level(0.0),
      s_tp_method(0),
      s_sl_method(0),
      s_tp_max(0),
      s_sl_max(0),
      s_lot_factor(GetLotSizeFactor()),
      s_avg_spread(GetCurrSpread()),
      market(new Market(_symbol)),
      logger(new Log(_log_level)),
      timeframe(new Timeframe(_tf))
    {

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

    // Assign class variables.
    logger = new Log(V_INFO);
    market = new Market();

    // Other variables.
    s_refresh_time        = 10;
  }

  /**
   * Class deconstructor.
   */
  void ~Strategy() {
    // Remove class variables.
    delete logger;
    delete market;
  }

  /**
   * Initialize strategy.
   */
  bool Init() {
    if (!Timeframe::ValidTf(s_tf, s_symbol)) {
      logger.Warning(StringFormat("Could not initialize %s since %s timeframe is not active!", s_name, Timeframe::TfToString(s_tf)), __FUNCTION__ + ": ");
      return false;
    }
    return true;
  }

};
