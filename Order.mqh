//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

/* Properties */
#property strict

// Prevents processing this includes file for the second time.
#ifndef ORDER_MQH
#define ORDER_MQH

/* Forward declaration */
#ifdef __MQL5__
class CPositionInfo;
class CTrade;
#endif

/* Includes */
#include "Log.mqh"
#include "String.mqh"
#include "SymbolInfo.mqh"
#ifdef __MQL5__
//#include <Trade/Trade.mqh>
//#include <Trade/PositionInfo.mqh>
#endif

/* Defines */
// Index in the order pool.
#ifndef SELECT_BY_POS
#define SELECT_BY_POS 0
#endif

// Index by the order ticket.
#ifndef SELECT_BY_TICKET
#define SELECT_BY_TICKET 1
#endif

/**
 * Class to provide methods to deal with the order.
 *
 * @see
 * - https://www.mql5.com/en/docs/trading/ordergetinteger
 */
class Order : public SymbolInfo { // : public Deal

public:

  /*
   * Default enumerations:
   *
   * Trade operation:
   *   0: OP_BUY (Buy operation)
   *   1: OP_SELL (Sell operation)
   *   2: OP_BUYLIMIT (Buy limit pending order)
   *   3: OP_SELLLIMIT (Sell limit pending order)
   *   4: OP_BUYSTOP (Buy stop pending order)
   *   5: OP_SELLSTOP (Sell stop pending order)
   */

  // Defines.
  #define ORDER_REFRESH_RATE 10

  /* Structs */
  struct OrderEntry {
    ulong                         ticket;           // Order ticket number.
    ENUM_ORDER_STATE              state;            // Order state.
    ulong                         magic_id;         // Expert Advisor ID (magic number).
    double                        profit;           // Order profit.
    double                        volume;           // Requested volume for a deal in lots.
    double                        open_price;       // Open price.
    double                        close_price;      // Close price.
    datetime                      open_time;        // Open time.
    datetime                      close_time;       // Close time.
    double                        stoplimit;        // StopLimit level of the order.
    double                        sl;               // Stop loss level of the order.
    double                        tp;               // Take Profit level of the order.
    ulong                         slippage;         // Maximal possible deviation from the requested price.
    ENUM_ORDER_TYPE               type;             // Order type.
    ENUM_ORDER_TYPE_FILLING       filling;          // Order execution type.
    ENUM_ORDER_TYPE_TIME          type_time;        // Order expiration type.
    datetime                      expiration;       // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type.
    String                       *comment;          // Order comment.
    ulong                         position;         // Position ticket.
    ulong                         position_by;      // The ticket of an opposite position.
    bool                          is_real;          // Whether order is real or fake.
    datetime                      last_update;      // Last update of order values.
    String                       *symbol;           // Order symbol pair.
    //Market                       *market;           // Access to market data of the order.
    Log                          *logger;           // Pointer to logger.
  };

protected:

  // Struct variables.
  OrderEntry order;
  MqlTradeRequest request;
  #ifdef __MQL5__
  MqlTradeCheckResult check_result;
  #endif
  MqlTradeResult result;

  // OrderType orderType;
  #ifdef __MQL5__
  //CTrade ctrade;
  //CPositionInfo position_info;
  #endif
  // Other variables.

public:

  /**
   * Class constructor.
   */
  void Order() {
  }
  void Order(ulong _ticket_no) //, Market *_market = NULL)
  {
    order.ticket = _ticket_no;
    Update(_ticket_no);
  }
  void Order(const OrderEntry &_order) {
    order = _order;
  }
  void Order(MqlTradeRequest &_req, MqlTradeResult &_res) {
    if (SendRequest(_req, _res)) {
      // @todo: Get the last executed order.
    }
    else {
      // @todo: Request to order.
    }
  }

  /**
   * Class deconstructor.
   */
  void ~Order() {
  }

