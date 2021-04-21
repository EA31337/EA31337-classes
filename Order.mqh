//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Implements class for managing orders.
 */

// Prevents processing this includes file for the second time.
#ifndef ORDER_MQH
#define ORDER_MQH

// Includes.
#include "Action.enum.h"
#include "Convert.mqh"
#include "Log.mqh"
#include "Order.enum.h"
#include "Order.struct.h"
#include "String.mqh"
#include "SymbolInfo.mqh"

/* Defines for backward compatibility. */

// Index in the order pool.
#ifndef SELECT_BY_POS
#define SELECT_BY_POS 0
#endif

// Index by the order ticket.
#ifndef SELECT_BY_TICKET
#define SELECT_BY_TICKET 1
#endif

#ifndef POSITION_TICKET
#define POSITION_TICKET 1
#endif

#ifndef ORDER_TICKET
#define ORDER_TICKET 1
#endif

#ifndef DEAL_TICKET
#define DEAL_TICKET 1
#endif

#ifndef ORDER_EXTERNAL_ID
// Order identifier in an external trading system (on the Exchange).
// Note: Required for backward compatibility in MQL4.
// @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties#enum_order_property_string
#define ORDER_EXTERNAL_ID ((ENUM_ORDER_PROPERTY_STRING)20)
#endif

#ifndef ORDER_REASON
// The reason or source for placing an order.
// Note: Required for backward compatibility in MQL4.
// @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
#define ORDER_REASON ((ENUM_ORDER_PROPERTY_INTEGER)23)
#endif

#ifndef __MQLBUILD__
// Defines.
// Mode constants.
// @see: https://docs.mql4.com/trading/orderselect
#define MODE_TRADES 0
#define MODE_HISTORY 1
#endif

/**
 * Class to provide methods to deal with the order.
 *
 * @see
 * - https://www.mql5.com/en/docs/trading/ordergetinteger
 * - https://www.mql5.com/en/articles/211
 */
class Order : public SymbolInfo {
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

 protected:
  // Struct variables.
  OrderParams oparams;
  OrderData odata;
  MqlTradeRequest orequest;           // Trade Request Structure.
  MqlTradeCheckResult oresult_check;  // Results of a Trade Request Check.
  MqlTradeResult oresult;             // Trade Request Result.
  // Ref<Log> logger;                    // Logger.

#ifdef __MQL5__
  // Used for order selection in MQL5.
  static unsigned long selected_ticket_id;
  static ENUM_ORDER_SELECT_TYPE selected_ticket_type;
#endif

 public:
  /**
   * Class constructors.
   */
  Order() {}
  Order(long _ticket_no) {
    odata.SetTicket(_ticket_no);
    Update();
  }
  Order(const MqlTradeRequest &_request, bool _send = true) {
    orequest = _request;
    if (_send) {
      if (!IsDummy()) {
        OrderSend();
      } else {
        OrderSendDummy();
      }
    }
  }
  Order(const MqlTradeRequest &_request, const OrderParams &_oparams, bool _send = true) {
    orequest = _request;
    oparams = _oparams;
    if (_send) {
      if (!IsDummy()) {
        OrderSend();
      } else {
        OrderSendDummy();
      }
    }
  }

  /**
   * Class copy constructors.
   */
  Order(const Order &_order) {
    oparams = _order.oparams;
    odata = _order.odata;
    orequest = _order.orequest;
    oresult_check = _order.oresult_check;
    oresult = _order.oresult;
  }

  /**
   * Class deconstructor.
   */
  ~Order() {}

  Log *Logger() { return logger.Ptr(); }

  /* Getters */

  /**
   * Get order's params.
   */
  OrderParams GetParams() const { return oparams; }

  /**
   * Get order's data.
   */
  OrderData GetData() const { return odata; }

  /**
   * Get order's request.
   */
  MqlTradeRequest GetRequest() { return orequest; }

  /**
   * Get order's result.
   */
  MqlTradeResult GetResult() { return oresult; }

  /**
   * Get order's check result.
   */
  MqlTradeCheckResult GetResultCheck() { return oresult_check; }

  /* Setters */

  /* State checkers */

  /**
   * Is order is open.
   */
  bool IsClosed() {
    if (odata.time_close == 0 && OrderSelect()) {
      odata.time_close = Order::OrderCloseTime();
    }
    return odata.time_close > 0;
  }

  /**
   * Is order closed.
   */
  bool IsOpen() { return !IsClosed(); }

  /**
   * Check whether order is active and open.
   */
  bool IsOrderOpen() {
    Update();
    return OrderOpenTime() > 0 && !(OrderCloseTime() > 0);
  }

  /**
   * Should order be closed.
   *
   * @return
   *   Returns true when order should be closed, otherwise false.
   */
  bool ShouldCloseOrder() {
    return oparams.HasCloseCondition() && Order::CheckCondition(oparams.cond_close, oparams.cond_close_args);
  }

  /* State checking */

  /**
   * Check whether order is selected and it is same as the class one.
   */
  bool IsSelected() {
    unsigned long ticket_id = Order::OrderTicket();
    bool is_selected;

    if (IsDummy()) {
      is_selected = true;
    } else {
      is_selected = (odata.ticket > 0 && ticket_id == odata.ticket);
    }

    ResetLastError();
    return is_selected;
  }
  bool IsSelectedDummy() {
    // @todo
    return false;
  }
  bool IsDummy() { return oparams.dummy; }

  /* Trade methods */

