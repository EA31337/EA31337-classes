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
#include "Market.mqh"

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
#endif

// Define MQL4 constants in case they're not defined (e.g. in MQL5).
#ifndef MODE_TRADES #define MODE_TRADES 0 #endif
#ifndef MODE_HISTORY #define MODE_HISTORY 1 #endif
#ifndef SELECT_BY_POS #define SELECT_BY_POS 0 #endif
#ifndef SELECT_BY_TICKET #define SELECT_BY_TICKET 1 #endif

/*
 * Class to provide methods to deal with the order.
 *
 * @see
 * - https://www.mql5.com/en/docs/trading/ordergetinteger
 */
class Order {

protected:
  double entryPrice;
  double takeProfit;
  double stopLoss;
  int orderTicket;
  int magicNumber;
  string symbol;
  // Class variables.
  Market *market;
  // OrderType orderType;

public:

  /**
   * Class constructor.
   */
  void Order(string _symbol = NULL) :
    symbol(_symbol != NULL ? _symbol : _Symbol)
  {
  }

  /**
   * Returns profit of the currently selected order.
   */
  static double GetOrderProfit() {
    #ifdef __MQL4__
    return OrderProfit() - OrderCommission() - OrderSwap();
    #else
    // @todo: Not implemented yet.
    return NULL;
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
    return NULL;
    #endif
  }

  /**
   * Returns number of total order deals from the history.
   */
  static int HistoryTotal() {
    return #ifndef __MQL5__ ::HistoryTotal(); #else ::HistoryDealsTotal(); #endif
  }