  /**
   * Send the trade operation to a trade server.
   */
  static bool SendRequest(MqlTradeRequest &_request) {
    MqlTradeResult _result;
    // @todo
    // return OrderSend(_request, _result) ? _result.retcode < TRADE_RETCODE_ERROR : false;
    return false;
  }
  static bool SendRequest(MqlTradeRequest &_request, MqlTradeResult &_result) {
    // MqlTradeResult _result; // @todo: _result.
    // @todo
    // return OrderSend(_request, _result) ? _result.retcode < TRADE_RETCODE_ERROR : false;
    return false;
  }

  /**
   * Get allowed order filling modes.
   */
  static ENUM_ORDER_TYPE_FILLING GetOrderFilling(const string _symbol) {
    ENUM_ORDER_TYPE_FILLING _result = ORDER_FILLING_RETURN;
    uint _filling = (uint) SymbolInfoInteger(_symbol, SYMBOL_FILLING_MODE);
    if ((_filling & SYMBOL_FILLING_IOC) != 0) {
      _result = ORDER_FILLING_IOC;
    }
    else if ((_filling & SYMBOL_FILLING_FOK) != 0) {
      _result = ORDER_FILLING_FOK;
    }
    return (_result);
  }
  ENUM_ORDER_TYPE_FILLING GetOrderFilling() {
    return GetOrderFilling(this.GetSymbol());
  }

  /**
   * Get allowed order filling modes.
   */
  static ENUM_ORDER_TYPE_FILLING GetOrderFilling(const string _symbol, const uint _type) {
    const ENUM_SYMBOL_TRADE_EXECUTION _exe_mode = (ENUM_SYMBOL_TRADE_EXECUTION)::SymbolInfoInteger(_symbol, SYMBOL_TRADE_EXEMODE);
    const int _filling_mode = (int) ::SymbolInfoInteger(_symbol, SYMBOL_FILLING_MODE);
    return ((_filling_mode == 0 || (_type >= ORDER_FILLING_RETURN) || ((_filling_mode & (_type + 1)) != _type + 1)) ?
      (((_exe_mode == SYMBOL_TRADE_EXECUTION_EXCHANGE) || (_exe_mode == SYMBOL_TRADE_EXECUTION_INSTANT)) ?
       ORDER_FILLING_RETURN : ((_filling_mode == SYMBOL_FILLING_IOC) ? ORDER_FILLING_IOC : ORDER_FILLING_FOK)) :
      (ENUM_ORDER_TYPE_FILLING) _type);
  }

  /* MT ORDER METHODS */

  /**
   * Closes opened order.
   *
   * @see http://docs.mql4.com/trading/orderclose
   */
  static bool OrderClose(
      ulong  _ticket,                // Unique number of the order ticket.
      double _lots,                  // Number of lots.
      double _price,                 // Closing price.
      int    _slippage,              // Value of the maximum price slippage in points.
      color  _arrow_color = CLR_NONE // Color of the closing arrow on the chart.
      ) {
    #ifdef __MQL4__
    return ::OrderClose((uint) _ticket, _lots, _price, _slippage, _arrow_color);
    #else
    MqlTradeRequest _request = {0};
    _request.action       = TRADE_ACTION_DEAL;
    _request.position     = _ticket;
    _request.symbol       = ::PositionGetString(POSITION_SYMBOL);
    _request.volume       = _lots;
    _request.price        = _price;
    _request.deviation    = _slippage;
    _request.type         = (ENUM_ORDER_TYPE) (1 - ::PositionGetInteger(POSITION_TYPE));
    _request.type_filling = GetOrderFilling(_request.symbol, (uint) _request.deviation);
    return SendRequest(_request);
    #endif
  }
  bool OrderClose() {
    if (OrderSelect() && IsOrderOpen()) {
      /*
      if (OrderClose(order.ticket, order.volume, order.market.GetAsk())) {
        // @todo
        return false;
      }
      */
    }
    return false;
  }

  /**
   * Closes a position by an opposite one.
   */
  static bool OrderCloseBy(int _ticket, int _opposite, color _color) {
    #ifdef __MQL4__
    return ::OrderCloseBy(_ticket, _opposite, _color);
    #else
    if (::OrderSelect(_ticket)) {
      MqlTradeRequest _request = {0};
      _request.action      = TRADE_ACTION_CLOSE_BY;
      _request.position    = _ticket;
      _request.position_by = _opposite;
      return SendRequest(_request);
    } else {
      return false;
    }
    #endif
  }