  /**
   * Gets allowed order filling mode.
   *
   * @docs
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#symbol_filling_mode
   */
  static ENUM_ORDER_TYPE_FILLING GetOrderFilling(const string _symbol) {
    // Default policy is used only for market orders (Buy and Sell), limit and stop limit orders
    // and only for the symbols with Market or Exchange execution.
    // In case of partial filling a market or limit order with remaining volume is not canceled but processed further.
    ENUM_ORDER_TYPE_FILLING _result = ORDER_FILLING_RETURN;
    const long _filling_mode = SymbolInfo::GetFillingMode(_symbol);
    if ((_filling_mode & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC) {
      // Execute a deal with the volume maximally available in the market within that indicated in the order.
      // In case the order cannot be filled completely, the available volume of the order will be filled, and the
      // remaining volume will be canceled. The possibility of using IOC orders is determined at the trade server.
      _result = ORDER_FILLING_IOC;
    } else if ((_filling_mode & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK) {
      // A deal can be executed only with the specified volume.
      // In MT4, orders are usually on an FOK basis in that you get a complete fill or nothing.
      // If the necessary amount of a financial instrument is currently unavailable in the market, the order will not be
      // executed. The required volume can be filled using several offers available on the market at the moment.
      _result = ORDER_FILLING_FOK;
    }
    return (_result);
  }

  /**
   * Gets order's filling mode.
   */
  ENUM_ORDER_TYPE_FILLING GetOrderFilling() {
    Update(ORDER_TYPE_FILLING);
    return odata.type_filling;
  }

  /**
   * Get allowed order filling modes.
   */
  static ENUM_ORDER_TYPE_FILLING GetOrderFilling(const string _symbol, const long _type) {
    const ENUM_SYMBOL_TRADE_EXECUTION _exe_mode =
        (ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_TRADE_EXEMODE);
    const long _filling_mode = SymbolInfo::GetFillingMode(_symbol);
    return ((_filling_mode == 0 || (_type >= ORDER_FILLING_RETURN) || ((_filling_mode & (_type + 1)) != _type + 1))
                ? (((_exe_mode == SYMBOL_TRADE_EXECUTION_EXCHANGE) || (_exe_mode == SYMBOL_TRADE_EXECUTION_INSTANT))
                       ? ORDER_FILLING_RETURN
                       : ((_filling_mode == SYMBOL_FILLING_IOC) ? ORDER_FILLING_IOC : ORDER_FILLING_FOK))
                : (ENUM_ORDER_TYPE_FILLING)_type);
  }

  /* MT ORDER METHODS */

  /* Order getters */

  /**
   * Returns close price of the currently selected order.
   */
  static double OrderClosePrice() {
#ifdef __MQL4__
    return ::OrderClosePrice();
#else  // __MQL5__
    // @docs https://www.mql5.com/en/docs/trading/HistoryDealGetDouble
    double _result = 0;
    unsigned long _ticket = Order::OrderTicket();
    if (HistorySelectByPosition(_ticket)) {
      for (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
        // https://www.mql5.com/en/docs/trading/historydealgetticket
        const unsigned long _deal_ticket = HistoryDealGetTicket(i);
        const ENUM_DEAL_ENTRY _deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(_deal_ticket, DEAL_ENTRY);
        if (_deal_entry == DEAL_ENTRY_OUT || _deal_entry == DEAL_ENTRY_OUT_BY) {
          _result = HistoryDealGetDouble(_deal_ticket, DEAL_PRICE);
          break;
        }
      }
    }
    return _result;
#endif
  }
  double GetClosePrice() { return IsClosed() ? odata.price_close : 0; }

  /**
   * Returns open time of the currently selected order.
   *
   * @see
   * - http://docs.mql4.com/trading/orderopentime
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static datetime OrderOpenTime() {
#ifdef __MQL4__
    // http://docs.mql4.com/trading/orderopentime
    return ::OrderOpenTime();
#else
    long _result = 0;
    unsigned long _ticket = Order::OrderTicket();
    if (HistorySelectByPosition(_ticket)) {
      for (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
        // https://www.mql5.com/en/docs/trading/historydealgetticket
        const unsigned long _deal_ticket = HistoryDealGetTicket(i);
        const ENUM_DEAL_ENTRY _deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(_deal_ticket, DEAL_ENTRY);
        if (_deal_entry == DEAL_ENTRY_IN) {
          _result = HistoryDealGetInteger(_deal_ticket, DEAL_TIME);
          break;
        }
      }
    }
    return (datetime)_result;
#endif
  }
  datetime GetOpenTime() {
    if (odata.time_open == 0) {
      OrderSelect();
      odata.time_open = Order::OrderOpenTime();
    }
    return odata.time_open;
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
#else  // __MQL5__
    // @docs https://www.mql5.com/en/docs/trading/historydealgetinteger
    long _result = 0;
    unsigned long _ticket = Order::OrderTicket();
    if (HistorySelectByPosition(_ticket)) {
      for (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
        // https://www.mql5.com/en/docs/trading/historydealgetticket
        const unsigned long _deal_ticket = HistoryDealGetTicket(i);
        const ENUM_DEAL_ENTRY _deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(_deal_ticket, DEAL_ENTRY);
        if (_deal_entry == DEAL_ENTRY_OUT || _deal_entry == DEAL_ENTRY_OUT_BY) {
          _result = HistoryDealGetInteger(_deal_ticket, DEAL_TIME);
          break;
        }
      }
    }
    return (datetime)_result;
#endif
  }
  datetime GetCloseTime() { return IsClosed() ? odata.time_close : 0; }

  /**
   * Returns comment of the currently selected order.
   *
   * @see:
   * - https://docs.mql4.com/trading/ordercomment
   * - https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
   */
  static string OrderComment() { return Order::OrderGetString(ORDER_COMMENT); }
  string GetComment() { return odata.comment; }

  /**
   * Returns calculated commission of the currently selected order.
   *
   */
  static double OrderCommission() {
#ifdef __MQL4__
    // https://docs.mql4.com/trading/ordercommission
    return ::OrderCommission();
#else  // __MQL5__
    double _result = 0;
    unsigned long _ticket = Order::OrderTicket();
    if (HistorySelectByPosition(_ticket)) {
      for (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
        // https://www.mql5.com/en/docs/trading/historydealgetticket
        const unsigned long _deal_ticket = HistoryDealGetTicket(i);
        _result += _deal_ticket > 0 ? HistoryDealGetDouble(_deal_ticket, DEAL_COMMISSION) : 0;
      }
    }
    return _result;
#endif
  }
  double GetCommission() {
    odata.commission = IsSelected() ? Order::OrderCommission() : odata.commission;
    return odata.commission;
  }

  /**
   * Returns total fees of the currently selected order.
   *
   */
  static double OrderTotalFees() {
#ifdef __MQL4__
    return Order::OrderCommission() - Order::OrderSwap();
#else  // __MQL5__
    double _result = 0;
    unsigned long _ticket = Order::OrderTicket();
    if (HistorySelectByPosition(_ticket)) {
      for (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
        // https://www.mql5.com/en/docs/trading/historydealgetticket
        const unsigned long _deal_ticket = HistoryDealGetTicket(i);
        if (_deal_ticket > 0) {
          _result += HistoryDealGetDouble(_deal_ticket, DEAL_COMMISSION);
          _result += HistoryDealGetDouble(_deal_ticket, DEAL_FEE);
          _result += HistoryDealGetDouble(_deal_ticket, DEAL_SWAP);
        }
      }
    }
    return _result;
#endif
  }
  double GetTotalFees() {
    if (!IsClosed()) {
      OrderSelect();
      odata.total_fees = Order::OrderTotalFees();
    }
    return odata.total_fees;
  }

  /**
   * Returns expiration date of the selected pending order.
   *
   * @see
   * - https://docs.mql4.com/trading/orderexpiration
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static datetime OrderExpiration() { return (datetime)Order::OrderGetInteger(ORDER_TIME_EXPIRATION); }
  datetime GetExpiration() { return odata.expiration; }

  /**
   * Returns amount of lots of the selected order.
   *
   * @see:
   * - https://docs.mql4.com/trading/orderlots
   * - https://www.mql5.com/en/docs/trading/ordergetdouble
   */
  static double OrderLots() {
#ifdef __MQL4__
    return ::OrderLots();
#else
    // @fixme: It returns 0.
    // @fixme: Error 69639.
    return Order::OrderGetDouble(ORDER_VOLUME_CURRENT);
#endif
  }
  double GetVolume() { return orequest.volume; }

  /**
   * Returns an identifying (magic) number of the currently selected order.
   *
   * @see
   * - http://docs.mql4.com/trading/ordermagicnumber
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static long OrderMagicNumber() { return Order::OrderGetInteger(ORDER_MAGIC); }
  unsigned long GetMagicNumber() { return orequest.magic; }

  /**
   * Returns open price of the currently selected order.
   *
   * @see
   * - http://docs.mql4.com/trading/orderopenprice
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   */
  static double OrderOpenPrice() { return Order::OrderGetDouble(ORDER_PRICE_OPEN); }
  double GetOpenPrice() { return odata.price_open; }

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
    // https://docs.mql4.com/trading/orderprofit
    return ::OrderProfit();
#else
    double _result = 0;
    unsigned long _ticket = Order::OrderTicket();
    if (HistorySelectByPosition(_ticket)) {
      for (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
        // https://www.mql5.com/en/docs/trading/historydealgetticket
        const unsigned long _deal_ticket = HistoryDealGetTicket(i);
        _result += _deal_ticket > 0 ? HistoryDealGetDouble(_deal_ticket, DEAL_PROFIT) : 0;
      }
    }
    return _result;
#endif
  }
  double GetProfit() {
    Update(ORDER_PRICE_CURRENT);
    return odata.profit;
  }

  /**
   * Returns stop loss value of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/orderstoploss
   */
  static double OrderStopLoss() { return Order::OrderGetDouble(ORDER_SL); }
  double GetStopLoss(bool _refresh = true) {
    long _osl_last_update = 0;
    if (_refresh && _osl_last_update < TimeCurrent()) {
      Update(ORDER_SL);
      _osl_last_update = TimeCurrent();
    }
    return odata.sl;
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
  static double OrderTakeProfit() { return Order::OrderGetDouble(ORDER_TP); }
  double GetTakeProfit(bool _refresh = true) {
    long _osl_last_update = 0;
    if (_refresh && _osl_last_update < TimeCurrent()) {
      Update(ORDER_TP);
      _osl_last_update = TimeCurrent();
    }
    return odata.tp;
  }

  /**
   * Returns SL/TP value of the currently selected order.
   */
  static double GetOrderSLTP(ENUM_ORDER_PROPERTY_DOUBLE _mode) {
    switch (_mode) {
      case ORDER_SL:
        return OrderStopLoss();
      case ORDER_TP:
        return OrderTakeProfit();
    }
    return NULL;
  }

  /**
   * Returns cumulative swap of the currently selected order.
   */
  static double OrderSwap() {
#ifdef __MQL4__
    // https://docs.mql4.com/trading/orderswap
    return ::OrderSwap();
#else
    double _result = 0;
    unsigned long _ticket = Order::OrderTicket();
    if (HistorySelectByPosition(_ticket)) {
      for (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
        // https://www.mql5.com/en/docs/trading/historydealgetticket
        const unsigned long _deal_ticket = HistoryDealGetTicket(i);
        _result += _deal_ticket > 0 ? HistoryDealGetDouble(_deal_ticket, DEAL_SWAP) : 0;
      }
    }
    return _result;
#endif
  }
  double GetSwap() {
    if (!IsClosed()) {
      OrderSelect();
      odata.swap = Order::OrderSwap();
    }
    return odata.swap;
  }

  /**
   * Returns symbol name of the currently selected order.
   *
   * @see
   * - https://docs.mql4.com/trading/ordersymbol
   * - https://www.mql5.com/en/docs/trading/positiongetstring
   */
  static string OrderSymbol() {
#ifdef __MQL4__
    return ::OrderSymbol();
#else
    return Order::OrderGetString(ORDER_SYMBOL);
#endif
  }
  string GetSymbol() { return orequest.symbol; }

  /**
   * Returns a ticket number of the currently selected order.
   *
   * It is a unique number assigned to each order.
   *
   * @see https://docs.mql4.com/trading/orderticket
   * @see https://www.mql5.com/en/docs/trading/ordergetticket
   */
  static unsigned long OrderTicket() {
#ifdef __MQL4__
    return ::OrderTicket();
#else
    return selected_ticket_id;
#endif
  }
  unsigned long GetTicket() const { return odata.ticket; }

  /**
   * Returns order operation type of the currently selected order.
   *
   * @see http://docs.mql4.com/trading/ordertype
   */
  static ENUM_ORDER_TYPE OrderType() {
#ifdef __MQL4__
    return (ENUM_ORDER_TYPE)::OrderType();
#else
    return (ENUM_ORDER_TYPE)Order::OrderGetInteger(ORDER_TYPE);
#endif
  }
  ENUM_ORDER_TYPE GetType() {
    if (odata.type < 0 && Select()) {
      Update(ORDER_TYPE);
    }
    return odata.type;
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
#ifdef __MQL4__
    return ORDER_TIME_GTC;
#else
    // @fixme
    return (ENUM_ORDER_TYPE_TIME)Order::OrderGetInteger(ORDER_TYPE_TIME);
#endif
  }

  /**
   * Returns the order position based on the ticket.
   *
   * It is set to an order as soon as it is executed.
   * Each executed order results in a deal that opens or modifies an already existing position.
   * The identifier of exactly this position is set to the executed order at this moment.
   */
  static unsigned long OrderGetPositionID() {
#ifdef __MQL4__
    unsigned long _ticket = ::OrderTicket();
    for (int _pos = 0; _pos < OrdersTotal(); _pos++) {
      if (::OrderSelect(_pos, SELECT_BY_POS, MODE_TRADES) && ::OrderTicket() == _ticket) {
        return _pos;
      }
    }
    return -1;
#else  // __MQL5__
    return Order::OrderGetInteger(ORDER_POSITION_ID);
#endif
  }
  unsigned long GetPositionID() {
#ifdef ORDER_POSITION_ID
    if (odata.position_id == 0) {
      OrderSelect();
      Update(ORDER_POSITION_ID);
    }
#endif
    return odata.position_id;
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
  static unsigned long OrderGetPositionBy() {
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
#else  // __MQL5__
    return Order::OrderGetInteger(ORDER_POSITION_BY_ID);
#endif
  }
  unsigned long GetOrderPositionBy() {
#ifdef ORDER_POSITION_BY_ID
    if (odata.position_by_id == 0) {
      OrderSelect();
      Update(ORDER_POSITION_BY_ID);
    }
#endif
    return odata.position_by_id;
  }

  /**
   * Returns the ticket of a position in the list of open positions.
   *
   * @see https://www.mql5.com/en/docs/trading/positiongetticket
   */
  unsigned long PositionGetTicket(int _index) {
#ifdef __MQL4__
    if (::OrderSelect(_index, SELECT_BY_POS, MODE_TRADES)) {
      return ::OrderTicket();
    }
    return -1;
#else  // __MQL5__
    return ::PositionGetTicket(_index);
#endif
  }

  /* Order manipulation */

  /**
   * Closes opened order.
   *
   * @docs
   * - https://docs.mql4.com/trading/orderclose
   * - https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions
   *
   * @return
   *   Returns true if successful, otherwise false.
   *   To get details about error, call the GetLastError() function.
   */
  static bool OrderClose(unsigned long _ticket,  // Unique number of the order ticket.
                         double _lots,           // Number of lots.
                         double _price,          // Closing price.
                         int _deviation,  // Maximal possible deviation/slippage from the requested price (in points).
                         color _arrow_color = CLR_NONE  // Color of the closing arrow on the chart.
  ) {
#ifdef __MQL4__
    return ::OrderClose((int)_ticket, _lots, _price, _deviation, _arrow_color);
#else
    if (::OrderSelect(_ticket) || ::PositionSelectByTicket(_ticket) || ::HistoryOrderSelect(_ticket)) {
      MqlTradeRequest _request = {0};
      MqlTradeCheckResult _result_check = {0};
      MqlTradeResult _result = {0};
      _request.action = TRADE_ACTION_DEAL;
      _request.position = ::PositionGetInteger(POSITION_TICKET);
      _request.symbol = ::PositionGetString(POSITION_SYMBOL);
      _request.type = NegateOrderType((ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE));
      _request.volume = _lots;
      _request.price = _price;
      _request.deviation = _deviation;
      return Order::OrderSend(_request, _result, _result_check, _arrow_color);
    }
    return false;
#endif
  }
  bool OrderClose(string _comment = "") {
    odata.ResetError();
    if (!OrderSelect()) {
      if (!OrderSelectHistory()) {
        odata.ProcessLastError();
        return false;
      }
    }
    MqlTradeRequest _request = {0};
    MqlTradeResult _result = {0};
    _request.action = TRADE_ACTION_DEAL;
    _request.comment = _comment;
    _request.deviation = orequest.deviation;
    _request.type = NegateOrderType(orequest.type);
    _request.position = oresult.deal;
    _request.price = SymbolInfo::GetCloseOffer(orequest.type);
    _request.symbol = orequest.symbol;
    _request.volume = orequest.volume;
    Order::OrderSend(_request, oresult, oresult_check);
    if (oresult.retcode == TRADE_RETCODE_DONE) {
      odata.SetTimeClose(DateTime::TimeTradeServer());             // For now, sets the current time.
      odata.SetPriceClose(SymbolInfo::GetCloseOffer(odata.type));  // For now, sets using the actual close price.
      odata.SetLastError(ERR_NO_ERROR);
      Update();
      return true;
    } else {
      odata.last_error = oresult.retcode;
      if (OrderSelect()) {
        if (IsClosed()) {
          Update();
        }
      }
    }
    return false;
  }

  bool OrderCloseDummy(string _comment = "") { return true; }

  /**
   * Closes a position by an opposite one.
   */
  static bool OrderCloseBy(long _ticket, long _opposite, color _color) {
#ifdef __MQL4__
    return ::OrderCloseBy((int)_ticket, (int)_opposite, _color);
#else
    if (::OrderSelect(_ticket) || ::PositionSelectByTicket(_ticket) || ::HistoryOrderSelect(_ticket)) {
      MqlTradeRequest _request = {0};
      MqlTradeCheckResult _result_check = {0};
      MqlTradeResult _result = {0};
      _request.action = TRADE_ACTION_CLOSE_BY;
      _request.position = ::PositionGetInteger(POSITION_TICKET);
      _request.position_by = _opposite;
      _request.symbol = ::PositionGetString(POSITION_SYMBOL);
      _request.type = NegateOrderType((ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE));
      _request.volume = ::PositionGetDouble(POSITION_VOLUME);
      return Order::OrderSend(_request, _result);
    }
    return false;
#endif
  }

  /**
   * Deletes previously opened pending order.
   *
   * @see: https://docs.mql4.com/trading/orderdelete
   */
  static bool OrderDelete(unsigned long _ticket, color _color = NULL) {
#ifdef __MQL4__
    return ::OrderDelete((int)_ticket, _color);
#else
    if (::OrderSelect(_ticket)) {
      MqlTradeRequest _request = {0};
      MqlTradeResult _result = {0};
      _request.action = TRADE_ACTION_REMOVE;
      _request.order = _ticket;
      return Order::OrderSend(_request, _result);
    }
    return false;
#endif
  }
  bool OrderDelete() { return Order::OrderDelete(GetTicket()); }

  /**
   * Modification of characteristics of the previously opened or pending orders.
   *
   * @see http://docs.mql4.com/trading/ordermodify
   */
  static bool OrderModify(unsigned long _ticket,        // Ticket of the position.
                          double _price,                // Price.
                          double _stoploss,             // Stop loss.
                          double _takeprofit,           // Take profit.
                          datetime _expiration,         // Expiration.
                          color _arrow_color = clrNONE  // Color of order.
  ) {
#ifdef __MQL4__
    return ::OrderModify((unsigned int)_ticket, _price, _stoploss, _takeprofit, _expiration, _arrow_color);
#else
    if (!::PositionSelectByTicket(_ticket)) {
      return false;
    }
    MqlTradeRequest _request = {0};
    MqlTradeResult _result = {0};
    _request.action = TRADE_ACTION_SLTP;
    //_request.type = PositionTypeToOrderType();
    _request.position = _ticket;  // Position ticket.
    _request.symbol = ::PositionGetString(POSITION_SYMBOL);
    _request.sl = _stoploss;
    _request.tp = _takeprofit;
    _request.expiration = _expiration;
    return Order::OrderSend(_request, _result);
#endif
  }
  bool OrderModify(double _sl, double _tp, double _price = 0, datetime _expiration = 0) {
    if (odata.time_close > 0) {
      // Ignore change for already closed orders.
      return false;
    } else if (_sl == odata.sl && _tp == odata.tp && _expiration == odata.expiration) {
      // Ignore change for the same values.
      return false;
    }
    bool _result = Order::OrderModify(odata.ticket, _price, _sl, _tp, _expiration);
    long _last_error = GetLastError();
    if (_result && OrderSelect()) {
      // Updating expected values.
      odata.SetStopLoss(_sl);
      odata.SetProfitTake(_tp);
      // @todo: Add if condition.
      // Update(ORDER_PRICE_OPEN); // For pending order only.
      // Update(ORDER_TIME_EXPIRATION); // For pending order only.
      ResetLastError();
    } else {
      if (OrderSelect()) {
        if (IsClosed()) {
          Update();
        } else {
          Logger().Warning(StringFormat("Failed to modify order (#%d/p:%g/sl:%g/tp:%g/code:%d).",
                                        odata.ticket, _price, _sl, _tp, _last_error),
                           __FUNCTION_LINE__, ToCSV());
          Update(ORDER_SL);
          Update(ORDER_TP);
          // TODO: Update(ORDER_PRI)
          // @todo: Add if condition.
          // Update(ORDER_PRICE_OPEN); // For pending order only.
          // Update(ORDER_TIME_EXPIRATION); // For pending order only.
        }
        ResetLastError();
        _result = false;
      } else {
        Logger().Error(StringFormat("Error: %d! Failed to modify non-existing order (#%d/p:%g/sl:%g/tp:%g).",
                                    _last_error, odata.ticket, _price, _sl, _tp),
                       __FUNCTION_LINE__, ToCSV());
      }
    }
    return _result;
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
  static long OrderSend(string _symbol,               // Symbol.
                        int _cmd,                     // Operation.
                        double _volume,               // Volume.
                        double _price,                // Price.
                        unsigned long _deviation,     // Deviation.
                        double _stoploss,             // Stop loss.
                        double _takeprofit,           // Take profit.
                        string _comment = NULL,       // Comment.
                        unsigned long _magic = 0,     // Magic number.
                        datetime _expiration = 0,     // Pending order expiration.
                        color _arrow_color = clrNONE  // Color.
  ) {
#ifdef __MQL4__
    return ::OrderSend(_symbol, _cmd, _volume, _price, (int)_deviation, _stoploss, _takeprofit, _comment,
                       (unsigned int)_magic, _expiration, _arrow_color);
#else
    // @docs
    // - https://www.mql5.com/en/articles/211
    // - https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions
    MqlTradeRequest _request = {0};  // Query structure.
    MqlTradeResult _result = {0};    // Structure of the result.
    _request.action = TRADE_ACTION_DEAL;
    _request.symbol = _symbol;
    _request.volume = _volume;
    _request.price = _price;
    _request.sl = _stoploss;
    _request.tp = _takeprofit;
    _request.deviation = _deviation;
    _request.comment = _comment;
    _request.magic = _magic;
    _request.expiration = _expiration;
    _request.type = (ENUM_ORDER_TYPE)_cmd;
    _request.type_filling = _request.type_filling ? _request.type_filling : GetOrderFilling(_symbol);
    if (!Order::OrderSend(_request, _result)) {
      return -1;
    }
    return (long)_result.order;
#endif
  }
  static bool OrderSend(const MqlTradeRequest &_request, MqlTradeResult &_result, MqlTradeCheckResult &_check_result,
                        color _color = clrNONE) {
#ifdef __MQL4__
    // Convert Trade Request Structure to function parameters.
    _result.retcode = TRADE_RETCODE_ERROR;
    if (_request.position > 0) {
      if (_request.action == TRADE_ACTION_SLTP) {
        if (Order::OrderModify(_request.position, _request.price, _request.sl, _request.tp, _request.expiration,
                               _color)) {
          // @see: https://www.mql5.com/en/docs/constants/structures/mqltraderesult
          _result.ask = SymbolInfo::GetAsk(_request.symbol);  // The current market Bid price (requote price).
          _result.bid = SymbolInfo::GetBid(_request.symbol);  // The current market Ask price (requote price).
          _result.order = _request.position;                  // Order ticket.
          _result.price = _request.price;                     // Deal price, confirmed by broker.
          _result.volume = _request.volume;                   // Deal volume, confirmed by broker (@fixme?).
          _result.retcode = TRADE_RETCODE_DONE;
          //_result.comment = TODO; // The broker comment to operation (by default it is filled by description of trade
          // server return code).
        }
      } else if (_request.action == TRADE_ACTION_CLOSE_BY) {
        if (Order::OrderCloseBy(_request.position, _request.position_by, _color)) {
          // @see: https://www.mql5.com/en/docs/constants/structures/mqltraderesult
          _result.ask = SymbolInfo::GetAsk(_request.symbol);  // The current market Bid price (requote price).
          _result.bid = SymbolInfo::GetBid(_request.symbol);  // The current market Ask price (requote price).
          _result.retcode = TRADE_RETCODE_DONE;
        }
      } else if (_request.action == TRADE_ACTION_DEAL || _request.action == TRADE_ACTION_REMOVE) {
        // @see: https://docs.mql4.com/trading/orderclose
        if (Order::OrderClose(_request.position, _request.volume, _request.price, (int)_request.deviation, _color)) {
          // @see: https://www.mql5.com/en/docs/constants/structures/mqltraderesult
          _result.ask = SymbolInfo::GetAsk(_request.symbol);  // The current market Bid price (requote price).
          _result.bid = SymbolInfo::GetBid(_request.symbol);  // The current market Ask price (requote price).
          _result.order = _request.position;                  // Order ticket.
          _result.price = _request.price;                     // Deal price, confirmed by broker.
          _result.volume = _request.volume;                   // Deal volume, confirmed by broker (@fixme?).
          _result.retcode = TRADE_RETCODE_DONE;
          //_result.comment = TODO; // The broker comment to operation (by default it is filled by description of trade
          // server return code).
        }
      }
    } else if (_request.action == TRADE_ACTION_DEAL) {
      // @see: https://docs.mql4.com/trading/ordersend
      _result.order = Order::OrderSend(_request.symbol,      // Symbol.
                                       _request.type,        // Operation.
                                       _request.volume,      // Volume.
                                       _request.price,       // Price.
                                       _request.deviation,   // Deviation.
                                       _request.sl,          // Stop loss.
                                       _request.tp,          // Take profit.
                                       _request.comment,     // Comment.
                                       _request.magic,       // Magic number.
                                       _request.expiration,  // Pending order expiration.
                                       _color                // Color.

      );

      _result.retcode = _result.order > 0 ? TRADE_RETCODE_DONE : GetLastError();

      if (_request.order > 0) {
        // @see: https://www.mql5.com/en/docs/constants/structures/mqltraderesult
        _result.ask = SymbolInfo::GetAsk(_request.symbol);  // The current market Bid price (requote price).
        _result.bid = SymbolInfo::GetBid(_request.symbol);  // The current market Ask price (requote price).
        _result.price = _request.price;                     // Deal price, confirmed by broker.
        _result.volume = _request.volume;                   // Deal volume, confirmed by broker (@fixme?).
        //_result.comment = TODO; // The broker comment to operation (by default it is filled by description of trade
        // server return code).
      }
    }

    return _result.retcode == TRADE_RETCODE_DONE;
#else
    // The trade requests go through several stages of checking on a trade server.
    // First of all, it checks if all the required fields of the request parameter are filled out correctly.
    if (!OrderCheck(_request, _check_result)) {
      // If funds are not enough for the operation,
      // or parameters are filled out incorrectly, the function returns false.
      // In order to obtain information about the error, call the GetLastError() function.
      // @docs
      // - https://www.mql5.com/en/docs/trading/ordercheck
      // - https://www.mql5.com/en/docs/constants/errorswarnings/enum_trade_return_codes
      // - https://www.mql5.com/en/docs/constants/structures/mqltradecheckresult
#ifdef __debug__
      PrintFormat("%s: Error %d: %s", __FUNCTION_LINE__, _check_result.retcode,
                  Terminal::GetErrorText(_check_result.retcode));
#endif
      _result.retcode = _check_result.retcode;
      return false;
    }
    // In case of a successful basic check of structures (index checking) returns true.
    // However, this is not a sign of successful execution of a trade operation.
    // If there are no errors, the server accepts the order for further processing.
    // The check results are placed to the fields of the MqlTradeCheckResult structure.
    // For a more detailed description of the function execution result,
    // analyze the fields of the result structure.
    // In order to obtain information about the error, call the GetLastError() function.
    // --
    // @docs
    // - https://www.mql5.com/en/docs/trading/ordersend
    // - https://www.mql5.com/en/docs/constants/errorswarnings/enum_trade_return_codes
    // --
    // Sends trade requests to a server.
    return ::OrderSend(_request, _result);
    // The function execution result is placed to structure MqlTradeResult,
    // whose retcode field contains the trade server return code.
    // In order to obtain information about the error, call the GetLastError() function.
#endif
  }
  static bool OrderSend(const MqlTradeRequest &_request, MqlTradeResult &_result) {
    MqlTradeCheckResult _check_result = {0};
    return Order::OrderSend(_request, _result, _check_result);
  }
  long OrderSend() {
    long _result = false;
    odata.ResetError();
#ifdef __MQL4__
    _result = Order::OrderSend(orequest.symbol,      // Symbol.
                               orequest.type,        // Operation.
                               orequest.volume,      // Volume.
                               orequest.price,       // Price.
                               orequest.deviation,   // Deviation (in pts).
                               orequest.sl,          // Stop loss.
                               orequest.tp,          // Take profit.
                               orequest.comment,     // Comment.
                               orequest.magic,       // Magic number.
                               orequest.expiration,  // Pending order expiration.
                               oparams.color_arrow   // Color.
    );
    oresult.retcode = _result == -1 ? TRADE_RETCODE_ERROR : TRADE_RETCODE_DONE;
#else
    orequest.type_filling = orequest.type_filling ? orequest.type_filling : GetOrderFilling(orequest.symbol);
    // The trade requests go through several stages of checking on a trade server.
    // First of all, it checks if all the required fields of the request parameter are filled out correctly.
    if (!OrderCheck(orequest, oresult_check)) {
      // If funds are not enough for the operation,
      // or parameters are filled out incorrectly, the function returns false.
      // In order to obtain information about the error, call the GetLastError() function.
      // @see: https://www.mql5.com/en/docs/trading/ordercheck
      odata.last_error = oresult_check.retcode;
      _result = -1;
    } else {
      // If there are no errors, the server accepts the order for further processing.
      // The check results are placed to the fields of the MqlTradeCheckResult structure.
      // For a more detailed description of the function execution result,
      // analyze the fields of the result structure.
      // In order to obtain information about the error, call the GetLastError() function.
    }
    // Sends trade requests to a server.
    if (::OrderSend(orequest, oresult)) {
      // In case of a successful basic check of structures (index checking) returns true.
      // However, this is not a sign of successful execution of a trade operation.
      // @see: https://www.mql5.com/en/docs/trading/ordersend
      // In order to obtain information about the error, call the GetLastError() function.
      odata.ticket = oresult.order;
      _result = (long)oresult.order;
    } else {
      // The function execution result is placed to structure MqlTradeResult,
      // whose retcode field contains the trade server return code.
      // @see: https://www.mql5.com/en/docs/constants/errorswarnings/enum_trade_return_codes
      // In order to obtain information about the error, call the GetLastError() function.
      _result = -1;
    }
    odata.last_error = oresult.retcode;
#endif
    if (_result >= 0) {
#ifdef __MQL4__
      // In MQL4 there is no difference in selecting various types of tickets.
      oresult.deal = _result;
      oresult.order = _result;
#endif
      // Update order data values.
      odata.ticket = _result;
      odata.symbol = orequest.symbol;
      odata.type = orequest.type;
      odata.volume = orequest.volume;
      odata.price_open = orequest.price;
      odata.sl = orequest.sl;
      odata.tp = orequest.tp;
      odata.comment = orequest.comment;
      odata.magic = orequest.magic;
      odata.expiration = orequest.expiration;
      Update();
      ResetLastError();
    }
    return _result;
  }

  /**
   * Executes dummy trade operation by sending the fake request.
   *
   * @return
   * Returns number of the fake ticket assigned to the order.
   */
  long OrderSendDummy() {
    static int _dummy_order_id = 0;
    odata.ResetError();
    orequest.type_filling = orequest.type_filling ? orequest.type_filling : GetOrderFilling(orequest.symbol);
    if (!OrderCheckDummy(orequest, oresult_check)) {
      // If funds are not enough for the operation,
      // or parameters are filled out incorrectly, the function returns false.
      odata.last_error = oresult_check.retcode;
      return -1;
    }
    // Process dummy request.
    oresult.ask = SymbolInfo::GetAsk(orequest.symbol);  // The current market Bid price (requote price).
    oresult.bid = SymbolInfo::GetBid(orequest.symbol);  // The current market Ask price (requote price).
    oresult.order = orequest.position;                  // Order ticket.
    oresult.price = orequest.price;                     // Deal price, confirmed by broker.
    oresult.volume = orequest.volume;                   // Deal volume, confirmed by broker (@fixme?).
    oresult.retcode = TRADE_RETCODE_DONE;               // Mark trade operation as done.
    oresult.comment = orequest.comment;                 // Order comment.
    oresult.order = ++_dummy_order_id;                  // Assign sequential order id. Starts from 1.
    odata.ticket = oresult.order;
    UpdateDummy();
    odata.last_error = oresult.retcode;

    // @todo Register order in a static dictionary order_id -> order for further select.

    return (long)oresult.order;
  }

  /**
   * Checks if there are enough money to execute a required trade operation.
   *
   * @param
   *   _request MqlTradeRequest
   *     Pointer to the structure of the MqlTradeRequest type, which describes the required trade action.
   *   _result_check MqlTradeCheckResult
   *     Pointer to the structure of the MqlTradeCheckResult type, to which the check result will be placed.
   *
   * @return
   *   If funds are not enough for the operation, or parameters are filled out incorrectly, the function returns false.
   *   In case of a successful basic check of structures (check of pointers), it returns true.
   *
   * @docs https://www.mql5.com/en/docs/trading/ordercheck
   */
  static bool OrderCheck(const MqlTradeRequest &_request, MqlTradeCheckResult &_result_check) {
#ifdef __MQL4__
    return OrderCheckDummy(_request, _result_check);
#else
    return ::OrderCheck(_request, _result_check);
#endif
  }
  static bool OrderCheckDummy(const MqlTradeRequest &_request, MqlTradeCheckResult &_result_check) {
    _result_check.retcode = ERR_NO_ERROR;
    if (_request.volume <= 0) {
      _result_check.retcode = TRADE_RETCODE_INVALID_VOLUME;
    }
    if (_request.price <= 0) {
      _result_check.retcode = TRADE_RETCODE_INVALID_PRICE;
    }
    // @todo
    // - https://www.mql5.com/en/docs/constants/errorswarnings/enum_trade_return_codes
    // _result_check.balance = Account::Balance() - something; // Balance value that will be after the execution of the
    // trade operation. equity;              // Equity value that will be after the execution of the trade operation.
    // profit;              // Value of the floating profit that will be after the execution of the trade operation.
    // margin;              // Margin required for the trade operation.
    // margin_free;         // Free margin that will be left after the execution of the trade operation.
    // margin_level;        // Margin level that will be set after the execution of the trade operation.
    // comment;             // Comment to the reply code (description of the error).
    if (_result_check.retcode != ERR_NO_ERROR) {
      // SetUserError(???);
    }
    return _result_check.retcode == ERR_NO_ERROR;
  }

  /* Order selection methods */

  /**
   * Select an order to work with.
   *
   * The function selects an order for further processing.
   *
   *  @see http://docs.mql4.com/trading/orderselect
   */
  static bool OrderSelect(unsigned long _index, int select, int pool = MODE_TRADES) {
    ResetLastError();
#ifdef __MQL4__
    return ::OrderSelect((int)_index, select, pool);
#else
    bool _result = false;
    if (select == SELECT_BY_POS) {
      if (pool == MODE_TRADES) {
        if (::PositionGetTicket((int)_index)) {
          selected_ticket_type = ORDER_SELECT_TYPE_POSITION;
        } else if (::OrderGetTicket((int)_index)) {
          selected_ticket_type = ORDER_SELECT_TYPE_ACTIVE;
        } else {
          selected_ticket_type = ORDER_SELECT_TYPE_NONE;
          selected_ticket_id = 0;
        }
      } else if (pool == MODE_HISTORY) {
        // The HistoryOrderGetTicket(_index) return the ticket of the historical order, by its _index from the cache of
        // the historical orders (not from the terminal base!). The obtained ticket can be used in the
        // HistoryOrderSelect(ticket) function, which clears the cache and re-fill it with only one order, in the
        // case of success. Recall that the value, returned from HistoryOrdersTotal() depends on the number of orders
        // in the cache.
        unsigned long _ticket_id = HistoryOrderGetTicket((int)_index);
        if (_ticket_id != 0) {
          selected_ticket_type = ORDER_SELECT_TYPE_HISTORY;
        } else if (::HistoryOrderSelect(_ticket_id)) {
          selected_ticket_type = ORDER_SELECT_TYPE_HISTORY;
        } else {
          selected_ticket_type = ORDER_SELECT_TYPE_NONE;
          selected_ticket_id = 0;
        }

        selected_ticket_id = selected_ticket_type == ORDER_SELECT_TYPE_NONE ? 0 : _ticket_id;
      }
    } else if (select == SELECT_BY_TICKET) {
      ResetLastError();
      if (::OrderSelect(_index) && GetLastError() == ERR_SUCCESS) {
        selected_ticket_type = ORDER_SELECT_TYPE_ACTIVE;
      } else {
        ResetLastError();
        if (::PositionSelectByTicket(_index) && GetLastError() == ERR_SUCCESS) {
          selected_ticket_type = ORDER_SELECT_TYPE_POSITION;
        } else {
          ResetLastError();
          if (::HistoryOrderSelect(_index) && GetLastError() == ERR_SUCCESS) {
            selected_ticket_type = ORDER_SELECT_TYPE_HISTORY;
          } else {
            ResetLastError();
            if (::HistoryDealSelect(_index) && GetLastError() == ERR_SUCCESS) {
              selected_ticket_type = ORDER_SELECT_TYPE_DEAL;
            } else {
              selected_ticket_type = ORDER_SELECT_TYPE_NONE;
              selected_ticket_id = 0;
            }
          }
        }
      }

      selected_ticket_id = selected_ticket_type == ORDER_SELECT_TYPE_NONE ? 0 : _index;
    } else {
#ifdef __debug__
      PrintFormat("%s: Possible values for 'select' parameters are: SELECT_BY_POS or SELECT_BY_HISTORY.",
                  __FUNCTION_LINE__);
#endif
    }
    _result = selected_ticket_type != ORDER_SELECT_TYPE_NONE;

    if (_result) {
      ResetLastError();
    }
    return _result;
#endif
  }

  /**
   * Tries to select an order to work with.
   *
   * The function selects an order for further processing.

   * Same as OrderSelect(), it will just perform ResetLastError().
   *
   * @see http://docs.mql4.com/trading/orderselect
   */
  static bool TryOrderSelect(unsigned long _index, int select, int pool = MODE_TRADES) {
    bool result = OrderSelect(_index, select, pool);

    ResetLastError();

    return result;
  }

  static bool OrderSelectByTicket(unsigned long _ticket) {
    return Order::OrderSelect(_ticket, SELECT_BY_TICKET, MODE_TRADES) ||
           Order::OrderSelect(_ticket, SELECT_BY_TICKET, MODE_HISTORY);
  }

  static bool TryOrderSelectByTicket(unsigned long _ticket) {
    return Order::TryOrderSelect(_ticket, SELECT_BY_TICKET, MODE_TRADES) ||
           Order::TryOrderSelect(_ticket, SELECT_BY_TICKET, MODE_HISTORY);
  }

  bool OrderSelect() { return !IsSelected() ? Order::OrderSelectByTicket(odata.ticket) : true; }
  bool TryOrderSelect() { return !IsSelected() ? Order::TryOrderSelectByTicket(odata.ticket) : true; }
  bool OrderSelectHistory() { return OrderSelect(odata.ticket, MODE_HISTORY); }

  /* Setters */

  /**
   * Update values of the current order.
   */
  bool Update() {
    bool _result = true;
    if (odata.last_update + oparams.refresh_rate > TimeCurrent()) {
      return false;
    }
    odata.ResetError();
    if (!OrderSelect()) {
      SetUserError(ERR_USER_ITEM_NOT_FOUND);
      return false;
    }
    odata.ResetError();

    // IsOpen() could end up with "Position not found" error.
    ResetLastError();

    // Checks if order is updated for the first time.
    bool _is_init = odata.price_open == 0 || odata.time_open == 0;

    // Update integer values.
    if (_is_init) {
      // Some values needs to be updated only once.
      // Update integer values.
      _result &= Update(ORDER_MAGIC);
      _result &= Update(ORDER_TIME_SETUP);
      _result &= Update(ORDER_TIME_SETUP_MSC);
      _result &= Update(ORDER_TYPE);
#ifdef ORDER_POSITION_ID
      _result &= Update(ORDER_POSITION_ID);
#endif
#ifdef ORDER_POSITION_BY_ID
      _result &= Update(ORDER_POSITION_BY_ID);
#endif
      // Update double values.
      _result &= Update(ORDER_PRICE_OPEN);
      // Update string values.
      _result &= Update(ORDER_SYMBOL);
      _result &= Update(ORDER_COMMENT);
    } else {
      // Updates current close price.
      odata.price_close = Order::OrderClosePrice();
      // Update integer values.
      // _result &= Update(ORDER_TIME_EXPIRATION); // @fixme: Error 69539
      // _result &= Update(ORDER_STATE); // @fixme: Error 69539
      // _result &= Update(ORDER_TYPE_TIME); // @fixme: Error 69539
      // _result &= Update(ORDER_TYPE_FILLING); // @fixme: Error 69539
      // Update double values.
      // _result &= Update(ORDER_VOLUME_INITIAL); // @fixme: false
      // _result &= Update(ORDER_VOLUME_CURRENT); // @fixme: Error 69539
    }

    // Updates whether order is open or closed.
    if (odata.time_close == 0) {
      // Updates close time.
      odata.time_close = Order::OrderCloseTime();
    }

    if (IsOpen()) {
      // Update values for open orders only.
      _result &= Update(ORDER_PRICE_CURRENT);
      _result &= Update(ORDER_SL);
      _result &= Update(ORDER_TP);
    }
    //} else if (IsPending())
    // _result &= Update(ORDER_PRICE_STOPLIMIT); // @fixme: Error 69539

    // Get last error.
    int _last_error = GetLastError();
    // TODO
    // odata.SetTicket(Order::GetTicket());
    // order.filling     = GetOrderFilling();          // Order execution type.
    // order.comment     = new String(OrderComment()); // Order comment.
    // order.position    = OrderGetPositionID();       // Position ticket.
    // order.position_by = OrderGetPositionBy();       // The ticket of an opposite position.

    // Process conditions.
    if (!_is_init) {
      ProcessConditions();
    }

    if (!_result || _last_error > ERR_NO_ERROR) {
      if (_last_error > ERR_NO_ERROR && _last_error != 4014) {  // @fixme: In MT4 (why 4014?).
        Logger().Warning(StringFormat("Update failed! Error: %d", _last_error), __FUNCTION_LINE__);
      }
      odata.last_update = TimeCurrent();
      odata.ProcessLastError();
      ResetLastError();
    }
    return _result && _last_error == ERR_NO_ERROR;
  }

  /**
   * Update values of the current dummy order.
   */
  bool UpdateDummy() {
    if (odata.last_update + oparams.refresh_rate > TimeCurrent()) {
      return false;
    }
    odata.ResetError();
    if (!OrderSelect()) {
      return false;
    }
    // Process conditions.
    ProcessConditions();

    UpdateDummy(ORDER_SYMBOL);
    UpdateDummy(ORDER_PRICE_OPEN);
    UpdateDummy(ORDER_VOLUME_CURRENT);

    if (IsOpen() || true) {  // @fixit
      // Update values for open orders only.
      UpdateDummy(ORDER_SL);
      UpdateDummy(ORDER_TP);
      UpdateDummy(ORDER_PRICE_CURRENT);
    }

    odata.profit = oresult.bid - oresult.ask;

    // @todo: More UpdateDummy(XXX);

    odata.ResetError();
    odata.last_update = TimeCurrent();
    odata.ProcessLastError();
    return GetLastError() == ERR_NO_ERROR;
  }

  /**
   * Update specific double value of the current order.
   */
  bool UpdateDummy(ENUM_ORDER_PROPERTY_DOUBLE property_id) {
    bool _result = false;
    double _value = WRONG_VALUE;
    ResetLastError();
    switch (property_id) {
      case ORDER_PRICE_CURRENT:
        odata.SetPriceCurrent(SymbolInfo::GetAsk(orequest.symbol));
        switch (odata.type) {
          case ORDER_TYPE_BUY:
          case ORDER_TYPE_BUY_LIMIT:
          case ORDER_TYPE_BUY_STOP:
#ifndef __MQL4__
          case ORDER_TYPE_BUY_STOP_LIMIT:
#endif
            if (odata.tp != 0.0 && odata.price_current > odata.tp) {
              // Take-Profit buy orders sent when the market price drops below their trigger price.
              OrderCloseDummy();
            } else if (odata.sl != 0.0 && odata.price_current < odata.sl) {
              // Stop-loss buy orders are sent when the market price exceeds their trigger price.
              OrderCloseDummy();
            }
            break;
          case ORDER_TYPE_SELL:
          case ORDER_TYPE_SELL_LIMIT:
          case ORDER_TYPE_SELL_STOP:
#ifndef __MQL4__
          case ORDER_TYPE_SELL_STOP_LIMIT:
#endif
            if (odata.tp != 0.0 && odata.price_current > odata.tp) {
              // Take-profit sell orders are sent when the market price exceeds their trigger price.
              OrderCloseDummy();
            } else if (odata.sl != 0.0 && odata.price_current < odata.sl) {
              // Stop-loss sell orders are sent when the market price drops below their trigger price.
              OrderCloseDummy();
            }
            break;
        }
        break;
      case ORDER_PRICE_OPEN:
        odata.SetPriceOpen(SymbolInfo::GetBid(orequest.symbol));
        break;
      case ORDER_VOLUME_CURRENT:
        odata.SetVolume(orequest.volume);
        break;
      case ORDER_SL:
        odata.SetStopLoss(orequest.sl);
        break;
      case ORDER_TP:
        odata.SetProfitTake(orequest.tp);
        break;
        break;
    }

    return true;
  }

  /**
   * Update specific integer value of the current order.
   */
  bool UpdateDummy(ENUM_ORDER_PROPERTY_INTEGER property_id) {
    bool _result = false;
    long _value = WRONG_VALUE;
    ResetLastError();
    switch (property_id) {
      case ORDER_MAGIC:
        odata.SetMagicNo(orequest.magic);
        break;
    }

    return _result && GetLastError() == ERR_NO_ERROR;
  }

  /**
   * Update specific string value of the current order.
   */
  bool UpdateDummy(ENUM_ORDER_PROPERTY_STRING property_id) {
    switch (property_id) {
      case ORDER_SYMBOL:
        odata.SetSymbol(orequest.symbol);
        break;
      case ORDER_COMMENT:
        break;
    }

    return true;
  }

  /**
   * Update specific double value of the current order.
   */
  bool Update(ENUM_ORDER_PROPERTY_DOUBLE property_id) {
    bool _result = false;
    double _value = WRONG_VALUE;
    ResetLastError();
    switch (property_id) {
      case ORDER_PRICE_CURRENT:
        _result = Order::OrderGetDouble(ORDER_PRICE_CURRENT, _value);
        if (_result) {
          odata.SetPriceCurrent(_value);
        }
        break;
      case ORDER_PRICE_OPEN:
        _result = Order::OrderGetDouble(ORDER_PRICE_OPEN, _value);
        if (_result) {
          odata.SetPriceOpen(_value);
        }
        break;
      case ORDER_PRICE_STOPLIMIT:
        _result = Order::OrderGetDouble(ORDER_PRICE_STOPLIMIT, _value);
        if (_result) {
          odata.SetPriceStopLimit(_value);
        }
        break;
      case ORDER_SL:
        _result = Order::OrderGetDouble(ORDER_SL, _value);
        if (_result) {
          if (_value == 0) {
            // @fixme
            _result = Order::OrderGetDouble(ORDER_SL, _value);
          }
          odata.SetStopLoss(_value);
        }
        break;
      case ORDER_TP:
        _result = Order::OrderGetDouble(ORDER_TP, _value);
        if (_result) {
          odata.SetProfitTake(_value);
        }
        break;
      case ORDER_VOLUME_CURRENT:
        _result = Order::OrderGetDouble(ORDER_VOLUME_CURRENT, _value);
        if (_result) {
          odata.SetVolume(_value);
        }
        break;
      default:
        return false;
    }
    return _result && GetLastError() == ERR_NO_ERROR;
  }

  /**
   * Update specific integer value of the current order.
   */
  bool Update(ENUM_ORDER_PROPERTY_INTEGER property_id) {
    bool _result = false;
    long _value = WRONG_VALUE;
    ResetLastError();
    switch (property_id) {
      case ORDER_MAGIC:
        _result = Order::OrderGetInteger(ORDER_MAGIC, _value);
        if (_result) {
          odata.SetMagicNo(_value);
        }
        break;
#ifdef ORDER_POSITION_ID
      case ORDER_POSITION_ID:
        _result = Order::OrderGetInteger(ORDER_POSITION_ID, _value);
        if (_result) {
          odata.position_id = _value;
        }
        break;
#endif
#ifdef ORDER_POSITION_BY_ID
      case ORDER_POSITION_BY_ID:
        _result = Order::OrderGetInteger(ORDER_POSITION_BY_ID, _value);
        if (_result) {
          odata.position_by_id = _value;
        }
        break;
#endif
      case (ENUM_ORDER_PROPERTY_INTEGER)ORDER_REASON:
        _result = Order::OrderGetInteger((ENUM_ORDER_PROPERTY_INTEGER)ORDER_REASON, _value);
        if (_result) {
          odata.SetReason(_value);
        }
        break;
      case ORDER_STATE:
        _result = Order::OrderGetInteger(ORDER_STATE, _value);
        if (_result) {
          odata.SetState(_value);
        }
        break;
      case ORDER_TIME_EXPIRATION:
        _result = Order::OrderGetInteger(ORDER_TIME_EXPIRATION, _value);
        if (_result) {
          odata.SetExpiration(_value);
        }
        break;
      // @wtf: Same value as ORDER_TICKET?!
      case ORDER_TIME_DONE:
        _result = Order::OrderGetInteger(ORDER_TIME_DONE, _value);
        if (_result) {
          odata.SetTimeOpen(_value);
        }
        break;
      case ORDER_TIME_SETUP:  // Note: In MT5 it conflicts with ORDER_TICKET.
        // Order setup time.
        _result = Order::OrderGetInteger(ORDER_TIME_SETUP, _value);
        if (_result) {
          odata.SetTimeOpen(_value);
        }
        break;
      case ORDER_TIME_SETUP_MSC:
        // The time of placing an order for execution in milliseconds since 01.01.1970.
        _result = Order::OrderGetInteger(ORDER_TIME_SETUP_MSC, _value);
        if (_result) {
          odata.SetTimeOpen(_value / 1000);
        }
        break;
      case ORDER_TYPE:
        _result = Order::OrderGetInteger(ORDER_TYPE, _value);
        if (_result) {
          odata.SetType(_value);
        }
        break;
      case ORDER_TYPE_FILLING:
        _result = Order::OrderGetInteger(ORDER_TYPE_FILLING, _value);
        if (_result) {
          odata.SetTypeFilling(_value);
        }
        break;
      case ORDER_TYPE_TIME:
        _result = Order::OrderGetInteger(ORDER_TYPE_TIME, _value);
        if (_result) {
          odata.SetTypeTime(_value);
        }
        break;
      default:
        return false;
    }
    if (!_result) {
      int _last_error = GetLastError();
      logger.Ptr().Error("Error updating order property!", __FUNCTION_LINE__,
                         StringFormat("Code: %d, Msg: %s", _last_error, Terminal::GetErrorText(_last_error)));
    }
    return _result && GetLastError() == ERR_NO_ERROR;
  }

  /**
   * Update specific string value of the current order.
   */
  bool Update(ENUM_ORDER_PROPERTY_STRING property_id) {
    switch (property_id) {
      case ORDER_COMMENT:
        odata.SetComment(Order::OrderGetString(ORDER_COMMENT));
        break;
#ifdef ORDER_EXTERNAL_ID
      case (ENUM_ORDER_PROPERTY_STRING)ORDER_EXTERNAL_ID:
        // Not supported right now.
        // odata.SetExternalId(Order::OrderGetString(ORDER_EXTERNAL_ID));
        return false;
        break;
#endif
      case ORDER_SYMBOL:
        odata.SetSymbol(Order::OrderGetString(ORDER_SYMBOL));
        break;
      default:
        return false;
    }
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
  string OrderTypeToString(bool _lc = false) { return OrderTypeToString(orequest.type, _lc); }

  /* Custom order methods */

  /**
   * Returns gross profit of the currently selected order.
   *
   * @return
   * Returns the gross profit value (including swaps, commissions and fees/taxes)
   * for the selected order, in the base currency.
   */
  static double GetOrderTotalProfit() { return Order::OrderProfit() - Order::OrderTotalFees(); }
  double GetTotalProfit() {
    if (odata.total_profit == 0 || !IsClosed()) {
      odata.total_profit = Order::GetOrderTotalProfit();
    }
    return odata.total_profit;
  }

  /**
   * Returns profit of the currently selected order in pips.
   *
   * @return
   * Returns the profit value for the selected order in pips.
   */
  static double GetOrderProfitInPips() {
    return (OrderOpenPrice() - SymbolInfo::GetCloseOffer(OrderSymbol(), OrderType())) /
           SymbolInfo::GetPointSize(OrderSymbol());
  }

  /**
   * Return opposite trade of command operation.
   *
   * @param
   *   cmd int Trade command operation.
   */
  static ENUM_ORDER_TYPE NegateOrderType(ENUM_ORDER_TYPE _cmd) {
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        return ORDER_TYPE_SELL;
      case ORDER_TYPE_SELL:
        return ORDER_TYPE_BUY;
    }
    return -1;
  }

  /**
   * Return opposite order type based on position type.
   *
   * @param
   *   _pos ENUM_POSITION_TYPE Direction of an open position.
   *
   * @return
   *   Returns opposite order type.
   */
  static ENUM_ORDER_TYPE NegateOrderType(ENUM_POSITION_TYPE _ptype) {
    switch (_ptype) {
      case POSITION_TYPE_BUY:
        return ORDER_TYPE_SELL;
      case POSITION_TYPE_SELL:
        return ORDER_TYPE_BUY;
    }
    return -1;
  }

  /*
   * Returns direction value of order.
   *
   * @param
   *   op_type short Order operation type of the order.
   *
   * @return
   *   Returns 1 for buy, -1 for sell orders, otherwise 0.
   */
  static short OrderDirection(ENUM_ORDER_TYPE _cmd) {
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
  static short OrderDirection(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode) {
    return OrderDirection(_cmd) * (_mode == ORDER_TYPE_SL ? -1 : 1);
  }

  /**
   * Get color of the order based on its type.
   */
  static color GetOrderColor(ENUM_ORDER_TYPE _cmd = NULL, color cbuy = Blue, color csell = Red) {
    if (_cmd == NULL) _cmd = (ENUM_ORDER_TYPE)OrderType();
    return OrderDirection(_cmd) > 0 ? cbuy : csell;
  }

  /* Order property getters */

  /**
   * Returns the requested property of an order.
   *
   * @param ENUM_ORDER_PROPERTY_INTEGER property_id
   *   Identifier of a property.
   *
   * @return string
   *   Returns the value of the property.
   *   In case of error, information can be obtained using GetLastError() function.
   *
   * @docs
   * - https://www.mql5.com/en/docs/trading/ordergetinteger
   *
   */
  static long OrderGetInteger(ENUM_ORDER_PROPERTY_INTEGER property_id) {
    ResetLastError();
    long _result = 0;
#ifdef __MQL4__
#ifdef __debug__
    Print("OrderGetInteger(", EnumToString(property_id), ")...");
#endif
    switch (property_id) {
#ifndef __MQL__
      case ORDER_TICKET:  // Note: In MT, the value conflicts with ORDER_TIME_SETUP.
        _result = ::OrderTicket();
        break;
#endif
      case ORDER_TIME_SETUP:
        _result = OrderOpenTime();  // @fixit Are we sure?
        break;
      case ORDER_TIME_SETUP_MSC:
        _result = OrderGetInteger(ORDER_TIME_SETUP) * 1000;  // @fixit We need more precision.
        break;
      case ORDER_TYPE:
        _result = ::OrderType();
        break;
      case ORDER_TIME_EXPIRATION:
        _result = ::OrderExpiration();
        break;
      case ORDER_TIME_DONE:
        _result = ::OrderCloseTime();  // @fixit Are we sure?
        break;
      case ORDER_TIME_DONE_MSC:
        _result = OrderGetInteger(ORDER_TIME_DONE) * 1000;  // @fixit We need more precision.
        break;
      case ORDER_STATE:
      case ORDER_TYPE_FILLING:
      case ORDER_REASON:
      case ORDER_TYPE_TIME:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
      case ORDER_MAGIC:
        _result = ::OrderMagicNumber();
        break;
#ifdef ORDER_POSITION_ID
      case ORDER_POSITION_ID:
        _result = OrderGetPositionID();
        break;
#endif
#ifdef ORDER_POSITION_BY_ID
      case ORDER_POSITION_BY_ID:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
#endif
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }

    int _last_error = GetLastError();

#ifdef __debug__
    if (_last_error > 0) {
      Print("OrderGetInteger(", EnumToString(property_id), ") = ", _result, ", error = ", _last_error);
    }
#endif

    if (_last_error != ERR_SUCCESS) {
      SetUserError((unsigned short)_last_error);
    }

    return _result;
#else
    return OrderGetParam(property_id, selected_ticket_type, ORDER_SELECT_DATA_TYPE_INTEGER, _result);
#endif
  }
  static bool OrderGetInteger(ENUM_ORDER_PROPERTY_INTEGER property_id, long &_out) {
#ifdef __MQL4__
    _out = (long)OrderGetInteger(property_id);
    return true;
#else
    return OrderGetParam(property_id, selected_ticket_type, ORDER_SELECT_DATA_TYPE_INTEGER, _out) >= 0;
#endif
  }

  /**
   * Returns the requested property of an order.
   *
   * @param ENUM_ORDER_PROPERTY_DOUBLE property_id
   *   Identifier of a property.
   *
   * @return double
   *   Returns the value of the property.
   *   In case of error, information can be obtained using GetLastError() function.
   *
   * @docs
   * - https://www.mql5.com/en/docs/trading/ordergetdouble
   *
   */
  static double OrderGetDouble(ENUM_ORDER_PROPERTY_DOUBLE property_id) {
    ResetLastError();
    double _result = WRONG_VALUE;
#ifdef __MQL4__
#ifdef __debug__
    Print("OrderGetDouble(", EnumToString(property_id), ")...");
#endif
    switch (property_id) {
      case ORDER_VOLUME_INITIAL:
        _result = ::OrderLots();  // @fixit Are we sure?
        break;
      case ORDER_VOLUME_CURRENT:
        _result = ::OrderLots();  // @fixit Are we sure?
        break;
      case ORDER_PRICE_OPEN:
        _result = ::OrderOpenPrice();
        break;
      case ORDER_SL:
        _result = ::OrderStopLoss();
        break;
      case ORDER_TP:
        _result = ::OrderTakeProfit();
        break;
      case ORDER_PRICE_CURRENT:
        _result = SymbolInfo::GetBid(Order::OrderSymbol());
        break;
      case ORDER_PRICE_STOPLIMIT:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }

    int _last_error = GetLastError();

#ifdef __debug__
    if (_last_error > 0) {
      Print("OrderGetDouble(", EnumToString(property_id), ") = ", _result, ", error = ", _last_error);
    }
#endif

    if (_last_error != ERR_SUCCESS) {
      SetUserError((unsigned short)_last_error);
    }

    return _result;
#else
    return OrderGetParam(property_id, selected_ticket_type, ORDER_SELECT_DATA_TYPE_DOUBLE, _result);
#endif
  }
  static bool OrderGetDouble(ENUM_ORDER_PROPERTY_DOUBLE property_id, double &_out) {
#ifdef __MQL4__
    _out = OrderGetDouble(property_id);
    return true;
#else
    return OrderGetParam(property_id, selected_ticket_type, ORDER_SELECT_DATA_TYPE_DOUBLE, _out) >= 0;
#endif
  }

  /**
   * Returns the requested property of an order.
   *
   * @param ENUM_ORDER_PROPERTY_STRING property_id
   *   Identifier of a property.
   *
   * @return string
   *   Returns the value of the property.
   *   In case of error, information can be obtained using GetLastError() function.
   *
   * @docs
   * - https://www.mql5.com/en/docs/trading/ordergetstring
   *
   */
  static string OrderGetString(ENUM_ORDER_PROPERTY_STRING property_id) {
    ResetLastError();
    string _result;
#ifdef __MQL4__
#ifdef __debug__
    Print("OrderGetString(", EnumToString(property_id), ")...");
#endif
    switch (property_id) {
      case ORDER_SYMBOL:
        _result = ::OrderSymbol();
        break;
      case ORDER_COMMENT:
        _result = ::OrderComment();
        break;
      case ORDER_EXTERNAL_ID:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    int _last_error = GetLastError();
#ifdef __debug__
    if (_last_error > 0) {
      Print("OrderGetString(", EnumToString(property_id), ") = ", _result, ", error = ", _last_error);
    }
#endif
    if (_last_error != ERR_SUCCESS) {
      SetUserError((unsigned short)_last_error);
    }
    return _result;
#else
    return OrderGetParam(property_id, selected_ticket_type, ORDER_SELECT_DATA_TYPE_STRING, _result);
#endif
  }
  static bool OrderGetString(ENUM_ORDER_PROPERTY_STRING property_id, string &_out) {
#ifdef __MQL4__
    _out = OrderGetString(property_id);
    return true;
#else
    return OrderGetParam(property_id, selected_ticket_type, ORDER_SELECT_DATA_TYPE_STRING, _out) != NULL;
#endif
  }

#ifdef __MQL5__
  /**
   * Returns the requested property for an order.
   *
   * @param int property_id
   *   Identifier of a property.
   *
   * @param ENUM_ORDER_SELECT_TYPE type
   *   Identifier of a property.
   *
   * @param long& _out
   *   Reference to output value (the same as returned from the function).
   *
   * @return long
   *   Returns the value of the property (same as for `_out` variable).
   *   In case of error, information can be obtained using GetLastError() function.
   *
   */
  static long OrderGetValue(int property_id, ENUM_ORDER_SELECT_TYPE type, long &_out) {
    switch (type) {
      case ORDER_SELECT_TYPE_NONE:
        return NULL;
      case ORDER_SELECT_TYPE_ACTIVE:
        _out = ::OrderGetInteger((ENUM_ORDER_PROPERTY_INTEGER)property_id);
        break;
      case ORDER_SELECT_TYPE_HISTORY:
        _out = ::HistoryOrderGetInteger(selected_ticket_id, (ENUM_ORDER_PROPERTY_INTEGER)property_id);
        break;
      case ORDER_SELECT_TYPE_DEAL:
        _out = ::HistoryDealGetInteger(selected_ticket_id, (ENUM_DEAL_PROPERTY_INTEGER)property_id);
        break;
      case ORDER_SELECT_TYPE_POSITION:
        _out = ::PositionGetInteger((ENUM_POSITION_PROPERTY_INTEGER)property_id);
        break;
    }

    return _out;
  }

  /**
   * Returns the requested property for an order.
   *
   * @param int property_id
   *   Identifier of a property.
   *
   * @param ENUM_ORDER_SELECT_TYPE type
   *   Identifier of a property.
   *
   * @param double& _out
   *   Reference to output value (the same as returned from the function).
   *
   * @return double
   *   Returns the value of the property (same as for `_out` variable).
   *   In case of error, information can be obtained using GetLastError() function.
   *
   */
  static double OrderGetValue(int property_id, ENUM_ORDER_SELECT_TYPE type, double &_out) {
    switch (type) {
      case ORDER_SELECT_TYPE_NONE:
        return NULL;
      case ORDER_SELECT_TYPE_ACTIVE:
        _out = ::OrderGetDouble((ENUM_ORDER_PROPERTY_DOUBLE)property_id);
        break;
      case ORDER_SELECT_TYPE_HISTORY:
        _out = ::HistoryOrderGetDouble(selected_ticket_id, (ENUM_ORDER_PROPERTY_DOUBLE)property_id);
        break;
      case ORDER_SELECT_TYPE_DEAL:
        _out = ::HistoryDealGetDouble(selected_ticket_id, (ENUM_DEAL_PROPERTY_DOUBLE)property_id);
        break;
      case ORDER_SELECT_TYPE_POSITION:
        _out = ::PositionGetDouble((ENUM_POSITION_PROPERTY_DOUBLE)property_id);
        break;
    }

    return _out;
  }

  /**
   * Returns the requested property for an order.
   *
   * @param int property_id
   *   Identifier of a property.
   *
   * @param ENUM_ORDER_SELECT_TYPE type
   *   Identifier of a property.
   *
   * @param string& _out
   *   Reference to output value (the same as returned from the function).
   *
   * @return string
   *   Returns the value of the property (same as for `_out` variable).
   *   In case of error, information can be obtained using GetLastError() function.
   *
   */
  static string OrderGetValue(int _prop_id, ENUM_ORDER_SELECT_TYPE _type, string &_out) {
    switch (_type) {
      case ORDER_SELECT_TYPE_NONE:
        _out = "";
        break;
      case ORDER_SELECT_TYPE_ACTIVE:
        _out = ::OrderGetString((ENUM_ORDER_PROPERTY_STRING)_prop_id);
        break;
      case ORDER_SELECT_TYPE_HISTORY:
        _out = ::HistoryOrderGetString(selected_ticket_id, (ENUM_ORDER_PROPERTY_STRING)_prop_id);
        break;
      case ORDER_SELECT_TYPE_DEAL:
        _out = ::HistoryDealGetString(selected_ticket_id, (ENUM_DEAL_PROPERTY_STRING)_prop_id);
        break;
      case ORDER_SELECT_TYPE_POSITION:
        _out = ::PositionGetString((ENUM_POSITION_PROPERTY_STRING)_prop_id);
        break;
    }

    return _out;
  }

  /**
   * Returns the requested property of an order.
   *
   * @param int _prop_id
   *   Mixed identifier of a property.
   *
   * @param ENUM_ORDER_SELECT_TYPE type
   *   Type of a property (active, history, deal, position).
   *
   * @param ENUM_ORDER_SELECT_DATA_TYPE data_type
   *   Type of the value requested (integer, double, string).
   *
   * @param ENUM_ORDER_SELECT_DATA_TYPE data_type
   *   Type of the value requested (integer, double, string).
   *
   * @return X& _out
   *   Returns the value of the property.
   *   In case of error, information can be obtained using GetLastError() function.
   */
  template <typename X>
  static X OrderGetParam(int _prop_id, ENUM_ORDER_SELECT_TYPE _type, ENUM_ORDER_SELECT_DATA_TYPE _data_type, X &_out) {
#ifdef __MQL5__
    switch (selected_ticket_type) {
      case ORDER_SELECT_TYPE_NONE:
        return NULL;

      case ORDER_SELECT_TYPE_ACTIVE:
      case ORDER_SELECT_TYPE_HISTORY:
        return OrderGetValue(_prop_id, selected_ticket_type, _out);

      case ORDER_SELECT_TYPE_DEAL:
        switch (_data_type) {
          case ORDER_SELECT_DATA_TYPE_INTEGER:
            switch (_prop_id) {
              case ORDER_TIME_SETUP:
                return OrderGetValue(DEAL_TIME, _type, _out);
              case ORDER_TYPE:
                switch ((int)OrderGetValue(DEAL_TYPE, _type, _out)) {
                  case DEAL_TYPE_BUY:
                    return (X)ORDER_TYPE_BUY;
                  case DEAL_TYPE_SELL:
                    return (X)ORDER_TYPE_SELL;
                  default:
                    return NULL;
                }
                break;
              case ORDER_STATE:
                // @fixme
                SetUserError(ERR_INVALID_PARAMETER);
              case ORDER_TIME_EXPIRATION:
              case ORDER_TIME_DONE:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
              case ORDER_TIME_SETUP_MSC:
                return OrderGetValue(DEAL_TIME_MSC, _type, _out);
              case ORDER_TIME_DONE_MSC:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
              case ORDER_TYPE_FILLING:
              case ORDER_TYPE_TIME:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
              case ORDER_MAGIC:
                return OrderGetValue(DEAL_MAGIC, _type, _out);
              case ORDER_REASON:
                switch ((int)OrderGetValue(DEAL_REASON, _type, _out)) {
                  case DEAL_REASON_CLIENT:
                    return (X)ORDER_REASON_CLIENT;
                  case DEAL_REASON_MOBILE:
                    return (X)ORDER_REASON_MOBILE;
                  case DEAL_REASON_WEB:
                    return (X)ORDER_REASON_WEB;
                  case DEAL_REASON_EXPERT:
                    return (X)ORDER_REASON_EXPERT;
                  case DEAL_REASON_SL:
                    return (X)ORDER_REASON_SL;
                  case DEAL_REASON_TP:
                    return (X)ORDER_REASON_TP;
                  case DEAL_REASON_SO:
                    return (X)ORDER_REASON_SO;
                  default:
                    return NULL;
                }
                break;
              case ORDER_POSITION_ID:
                return OrderGetValue(DEAL_POSITION_ID, _type, _out);
              case ORDER_POSITION_BY_ID:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
            }
            break;
          case ORDER_SELECT_DATA_TYPE_DOUBLE:
            switch (_prop_id) {
              case ORDER_VOLUME_INITIAL:
                return OrderGetValue(DEAL_VOLUME, _type, _out);
              case ORDER_VOLUME_CURRENT:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
              case ORDER_PRICE_OPEN:
                return OrderGetValue(DEAL_PRICE, _type, _out);
              case ORDER_SL:
              case ORDER_TP:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
              case ORDER_PRICE_CURRENT:
                return OrderGetValue(DEAL_PRICE, _type, _out);
              case ORDER_PRICE_STOPLIMIT:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
            }
            break;
          case ORDER_SELECT_DATA_TYPE_STRING:
            switch (_prop_id) {
              case ORDER_SYMBOL:
              case ORDER_COMMENT:
              case ORDER_EXTERNAL_ID:
                return NULL;
            }
            break;
        }
        break;

      case ORDER_SELECT_TYPE_POSITION:
        switch (_data_type) {
          case ORDER_SELECT_DATA_TYPE_INTEGER:
            switch (_prop_id) {
              case ORDER_TIME_SETUP:
                return OrderGetValue(POSITION_TIME, _type, _out);
              case ORDER_TYPE:
                switch ((int)OrderGetValue(POSITION_TYPE, _type, _out)) {
                  case POSITION_TYPE_BUY:
                    return (X)ORDER_TYPE_BUY;
                  case POSITION_TYPE_SELL:
                    return (X)ORDER_TYPE_SELL;
                  default:
                    return NULL;
                }
                break;
              case ORDER_STATE:
                // @fixme
                SetUserError(ERR_INVALID_PARAMETER);
              case ORDER_TIME_EXPIRATION:
              case ORDER_TIME_DONE:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
              case ORDER_TIME_SETUP_MSC:
                return OrderGetValue(POSITION_TIME_MSC, _type, _out);
              case ORDER_TIME_DONE_MSC:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
              case ORDER_TYPE_FILLING:
              case ORDER_TYPE_TIME:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
              case ORDER_MAGIC:
                return OrderGetValue(POSITION_MAGIC, _type, _out);
              case ORDER_REASON:
                switch ((int)OrderGetValue(POSITION_REASON, _type, _out)) {
                  case POSITION_REASON_CLIENT:
                    return (X)ORDER_REASON_CLIENT;
                  case POSITION_REASON_MOBILE:
                    return (X)ORDER_REASON_MOBILE;
                  case POSITION_REASON_WEB:
                    return (X)ORDER_REASON_WEB;
                  case POSITION_REASON_EXPERT:
                    return (X)ORDER_REASON_EXPERT;
                  default:
                    return NULL;
                }
                break;
              case ORDER_POSITION_ID:
                return OrderGetValue(POSITION_IDENTIFIER, _type, _out);
              case ORDER_POSITION_BY_ID:
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
            }
            break;
          case ORDER_SELECT_DATA_TYPE_DOUBLE:
            switch (_prop_id) {
              case ORDER_VOLUME_INITIAL:
                return OrderGetValue(POSITION_VOLUME, _type, _out);
              case ORDER_VOLUME_CURRENT:
                // @fixme
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
              case ORDER_PRICE_OPEN:
                return OrderGetValue(POSITION_PRICE_OPEN, _type, _out);
              case ORDER_SL:
                return OrderGetValue(POSITION_SL, _type, _out);
              case ORDER_TP:
                return OrderGetValue(POSITION_TP, _type, _out);
              case ORDER_PRICE_CURRENT:
                return OrderGetValue(POSITION_PRICE_CURRENT, _type, _out);
              case ORDER_PRICE_STOPLIMIT:
                // @fixme
                SetUserError(ERR_INVALID_PARAMETER);
                return NULL;
            }
            break;
          case ORDER_SELECT_DATA_TYPE_STRING:
            switch (_prop_id) {
              case ORDER_SYMBOL:
                return OrderGetValue(POSITION_SYMBOL, _type, _out);
              case ORDER_COMMENT:
                return OrderGetValue(POSITION_COMMENT, _type, _out);
              case ORDER_EXTERNAL_ID:
                return OrderGetValue(POSITION_EXTERNAL_ID, _type, _out);
            }
            break;
        }
        break;
    }

    return NULL;
#else
    return OrderGetValue(_prop_id, _type, _out);
#endif;
  }

#endif

  /**
   * Returns the requested property of an order.
   *
   * @param ENUM_ORDER_PROPERTY_DOUBLE _prop_id
   *   Identifier of a property.
   *
   * @return long
   *   Returns the value of the property.
   *
   * @docs
   * - https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
   *
   */
  double OrderGet(ENUM_ORDER_PROPERTY_DOUBLE _prop_id) {
    switch (_prop_id) {
      case ORDER_PRICE_CURRENT:
        return odata.price_current;
      case ORDER_PRICE_OPEN:
        return odata.price_open;
      case ORDER_PRICE_STOPLIMIT:
        return odata.price_stoplimit;
      case ORDER_SL:
        return odata.sl;
      case ORDER_TP:
        return odata.tp;
      case ORDER_VOLUME_CURRENT:
        return odata.volume;
      case ORDER_VOLUME_INITIAL:
        return odata.volume;
    }
    return EMPTY;
  }

  /**
   * Returns the requested property of an order.
   *
   * @param ENUM_ORDER_PROPERTY_INTEGER _prop_id
   *   Identifier of a property.
   *
   * @return long
   *   Returns the value of the property.
   *
   * @docs
   * - https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
   *
   */
  long OrderGet(ENUM_ORDER_PROPERTY_INTEGER _prop_id) {
    switch (_prop_id) {
      case ORDER_MAGIC:
        return (long)odata.magic;
      case ORDER_STATE:
        return odata.state;
#ifndef __MQL__
      case ORDER_TICKET:  // Note: In MT, the value conflicts with ORDER_TIME_SETUP.
        return (long)odata.ticket;
#endif
      case ORDER_TIME_SETUP:  // Note: In MT5, the value conflicts with ORDER_TICKET.
      case ORDER_TIME_DONE:
      case ORDER_TIME_DONE_MSC:
        // Order execution or cancellation time.
        return odata.time_open;
      case ORDER_TIME_EXPIRATION:
        return odata.expiration;
      case ORDER_TIME_SETUP_MSC:
        // Order setup time.
        return odata.time_open;
      case ORDER_TYPE:
        return odata.type;
      case ORDER_TYPE_FILLING:
        return odata.type_filling;
      case ORDER_TYPE_TIME:
        return odata.type_time;
#ifdef ORDER_POSITION_ID
      case ORDER_POSITION_ID:
        return (long)odata.position;
#endif
#ifdef ORDER_POSITION_BY_ID
      case ORDER_POSITION_BY_ID:
        return (long)odata.position_by;
#endif
        // case ORDER_REASON:
    }
    return EMPTY;
  }

  /**
   * Returns the requested property of an order.
   *
   * @param ENUM_ORDER_PROPERTY_STRING _prop_id
   *   Identifier of a property.
   *
   * @return long
   *   Returns the value of the property.
   *
   * @docs
   * - https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
   *
   */
  string OrderGet(ENUM_ORDER_PROPERTY_STRING _prop_id) {
    switch (_prop_id) {
      case ORDER_COMMENT:
        return odata.comment;
      case ORDER_SYMBOL:
        return odata.symbol;
#ifdef ORDER_EXTERNAL_ID
      case (ENUM_ORDER_PROPERTY_STRING)ORDER_EXTERNAL_ID:
        return odata.ext_id;
#endif
    }
    return "";
  }

  /* Conditions and actions */

  /**
   * Process order conditions.
   */
  bool ProcessConditions() {
    bool _result = true;
    if (IsOpen() && ShouldCloseOrder()) {
      MqlParam _args[] = {{TYPE_STRING, 0, 0, "Close condition"}};
#ifdef __MQL__
      _args[0].string_value += StringFormat(": %s", EnumToString(oparams.cond_close));
#endif
      _result &= Order::ExecuteAction(ORDER_ACTION_CLOSE, _args);
    }
    return _result;
  }

  /**
   * Checks for order condition.
   *
   * @param ENUM_ORDER_CONDITION _cond
   *   Order condition.
   * @param MqlParam _args
   *   Trade action arguments.
   * @return
   *   Returns true when the condition is met.
   */
  bool CheckCondition(ENUM_ORDER_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      case ORDER_COND_IN_LOSS:
        return GetProfit() < 0;
      case ORDER_COND_IN_PROFIT:
        return GetProfit() > 0;
      case ORDER_COND_IS_CLOSED:
        return IsClosed();
      case ORDER_COND_IS_OPEN:
        return IsOpen();
      case ORDER_COND_LIFETIME_GT_ARG:
      case ORDER_COND_LIFETIME_LT_ARG:
        if (ArraySize(_args) > 0) {
          long _arg_value = Convert::MqlParamToInteger(_args[0]);
          switch (_cond) {
            case ORDER_COND_LIFETIME_GT_ARG:
              return TimeCurrent() - OrderGet(ORDER_TIME_SETUP) > _arg_value;
            case ORDER_COND_LIFETIME_LT_ARG:
              return TimeCurrent() - OrderGet(ORDER_TIME_SETUP) < _arg_value;
          }
        }
      case ORDER_COND_PROP_EQ_ARG:
      case ORDER_COND_PROP_GT_ARG:
      case ORDER_COND_PROP_LT_ARG: {
        if (ArraySize(_args) >= 2) {
          // First argument is enum value (order property).
          long _prop_id = _args[0].integer_value;
          // Second argument is the actual value with compare with.
          switch (_args[1].type) {
            case TYPE_DOUBLE:
            case TYPE_FLOAT:
              Update((ENUM_ORDER_PROPERTY_DOUBLE)_prop_id);
              switch (_cond) {
                case ORDER_COND_PROP_EQ_ARG:
                  return OrderGet((ENUM_ORDER_PROPERTY_DOUBLE)_prop_id) == _args[1].double_value;
                case ORDER_COND_PROP_GT_ARG:
                  return OrderGet((ENUM_ORDER_PROPERTY_DOUBLE)_prop_id) > _args[1].double_value;
                case ORDER_COND_PROP_LT_ARG:
                  return OrderGet((ENUM_ORDER_PROPERTY_DOUBLE)_prop_id) < _args[1].double_value;
              }
            case TYPE_INT:
            case TYPE_LONG:
            case TYPE_UINT:
            case TYPE_ULONG:
              Update((ENUM_ORDER_PROPERTY_INTEGER)_prop_id);
              switch (_cond) {
                case ORDER_COND_PROP_EQ_ARG:
                  return OrderGet((ENUM_ORDER_PROPERTY_INTEGER)_prop_id) == _args[1].integer_value;
                case ORDER_COND_PROP_GT_ARG:
                  return OrderGet((ENUM_ORDER_PROPERTY_INTEGER)_prop_id) > _args[1].integer_value;
                case ORDER_COND_PROP_LT_ARG:
                  return OrderGet((ENUM_ORDER_PROPERTY_INTEGER)_prop_id) < _args[1].integer_value;
              }
            case TYPE_STRING:
              Update((ENUM_ORDER_PROPERTY_STRING)_prop_id);
              return OrderGet((ENUM_ORDER_PROPERTY_STRING)_prop_id) == _args[1].string_value;
              switch (_cond) {
                case ORDER_COND_PROP_EQ_ARG:
                  return OrderGet((ENUM_ORDER_PROPERTY_STRING)_prop_id) == _args[1].string_value;
                case ORDER_COND_PROP_GT_ARG:
                  return OrderGet((ENUM_ORDER_PROPERTY_STRING)_prop_id) > _args[1].string_value;
                case ORDER_COND_PROP_LT_ARG:
                  return OrderGet((ENUM_ORDER_PROPERTY_STRING)_prop_id) < _args[1].string_value;
              }
          }
        }
      }
      default:
        Logger().Error(StringFormat("Invalid order condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return false;
  }
  bool CheckCondition(ENUM_ORDER_CONDITION _cond) {
    MqlParam _args[] = {};
    return Order::CheckCondition(_cond, _args);
  }

  /**
   * Execute order action.
   *
   * @param ENUM_ORDER_ACTION _action
   *   Order action to execute.
   * @param MqlParam _args
   *   Trade action arguments.
   * @return
   *   Returns true when the condition is met.
   */
  bool ExecuteAction(ENUM_ORDER_ACTION _action, MqlParam &_args[]) {
    switch (_action) {
      case ORDER_ACTION_CLOSE: {
        string _comment = ArraySize(_args) > 0 ? _args[0].string_value : __FUNCTION__;
        switch (oparams.dummy) {
          case false:
            return OrderClose(_comment);
          case true:
            odata.SetPriceClose(SymbolInfo::GetCloseOffer(symbol, odata.type));
            odata.SetTimeClose(DateTime::TimeTradeServer());
            odata.SetComment(_comment);
            return true;
        }
      }
      case ORDER_ACTION_OPEN:
        return !oparams.dummy ? OrderSend() >= 0 : OrderSendDummy() >= 0;
      default:
        Logger().Error(StringFormat("Invalid order action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
    }
  }
  bool ExecuteAction(ENUM_ORDER_ACTION _action) {
    MqlParam _args[] = {};
    return Order::ExecuteAction(_action, _args);
  }

  /* Printer methods */

  /**
   * Returns order details in text.
   */
  static string ToString() {
    return StringFormat(
        "Order Details: Ticket: %d; Time: %s; Comment: %s; Commision: %g; Symbol: %s; Type: %s, Expiration: %s; " +
            "Open Price: %g, Close Price: %g, Take Profit: %g, Stop Loss: %g; " + "Swap: %g; Lot size: %g",
        OrderTicket(), DateTime::TimeToStr(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS), OrderComment(),
        OrderCommission(), OrderSymbol(), OrderTypeToString(OrderType()),
        DateTime::TimeToStr(OrderExpiration(), TIME_DATE | TIME_MINUTES), DoubleToStr(OrderOpenPrice(), Digits),
        DoubleToStr(OrderClosePrice(), Digits), OrderProfit(), OrderStopLoss(), OrderSwap(), OrderLots());
  }

  /**
   * Returns order details in text.
   */
  string ToString(long &_props[], ENUM_DATATYPE _type = TYPE_DOUBLE, string _dlm = ";") {
    int i = 0;
    string _output = "";
    switch (_type) {
      case TYPE_DOUBLE:
        for (i = 0; i < Array::ArraySize(_props); i++) {
          _output += StringFormat("%g%s", OrderGet((ENUM_ORDER_PROPERTY_DOUBLE)_props[i]), _dlm);
        }
        break;
      case TYPE_LONG:
        for (i = 0; i < Array::ArraySize(_props); i++) {
          _output += StringFormat("%d%s", OrderGet((ENUM_ORDER_PROPERTY_INTEGER)_props[i]), _dlm);
        }
        break;
      case TYPE_STRING:
        for (i = 0; i < Array::ArraySize(_props); i++) {
          _output += StringFormat("%d%s", OrderGet((ENUM_ORDER_PROPERTY_STRING)_props[i]), _dlm);
        }
        break;
      default:
        Logger().Error(StringFormat("%s: Unsupported type: %s!", __FUNCTION_LINE__, EnumToString(_type)));
    }
    return "";
  }

  /**
   * Prints information about the selected order in the log.
   *
   * @see http://docs.mql4.com/trading/orderprint
   */
  static void OrderPrint() {
#ifdef __MQLBUILD__
#ifdef __MQL4__
    ::OrderPrint();
#else
    Print(ToString());
#endif
#else
    printf("%s", ToString());
#endif
  }
};

#ifdef __MQL5__
// Assigns values to static variables.
ENUM_ORDER_SELECT_TYPE Order::selected_ticket_type = ORDER_SELECT_TYPE_NONE;
unsigned long Order::selected_ticket_id = 0;
#endif

#endif ORDER_MQH