  /* MT ORDER METHODS */

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
    return false;
    #endif
  }

  /**
   * Closes a position by an opposite one.
   */
  static bool OrderCloseBy(int ticket, int opposite, color arrow_color) {
    #ifdef __MQL4__
    return ::OrderCloseBy(ticket, opposite, arrow_color);
    #else
    // @todo
    return false;
    #endif
  }

  /**
   * Returns close price of the currently selected order.
   */
  static double OrderClosePrice() {
    #ifdef __MQL4__
    return ::OrderClosePrice();
    #else // __MQL5__
    // @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
    // @todo
    return NULL;
    #endif
  }

  /*
   * Returns close time of the currently selected order.
   *
   * @see:
   * - https://docs.mql4.com/trading/orderclosetime
   * - https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
   */
  static datetime OrderCloseTime() {
    #ifdef __MQL4__
    return ::OrderCloseTime();
    #else // __MQL5__
    // @todo: Create implementation.
    return NULL;
    #endif
  }

  /**
   * Returns calculated commission of the currently selected order.
   *
   * @see:
   * - https://docs.mql4.com/trading/ordercommission
   * - https://www.mql5.com/en/docs/standardlibrary/tradeclasses/cpositioninfo/cpositioninfocommission
   */
  static double OrderCommission() {
    #ifdef __MQL4__
    return ::OrderCommission();
    #else // __MQL5__
    // @fixme
    CPositionInfo m_position;
    return m_position.Commission();
    #endif
  }

  /**
   * Deletes previously opened pending order.
   *
   * @see: https://docs.mql4.com/trading/orderdelete
   */
  static bool OrderDelete(int ticket, color arrow_color) {
    #ifdef __MQL4__
    return OrderDelete(ticket, arrow_color);
    #else
    CTrade *trade = new CTrade();
    bool _res = trade.OrderDelete(ticket);
    delete trade;
    return _res;
    #endif
  }

  /**
   * Returns expiration date of the selected pending order.
   *
   * @see
   * - https://docs.mql4.com/trading/orderexpiration
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static datetime OrderExpiration() {
    return #ifdef __MQL4__ ::OrderExpiration(); #else (datetime) OrderGetInteger(ORDER_TIME_EXPIRATION); #endif
  }

  /**
   * Returns amount of lots of the selected order.
   *
   * @see:
   * - https://docs.mql4.com/trading/orderlots
   * - https://www.mql5.com/en/docs/trading/ordergetdouble
   */
  static double OrderLots() {  
    return #ifdef __MQL4__ ::OrderLots(); #else OrderGetDouble(ORDER_VOLUME_CURRENT); #endif
  }

  /**
   * Returns an identifying (magic) number of the currently selected order.
   *
   * @see
   * - http://docs.mql4.com/trading/ordermagicnumber
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static int OrderMagicNumber() {
    return #ifdef __MQL4__ ::OrderMagicNumber(); #else (int) OrderGetInteger(ORDER_MAGIC); #endif
  }

  /**
   * Modification of characteristics of the previously opened or pending orders.
   *
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
    return false;
    #endif
  }

  /**
   * Returns open price of the currently selected order.
   *
   * @see
   * - http://docs.mql4.com/trading/orderopenprice
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static double OrderOpenPrice() {
    return #ifdef __MQL4__ ::OrderOpenPrice(); #else OrderGetDouble(ORDER_PRICE_OPEN); #endif
  }

  /**
   * Returns open time of the currently selected order.
   *
   * @see
   * - http://docs.mql4.com/trading/orderopentime
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static datetime OrderOpenTime() {
    return #ifdef __MQL4__ ::OrderOpenTime(); #else (datetime) OrderGetInteger(ORDER_TIME_SETUP); #endif
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
   *
   * @see https://docs.mql4.com/trading/orderprofit
   */
  static double OrderProfit() {
    #ifdef __MQL4__
    return ::OrderProfit();
    #else
    // @todo: Not implemented yet.
    return NULL;
    #endif
  }

  /**
   * Select an order to work with.
   *
   * The function selects an order for further processing.
   *
   *  @see http://docs.mql4.com/trading/orderselect
   */
  static bool OrderSelect(int index, int select = 0, int pool = 0) {
    #ifdef __MQL4__
      return ::OrderSelect(index, select, pool);
    #else
      return ::OrderSelect(index);
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
   * Returns swap value of the currently selected order.
   *
   * @see: https://docs.mql4.com/trading/orderswap
   */
  static double OrderSwap() {
    #ifdef __MQL4__
    return ::OrderSwap();
    #else
    // @todo
    return NULL;
    #endif
  }

  /**
   * Returns symbol name of the currently selected order.
   *
   * @see
   * - https://docs.mql4.com/trading/ordersymbol
   * - https://www.mql5.com/en/docs/trading/positiongetstring
   */
  static string OrderSymbol() {
    return #ifdef __MQL4__ ::OrderSymbol(); #else OrderGetString(ORDER_SYMBOL); #endif
  }

  /**
   * Returns take profit value of the currently selected order.
   *
   * @see
   * - https://docs.mql4.com/trading/ordertakeprofit
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static double OrderTakeProfit() {
    return #ifdef __MQL4__ ::OrderTakeProfit(); #else OrderGetDouble(ORDER_TP); #endif
  }

  /**
   * Returns a ticket number of the currently selected order.
   *
   * It is a unique number assigned to each order.
   *
   * @see https://docs.mql4.com/trading/orderticket
   * @see https://www.mql5.com/en/docs/trading/ordergetticket
   */
  static ulong OrderTicket() {
    return #ifdef __MQL4__ ::OrderTicket(); #else OrderGetInteger(ORDER_TICKET); #endif
  }

  /**
   * Returns order operation type of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/ordertype
   */
  static ENUM_ORDER_TYPE OrderType() {
    return (ENUM_ORDER_TYPE) #ifdef __MQL4__ ::OrderType(); #else OrderGetInteger(ORDER_TYPE); #endif
  }

  /* OTHER METHODS */

  /*
   * Returns direction value of order.
   *
   * @param
   *   op_type int Order operation type of the order.
   *
   * @return
   *   Returns 1 for buy, -1 for sell orders, otherwise EMPTY (-1).
   */
  static int OrderDirection(ENUM_ORDER_TYPE op_type) {
    switch (op_type) {
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
        return -1;
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
        return 1;
      default:
        return 0;
    }
  }

  /**
   * Get color of the order based on its type.
   */
  static color GetOrderColor(ENUM_ORDER_TYPE _cmd = NULL, color cbuy = Blue, color csell = Red) {
    if (_cmd == NULL) _cmd = (ENUM_ORDER_TYPE) OrderType();
    return OrderDirection(_cmd) > 0 ? cbuy : csell;
  }

};
