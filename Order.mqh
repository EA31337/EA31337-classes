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

  /* MT ORDER METHODS */

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
   * Closes opened order.
   *
   * @see http://docs.mql4.com/trading/orderclose
   */
  static bool OrderClose(
          int        ticket,      // ticket
          double     lots,        // volume
          double     price,       // close price
          int        slippage,    // slippage
          color      arrow_color  // color
          ) {
    #ifdef __MQL4__
    return ::OrderClose(ticket, lots, price, slippage, arrow_color);
    #else
    // @todo: Create implementation.
    return FALSE;
    #endif
  }

  /**
   * Closes an opened order by another opposite opened order.
   */
  /* todo */ static void OrderCloseBy(int todo) {
    #ifdef __MQL4__
    // @todo
    // ::OrderCloseBy();
    #else
    // @todo
    #endif
  }

  /**
   * Returns close price of the currently selected order.
   */
  /* todo */ static void OrderClosePrice(int todo) {
    #ifdef __MQL4__
    // @todo
    // ::OrderClosePrice()
    #else
    // @todo
    #endif
  }

  /*
   * Returns close time of the currently selected order.
   *
   *  @see http://docs.mql4.com/trading/orderclosetime
   */
  static datetime OrderCloseTime() {
    // @todo: Create implementation.
    return datetime (0);
  }

  /**
   * Returns calculated commission of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/ordercommission
   */
  static double OrderCommission() {
    #ifdef __MQL4__
    return ::OrderCommission();
    #else
    // @todo: Create implementation.
    return 0.0;
    #endif
  }

  /**
   * Returns calculated commission of the currently selected order.
   */
  /* todo */ static void OrderCommission(int todo) {
    #ifdef __MQL4__
    // @todo
    #else
    // @todo
    #endif
  }

  /**
   * Deletes previously opened pending order.
   */
  /* todo */ static void OrderDelete(int todo) {
    #ifdef __MQL4__
    // @todo
    #else
    // @todo
    #endif
  }

  /**
   * Returns expiration date of the selected pending order.
   */
  /* todo */ static void OrderExpiration(int todo) {
    #ifdef __MQL4__
    // @todo
    #else
    // @todo
    #endif
  }

  /**
   * Returns amount of lots of the selected order.
   *
   * @see http://docs.mql4.com/trading/orderlots
   */
  static double OrderLots() {
    #ifdef __MQL4__
    return ::OrderLots();
    #else
    // @todo: Check if this is what we want.
    return OrderGetDouble(ORDER_VOLUME_CURRENT); // Order current volume.
    #endif
  }

  /**
   * Returns an identifying (magic) number of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/ordermagicnumber
   */
  static int OrderMagicNumber() {
    #ifdef __MQL4__
    return ::OrderMagicNumber();
    #else
    // @todo: Create implementation.
    return 0;
    #endif
  }

  /**
   * Modification of characteristics of the previously opened or pending orders.

   * @see http://docs.mql4.com/trading/ordermodify
   */
  static bool OrderModify(
          int        ticket,      // ticket
          double     price,       // price
          double     stoploss,    // stop loss
          double     takeprofit,  // take profit
          datetime   expiration,  // expiration
          color      arrow_color  // color
          ) {
    #ifdef __MQL4__
    return ::OrderModify(ticket, price, stoploss, takeprofit, expiration, arrow_color);
    #else
    // @todo: Create implementation.
    return False;
    #endif
  }


  /**
   * Returns open price of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/orderopenprice
   */
  static double OrderOpenPrice() {
    #ifdef __MQL4__
    return ::OrderOpenPrice();
    #else
    return OrderGetDouble(ORDER_PRICE_OPEN);
    #endif
  }

  /**
   * Returns open time of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/orderopentime
   */
  static datetime OrderOpenTime() {
    #ifdef __MQL4__
    return ::OrderOpenTime();
    #else
    // @todo: Create implementation.
    return (datetime)0;
    #endif
  }

  /**
   * Prints information about the selected order in the log.
   *
   * @see http://docs.mql4.com/trading/orderprint
   */
  static void OrderPrint() {
    #ifdef __MQL4__
    ::OrderPrint();
    #else
    // @todo: Not implemented yet.
    #endif
  }


  /**
   * Returns profit of the currently selected order.
   */
  /* todo */ static void OrderProfit(int todo) {
    #ifdef __MQL4__
    // @todo
    #else
    // @todo
    #endif
  }

  /**
   * The function selects an order for further processing.
   *
   *  @see http://docs.mql4.com/trading/orderselect
   */
  static bool OrderSelect(
          int     index,            // index or order ticket
          int     select,           // flag
          int     pool=MODE_TRADES  // mode
          ) {
    #ifdef __MQL4__
    return ::OrderSelect(index, select, pool);
    #else
    // @todo: Create implementation.
    #endif
  }


  /**
   * The main function used to open market or place a pending order.
   *
   *  @see http://docs.mql4.com/trading/ordersend
   */
  static int OrderSend(
          string   symbol,              // symbol
          int      cmd,                 // operation
          double   volume,              // volume
          double   price,               // price
          int      slippage,            // slippage
          double   stoploss,            // stop loss
          double   takeprofit,          // take profit
          string   comment=NULL,        // comment
          int      magic=0,             // magic number
          datetime expiration=0,        // pending order expiration
          color    arrow_color=clrNONE  // color
          )
  {
    #ifdef __MQL4__
    return ::OrderSend(symbol,
        cmd,
        volume,
        price,
        slippage,
        stoploss,
        takeprofit,
        comment,
        magic,
        expiration,
        arrow_color);
    #else
    // Structure: https://www.mql5.com/en/docs/constants/structures/mqltraderequest
    MqlTradeRequest request;

    // Structure: https://www.mql5.com/en/docs/constants/structures/mqltraderesult
    MqlTradeResult result;

    request.action = TRADE_ACTION_DEAL;
    request.symbol = symbol;
    request.volume = volume;
    request.price = price;
    request.sl = stoploss;
    request.tp = takeprofit;
    request.comment = comment;
    request.magic = magic;
    request.expiration = expiration;
    // MQL4 has OP_BUY, OP_SELL. MQL5 has ORDER_TYPE_BUY, ORDER_TYPE_SELL, etc.
    request.type = (ENUM_ORDER_TYPE)cmd;

    bool status = OrderSend(request, result);

    // @todo: Finish the implementation.
    return 0;
    #endif
  }


  /**
   * Returns the number of closed orders in the account history loaded into the terminal.
   */
  /* todo */ static void OrdersHistoryTotal(int todo) {
    #ifdef __MQL4__
    // @todo
    #else
    // @todo
    #endif
  }

  /**
   * Returns stop loss value of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/orderstoploss
   */
  static double OrderStopLoss() {
    #ifdef __MQL4__
    return ::OrderStopLoss();
    #else
    // @todo: Create implementation.
    return 0.0;
    #endif
  }

  /**
   * Returns the number of market and pending orders.
   */
  /* todo */ static void OrdersTotal(int todo) {
    #ifdef __MQL4__
    // @todo
    #else
    // @todo
    #endif
  }

  /**
   * Returns swap value of the currently selected order.
   */
  /* todo */ static void OrderSwap(int todo) {
    #ifdef __MQL4__
    // @todo
    #else
    // @todo
    #endif
  }

  /**
   * Returns symbol name of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/ordersymbol
   */
  static string OrderSymbol() {
    #ifdef __MQL4__
    return ::OrderSymbol();
    #else
    // @todo: Create implementation.
    return "";
    #endif
  }

  /**
   * Returns take profit value of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/ordertakeprofit
   */
  static double OrderTakeProfit() {
    #ifdef __MQL4__
    return ::OrderTakeProfit();
    #else
    // @todo: Create implementation.
    return 0.0;
    #endif
  }

  /**
   * Returns ticket number of the currently selected order.
   *
   * @see https://docs.mql4.com/trading/orderticket
   * @see https://www.mql5.com/en/docs/trading/ordergetticket
   */
  static int OrderTicket() {
    #ifdef __MQL4__
    return ::OrderTicket();
    #else
    // return OrderGetTicket(i);
    // @todo: Create implementation.
    return 0;
    #endif
  }

  /**
   * Returns order operation type of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/ordertype
   */
  static int OrderType() {
    #ifdef __MQL4__
    return ::OrderType();
    #else
    // @todo: Create implementation.
    return 0;
    #endif
  }

};
