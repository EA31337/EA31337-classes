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
    s_enabled = True;
  }

  /**
   * Disable the strategy.
   */
  void Disable() {
    s_enabled = False;
  }

  /**
   * Resume suspended strategy.
   */
  void Resume() {
    s_suspended = False;
  }

  /**
   * Suspend the strategy.
   */
  void Suspend() {
    s_suspended = True;
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
    for (int i = 0; i < OrdersTotal(); i++) {
      if (s_symbol == OrderSymbol() && s_magic_no == OrderMagicNumber()) {
        _total++;
        _order_profit = OrderProfit() - OrderCommission() - OrderSwap();
        _net_profit += _order_profit;
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
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
    return (Ask - Bid) * pow(10, MarketInfo(s_symbol, MODE_DIGITS) < 4 ? 2 : 4);
  }

public:

  int TfToIndex(ENUM_TIMEFRAMES tf) {
    #include "Timeframe.mqh"
    return Timeframe::TfToIndex(tf);
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
    s_enabled = True;
    s_suspended = False;

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
  void Strategy(string si_name, int si_magic_no, double si_lot_size, double si_weight = 1.0, int si_spread_limit = 10.0, string si_symbol = NULL) :
      s_enabled(True),
      s_suspended(False),
      s_name(si_name),
      s_magic_no(si_magic_no),
      s_lot_size(si_lot_size),
      s_weight(si_weight),
      s_spread_limit(si_spread_limit),
      s_symbol(si_symbol != NULL ? si_symbol : _Symbol),
      s_pattern_method(0),
      s_open_level(0.0),
      s_tp_method(0),
      s_sl_method(0),
      s_tp_max(0),
      s_sl_max(0),
      s_lot_factor(GetLotSizeFactor())
    {

    // Trading variables.
    // s_lot_factor = GetLotSizeFactor();
    s_avg_spread = GetCurrSpread();

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

};
