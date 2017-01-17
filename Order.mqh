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

// Class dependencies.
#ifdef __MQL5__
class CPositionInfo;
class CTrade;
#endif

// Includes.
#include "Convert.mqh"
#include "Errors.mqh"
#include "Log.mqh"
#include "Market.mqh"
#include "String.mqh"
#ifdef __MQL5__
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#endif

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

/**
 * Class to provide methods to deal with the order.
 *
 * @see
 * - https://www.mql5.com/en/docs/trading/ordergetinteger
 */
class Order {
public:
  // Defines.
  #define ORDER_REFRESH_RATE 10
  // Enums.
  #ifdef __MQL4__
  // Fill Policy.
  enum ENUM_SYMBOL_FILLING {
    // @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
    SYMBOL_FILLING_FOK = 1, // A deal can be executed only with the specified volume.
    SYMBOL_FILLING_IOC = 2  // Trader agrees to execute a deal with the volume maximally available in the market.
  };
  enum ENUM_ORDER_TYPE_FILLING {
    // @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
    ORDER_FILLING_FOK, // An order can be filled only in the specified amount.
    ORDER_FILLING_IOC, // A trader agrees to execute a deal with the volume maximally available in the market.
    ORDER_FILLING_RETURN // In case of partial filling a market or limit order with remaining volume is not canceled but processed further.
  };
  enum ENUM_ORDER_TYPE_TIME {
    // @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
    ORDER_TIME_GTC,           // Good till cancel order.
    ORDER_TIME_DAY,           // Good till current trade day order.
    ORDER_TIME_SPECIFIED,     // Good till expired order.
    ORDER_TIME_SPECIFIED_DAY  // The order will be effective till 23:59:59 of the specified day.
  };
  // Trading operations.
  enum ENUM_TRADE_REQUEST_ACTIONS {
   // @see: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions
   TRADE_ACTION_DEAL,    // Place a trade order for an immediate execution with the specified parameters (market order).
   TRADE_ACTION_PENDING, // Place a trade order for the execution under specified conditions (pending order).
   TRADE_ACTION_SLTP,    // Modify Stop Loss and Take Profit values of an opened position.
   TRADE_ACTION_MODIFY,  // Modify the parameters of the order placed previously.
   TRADE_ACTION_REMOVE,  // Delete the pending order placed previously.
   TRADE_ACTION_CLOSE_BY // Close a position by an opposite one.
  };
  // An order status that describes its state.
  enum ENUM_ORDER_STATE {
    ORDER_STATE_STARTED,        // Order checked, but not yet accepted by broker
    ORDER_STATE_PLACED,         // Order accepted
    ORDER_STATE_CANCELED,       // Order canceled by client
    ORDER_STATE_PARTIAL,        // Order partially executed
    ORDER_STATE_FILLED,         // Order fully executed
    ORDER_STATE_REJECTED,       // Order rejected
    ORDER_STATE_EXPIRED,        // Order expired
    ORDER_STATE_REQUEST_ADD,    // Order is being registered (placing to the trading system)
    ORDER_STATE_REQUEST_MODIFY, // Order is being modified (changing its parameters)
    ORDER_STATE_REQUEST_CANCEL  // Order is being deleted (deleting from the trading system)
  };
  #endif
  // Structs.
  struct OrderEntry {
    ulong                         ticket;           // Order ticket number.
    ENUM_ORDER_STATE              state;            // Order state.
    ulong                         magic_id;         // Expert Advisor ID (magic number).
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
  };
  #ifdef __MQL4__
  // @see: https://www.mql5.com/en/docs/constants/structures/mqltraderequest
  struct MqlTradeRequest {
    ENUM_TRADE_REQUEST_ACTIONS    action;           // Trade operation type.
    ulong                         magic;            // Expert Advisor ID (magic number).
    ulong                         order;            // Order ticket.
    string                        symbol;           // Trade symbol.
    double                        volume;           // Requested volume for a deal in lots.
    double                        price;            // Price.
    double                        stoplimit;        // StopLimit level of the order.
    double                        sl;               // Stop Loss level of the order.
    double                        tp;               // Take Profit level of the order.
    ulong                         deviation;        // Maximal possible deviation from the requested price.
    ENUM_ORDER_TYPE               type;             // Order type.
    ENUM_ORDER_TYPE_FILLING       type_filling;     // Order execution type.
    ENUM_ORDER_TYPE_TIME          type_time;        // Order expiration type.
    datetime                      expiration;       // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type.
    string                        comment;          // Order comment.
    ulong                         position;         // Position ticket.
    ulong                         position_by;      // The ticket of an opposite position.
  };
  // @see: https://www.mql5.com/en/docs/constants/structures/mqltraderesult
  struct MqlTradeResult  {
    uint     retcode;          // Operation return code.
    ulong    deal;             // Deal ticket, if it is performed.
    ulong    order;            // Order ticket, if it is placed.
    double   volume;           // Deal volume, confirmed by broker.
    double   price;            // Deal price, confirmed by broker.
    double   bid;              // Current Bid price.
    double   ask;              // Current Ask price.
    string   comment;          // Broker comment to operation (by default it is filled by description of trade server return code).
    uint     request_id;       // Request ID set by the terminal during the dispatch.
    uint     retcode_external; // Return code of an external trading system.
  };
  #endif

protected:

  // Struct variables.
  OrderEntry order;
  MqlTradeRequest request;

  // Class variables.
  Log *logger;
  Market *market;
  // OrderType orderType;
  #ifdef __MQL5__
  CTrade ctrade;
  CPositionInfo position_info;
  #endif
  // Other variables.

public:

  /**
   * Class constructor.
   */
  void Order(ulong _ticket_no, Market *_market, Log *_logger) :
    market(_market != NULL ? _market : new Market),
    logger(_logger != NULL ? _logger : new Log)
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
    delete logger;
    delete market;
    // delete CTrade;
    // delete CPositionInfo;
  }

  /**
   * Execute trade operations by sending the request to a trade server.
   */
  static bool OrderSend(
    MqlTradeRequest  &_req, // Query structure.
    MqlTradeResult   &_res  // Structure of the answer.
  ) {
    #ifdef __MQL4__
    // @todo
      return ::OrderSend(_req.symbol, _req.type, _req.volume, _req.price,
        0, // // @todo
        _req.sl, _req.tp, _req.comment, (uint) _req.magic, _req.expiration,
        Blue // @todo
      );
    #else
      return ::OrderSend(_req, _res);
    #endif
  }

  /**
   * Send the trade operation to a trade server.
   */
  static bool SendRequest(MqlTradeRequest &_request) {
    MqlTradeResult _result;
    return OrderSend(_request, _result) ? _result.retcode < TRADE_RETCODE_ERROR : false;
  }
  static bool SendRequest(MqlTradeRequest &_request, MqlTradeResult &_result) {
    // MqlTradeResult _result; // @todo: _result.
    return OrderSend(_request, _result) ? _result.retcode < TRADE_RETCODE_ERROR : false;
  }

  /**
   * Returns profit of the currently selected order.
   */
  static double GetOrderProfit() {
    return OrderProfit() - OrderCommission() - OrderSwap();
  }

  static string OrderToText() {
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
    return GetOrderFilling(market.GetSymbol());
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
      int        _ticket,      // ticket
      double     _lots,        // volume
      double     _price,       // close price
      int        _slippage,    // slippage
      color      _arrow_color  // color
      ) {
    #ifdef __MQL4__
    return ::OrderClose(_ticket, _lots, _price, _slippage, _arrow_color);
    #else
    MqlTradeRequest _request = {0};
    _request.action   = TRADE_ACTION_DEAL;
    _request.position = _ticket;
    _request.symbol   = ::PositionGetString(POSITION_SYMBOL);
    _request.volume   = _lots;
    _request.price    = _price;
    _request.slippage = _slippage;
    _request.type     = (ENUM_ORDER_TYPE) (1 - ::PositionGetInteger(POSITION_TYPE));
    _request.filling  = GetOrderFilling(_request.symbol, (uint) _request.deviation);
    return SendRequest(_request);
    #endif
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
    return order.close_price = OrderSelected() ? OrderClosePrice() : order.close_price;
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
    return order.open_time = OrderSelected() ? OrderOpenTime() : order.open_time;
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
    return order.close_time = OrderSelected() ? OrderCloseTime() : order.close_time;
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
    return order.volume = OrderSelected() ? OrderLots() : order.volume;
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
    return order.magic_id = OrderSelected() ? OrderMagicNumber() : order.magic_id;
  }

  /**
   * Modification of characteristics of the previously opened or pending orders.
   *
   * @see http://docs.mql4.com/trading/ordermodify
   */
  static bool OrderModify(
          int        _ticket,      // Ticket number.
          double     _price,       // Price.
          double     _stoploss,    // Stop loss.
          double     _takeprofit,  // Take profit.
          datetime   _expiration,  // Expiration.
          color      _arrow_color  // Color of order.
          ) {
    #ifdef __MQL4__
    return ::OrderModify(_ticket, _price, _stoploss, _takeprofit, _expiration, _arrow_color);
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
    return order.open_price = OrderSelected() ? OrderOpenPrice() : order.open_price;
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
    Print(OrderToText());
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
    return ::PositionGetDouble(POSITION_PROFIT);
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
          ) {
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
    MqlTradeRequest _request;
    MqlTradeResult _result;
    _request.action = TRADE_ACTION_DEAL;
    _request.symbol = symbol;
    _request.volume = volume;
    _request.price = price;
    _request.sl = stoploss;
    _request.tp = takeprofit;
    _request.comment = comment;
    _request.magic = magic;
    _request.expiration = expiration;
    _request.type = (ENUM_ORDER_TYPE) cmd;
    return SendRequest(_request);
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
    return order.sl = OrderSelected() ? OrderStopLoss() : order.sl;
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
  double GetTakeProfit() {
    return order.tp = OrderSelected() ? OrderTakeProfit() : order.tp;
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
    return OrderSelected() ? OrderSymbol() : market.GetSymbol();
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
    return #ifdef __MQL4__ ORDER_TIME_GTC; #else OrderGetInteger(ORDER_TYPE); #endif
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
    if (OrderSelect(_index, SELECT_BY_POS, MODE_TRADES)) {
      return OrderTicket();
    } else {
      return -1;
    }
    #else // __MQL5__
    return PositionGetTicket(_index);
    #endif
  }

  /**
   * Select an order to work with.
   *
   * The function selects an order for further processing.
   *
   *  @see http://docs.mql4.com/trading/orderselect
   */
  static bool OrderSelect(ulong index, int select = SELECT_BY_POS, int pool = MODE_TRADES) {
    #ifdef __MQL4__
      return ::OrderSelect((uint) index, select, pool);
    #else
      return ::OrderSelect(index);
    #endif
  }

  /**
   * Check whether order is selected and it is same as the class one.
   */
  bool OrderSelected() {
   return OrderTicket() == order.ticket;
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
    order.magic_id    = OrderMagicNumber();        // Magic number ID.
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
    switch (_cmd) {
      case ORDER_TYPE_BUY:           return !_lc ? "Buy" : "buy";
      case ORDER_TYPE_SELL:          return !_lc ? "Sell" : "sell";
      case ORDER_TYPE_BUY_LIMIT:     return !_lc ? "Buy Limit" : "buy limit";
      case ORDER_TYPE_BUY_STOP:      return !_lc ? "Buy Stop" : "buy stop";
      case ORDER_TYPE_SELL_LIMIT:    return !_lc ? "Sell Limit" : "sell limit";
      case ORDER_TYPE_SELL_STOP:     return !_lc ? "Sell Stop" : "sell stop";
      default:                       return !_lc ? "Unknown" : "unknown";
    }
  }
  string OrderTypeToString(bool _lc = false) {
    return OrderTypeToString(order.type, _lc);
  }

  /* OTHER METHODS */

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
