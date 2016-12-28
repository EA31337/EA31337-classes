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

/*
 * Trade class
 */
class Trade {

private:
    int totalOrders;
    // Order* orders[];

public:

    /**
     * Returns safe Stop Loss value given the risk margin (in %).
     */
    static double SafeStopLoss(double sl) {
      // @todo
      return sl;
    }


    /**
     * Get realized P&L (Profit and Loss).
     */
    /*
    double GetRealizedPL() const {
        double profit = 0;
        for (int i = 0; i <= numberOrders; ++i) {
            if (this.orders[i].getOrderType() == ORDER_FINAL) {
                // @todo
                // profit += this.orders[i].getOrderProfit();
            }
        }
        return profit;
    }
    */

    /**
     * Get unrealized P&L (Profit and Loss).
     *
     * A reflection of what profit or loss
     * that could be realized if the position were closed at that time.
     */
    /*
    double GetUnrealizedPL() const {
        double profit = 0;
        for (int i = 0; i <= numberOrders; ++i) {
            if (this.orders[i].getOrderType() != ORDER_FINAL) {
                profit += this.orders[i].getOrderProfit();
            }
        }
        return profit;
    }

    double GetTotalEquity() const {
        double profit = 0;
        for (int i = 0; i <= numberOrders; ++i) {
            profit += this.orders[i].GetOrderProfit();
        }
        return profit;
    }

    double GetTotalCommission() const {
        double commission = 0;
        for (int i = 0; i <= numberOrders; ++i) {
            commission += this.orders[i].GetOrderCommission();
        }
        return commission;
    }

    double GetTotalSwap() const {
        double swap = 0;
        for (int i = 0; i <= numberOrders; ++i) {
            swap += this.orders[i].GetOrderSwap();
        }
        return swap;
    }
    */

};