  /**
   * Returns close price of the currently selected order.
   */
  static double OrderClosePrice() {
    #ifdef __MQL4__
    return ::OrderClosePrice();
    #else // __MQL5__
    return ::PositionGetDouble(POSITION_PRICE_CURRENT);
    #endif
  }
  double GetClosePrice() {
    return order.close_price = IsOrderSelected() ? OrderClosePrice() : order.close_price;
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
  datetime GetOpenTime() {
    return order.open_time = IsOrderSelected() ? OrderOpenTime() : order.open_time;
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
    // @todo
    // return position_info.?
    return 0;
    #endif
  }
  datetime GetCloseTime() {
    return order.close_time = IsOrderSelected() ? OrderCloseTime() : order.close_time;
  }

  /**
   * Returns comment of the currently selected order.
   *
   * @see:
   * - https://docs.mql4.com/trading/ordercomment
   * - https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
   */
  static string OrderComment() {
    #ifdef __MQL4__
    return ::OrderComment();
    #else // __MQL5__
    return ::OrderGetString(ORDER_COMMENT);
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
    return ::PositionGetDouble(POSITION_COMMISSION);
    #endif
  }

  /**
   * Deletes previously opened pending order.
   *
   * @see: https://docs.mql4.com/trading/orderdelete
   */
  static bool OrderDelete(ulong _ticket, color _color = NULL) {
    #ifdef __MQL4__
    return ::OrderDelete((uint) _ticket, _color);
    #else
    if (::OrderSelect(_ticket)) {
      MqlTradeRequest _request = {0};
      MqlTradeResult _result;
      _request.action = TRADE_ACTION_REMOVE;
      _request.order = _ticket;
      return SendRequest(_request);
    } else {
      return false;
    }
    #endif
  }
  bool OrderDelete() {
    return OrderDelete(order.ticket);
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
  double GetVolume() {
    return order.volume = IsOrderSelected() ? OrderLots() : order.volume;
  }

  /**
   * Returns an identifying (magic) number of the currently selected order.
   *
   * @see
   * - http://docs.mql4.com/trading/ordermagicnumber
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static long OrderMagicNumber() {
    return #ifdef __MQL4__ (long) ::OrderMagicNumber(); #else OrderGetInteger(ORDER_MAGIC); #endif
  }
  ulong GetMagicNumber() {
    return order.magic_id = IsOrderSelected() ? OrderMagicNumber() : order.magic_id;
  }

  /**
   * Modification of characteristics of the previously opened or pending orders.
   *
   * @see http://docs.mql4.com/trading/ordermodify
   */
  static bool OrderModify(
          ulong      _ticket,      // Ticket number.
          double     _price,       // Price.
          double     _stoploss,    // Stop loss.
          double     _takeprofit,  // Take profit.
          datetime   _expiration,  // Expiration.
          color      _arrow_color  // Color of order.
          ) {
    #ifdef __MQL4__
    return ::OrderModify((uint) _ticket, _price, _stoploss, _takeprofit, _expiration, _arrow_color);
    #else
    MqlTradeRequest _request = {0};
    _request.order = _ticket;
    _request.price = _price;
    _request.sl = _stoploss;
    _request.tp = _takeprofit;
    _request.expiration = _expiration;
    return SendRequest(_request);
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
  double GetOpenPrice() {
    return order.open_price = IsOrderSelected() ? OrderOpenPrice() : order.open_price;
  }

  /**
   * Returns profit of the currently selected order.
   *
   * @return
   * Returns the net profit value (without swaps or commissions) for the selected order.
   * For open orders, it is the current unrealized profit. For closed orders, it is the fixed profit.
   *
   * @see https://docs.mql4.com/trading/orderprofit
   */
  static double OrderProfit() {
    #ifdef __MQL4__
    return ::OrderProfit();
    #else
    return ::PositionGetDouble(POSITION_PROFIT);
    #endif
  }
  double GetProfit() {
    return order.profit = IsOrderSelected() ? OrderProfit() : order.profit;
  }

  /**
   * Executes trade operations by sending the request to a trade server.
   *
   * The main function used to open market or place a pending order.
   *
   * @see
   * - http://docs.mql4.com/trading/ordersend
   * - https://www.mql5.com/en/docs/trading/ordersend
   *
   * @return
   * Returns number of the ticket assigned to the order by the trade server
   * or -1 if it fails.
   */
  long OrderSend(
          string   _symbol,              // Symbol.
          int      _cmd,                 // Operation.
          double   _volume,              // Volume.
          double   _price,               // Price.
          int      _slippage,            // Slippage.
          double   _stoploss,            // Stop loss.
          double   _takeprofit,          // Take profit.
          string   _comment=NULL,        // Comment.
          int      _magic=0,             // Magic number.
          datetime _expiration=0,        // Pending order expiration.
          color    _arrow_color=clrNONE  // Color.
          ) {
    #ifdef __MQL4__
    return ::OrderSend(_symbol,
      _cmd,
      _volume,
      _price,
      _slippage,
      _stoploss,
      _takeprofit,
      _comment,
      _magic,
      _expiration,
      _arrow_color);
    #else
    MqlTradeRequest _request = {0}; // Query structure.
    MqlTradeCheckResult _check_result = {0};
    MqlTradeResult _result = {0}; // Structure of the result.
    _request.action = TRADE_ACTION_DEAL;
    _request.symbol = _symbol;
    _request.volume = _volume;
    _request.price = _price;
    _request.sl = _stoploss;
    _request.tp = _takeprofit;
    _request.comment = _comment;
    _request.magic = _magic;
    _request.expiration = _expiration;
    _request.type = (ENUM_ORDER_TYPE) _cmd;
    this.request = _request;
    // The trade requests go through several stages of checking on a trade server.
    // First of all, it checks if all the required fields of the request parameter are filled out correctly.
    if (!OrderCheck(_request, _check_result)) {
      // If funds are not enough for the operation,
      // or parameters are filled out incorrectly, the function returns false.
      // In order to obtain information about the error, call the GetLastError() function.
      // @see: https://www.mql5.com/en/docs/trading/ordercheck
      this.check_result = _check_result;
      return -1;
    }
    else {
      // If there are no errors, the server accepts the order for further processing.
      // The check results are placed to the fields of the MqlTradeCheckResult structure.
      // For a more detailed description of the function execution result,
      // analyze the fields of the result structure.
      this.check_result = _check_result;
    }
    // Sends trade requests to a server.
    if (::OrderSend(_request, _result)) {
      // In case of a successful basic check of structures (index checking) returns true.
      // However, this is not a sign of successful execution of a trade operation.
      // @see: https://www.mql5.com/en/docs/trading/ordersend
      this.result = _result;
      return (long) (_request.action == TRADE_ACTION_DEAL ? _result.deal : _result.order);
    }
    else {
      // The function execution result is placed to structure MqlTradeResult,
      // whose retcode field contains the trade server return code.
      // @see: https://www.mql5.com/en/docs/constants/errorswarnings/enum_trade_return_codes
      this.result = _result;
    }
    return -1;
    #endif
  }

  /**
   * Returns stop loss value of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/orderstoploss
   */
  static double OrderStopLoss() {
    return #ifdef __MQL4__ ::OrderStopLoss(); #else ::PositionGetDouble(POSITION_SL); #endif
  }
  double GetStopLoss() {
    return order.sl = IsOrderSelected() ? OrderStopLoss() : order.sl;
  }

  /**
   * Returns take profit value of the currently selected order.
   *
   * @return
   * Returns take profit value of the currently selected order.
   *
   * @see
   * - https://docs.mql4.com/trading/ordertakeprofit
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static double OrderTakeProfit() {
    return #ifdef __MQL4__ ::OrderTakeProfit(); #else OrderGetDouble(ORDER_TP); #endif
  }
  double GetTakeProfit() {
    return order.tp = IsOrderSelected() ? OrderTakeProfit() : order.tp;
  }

  /**
   * Returns SL/TP value of the currently selected order.
   */
  static double OrderSLTP(ENUM_ORDER_PROPERTY_DOUBLE _mode) {
    switch (_mode) {
      case ORDER_SL: return OrderStopLoss();
      case ORDER_TP: return OrderTakeProfit();
    }
    return NULL;
  }

  /**
   * Returns swap value of the currently selected order.
   *
   * @see: https://docs.mql4.com/trading/orderswap
   */
  static double OrderSwap() {
    return #ifdef __MQL4__ ::OrderSwap(); #else ::PositionGetDouble(POSITION_SWAP); #endif
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
  string GetSymbol() {
    return IsOrderSelected() ? OrderSymbol() : order.symbol.ToString();
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
  ulong GetTicket() {
    return order.ticket;
  }

  /**
   * Returns order operation type of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/ordertype
   */
  static ENUM_ORDER_TYPE OrderType() {
    return (ENUM_ORDER_TYPE) #ifdef __MQL4__ ::OrderType(); #else OrderGetInteger(ORDER_TYPE); #endif
  }

  /**
   * Returns order operation type of the currently selected order.
   *
   * Limit and stop orders are on a GTC basis unless an expiry time is set explicitly.
   *
   * @see https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
   */
  static ENUM_ORDER_TYPE_TIME OrderTypeTime() {
    // MT4 orders are usually on an FOK basis in that you get a complete fill or nothing.
    return #ifdef __MQL4__ ORDER_TIME_GTC; #else (ENUM_ORDER_TYPE_TIME) OrderGetInteger(ORDER_TYPE); #endif
  }

  /**
   * Returns the order position based on the ticket.
   *
   * It is set to an order as soon as it is executed.
   * Each executed order results in a deal that opens or modifies an already existing position.
   * The identifier of exactly this position is set to the executed order at this moment.
   */
  static ulong OrderGetPositionID(ulong _ticket) {
    #ifdef __MQL4__
    for (int _pos = 0; _pos < OrdersTotal(); _pos++) {
      if (OrderSelect(_pos, SELECT_BY_POS, MODE_TRADES) && OrderTicket() == _ticket) {
        return _pos;
      }
    }
    return -1;
    #else // __MQL5__
    OrderSelect(_ticket, SELECT_BY_TICKET, MODE_TRADES);
    return OrderGetInteger(ORDER_POSITION_ID);
    #endif
  }
  ulong OrderGetPositionID() {
    return OrderGetPositionID(order.ticket);
  }

  /**
   * Returns the ticket of an opposite position.
   *
   * Used when a position is closed by an opposite one open for the same symbol in the opposite direction.
   *
   * @see:
   * - https://www.mql5.com/en/docs/constants/structures/mqltraderequest
   * - https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
   */
  static ulong OrderGetPositionBy(ulong _ticket) {
    #ifdef __MQL4__
    // @todo
    /*
    for (int _pos = 0; _pos < OrdersTotal(); _pos++) {
      if (OrderSelect(_pos, SELECT_BY_POS, MODE_TRADES) && OrderTicket() == _ticket) {
        return _pos;
      }
    }
    */
    return -1;
    #else // __MQL5__
    OrderSelect(_ticket, SELECT_BY_TICKET, MODE_TRADES);
    return OrderGetInteger(ORDER_POSITION_BY_ID);
    #endif
  }
  ulong OrderGetPositionBy() {
    return OrderGetPositionBy(order.ticket);
  }

  /**
   * Returns the ticket of a position in the list of open positions.
   *
   * @see https://www.mql5.com/en/docs/trading/positiongetticket
   */
  ulong PositionGetTicket(int _index) {
    #ifdef __MQL4__
    if (::OrderSelect(_index, SELECT_BY_POS, MODE_TRADES)) {
      return ::OrderTicket();
    } else {
      return -1;
    }
    #else // __MQL5__
    return PositionGetTicket(_index);
    #endif
  }

  /* Order selection methods */

  /**
   * Select an order to work with.
   *
   * The function selects an order for further processing.
   *
   *  @see http://docs.mql4.com/trading/orderselect
   */
  static bool OrderSelect(ulong index, int select = SELECT_BY_POS, int pool = MODE_TRADES) {
    #ifdef __MQL4__
      return ::OrderSelect((int) index, select, pool);
    #else
      if (select == SELECT_BY_POS) {
        if (pool == MODE_TRADES) {
          // Returns ticket of a corresponding order and automatically selects the order for further working with it
          // using functions.
          // Declaration: ulong  OrderGetTicket (int index (Number in the list of orders) )
          return OrderGetTicket((int) index) != 0;
        }
        else
        if (pool == MODE_HISTORY) {
          // The HistoryOrderGetTicket(index) return the ticket of the historical order, by its index from the cache of
          // the historical orders (not from the terminal base!). The obtained ticket can be used in the
          // HistoryOrderSelect(ticket) function, which clears the cache and re-fill it with only one order, in the
          // case of success. Recall that the value, returned from HistoryOrdersTotal() depends on the number of orders
          // in the cache.
          ulong ticket_id = HistoryOrderGetTicket((int) index);
          
          if (ticket_id == 0) {
            return false;
          }

          // For MQL5-targeted code, we need to call HistoryOrderGetTicket(index), so user may use
          // HistoryOrderGetTicket(), HistoryOrderGetDouble() and so on.
          if (!HistoryOrderSelect(ticket_id))
            return false;

          // For MQL4-legacy code, we also need to call OrderSelect(ticket), as user may still use OrderTicket(),
          // OrderType() and so on.
          return ::OrderSelect(ticket_id);
        }
      }
      else
      if (select == SELECT_BY_TICKET) {
        // Pool parameter is ignored if the order is selected by the ticket number. The ticket number is a unique order identifier.
        return ::OrderSelect(index);
      }
      Print("OrderSelect(): Possible values for \"select\" parameters are: SELECT_BY_POS or SELECT_BY_HISTORY.");
      return false;
    #endif
  }
  bool OrderSelect() {
    return this.OrderSelect(order.ticket, SELECT_BY_TICKET);
  }

  /**
   * Check whether order is selected and it is same as the class one.
   */
  bool IsOrderSelected() {
   return OrderTicket() == order.ticket;
  }

  /* State checking */

  /**
   * Check whether order is active and open.
   */
  bool IsOrderOpen() {
   return OrderOpenTime() > 0 && !(OrderCloseTime() > 0);
  }

  /* Setters */

  /**
   * Update values of the current order.
   */
  bool Update(ulong _ticket_no) {
    return OrderSelect(_ticket_no, SELECT_BY_TICKET) ? Update() : false;
  }

  /**
   * Update values of the current order.
   *
   * It assumes that the order is already pre-selected.
   */
  bool Update() {
    if (OrderTicket() != order.ticket) {
      return false;
    }
    order.ticket      = OrderTicket();              // Order ticket number.
    order.magic_id    = OrderMagicNumber();         // Magic number ID.
    order.profit      = OrderProfit();              // Order profit.
    order.volume      = OrderLots();                // Requested volume for a deal in lots.
    order.open_price  = OrderOpenPrice();           // Open price.
    order.close_price = OrderClosePrice();          // Close price.
    order.open_time   = OrderOpenTime();            // Open time.
    order.close_time  = OrderCloseTime();           // Close time.
    // order.stoplimit    = ?;                      // StopLimit level of the order.
    order.sl          = OrderStopLoss();            // Stop Loss level of the order.
    order.tp          = OrderTakeProfit();          // Take Profit level of the order.
    order.type        = OrderType();                // Order type.
    order.filling     = GetOrderFilling();          // Order execution type.
    order.type_time   = OrderTypeTime();            // Order expiration type.
    order.expiration  = OrderExpiration();          // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type.
    order.comment     = new String(OrderComment()); // Order comment.
    order.position    = OrderGetPositionID();       // Position ticket.
    order.position_by = OrderGetPositionBy();       // The ticket of an opposite position.
    order.symbol      = new String(OrderSymbol());  // Order symbol;
    return true;
  }

  /**
   * Update specific order value.
   */
  double UpdateValue(double _src, double &_dst) {
    _dst = _src;
    return _dst;
  }

  /* Conversion methods */

  /**
   * Returns OrderType as a text.
   *
   * @param
   *   op_type int Order operation type of the order.
   *   lc bool If true, return order operation in lower case.
   *
   * @return
   *   Return text representation of the order.
   */
  static string OrderTypeToString(ENUM_ORDER_TYPE _cmd, bool _lc = false) {
    _cmd = _cmd != NULL ? _cmd : OrderType();
    string _res = StringSubstr(EnumToString(_cmd), 11);
    StringReplace(_res, "_", " ");
    if (_lc) {
      StringToLower(_res);
    }
    return _res;
  }
  string OrderTypeToString(bool _lc = false) {
    return OrderTypeToString(order.type, _lc);
  }

  /* Custom order methods */

  /**
   * Returns profit of the currently selected order.
   *
   * @return
   * Returns the gross profit value (with swaps or commissions) for the selected order,
   * in the base currency.
   */
  static double GetOrderProfit() {
    return OrderProfit() - OrderCommission() - OrderSwap();
  }

  /**
   * Returns profit of the currently selected order in pips.
   *
   * @return
   * Returns the profit value for the selected order in pips.
   */
  static double GetOrderProfitInPips() {
    return (OrderOpenPrice() - SymbolInfo::GetCloseOffer(OrderSymbol(), OrderType())) / SymbolInfo::GetPointSize(OrderSymbol());
  }

  /**
   * Return opposite trade of command operation.
   *
   * @param
   *   cmd int Trade command operation.
   */
  static ENUM_ORDER_TYPE NegateOrderType(ENUM_ORDER_TYPE _cmd) {
    if (_cmd == ORDER_TYPE_BUY)  return ORDER_TYPE_SELL;
    if (_cmd == ORDER_TYPE_SELL) return ORDER_TYPE_BUY;
    return -1;
  }

  /*
   * Returns direction value of order.
   *
   * @param
   *   op_type int Order operation type of the order.
   *
   * @return
   *   Returns 1 for buy, -1 for sell orders, otherwise EMPTY (-1).
   */
  static int OrderDirection(ENUM_ORDER_TYPE _cmd) {
    switch (_cmd) {
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
  static int OrderDirection(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_PROPERTY_DOUBLE _mode) {
    return OrderDirection(_cmd) * (_mode == ORDER_SL ? -1 : 1);
  }

  /**
   * Get color of the order based on its type.
   */
  static color GetOrderColor(ENUM_ORDER_TYPE _cmd = NULL, color cbuy = Blue, color csell = Red) {
    if (_cmd == NULL) _cmd = (ENUM_ORDER_TYPE) OrderType();
    return OrderDirection(_cmd) > 0 ? cbuy : csell;
  }

  /* Text methods */

  /**
   * Returns order details in text.
   */
  static string ToString() {
    return StringFormat(
      "Order Details: Ticket: %d; Time: %s; Comment: %s; Commision: %g; Symbol: %s; Type: %s, Expiration: %s; " +
      "Open Price: %g, Close Price: %g, Take Profit: %g, Stop Loss: %g" +
      "Swap: %g; Lot size: %g",
      OrderTicket(),
      DateTime::TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS),
      OrderComment(),
      OrderCommission(),
      OrderSymbol(),
      OrderTypeToString(OrderType()),
      OrderExpiration(),
      DoubleToStr(OrderOpenPrice(), Digits),
      DoubleToStr(OrderClosePrice(), Digits),
      OrderProfit(),
      OrderStopLoss(),
      OrderSwap(),
      OrderLots()
    );
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
    Print(ToString());
    #endif
  }

  /* Class access methods */

  /**
   * Return access to Market class.
   */
  /*
  Market *MarketInfo() {
    return order.market;
  }
  */

};
#endif ORDER_MQH
