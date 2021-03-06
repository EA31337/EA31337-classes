//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * Includes Order's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

#include "Serializer.mqh"

#ifdef __MQL4__
/**
 * The structure of Results of a Trade Request Check (MqlTradeCheckResult).
 * The check is performed using the OrderCheck() function.
 *
 * @see: https://www.mql5.com/en/docs/constants/structures/mqltradecheckresult
 */
struct MqlTradeCheckResult {
  unsigned int retcode;  // Reply code.
  double balance;        // Balance after the execution of the deal.
  double equity;         // Equity after the execution of the deal.
  double profit;         // Floating profit.
  double margin;         // Margin requirements.
  double margin_free;    // Free margin.
  double margin_level;   // Margin level.
  string comment;        // Comment to the reply code (description of the error).
};
#endif

/**
 * The structure for order parameters.
 */
struct OrderParams {
  bool dummy;                        // Whether order is dummy (fake) or not (real).
  color color_arrow;                 // Color of the opening arrow on the chart.
  unsigned short refresh_rate;       // How often to refresh order values (in secs).
  ENUM_ORDER_CONDITION cond_close;   // Close condition.
  DataParamEntry cond_close_args[];  // Close condition argument.
  // Special struct methods.
  void OrderParams() : dummy(false), color_arrow(clrNONE), refresh_rate(10), cond_close(ORDER_COND_NONE){};
  void OrderParams(bool _dummy) : dummy(_dummy), color_arrow(clrNONE), refresh_rate(10), cond_close(ORDER_COND_NONE){};
  // Getters.
  template <typename T>
  T Get(ENUM_ORDER_PARAM _param) {
    switch (_param) {
      case ORDER_PARAM_COLOR_ARROW:
        return (T)color_arrow;
      case ORDER_PARAM_COND_CLOSE:
        return (T)cond_close;
      case ORDER_PARAM_COND_CLOSE_ARGS:
        return (T)cond_close_args;
      case ORDER_PARAM_DUMMY:
        return (T)dummy;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  // State checkers
  bool HasCloseCondition() { return cond_close != ORDER_COND_NONE; }
  bool IsDummy() { return dummy; }
  // Setters.
  template <typename T>
  void Set(ENUM_ORDER_PARAM _param, T _value) {
    switch (_param) {
      case ORDER_PARAM_COLOR_ARROW:
        color_arrow = (color)_value;
        return;
      case ORDER_PARAM_COND_CLOSE:
        cond_close = (ENUM_ORDER_CONDITION)_value;
        return;
      case ORDER_PARAM_COND_CLOSE_ARGS:
        ArrayResize(cond_close_args, 1);
        // @todo: Double support.
        cond_close_args[0].type = TYPE_INT;
        cond_close_args[0].integer_value = _value;
        return;
      case ORDER_PARAM_DUMMY:
        dummy = _value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void SetConditionClose(ENUM_ORDER_CONDITION _cond, DataParamEntry &_args[]) {
    cond_close = _cond;
    ArrayResize(cond_close_args, ArraySize(_args));
    for (int i = 0; i < ArraySize(_args); i++) {
      cond_close_args[i] = _args[i];
    }
  }
  void SetRefreshRate(unsigned short _value) { refresh_rate = _value; }
  // Serializers.
  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(this, "dummy", dummy);
    s.Pass(this, "color_arrow", color_arrow);
    s.Pass(this, "refresh_rate", refresh_rate);
    // s.Pass(this, "cond_close", cond_close);
    return SerializerNodeObject;
  }
};

/**
 * The structure for order data.
 */
struct OrderData {
  unsigned long magic;                   // Magic number.
  unsigned long position_id;             // Position ID.
  unsigned long position_by_id;          // Position By ID.
  unsigned long ticket;                  // Ticket number.
  ENUM_ORDER_STATE state;                // State.
  datetime time_closed;                  // Closed time.
  datetime time_done;                    // Execution/cancellation time.
  datetime time_expiration;              // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type).
  datetime time_setup;                   // Setup time.
  datetime time_last_updated;            // Last update of order values.
  double commission;                     // Commission.
  double profit;                         // Profit.
  double total_profit;                   // Total profit (profit minus fees).
  double price_open;                     // Open price.
  double price_close;                    // Close price.
  double price_current;                  // Current price.
  double price_stoplimit;                // The limit order price for the StopLimit order.
  double swap;                           // Order cumulative swap.
  double total_fees;                     // Total fees.
  double sl;                             // Current Stop loss level of the order.
  double tp;                             // Current Take Profit level of the order.
  long time_setup_msc;                   // The time of placing the order (in msc).
  long time_done_msc;                    // The time of execution/cancellation time (in msc).
  ENUM_ORDER_TYPE type;                  // Type.
  ENUM_ORDER_TYPE_FILLING type_filling;  // Filling type.
  ENUM_ORDER_TYPE_TIME type_time;        // Lifetime (the order validity period).
  ENUM_ORDER_REASON reason;              // Reason or source for placing an order.
  ENUM_ORDER_REASON_CLOSE reason_close;  // Reason or source for closing an order.
  unsigned int last_error;               // Last error code.
  double volume_curr;                    // Current volume.
  double volume_init;                    // Initial volume.
  string comment;                        // Comment.
  string ext_id;                         // External trading system identifier.
  string symbol;                         // Symbol of the order.
  OrderData()
      : magic(0),
        position_id(0),
        position_by_id(0),
        ticket(0),
        state(ORDER_STATE_STARTED),
        comment(""),
        commission(0),
        profit(0),
        price_open(0),
        price_close(0),
        price_current(0),
        price_stoplimit(0),
        swap(0),
        time_closed(0),
        time_done(0),
        time_done_msc(0),
        time_expiration(0),
        time_last_updated(0),
        time_setup(0),
        time_setup_msc(0),
        sl(0),
        tp(0),
        last_error(ERR_NO_ERROR),
        symbol(NULL),
        volume_curr(0),
        volume_init(0) {}
  // Getters.
  template <typename T>
  T Get(ENUM_ORDER_PROPERTY_CUSTOM _prop_name) {
    switch (_prop_name) {
      case ORDER_PROP_LAST_ERROR:
        return (T)last_error;
      case ORDER_PROP_PRICE_CLOSE:
        return (T)price_close;
      case ORDER_PROP_PRICE_CURRENT:
        return (T)price_current;
      case ORDER_PROP_PRICE_OPEN:
        return (T)price_open;
      case ORDER_PROP_PRICE_STOPLIMIT:
        return (T)price_stoplimit;
      case ORDER_PROP_REASON_CLOSE:
        return (T)reason_close;
      case ORDER_PROP_TICKET:
        return (T)ticket;
      case ORDER_PROP_TIME_CLOSED:
        return (T)time_closed;
      case ORDER_PROP_TIME_LAST_UPDATED:
        return (T)time_last_updated;
      case ORDER_PROP_TIME_OPENED:
        return (T)time_done;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  double Get(ENUM_ORDER_PROPERTY_DOUBLE _prop_name) {
    switch (_prop_name) {
      case ORDER_VOLUME_CURRENT:
        return volume_curr;
      case ORDER_VOLUME_INITIAL:
        return volume_init;
      case ORDER_PRICE_OPEN:
        return price_open;
      case ORDER_SL:
        return sl;
      case ORDER_TP:
        return tp;
      case ORDER_PRICE_CURRENT:
        return price_current;
      case ORDER_PRICE_STOPLIMIT:
        return price_stoplimit;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  long Get(ENUM_ORDER_PROPERTY_INTEGER _prop_name) {
    switch (_prop_name) {
      // case ORDER_TIME_SETUP: return time_setup; // @todo
      case ORDER_TYPE:
        return type;
      case ORDER_STATE:
        return state;
      case ORDER_TIME_EXPIRATION:
        return time_expiration;
      case ORDER_TIME_DONE:
        return time_done;
      case ORDER_TIME_DONE_MSC:
        return time_done_msc;
      case ORDER_TIME_SETUP:
        return time_setup;
      case ORDER_TIME_SETUP_MSC:
        return time_setup_msc;
      case ORDER_TYPE_FILLING:
        return type_filling;
      case ORDER_TYPE_TIME:
        return type_time;
      case ORDER_MAGIC:
        return (long)magic;
#ifndef __MQL4__
      case ORDER_POSITION_ID:
        return (long)position_id;
      case ORDER_POSITION_BY_ID:
        return (long)position_by_id;
      case ORDER_REASON:
        return reason;
      case ORDER_TICKET:
        return (long)ticket;
#endif
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  string Get(ENUM_ORDER_PROPERTY_STRING _prop_name) {
    switch (_prop_name) {
      case ORDER_COMMENT:
        return comment;
#ifndef __MQL4__
      case ORDER_EXTERNAL_ID:
        return ext_id;
#endif
      case ORDER_SYMBOL:
        return symbol;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return "";
  }
  string GetReasonCloseText() {
    switch (reason_close) {
      case ORDER_REASON_CLOSED_ALL:
        return "Closed all";
      case ORDER_REASON_CLOSED_BY_ACTION:
        return "Closed by action";
      case ORDER_REASON_CLOSED_BY_EXPIRE:
        return "Expired";
      case ORDER_REASON_CLOSED_BY_OPPOSITE:
        return "Closed by opposite trade";
      case ORDER_REASON_CLOSED_BY_SIGNAL:
        return "Closed by signal";
      case ORDER_REASON_CLOSED_BY_SL:
        return "Closed by stop loss";
      case ORDER_REASON_CLOSED_BY_TEST:
        return "Closed by test";
      case ORDER_REASON_CLOSED_BY_TP:
        return "Closed by take profit";
      case ORDER_REASON_CLOSED_BY_USER:
        return "Closed by user";
      case ORDER_REASON_CLOSED_UNKNOWN:
        return "Unknown";
    }
    return "Unknown";
  }
  // Setters.
  template <typename T>
  void Set(ENUM_ORDER_PROPERTY_CUSTOM _prop_name, T _value) {
    switch (_prop_name) {
      case ORDER_PROP_LAST_ERROR:
        last_error = (unsigned int)_value;
        return;
      case ORDER_PROP_PRICE_CLOSE:
        price_close = (double)_value;
        return;
      case ORDER_PROP_PRICE_CURRENT:
        price_current = (double)_value;
        return;
      case ORDER_PROP_PRICE_OPEN:
        price_open = (double)_value;
        return;
      case ORDER_PROP_PRICE_STOPLIMIT:
        price_stoplimit = (double)_value;
        return;
      case ORDER_PROP_REASON_CLOSE:
        reason_close = (ENUM_ORDER_REASON_CLOSE)_value;
        return;
      case ORDER_PROP_TICKET:
        ticket = (unsigned long)_value;
        return;
      case ORDER_PROP_TIME_CLOSED:
        time_closed = (datetime)_value;
        return;
      case ORDER_PROP_TIME_LAST_UPDATED:
        time_last_updated = (datetime)_value;
        return;
      case ORDER_PROP_TIME_OPENED:
        time_setup = (datetime)_value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void Set(ENUM_ORDER_PROPERTY_DOUBLE _prop_name, double _value) {
    switch (_prop_name) {
      case ORDER_VOLUME_CURRENT:
        volume_curr = _value;
        return;
      case ORDER_VOLUME_INITIAL:
        volume_init = _value;
        return;
      case ORDER_PRICE_OPEN:
        price_open = _value;
        return;
      case ORDER_SL:
        sl = _value;
        return;
      case ORDER_TP:
        tp = _value;
        return;
      case ORDER_PRICE_CURRENT:
        price_current = _value;
        UpdateProfit();
        return;
      case ORDER_PRICE_STOPLIMIT:
        price_stoplimit = _value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void Set(ENUM_ORDER_PROPERTY_INTEGER _prop_name, long _value) {
    switch (_prop_name) {
      case ORDER_TYPE:
        type = (ENUM_ORDER_TYPE)_value;
        return;
      case ORDER_STATE:
        state = (ENUM_ORDER_STATE)_value;
        return;
      case ORDER_TIME_EXPIRATION:
        time_expiration = (datetime)_value;
        return;
      case ORDER_TIME_DONE:
        time_done = (datetime)_value;
        return;
      case ORDER_TIME_DONE_MSC:
        time_done_msc = _value;
        return;
      case ORDER_TIME_SETUP:
        time_setup = (datetime)_value;
        return;
      case ORDER_TIME_SETUP_MSC:
        time_setup_msc = _value;
        return;
      case ORDER_TYPE_FILLING:
        type_filling = (ENUM_ORDER_TYPE_FILLING)_value;
        return;
      case ORDER_TYPE_TIME:
        type_time = (ENUM_ORDER_TYPE_TIME)_value;
        return;
      case ORDER_MAGIC:
        magic = _value;
        return;
#ifndef __MQL4__
      case ORDER_POSITION_ID:
        position_id = _value;
        return;
      case ORDER_POSITION_BY_ID:
        position_by_id = _value;
        return;
      case ORDER_REASON:
        reason = (ENUM_ORDER_REASON)_value;
        return;
      case ORDER_TICKET:
        ticket = _value;
        return;
#endif
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void Set(ENUM_ORDER_PROPERTY_STRING _prop_name, string _value) {
    switch (_prop_name) {
      case ORDER_COMMENT:
        comment = _value;
        return;
#ifndef __MQL4__
      case ORDER_EXTERNAL_ID:
        ext_id = _value;
        return;
#endif
      case ORDER_SYMBOL:
        symbol = _value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void ProcessLastError() { last_error = fmax(last_error, Terminal::GetLastError()); }
  void ResetError() {
    ResetLastError();
    last_error = ERR_NO_ERROR;
  }
  void UpdateProfit() { profit = price_open - price_current; }
  // Serializers.
  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(this, "magic", magic);
    s.Pass(this, "position_id", position_id);
    s.Pass(this, "position_by_id", position_by_id);
    s.Pass(this, "ticket", ticket);
    s.PassEnum(this, "state", state);
    s.Pass(this, "commission", commission);
    s.Pass(this, "profit", profit);
    s.Pass(this, "total_profit", total_profit);
    s.Pass(this, "price_open", price_open);
    s.Pass(this, "price_close", price_close);
    s.Pass(this, "price_current", price_current);
    s.Pass(this, "price_stoplimit", price_stoplimit);
    s.Pass(this, "swap", swap);
    s.Pass(this, "time_closed", time_closed);
    s.Pass(this, "time_done", time_done);
    s.Pass(this, "time_done_msc", time_done_msc);
    s.Pass(this, "time_expiration", time_expiration);
    s.Pass(this, "time_last_updated", time_last_updated);
    s.Pass(this, "time_setup", time_setup);
    s.Pass(this, "time_setup_msc", time_setup_msc);
    s.Pass(this, "total_fees", total_fees);
    s.Pass(this, "sl", sl);
    s.Pass(this, "tp", tp);
    s.PassEnum(this, "type", type);
    s.PassEnum(this, "type_filling", type_filling);
    s.PassEnum(this, "type_time", type_time);
    s.PassEnum(this, "reason", reason);
    s.Pass(this, "last_error", last_error);
    s.Pass(this, "volume_current", volume_curr);
    s.Pass(this, "volume_init", volume_init);
    s.Pass(this, "comment", comment);
    s.Pass(this, "ext_id", ext_id);
    s.Pass(this, "symbol", symbol);

    return SerializerNodeObject;
  }
};

// Structure for order static methods.
struct OrderStatic {
  /**
   * Selects an order/position for further processing.
   *
   * @docs
   * - https://docs.mql4.com/trading/orderselect
   * - https://www.mql5.com/en/docs/trading/positiongetticket
   */
  static bool SelectByPosition(int _pos) {
#ifdef __MQL4__
    return ::OrderSelect(_pos, SELECT_BY_POS, MODE_TRADES);
#else
    return ::PositionGetTicket(_pos) > 0;
#endif
  }

  /**
   * Returns expiration date of the selected pending order/position.
   *
   * @see
   * - https://docs.mql4.com/trading/orderexpiration
   */
  static datetime Expiration() {
#ifdef __MQL4__
    return ::OrderExpiration();
#else
    // Not supported.
    return 0;
#endif
  }

  /**
   * Returns open time of the currently selected order/position.
   *
   * @see
   * - http://docs.mql4.com/trading/orderopentime
   * - https://www.mql5.com/en/docs/trading/positiongetinteger
   */
  static datetime OpenTime() {
#ifdef __MQL4__
    return ::OrderOpenTime();
#else
    return (datetime)::PositionGetInteger(POSITION_TIME);
#endif
  }

  /*
   * Returns close time of the currently selected order/position.
   *
   * @see:
   * - https://docs.mql4.com/trading/orderclosetime
   */
  static datetime CloseTime() {
#ifdef __MQL4__
    return ::OrderCloseTime();
#else
    // Not supported.
    return 0;
#endif
  }

  /**
   * Returns close price of the currently selected order/position.
   *
   * @docs
   * - https://docs.mql4.com/trading/ordercloseprice
   */
  static double ClosePrice() {
#ifdef __MQL4__
    return ::OrderClosePrice();
#else
    // Not supported.
    return 0;
#endif
  }

  /**
   * Returns calculated commission of the currently selected order/position.
   *
   * @docs
   * - https://docs.mql4.com/trading/ordercommission
   */
  static double Commission() {
#ifdef __MQL4__
    return ::OrderCommission();
#else  // __MQL5__
    // Not supported.
    return 0;
#endif
  }

  /**
   * Returns amount of lots/volume of the selected order/position.
   *
   * @docs
   * - https://docs.mql4.com/trading/orderlots
   * - https://www.mql5.com/en/docs/trading/positiongetdouble
   */
  static double Lots() {
#ifdef __MQL4__
    return ::OrderLots();
#else
    return ::PositionGetDouble(POSITION_VOLUME);
#endif
  }

  /**
   * Returns open price of the currently selected order/position.
   *
   * @docs
   * - http://docs.mql4.com/trading/orderopenprice
   * - https://www.mql5.com/en/docs/trading/positiongetdouble
   */
  static double OpenPrice() {
#ifdef __MQL4__
    return ::OrderOpenPrice();
#else
    return ::PositionGetDouble(POSITION_PRICE_OPEN);
#endif
  }

  /**
   * Returns profit of the currently selected order/position.
   *
   * @docs
   * - http://docs.mql4.com/trading/orderprofit
   *
   * @return
   * Returns the order's net profit value (without swaps or commissions).
   */
  static double Profit() {
#ifdef __MQL4__
    // Returns the net profit value (without swaps or commissions) for the selected order.
    // For open orders, it is the current unrealized profit.
    // For closed orders, it is the fixed profit.
    return ::OrderProfit();
#else
    // Not supported.
    return 0;
#endif
  }

  /**
   * Returns stop loss value of the currently selected order.
   *
   * @docs
   * - http://docs.mql4.com/trading/orderstoploss
   * - https://www.mql5.com/en/docs/trading/positiongetdouble
   */
  static double StopLoss() {
#ifdef __MQL4__
    return ::OrderStopLoss();
#else
    return ::PositionGetDouble(POSITION_SL);
#endif
  }

  /**
   * Returns cumulative swap of the currently selected order/position.
   *
   * @docs
   * - https://docs.mql4.com/trading/orderswap
   * - https://www.mql5.com/en/docs/trading/positiongetdouble
   */
  static double Swap() {
#ifdef __MQL4__
    return ::OrderSwap();
#else
    return ::PositionGetDouble(POSITION_SWAP);
#endif
  }

  /**
   * Returns take profit value of the currently selected order/position.
   *
   * @docs
   * - https://docs.mql4.com/trading/ordertakeprofit
   * - https://www.mql5.com/en/docs/trading/positiongetdouble
   *
   * @return
   * Returns take profit value of the currently selected order/position.
   */
  static double TakeProfit() {
#ifdef __MQL4__
    return ::OrderTakeProfit();
#else
    return ::PositionGetDouble(POSITION_TP);
#endif
  }

  /**
   * Returns an identifying number of the currently selected order/position.
   *
   * @docs
   * - http://docs.mql4.com/trading/ordermagicnumber
   * - https://www.mql5.com/en/docs/trading/positiongetinteger
   *
   * @return
   * Identifying (magic) number of the currently selected order/position.
   */
  static long MagicNumber() {
#ifdef __MQL4__
    return ::OrderMagicNumber();
#else
    return ::PositionGetInteger(POSITION_MAGIC);
#endif
  }

  /**
   * Returns order operation type of the currently selected order/position.
   *
   * @docs
   * - http://docs.mql4.com/trading/ordertype
   * - https://www.mql5.com/en/docs/trading/positiongetinteger
   *
   * @return
   * Order/position operation type.
   */
  static int Type() {
#ifdef __MQL4__
    // @see: ENUM_ORDER_TYPE
    return ::OrderType();
#else
    // @see: ENUM_POSITION_TYPE
    return (int)::PositionGetInteger(POSITION_TYPE);
#endif
  }

  /**
   * Returns comment of the currently selected order/position.
   *
   * @docs
   * - https://docs.mql4.com/trading/ordercomment
   * - https://www.mql5.com/en/docs/trading/positiongetstring
   */
  static string Comment() {
#ifdef __MQL4__
    return ::OrderComment();
#else
    return ::PositionGetString(POSITION_COMMENT);
#endif
  }

  /**
   * Returns symbol name of the currently selected order/position.
   *
   * @docs
   * - https://docs.mql4.com/trading/ordersymbol
   * - https://www.mql5.com/en/docs/trading/positiongetstring
   */
  static string Symbol() {
#ifdef __MQL4__
    return ::OrderSymbol();
#else
    return ::PositionGetString(POSITION_SYMBOL);
#endif
  }

  /**
   * Returns a ticket number of the currently selected order/position.
   *
   * It is a unique number assigned to each order.
   *
   * @docs
   * - https://docs.mql4.com/trading/orderticket
   * - https://www.mql5.com/en/docs/trading/positiongetticket
   */
  static unsigned long Ticket() {
#ifdef __MQL4__
    return ::OrderTicket();
#else
    return ::PositionGetInteger(POSITION_TICKET);
#endif
  }

  /**
   * Prints information about the selected order in the log.
   *
   * @docs
   * - http://docs.mql4.com/trading/orderprint
   */
  static void Print() {
#ifdef __MQL4__
    ::OrderPrint();
#else
    PrintFormat("%d", OrderStatic::Ticket());
#endif
  }
};

/**
 * Proxy class used to serialize MqlTradeRequest object.
 *
 * Usage: SerializerConverter::FromObject(MqlTradeRequestProxy(_request)).ToString<SerializerJson>());
 */
struct MqlTradeRequestProxy : MqlTradeRequest {
  MqlTradeRequestProxy(MqlTradeRequest &r) { this = r; }

  SerializerNodeType Serialize(Serializer &s) {
    s.PassEnum(this, "action", action);
    s.Pass(this, "magic", magic);
    s.Pass(this, "order", order);
    s.Pass(this, "symbol", symbol);
    s.Pass(this, "volume", volume);
    s.Pass(this, "price", price);
    s.Pass(this, "stoplimit", stoplimit);
    s.Pass(this, "sl", sl);
    s.Pass(this, "tp", tp);
    s.Pass(this, "deviation", deviation);
    s.PassEnum(this, "type", type);
    s.PassEnum(this, "type_filling", type_filling);
    s.PassEnum(this, "type_time", type_time);
    s.Pass(this, "expiration", expiration);
    s.Pass(this, "comment", comment);
    s.Pass(this, "position", position);
    s.Pass(this, "position_by", position_by);
    return SerializerNodeObject;
  }
};

/**
 * Proxy class used to serialize MqlTradeResult object.
 *
 * Usage: SerializerConverter::FromObject(MqlTradeResultProxy(_request)).ToString<SerializerJson>());
 */
struct MqlTradeResultProxy : MqlTradeResult {
  MqlTradeResultProxy(MqlTradeResult &r) { this = r; }

  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(this, "retcode", retcode);
    s.Pass(this, "deal", deal);
    s.Pass(this, "order", order);
    s.Pass(this, "volume", volume);
    s.Pass(this, "price", price);
    s.Pass(this, "bid", bid);
    s.Pass(this, "ask", ask);
    s.Pass(this, "comment", comment);
    s.Pass(this, "request_id", request_id);
    s.Pass(this, "retcode_external", retcode_external);
    return SerializerNodeObject;
  }
};
