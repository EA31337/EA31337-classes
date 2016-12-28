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
#include "Account.mqh"
#include "Convert.mqh"

/*
 * Trade class
 */
class Trade {

private:
    int totalOrders;
    // Order* orders[];

public:

    /**
     * Returns maximal order stop loss value given the risk margin (in %).
     *
     * @param int cmd
     *   Trade command (e.g. OP_BUY/OP_SELL).
     * @param double lot_size
     *   Lot size to take into account.
     * @param double risk_margin
     *   Maximum account margin to risk (in %).
     * @return
     *   Returns maximum stop loss price value for the given symbol.
     */
    static double GetMaxStopLoss(int cmd, double lot_size, double risk_margin = 1.0, string symbol = NULL) {
      return Market::GetOpenPrice(cmd, symbol)
        + Market::GetMarketDistanceInValue(symbol)
        + Convert::MoneyToValue(Account::AccountRealBalance() / 100 * risk_margin, lot_size)
        * -Order::OrderDirection(cmd);
    }

    /**
     * Calculate the maximal lot size for the given stop loss value and risk margin.
     *
     * @param int cmd
     *   Trade command (e.g. OP_BUY/OP_SELL).
     * @param double sl
     *   Stop loss to calculate the lot size for.
     * @param double risk_margin
     *   Maximum account margin to risk (in %).
     *
     * @return
     *   Returns maximum safe lot size value.
     */
    static double GetMaxLotSize(int cmd, double sl, double risk_margin = 1.0, string symbol = NULL) {
      // @todo
      return 0;
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
