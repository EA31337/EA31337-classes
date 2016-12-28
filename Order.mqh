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

// Properties.
#property strict

// Includes.
#include "Convert.mqh"

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

  /**
   * Returns number of total order deals from the history.
   */
  static int HistoryTotal() {
    return #ifndef __MQL5__ ::HistoryTotal(); #else ::HistoryDealsTotal() #endif
  }

  /**
   * Select an order to work with.
   */
  static bool OrderSelect(int index, int select = SELECT_BY_POS, int pool = MODE_TRADES) {
    #ifdef __MQL4__
      return ::OrderSelect(index, select, pool);
    #else
      return ::OrderSelect(index);
    #endif
  }

   /**
    * Optimize lot size for open based on the consecutive wins and losses.
    *
    * @param
    *   lots (double)
    *     Base lot size.
    *   win_factor (double)
    *     Lot size increase factor (in %) multiplied by consecutive wins.
    *   loss_factor (double)
    *     Lot size increase factor (in %) multiplied by consecutive losses.
    *   ols_orders (double)
    *     Maximum number of recent orders to check for consecutive wins/losses.
    *   symbol (string)
    *     Optional symbol name if different than current.
    */
   static double OptimizeLotSize(double lots, double win_factor = 1.0, double loss_factor = 1.0, int ols_orders = 100, string symbol = NULL) {
     double lotsize = lots;
     int    wins = 0,  losses = 0; // Number of consequent losing orders.
     int    twins = 0, tlosses = 0; // Total number of consequent losing orders.
     if (win_factor == 0 && loss_factor == 0) {
       return lotsize;
     }
     // Calculate number of wins and losses orders without a break.
    #ifdef __MQL5__
    CDealInfo deal;
    HistorySelect(0, TimeCurrent()); // Select history for access.
    #endif
    int orders = HistoryTotal();
    for (int i = orders - 1; i >= fmax(0, orders - ols_orders); i--) {
       #ifdef __MQL5__
       deal.Ticket(HistoryDealGetTicket(i));
       if (deal.Ticket() == 0) {
         Print(__FUNCTION__, ": Error in history!");
         break;
       }
       if (deal.Symbol() != m_symbol.Name()) continue;
       double profit = deal.Profit();
       #else
       if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == False) {
         Print(__FUNCTION__, ": Error in history!");
         break;
       }
       if (OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
       double profit = OrderProfit();
       #endif
       if (profit > 0.0) {
         losses = 0;
         wins++;
       } else {
         wins = 0;
         losses++;
       }
       twins = fmax(wins, twins);
       tlosses = fmax(losses, tlosses);
     }
     lotsize = twins   > 1 ? NormalizeDouble(lotsize + (lotsize / 100 * win_factor * twins), 2) : lotsize;
     lotsize = tlosses > 1 ? NormalizeDouble(lotsize + (lotsize / 100 * loss_factor * tlosses), 2) : lotsize;
      // Normalize and check limits.
      double minvol = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      lotsize = lotsize < minvol ? minvol : lotsize;
      double maxvol = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      lotsize = lotsize > maxvol ? maxvol : lotsize;
      double stepvol = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      lotsize = stepvol * NormalizeDouble(lotsize / stepvol, 0);
      return (lotsize);
     }

};
