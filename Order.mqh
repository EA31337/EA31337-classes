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

#ifdef ___MQL5__

// Some of standard MQL4 constants are absent in MQL5, therefore they should be declared as below.
#define OP_BUY 0           // Buy
#define OP_SELL 1          // Sell
#define OP_BUYLIMIT 2      // Pending order of BUY LIMIT type
#define OP_SELLLIMIT 3     // Pending order of SELL LIMIT type
#define OP_BUYSTOP 4       // Pending order of BUY STOP type
#define OP_SELLSTOP 5      // Pending order of SELL STOP type

#define MODE_OPEN 0
#define MODE_CLOSE 3
#define MODE_VOLUME 4
#define MODE_REAL_VOLUME 5
#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1

#endif

/*
 * Class to provide methods to deal with the order.
 */
class Order {

private:
    double entryPrice;
    double takeProfit;
    double stopLoss;
    int orderTicket;
    int magicNumber;
    // OrderType orderType;

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
