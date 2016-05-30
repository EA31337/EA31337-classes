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

/*
 * Class to provide methods to deal with the order.
 */
class Order {
public:

    /**
     * Get order profit.
     */
    static double GetOrderProfit() {
#ifdef __MQL4__
        return OrderProfit() - OrderCommission() - OrderSwap();
#else
        // @todo: Not implemented yet.
#endif
    }

    static string GetOrderToText() {
#ifdef __MQL4__
        return StringConcatenate("Order Details: ",
            "Ticket: ", OrderTicket(), "; ",
            "Time: ", TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS), "; ",
            "Comment: ", OrderComment(), "; ",
            "Commision: ", OrderCommission(), "; ",
            "Symbol: ", StringSubstr(_Symbol, 0, 6), "; ",
            "Type: ", Convert::OrderTypeToString(OrderType()), "; ",
            "Expiration: ", OrderExpiration(), "; ",
            "Open Price: ", DoubleToStr(OrderOpenPrice(), Digits), "; ",
            "Close Price: ", DoubleToStr(OrderClosePrice(), Digits), "; ",
            "Take Profit: ", OrderProfit(), "; ",
            "Stop Loss: ", OrderStopLoss(), "; ",
            "Swap: ", OrderSwap(), "; ",
            "Lot size: ", OrderLots(), "; "
            );
#else
        // @todo: Not implemented yet.
#endif
    }

};
