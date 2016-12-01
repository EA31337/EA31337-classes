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
  static int CalcMaxOrders(double volume_size, double _risk_ratio = 1.0, int prev_max_orders = 0, int hard_limit = 0, bool smooth = True, string symbol = NULL) {
    double _avail_margin = fmin(Account::AccountFreeMargin(), Account::AccountBalance() + Account::AccountCredit());
    double _margin_required = MarketInfo(symbol, MODE_MARGINREQUIRED);
    double _avail_orders = _avail_margin / _margin_required / volume_size;
    int new_max_orders = (int) (_avail_orders * _risk_ratio);
    if (hard_limit > 0) new_max_orders = fmin(hard_limit, new_max_orders);
    if (smooth && new_max_orders > prev_max_orders) {
      // Increase the limit smoothly.
      return (prev_max_orders + new_max_orders) / 2;
    } else {
      return new_max_orders;
    }
  }
};
