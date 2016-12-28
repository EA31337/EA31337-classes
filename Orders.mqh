//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
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
#include "Account.mqh"
#include "Order.mqh"

// Properties.
#property strict

/**
 * Class to provide methods to deal with the orders.
 */
class Orders {
public:

  /**
   * Check the limit on the number of active pending orders.
   *
   * Validate whether the amount of open and pending orders
   * has reached the limit set by the broker.
   *
   * @see: https://www.mql5.com/en/articles/2555#account_limit_pending_orders
   */
  static bool IsNewOrderAllowed() {
    int _max_orders = (int) AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
    return _max_orders == 0 ? True : OrdersTotal() < _max_orders;
  }

  /**
   * Calculate number of allowed orders to open.
   */
  static uint CalcMaxOrders(double volume_size, double _risk_ratio = 1.0, uint prev_max_orders = 0, uint hard_limit = 0, bool smooth = True, string symbol = NULL) {
    double _avail_margin = fmin(Account::AccountFreeMargin(), Account::AccountBalance() + Account::AccountCredit());
    double _margin_required = MarketInfo(symbol, MODE_MARGINREQUIRED);
    double _avail_orders = _avail_margin / _margin_required / volume_size;
    uint new_max_orders = (int) (_avail_orders * _risk_ratio);
    if (hard_limit > 0) new_max_orders = fmin(hard_limit, new_max_orders);
    if (smooth && new_max_orders > prev_max_orders) {
      // Increase the limit smoothly.
      return (prev_max_orders + new_max_orders) / 2;
    } else {
      return new_max_orders;
    }
  }

  /**
   * Calculate number of lots for open positions.
   */
  static double GetOpenLots(string symbol = NULL, int magic_number = 0, int magic_range = 0) {
    double total_lots = 0;
    // @todo: Convert to MQL5.
    symbol = symbol != NULL ? symbol : _Symbol;
    for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == False) break;
      if (OrderSymbol() == symbol) {
        if ((magic_number > 0)
          && (OrderMagicNumber() < magic_number || OrderMagicNumber() > magic_number + magic_range)) {
          continue;
        }
        // This calculates the total no of lots opened in current orders.
        total_lots += OrderLots();
      }
    }
    return total_lots;
  }

  /**
   * Calculate sum of all stop loss or profit take points of opened orders.
   *
   * @return
   *   Returns sum of all stop loss or profit take points
   *   from all opened orders for the given symbol.
   */
  static double TotalSLTP(int op = EMPTY, string symbol = NULL, bool sl = True) {
    double total_buy_sl = 0, total_buy_tp = 0;
    double total_sell_sl = 0, total_sell_tp = 0;
    // @todo: Convert to MQL5.
    for (int i = 0; i < OrdersTotal(); i++) {
      if (!Order::OrderSelect(i)) {
        Print(i, ": OrderSelect returned the error of: ", GetLastError());
        break;
      }
      if (symbol == NULL || OrderSymbol() == symbol) {
        double order_tp = OrderTakeProfit();
        double order_sl = OrderStopLoss();
        switch (OrderType()) {
          case OP_BUY:
            order_tp = order_tp == 0 ? iHigh(OrderSymbol(), PERIOD_W1, 0) : order_tp;
            order_sl = order_sl == 0 ? iLow(OrderSymbol(), PERIOD_W1, 0) : order_sl;
            total_buy_sl += OrderLots() * (OrderOpenPrice() - order_sl);
            total_buy_tp += OrderLots() * (order_tp - OrderOpenPrice());
            // PrintFormat("%s:%d/%d: OP_BUY: TP=%g, SL=%g, total: %g/%g", __FUNCTION__, i, OrdersTotal(), order_tp, order_sl, total_buy_sl, total_buy_tp);
            break;
          case OP_SELL:
            order_tp = order_tp == 0 ? iLow(OrderSymbol(), PERIOD_W1, 0) : order_tp;
            order_sl = order_sl == 0 ? iHigh(OrderSymbol(), PERIOD_W1, 0) : order_sl;
            total_sell_sl += OrderLots() * (order_sl - OrderOpenPrice());
            total_sell_tp += OrderLots() * (OrderOpenPrice() - order_tp);
            // PrintFormat("%s:%d%d: OP_SELL: TP=%g, SL=%g, total: %g/%g", __FUNCTION__, i, OrdersTotal(), order_tp, order_sl, total_sell_sl, total_sell_tp);
            break;
        }
      }
    }
    switch (op) {
      case OP_BUY:
        return sl ? total_buy_sl : total_buy_tp;
      case OP_SELL:
        return sl ? total_sell_sl : total_sell_tp;
      case EMPTY:
      default:
        return sl ? fabs(total_buy_sl - total_sell_sl) : fabs(total_buy_tp - total_sell_tp);
    }
  }

  /**
   * Get sum of total stop loss values of opened orders.
   */
  static double TotalSL(int op = EMPTY, string symbol = NULL) {
    return TotalSLTP(op, symbol, True);
  }

  /**
   * Get sum of total take profit values of opened orders.
   *
   * @return
   *   Returns total take profit points.
   */
  static double TotalTP(int op = EMPTY, string symbol = NULL) {
    return TotalSLTP(op, symbol, False);
  }

  /**
   * Get ratio of total stop loss points.
   *
   * @return
   *   Returns ratio between 0 and 1.
   */
  static double RatioSL(int op = EMPTY, string symbol = NULL) {
    return 1.0 / fmax(TotalSL(op, symbol) + TotalTP(op, symbol), 0.01) * TotalSL(op, symbol);
  }

  /**
   * Get ratio of total profit take points.
   *
   * @return
   *   Returns ratio between 0 and 1.
   */
  static double RatioTP(int op = EMPTY, string symbol = NULL) {
    return 1.0 / fmax(TotalSL(op, symbol) + TotalTP(op, symbol), 0.01) * TotalTP(op, symbol);
  }

};
