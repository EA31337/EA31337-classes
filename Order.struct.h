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

// Includes.
#include "Data.struct.h"
#include "Order.enum.h"
#include "Serializer/Serializer.h"
#include "SymbolInfo.struct.static.h"
#include "Terminal.mqh"

#ifndef __MQL5__
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

// @see: https://www.mql5.com/en/docs/constants/structures/mqltraderequest
struct MqlTradeRequest {
  ENUM_TRADE_REQUEST_ACTIONS action;     // Trade operation type.
  unsigned long magic;                   // Expert Advisor ID (magic number).
  unsigned long order;                   // Order ticket.
  string symbol;                         // Trade symbol.
  double volume;                         // Requested volume for a deal in lots.
  double price;                          // Price.
  double stoplimit;                      // StopLimit level of the order.
  double sl;                             // Stop Loss level of the order.
  double tp;                             // Take Profit level of the order.
  unsigned long deviation;               // Maximal possible deviation from the requested price.
  ENUM_ORDER_TYPE type;                  // Order type.
  ENUM_ORDER_TYPE_FILLING type_filling;  // Order execution type.
  ENUM_ORDER_TYPE_TIME type_time;        // Order expiration type.
  datetime expiration;                   // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type.
  string comment;                        // Order comment.
  unsigned long position;                // Position ticket.
  unsigned long position_by;             // The ticket of an opposite position.
};

// @see: https://www.mql5.com/en/docs/constants/structures/mqltraderesult
struct MqlTradeResult {
  unsigned int retcode;  // Operation return code.
  unsigned long deal;    // Deal ticket, if it is performed.
  unsigned long order;   // Order ticket, if it is placed.
  double volume;         // Deal volume, confirmed by broker.
  double price;          // Deal price, confirmed by broker.
  double bid;            // Current Bid price.
  double ask;            // Current Ask price.
  string comment;  // Broker comment to operation (by default it is filled by description of trade server return code).
  unsigned int request_id;        // Request ID set by the terminal during the dispatch.
  unsigned int retcode_external;  // Return code of an external trading system.
};
#endif

/**
 * The structure for order parameters.
 */
