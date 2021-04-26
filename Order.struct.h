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
 * Includes Order's structs.
 */

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
  bool dummy;                       // Whether order is dummy (fake) or not (real).
  color color_arrow;                // Color of the opening arrow on the chart.
  unsigned short refresh_rate;      // How often to refresh order values (in secs).
  ENUM_ORDER_CONDITION cond_close;  // Close condition.
  MqlParam cond_close_args[];       // Close condition argument.
  // Special struct methods.
  void OrderParams() : dummy(false), color_arrow(clrNONE), refresh_rate(10), cond_close(ORDER_COND_NONE){};
  void OrderParams(bool _dummy) : dummy(_dummy), color_arrow(clrNONE), refresh_rate(10), cond_close(ORDER_COND_NONE){};
  // Getters.
  template <typename T>
  T Get(ENUM_ORDER_PARAM _param) {
    switch (_param) {
      case ORDER_PARAM_COLOR_ARROW:
        return (T) color_arrow;
      case ORDER_PARAM_COND_CLOSE:
        return (T) cond_close;
      case ORDER_PARAM_COND_CLOSE_ARGS:
        return (T) cond_close_args;
      case ORDER_PARAM_DUMMY:
        return (T) dummy;
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
        color_arrow = (color) _value;
        return;
      case ORDER_PARAM_COND_CLOSE:
        cond_close = (ENUM_ORDER_CONDITION) _value;
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
  void SetConditionClose(ENUM_ORDER_CONDITION _cond, MqlParam& _args[]) {
    cond_close = _cond;
    ArrayResize(cond_close_args, ArraySize(_args));
    for (int i = 0; i < ArraySize(_args); i++) {
      cond_close_args[i] = _args[i];
    }
  }
  void SetRefreshRate(unsigned short _value) { refresh_rate = _value; }
  // Serializers.
  SerializerNodeType Serialize(Serializer& s) {
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
  double commission;                     // Commission.
  double profit;                         // Profit.
  double total_profit;                   // Total profit (profit minus fees).
  double price_open;                     // Open price.
  double price_close;                    // Close price.
  double price_current;                  // Current price.
  double price_stoplimit;                // The limit order price for the StopLimit order.
  double swap;                           // Order cumulative swap.
  datetime time_open;                    // Open time.
  datetime time_close;                   // Close time.
  double total_fees;                     // Total fees.
  datetime expiration;                   // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type).
  double sl;                             // Current Stop loss level of the order.
  double tp;                             // Current Take Profit level of the order.
  ENUM_ORDER_TYPE type;                  // Type.
  ENUM_ORDER_TYPE_FILLING type_filling;  // Filling type.
  ENUM_ORDER_TYPE_TIME type_time;        // Lifetime (the order validity period).
  ENUM_ORDER_REASON reason;              // Reason or source for placing an order.
  ENUM_ORDER_REASON_CLOSE reason_close;  // Reason or source for closing an order.
  datetime last_update;                  // Last update of order values.
  unsigned int last_error;               // Last error code.
  double volume;                         // Current volume.
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
        time_close(0),
        time_open(0),
        expiration(0),
        sl(0),
        tp(0),
        last_update(0),
        last_error(ERR_NO_ERROR),
        symbol(NULL),
        volume(0) {}
  // Getters.
  template <typename T>
  T Get(ENUM_ORDER_PROPERTY_CUSTOM _prop_name) {
    switch (_prop_name) {
      case ORDER_PROP_REASON_CLOSE: return reason_close;
      /* @todo
      case ORDER_PARAM_CLOSE: return reason_close;
      case ORDER_PARAM_COMMENT: return comment;
      case ORDER_PARAM_COMMISSION: return commission.
      case ORDER_PARAM_CURRENT: return current;
      case ORDER_PARAM_EXPIRATION: return expiration;
      case ORDER_PARAM_EXT_ID: return ext_id;
      case ORDER_PARAM_FILLING: return filling;
      case ORDER_PARAM_LAST_ERROR: return last_error;
      case ORDER_PARAM_LAST_UPDATE: return last_update;
      case ORDER_PARAM_MAGIC: return magic;
      case ORDER_PARAM_OPEN: return open;
      case ORDER_PARAM_POSITION_BY_ID: return position_by_id;
      case ORDER_PARAM_POSITION_ID: return position_id;
      case ORDER_PARAM_PROFIT: return profit;
      case ORDER_PARAM_REASON: return reason;
      case ORDER_PARAM_REASON_CLOSE: return reason_close;
      case ORDER_PARAM_SL: return sl;
      case ORDER_PARAM_STATE: return state;
      case ORDER_PARAM_STOPLIMIT: return stoplimit;
      case ORDER_PARAM_SWAP: return swap;
      case ORDER_PARAM_SYMBOL: return symbol;
      case ORDER_PARAM_TICKET: return ticket;
      case ORDER_PARAM_TIME_CLOSE: return time_close;
      case ORDER_PARAM_TIME_OPEN: return time_open;
      case ORDER_PARAM_TOTAL_FEES: return total_fees;
      case ORDER_PARAM_TOTAL_PROFIT: return total_profit;
      case ORDER_PARAM_TP: return tp;
      case ORDER_PARAM_TYPE: return type;
      case ORDER_PARAM_TYPE_TIME: return type_time;
      case ORDER_PARAM_VOLUME: return volume;
      */
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  double Get(ENUM_ORDER_PROPERTY_DOUBLE _prop_name) {
    switch (_prop_name) {
      // case ORDER_VOLUME_INITIAL: // @todo?
      case ORDER_VOLUME_CURRENT: return volume;
      case ORDER_PRICE_OPEN: return price_open;
      case ORDER_SL: return sl;
      case ORDER_TP: return tp;
      case ORDER_PRICE_CURRENT: return price_current;
      case ORDER_PRICE_STOPLIMIT: return price_stoplimit;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  long Get(ENUM_ORDER_PROPERTY_INTEGER _prop_name) {
    switch (_prop_name) {
      case ORDER_TICKET: return (long) ticket;
      // case ORDER_TIME_SETUP: return time_setup; // @todo
      case ORDER_TYPE: return type;
      case ORDER_STATE: return state;
      case ORDER_TIME_EXPIRATION: return expiration;
      // case ORDER_TIME_DONE: return time_done; // @todo
      // case ORDER_TIME_SETUP_MSC: return time_setup_msc; // @todo
      // case ORDER_TIME_DONE_MSC: return time_done_msc; // @todo
      case ORDER_TYPE_FILLING: return type_filling;
      case ORDER_TYPE_TIME: return type_time;
      case ORDER_MAGIC: return (long) magic;
      case ORDER_REASON: return reason;
      case ORDER_POSITION_ID: return (long) position_id;
      case ORDER_POSITION_BY_ID: return (long) position_by_id;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  string Get(ENUM_ORDER_PROPERTY_STRING _prop_name) {
    switch (_prop_name) {
      case ORDER_COMMENT: return comment;
      case ORDER_EXTERNAL_ID: return ext_id;
      case ORDER_SYMBOL: return symbol;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return "";
  }
  string GetReasonCloseText() {
    switch (reason_close) {
      case ORDER_REASON_CLOSED_ALL: return "Closed all";
      case ORDER_REASON_CLOSED_BY_ACTION: return "Closed by action";
      case ORDER_REASON_CLOSED_BY_EXPIRE: return "Expired";
      case ORDER_REASON_CLOSED_BY_OPPOSITE: return "Closed by opposite trade";
      case ORDER_REASON_CLOSED_BY_SIGNAL: return "Closed by signal";
      case ORDER_REASON_CLOSED_BY_SL: return "Closed by stop loss";
      case ORDER_REASON_CLOSED_BY_TEST: return "Closed by test";
      case ORDER_REASON_CLOSED_BY_TP: return "Closed by take profit";
      case ORDER_REASON_CLOSED_BY_USER: return "Closed by user";
      case ORDER_REASON_CLOSED_UNKNOWN: return "Unknown";
    }
    return "Unknown";
  }
  unsigned long GetPositionID(unsigned long _value) { return position_id; }
  unsigned long GetPositionByID(unsigned long _value) { return position_by_id; }
  // Setters.
  template <typename T>
  void Set(ENUM_ORDER_PROPERTY_CUSTOM _prop_name, T _value) {
    switch (_prop_name) {
      case ORDER_PROP_REASON_CLOSE: reason_close = _value;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void Set(ENUM_ORDER_PROPERTY_DOUBLE _prop_name, double _value) {
    switch (_prop_name) {
      // case ORDER_VOLUME_INITIAL: // @todo?
      case ORDER_VOLUME_CURRENT: volume = _value; return;
      case ORDER_PRICE_OPEN: price_open = _value; return;
      case ORDER_SL: sl = _value; return;
      case ORDER_TP: tp = _value; return;
      case ORDER_PRICE_CURRENT: price_current = _value; UpdateProfit(); return;
      case ORDER_PRICE_STOPLIMIT: price_stoplimit = _value; return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void Set(ENUM_ORDER_PROPERTY_INTEGER _prop_name, long _value) {
    switch (_prop_name) {
      case ORDER_TICKET: ticket = _value; return;
      // case ORDER_TIME_SETUP: time_setup = _value; return; // @todo
      case ORDER_TYPE: type = (ENUM_ORDER_TYPE) _value; return;
      case ORDER_STATE: state = (ENUM_ORDER_STATE) _value; return;
      case ORDER_TIME_EXPIRATION: expiration = (datetime) _value; return;
      // case ORDER_TIME_DONE: time_done = _value; return; // @todo
      // case ORDER_TIME_SETUP_MSC: time_setup_msc = _value; return; // @todo
      // case ORDER_TIME_DONE_MSC: time_done_msc = _value; return; // @todo
      case ORDER_TYPE_FILLING: type_filling = (ENUM_ORDER_TYPE_FILLING) _value; return;
      case ORDER_TYPE_TIME: type_time = (ENUM_ORDER_TYPE_TIME) _value; return;
      case ORDER_MAGIC: magic = _value; return;
      case ORDER_REASON: reason = (ENUM_ORDER_REASON) _value; return;
      case ORDER_POSITION_ID: position_id = _value; return;
      case ORDER_POSITION_BY_ID: position_by_id = _value; return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void Set(ENUM_ORDER_PROPERTY_STRING _prop_name, string _value) {
    switch (_prop_name) {
      case ORDER_COMMENT: comment = _value; return;
      case ORDER_EXTERNAL_ID: ext_id = _value; return;
      case ORDER_SYMBOL: symbol = _value; return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  /* @todo
  template <typename T>
  void Set(ENUM_ORDER_PARAM _param, T _value) {
    switch (_prop_name) {
      case ORDER_PARAM_CLOSE: reason_close = _value; return;
      case ORDER_PARAM_COMMENT: comment = _value; return;
      case ORDER_PARAM_COMMISSION: commission = _value; return;
      case ORDER_PARAM_CURRENT: current = _value; return;
      case ORDER_PARAM_EXPIRATION: expiration = _value; return;
      case ORDER_PARAM_EXT_ID: ext_id = _value; return;
      case ORDER_PARAM_FILLING: filling = _value; return;
      case ORDER_PARAM_LAST_ERROR: last_error = _value; return;
      case ORDER_PARAM_LAST_UPDATE: last_update = _value; return;
      case ORDER_PARAM_MAGIC: magic = _value; return;
      case ORDER_PARAM_OPEN: open = _value; return;
      case ORDER_PARAM_POSITION_BY_ID: position_by_id = _value; return;
      case ORDER_PARAM_POSITION_ID: position_id = _value; return;
      case ORDER_PARAM_PROFIT: profit = _value; return;
      case ORDER_PARAM_REASON: reason = _value; return;
      case ORDER_PARAM_REASON_CLOSE: reason_close = _value; return;
      case ORDER_PARAM_SL: sl = _value; return;
      case ORDER_PARAM_STATE: state = _value; return;
      case ORDER_PARAM_STOPLIMIT: stoplimit = _value; return;
      case ORDER_PARAM_SWAP: swap = _value; return;
      case ORDER_PARAM_SYMBOL: ymbol = _value; return;
      case ORDER_PARAM_TICKET: ticket = _value; return;
      case ORDER_PARAM_TIME_CLOSE: time_close = _value; return;
      case ORDER_PARAM_TIME_OPEN: time_open = _value; return;
      case ORDER_PARAM_TOTAL_FEES: total_fees = _value; return;
      case ORDER_PARAM_TOTAL_PROFIT: total_profit = _value; return;
      case ORDER_PARAM_TP: tp = _value; return;
      case ORDER_PARAM_TYPE: ype = _value; return;
      case ORDER_PARAM_TYPE_TIME: type_time = _value; return;
      case ORDER_PARAM_VOLUME: volume = _value; return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  */
  void ProcessLastError() { last_error = fmax(last_error, Terminal::GetLastError()); }
  void ResetError() {
    ResetLastError();
    last_error = ERR_NO_ERROR;
  }
  void SetComment(string _value) { comment = _value; }
  void SetExpiration(datetime _exp) { expiration = _exp; }
  void SetLastError(unsigned int _value) { last_error = _value; }
  void SetLastUpdate(datetime _value) { last_update = _value; }
  void SetMagicNo(long _value) { magic = _value; }
  void SetPriceClose(double _value) { price_close = _value; }
  void SetPriceCurrent(double _value) {
    price_current = _value;
    UpdateProfit();
  }
  void SetPriceOpen(double _value) { price_open = _value; }
  void SetPriceStopLimit(double _value) { price_stoplimit = _value; }
  void SetProfit(double _profit) { profit = _profit; }
  void SetProfitTake(double _value) { tp = _value; }
  void SetReason(long _reason) { reason = (ENUM_ORDER_REASON)_reason; }
  void SetReason(ENUM_ORDER_REASON _reason) { reason = _reason; }
  void SetReasonClose(ENUM_ORDER_REASON_CLOSE _reason_close) { reason_close = _reason_close; }
  void SetState(ENUM_ORDER_STATE _state) { state = _state; }
  void SetState(long _state) { state = (ENUM_ORDER_STATE)_state; }
  void SetStopLoss(double _value) { sl = _value; }
  void SetSymbol(string _value) { symbol = _value; }
  void SetTicket(long _value) { ticket = _value; }
  void SetTimeClose(datetime _value) { time_close = _value; }
  void SetTimeOpen(datetime _value) { time_open = _value; }
  void SetType(ENUM_ORDER_TYPE _type) { type = _type; }
  void SetType(long _type) { type = (ENUM_ORDER_TYPE)_type; }
  void SetTypeFilling(ENUM_ORDER_TYPE_FILLING _type) { type_filling = _type; }
  void SetTypeFilling(long _type) { type_filling = (ENUM_ORDER_TYPE_FILLING)_type; }
  void SetTypeTime(ENUM_ORDER_TYPE_TIME _value) { type_time = _value; }
  void SetTypeTime(long _value) { type_time = (ENUM_ORDER_TYPE_TIME)_value; }
  void SetVolume(double _value) { volume = _value; }
  void UpdateProfit() { profit = price_open - price_current; }
  // Serializers.
  SerializerNodeType Serialize(Serializer& s) {
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
    s.Pass(this, "time_open", time_open);
    s.Pass(this, "time_close", time_close);
    s.Pass(this, "total_fees", total_fees);
    s.Pass(this, "expiration", expiration);
    s.Pass(this, "sl", sl);
    s.Pass(this, "tp", tp);
    s.PassEnum(this, "type", type);
    s.PassEnum(this, "type_filling", type_filling);
    s.PassEnum(this, "type_time", type_time);
    s.PassEnum(this, "reason", reason);
    s.Pass(this, "last_update", last_update);
    s.Pass(this, "last_error", last_error);
    s.Pass(this, "volume", volume);
    s.Pass(this, "comment", comment);
    s.Pass(this, "ext_id", ext_id);
    s.Pass(this, "symbol", symbol);

    return SerializerNodeObject;
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