struct OrderParams {
  struct OrderCloseCond {
    ENUM_ORDER_CONDITION cond;         // Close condition.
    ARRAY(DataParamEntry, cond_args);  // Close condition argument.
    // Getters.
    ENUM_ORDER_CONDITION GetCondition() { return cond; }
    template <typename T>
    T GetConditionArgValue(int _index = 0) {
      return cond_args[_index].ToValue<T>();
    }
    // Setters.
    void SetCondition(ENUM_ORDER_CONDITION _cond) { cond = _cond; }
    template <typename T>
    void SetConditionArg(T _value, int _index = 0) {
      DataParamEntry _arg = DataParamEntry::FromValue(_value);
      SetConditionArg(_arg, _index);
    }
    void SetConditionArg(DataParamEntry &_arg, int _index = 0) {
      int _size = ArraySize(cond_args);
      if (_size <= _index) {
        ArrayResize(cond_args, _index + 1);
      }
      cond_args[_index] = _arg;
    }
    void SetConditionArgs(ARRAY_REF(DataParamEntry, _args)) {
      ArrayResize(cond_args, ArraySize(_args));
      for (int i = 0; i < ArraySize(_args); i++) {
        cond_args[i] = _args[i];
      }
    }
    // Static methods.
    static bool Resize(ARRAY_REF(OrderCloseCond, _cond_close), int _index = 0) {
      bool _result = true;
      int _size = ArraySize(_cond_close);
      if (_size <= _index) {
        _result &= ArrayResize(_cond_close, _size + 1);
      }
      return _result;
    }
    // Serializers.
    SerializerNodeType Serialize(Serializer &s) {
      s.PassEnum(THIS_REF, "cond", cond);
      // s.Pass(THIS_REF, "cond_args", cond_args);
      return SerializerNodeObject;
    }
  } cond_close[];
  bool dummy;                   // Whether order is dummy (fake) or not (real).
  color color_arrow;            // Color of the opening arrow on the chart.
  unsigned short refresh_freq;  // How often to refresh order values (in secs).
  unsigned short update_freq;   // How often to update order stops (in secs).
  // Special struct methods.
  OrderParams() : dummy(false), color_arrow(clrNONE), refresh_freq(10), update_freq(60){};
  OrderParams(bool _dummy) : dummy(_dummy), color_arrow(clrNONE), refresh_freq(10), update_freq(60){};
  // Getters.
  template <typename T>
  T Get(ENUM_ORDER_PARAM _param, int _index1 = 0, int _index2 = 0) {
    switch (_param) {
      case ORDER_PARAM_COLOR_ARROW:
        return (T)color_arrow;
      case ORDER_PARAM_COND_CLOSE:
        return (T)cond_close[_index1].cond;
      case ORDER_PARAM_COND_CLOSE_ARG_VALUE:
        return (T)cond_close[_index1].GetConditionArgValue<T>(_index2);
      case ORDER_PARAM_COND_CLOSE_NUM:
        return (T)ArraySize(cond_close);
      case ORDER_PARAM_DUMMY:
        return (T)dummy;
      case ORDER_PARAM_REFRESH_FREQ:
        return (T)refresh_freq;
      case ORDER_PARAM_UPDATE_FREQ:
        return (T)update_freq;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  // State checkers
  bool HasCloseCondition() { return ArraySize(cond_close) > 0; }
  bool IsDummy() { return dummy; }
  // Setters.
  void AddConditionClose(ENUM_ORDER_CONDITION _cond, ARRAY_REF(DataParamEntry, _args)) {
    SetConditionClose(_cond, _args, ArraySize(cond_close));
  }
  template <typename T>
  void Set(ENUM_ORDER_PARAM _param, T _value, int _index1 = 0, int _index2 = 0) {
    switch (_param) {
      case ORDER_PARAM_COLOR_ARROW:
        color_arrow = (color)_value;
        return;
      case ORDER_PARAM_COND_CLOSE:
        SetConditionClose((ENUM_ORDER_CONDITION)_value, _index1);
        return;
      case ORDER_PARAM_COND_CLOSE_ARG_VALUE:
        cond_close[_index1].SetConditionArg(_value, _index2);
        return;
      case ORDER_PARAM_DUMMY:
        dummy = _value;
        return;
      case ORDER_PARAM_REFRESH_FREQ:
        refresh_freq = (unsigned short)_value;
        return;
      case ORDER_PARAM_UPDATE_FREQ:
        update_freq = (unsigned short)_value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void SetConditionClose(ENUM_ORDER_CONDITION _cond, int _index = 0) {
    DataParamEntry _args[];
    SetConditionClose(_cond, _args, _index);
  }
  void SetConditionClose(ENUM_ORDER_CONDITION _cond, ARRAY_REF(DataParamEntry, _args), int _index = 0) {
    OrderCloseCond::Resize(cond_close, _index);
    cond_close[_index].SetCondition(_cond);
    cond_close[_index].SetConditionArgs(_args);
  }
  void SetRefreshRate(unsigned short _value) { refresh_freq = _value; }
  // Serializers.
  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(THIS_REF, "dummy", dummy);
    s.Pass(THIS_REF, "color_arrow", color_arrow);
    s.Pass(THIS_REF, "refresh_freq", refresh_freq);
    // s.Pass(THIS_REF, "cond_close", cond_close);
    return SerializerNodeObject;
  }
};

/**
 * The structure for order data.
 */
struct OrderData {
 protected:
  unsigned long magic;                   // Magic number.
  unsigned long position_id;             // Position ID.
  unsigned long position_by_id;          // Position By ID.
  unsigned long ticket;                  // Ticket number.
  ENUM_ORDER_STATE state;                // State.
  datetime time_closed;                  // Closed time.
  datetime time_done;                    // Execution/cancellation time.
  datetime time_expiration;              // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type).
  datetime time_setup;                   // Setup time.
  datetime time_last_refresh;            // Last refresh of order values.
  datetime time_last_update;             // Last update of order stops.
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
 public:
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
        time_last_refresh(0),
        time_last_update(0),
        time_setup(0),
        time_setup_msc(0),
        sl(0),
        tp(0),
        last_error(ERR_NO_ERROR),
        symbol(NULL),
        volume_curr(0),
        volume_init(0) {}
  // Copy constructor.
  OrderData(OrderData &_odata) { this = _odata; }
  // Getters.
  template <typename T>
  T Get(ENUM_ORDER_PROPERTY_CUSTOM _prop_name) {
    double _tick_value = SymbolInfoStatic::GetTickValue(symbol);
    switch (_prop_name) {
      case ORDER_PROP_COMMISSION:
        return (T)commission;
      case ORDER_PROP_LAST_ERROR:
        return (T)last_error;
      case ORDER_PROP_PRICE_CLOSE:
        return (T)price_close;
      case ORDER_PROP_PRICE_OPEN:
        return (T)price_open;
      case ORDER_PROP_PRICE_STOPLIMIT:
        return (T)price_stoplimit;
      case ORDER_PROP_PROFIT:
        return (T)profit;
      case ORDER_PROP_PROFIT_PIPS:
        return (T)(profit * pow(10, SymbolInfoStatic::GetDigits(symbol)));
      case ORDER_PROP_PROFIT_VALUE:
        return (T)(Get<int>(ORDER_PROP_PROFIT_PIPS) * volume_curr * SymbolInfoStatic::GetTickValue(symbol));
      case ORDER_PROP_PROFIT_TOTAL:
        return (T)(profit - total_fees);
      case ORDER_PROP_REASON_CLOSE:
        return (T)reason_close;
      case ORDER_PROP_TICKET:
        return (T)ticket;
      case ORDER_PROP_TIME_CLOSED:
        return (T)time_closed;
      case ORDER_PROP_TIME_LAST_REFRESH:
        return (T)time_last_refresh;
      case ORDER_PROP_TIME_LAST_UPDATE:
        return (T)time_last_update;
      case ORDER_PROP_TIME_OPENED:
        return (T)time_done;
      case ORDER_PROP_TOTAL_FEES:
        return (T)total_fees;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  template <typename T>
  T Get(ENUM_ORDER_PROPERTY_DOUBLE _prop_name) {
    // See: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
    switch (_prop_name) {
      case ORDER_VOLUME_CURRENT:
        return (T)volume_curr;
      case ORDER_VOLUME_INITIAL:
        return (T)volume_init;
      case ORDER_PRICE_OPEN:
        return (T)price_open;
      case ORDER_SL:
        return (T)sl;
      case ORDER_TP:
        return (T)tp;
      case ORDER_PRICE_CURRENT:
        return (T)price_current;
      case ORDER_PRICE_STOPLIMIT:
        return (T)price_stoplimit;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  template <typename T>
  T Get(ENUM_ORDER_PROPERTY_INTEGER _prop_name) {
    // See: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
    switch (_prop_name) {
      // case ORDER_TIME_SETUP: return time_setup; // @todo
      case ORDER_TYPE:
        return (T)type;
      case ORDER_STATE:
        return (T)state;
      case ORDER_TIME_EXPIRATION:
        return (T)time_expiration;
      case ORDER_TIME_DONE:
        return (T)time_done;
      case ORDER_TIME_DONE_MSC:
        return (T)time_done_msc;
      case ORDER_TIME_SETUP:
        return (T)time_setup;
      case ORDER_TIME_SETUP_MSC:
        return (T)time_setup_msc;
      case ORDER_TYPE_FILLING:
        return (T)type_filling;
      case ORDER_TYPE_TIME:
        return (T)type_time;
      case ORDER_MAGIC:
        return (T)magic;
#ifndef __MQL4__
      case ORDER_POSITION_ID:
        return (T)position_id;
      case ORDER_POSITION_BY_ID:
        return (T)position_by_id;
      case ORDER_REASON:
        return (T)reason;
      case ORDER_TICKET:
        return (T)ticket;
#endif
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  string Get(ENUM_ORDER_PROPERTY_STRING _prop_name) {
    // See: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
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
  /*
   * Returns order type value.
   *
   * @param
   *   _type ENUM_ORDER_TYPE Order operation type of the order.
   *
   * @return
   *   Returns 1 for buy, -1 for sell orders, otherwise 0.
   */
  short GetTypeValue() { return GetTypeValue(type); }
  /*
   * Returns order type value.
   *
   * @param
   *   _type ENUM_ORDER_TYPE Order operation type of the order.
   *
   * @return
   *   Returns 1 for buy, -1 for sell orders, otherwise 0.
   */
  static short GetTypeValue(ENUM_ORDER_TYPE _type) {
    switch (_type) {
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
        // All sell orders are -1.
        return -1;
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
        // All buy orders are -1.
        return 1;
      default:
        return 0;
    }
  }
  /*
  template <typename T>
  T Get(int _prop_name) {
    // MQL4 back-compatibility version for non-enum properties.
    return Get<T>((ENUM_ORDER_PROPERTY_INTEGER)_prop_name);
  }
  */
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
      case ORDER_PROP_COMMISSION:
        commission = (double)_value;
        return;
      case ORDER_PROP_LAST_ERROR:
        last_error = (unsigned int)_value;
        return;
      case ORDER_PROP_PRICE_CLOSE:
        price_close = (double)_value;
        return;
      case ORDER_PROP_PRICE_OPEN:
        price_open = (double)_value;
        return;
      case ORDER_PROP_PRICE_STOPLIMIT:
        price_stoplimit = (double)_value;
        return;
      case ORDER_PROP_PROFIT:
        profit = (double)_value;
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
      case ORDER_PROP_TIME_LAST_REFRESH:
        time_last_refresh = (datetime)_value;
        return;
      case ORDER_PROP_TIME_LAST_UPDATE:
        time_last_update = (datetime)_value;
        return;
      case ORDER_PROP_TIME_OPENED:
        time_setup = (datetime)_value;
        return;
      case ORDER_PROP_TOTAL_FEES:
        total_fees = (double)_value;
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
        RefreshProfit();
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
  /*
  template <typename T>
  T Set(long _prop_name) {
    // MQL4 back-compatibility version for non-enum properties.
    return Set<T>((ENUM_ORDER_PROPERTY_INTEGER)_prop_name);
  }
  */
  void ProcessLastError() { last_error = MathMax(last_error, (unsigned int)Terminal::GetLastError()); }
  void ResetError() {
    ResetLastError();
    last_error = ERR_NO_ERROR;
  }
  void RefreshProfit() { profit = (price_current - price_open) * GetTypeValue(); }
  // Serializers.
  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(THIS_REF, "magic", magic);
    s.Pass(THIS_REF, "position_id", position_id);
    s.Pass(THIS_REF, "position_by_id", position_by_id);
    s.Pass(THIS_REF, "ticket", ticket);
    s.PassEnum(THIS_REF, "state", state);
    s.Pass(THIS_REF, "commission", commission);
    s.Pass(THIS_REF, "profit", profit);
    s.Pass(THIS_REF, "total_profit", total_profit);
    s.Pass(THIS_REF, "price_open", price_open);
    s.Pass(THIS_REF, "price_close", price_close);
    s.Pass(THIS_REF, "price_current", price_current);
    s.Pass(THIS_REF, "price_stoplimit", price_stoplimit);
    s.Pass(THIS_REF, "swap", swap);
    s.Pass(THIS_REF, "time_closed", time_closed);
    s.Pass(THIS_REF, "time_done", time_done);
    s.Pass(THIS_REF, "time_done_msc", time_done_msc);
    s.Pass(THIS_REF, "time_expiration", time_expiration);
    s.Pass(THIS_REF, "time_last_update", time_last_update);
    s.Pass(THIS_REF, "time_setup", time_setup);
    s.Pass(THIS_REF, "time_setup_msc", time_setup_msc);
    s.Pass(THIS_REF, "total_fees", total_fees);
    s.Pass(THIS_REF, "sl", sl);
    s.Pass(THIS_REF, "tp", tp);
    s.PassEnum(THIS_REF, "type", type);
    s.PassEnum(THIS_REF, "type_filling", type_filling);
    s.PassEnum(THIS_REF, "type_time", type_time);
    s.PassEnum(THIS_REF, "reason", reason);
    s.Pass(THIS_REF, "last_error", last_error);
    s.Pass(THIS_REF, "volume_current", volume_curr);
    s.Pass(THIS_REF, "volume_init", volume_init);
    s.Pass(THIS_REF, "comment", comment);
    s.Pass(THIS_REF, "ext_id", ext_id);
    s.Pass(THIS_REF, "symbol", symbol);

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
  MqlTradeRequestProxy(MqlTradeRequest &r) { THIS_REF = r; }

  SerializerNodeType Serialize(Serializer &s) {
    s.PassEnum(THIS_REF, "action", action);
    s.Pass(THIS_REF, "magic", magic);
    s.Pass(THIS_REF, "order", order);
    s.Pass(THIS_REF, "symbol", symbol);
    s.Pass(THIS_REF, "volume", volume);
    s.Pass(THIS_REF, "price", price);
    s.Pass(THIS_REF, "stoplimit", stoplimit);
    s.Pass(THIS_REF, "sl", sl);
    s.Pass(THIS_REF, "tp", tp);
    s.Pass(THIS_REF, "deviation", deviation);
    s.PassEnum(THIS_REF, "type", type);
    s.PassEnum(THIS_REF, "type_filling", type_filling);
    s.PassEnum(THIS_REF, "type_time", type_time);
    s.Pass(THIS_REF, "expiration", expiration);
    s.Pass(THIS_REF, "comment", comment);
    s.Pass(THIS_REF, "position", position);
    s.Pass(THIS_REF, "position_by", position_by);
    return SerializerNodeObject;
  }
};

/**
 * Proxy class used to serialize MqlTradeResult object.
 *
 * Usage: SerializerConverter::FromObject(MqlTradeResultProxy(_request)).ToString<SerializerJson>());
 */
struct MqlTradeResultProxy : MqlTradeResult {
  MqlTradeResultProxy(MqlTradeResult &r) { THIS_REF = r; }

  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(THIS_REF, "retcode", retcode);
    s.Pass(THIS_REF, "deal", deal);
    s.Pass(THIS_REF, "order", order);
    s.Pass(THIS_REF, "volume", volume);
    s.Pass(THIS_REF, "price", price);
    s.Pass(THIS_REF, "bid", bid);
    s.Pass(THIS_REF, "ask", ask);
    s.Pass(THIS_REF, "comment", comment);
    s.Pass(THIS_REF, "request_id", request_id);
    s.Pass(THIS_REF, "retcode_external", retcode_external);
    return SerializerNodeObject;
  }
};
