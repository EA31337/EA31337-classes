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
  bool dummy;                        // Whether order is dummy (fake) or not (real).
  color color_arrow;                 // Color of the opening arrow on the chart.
  unsigned short refresh_rate;       // How often to refresh order values (in sec).
  ENUM_ORDER_CONDITION cond_close;   // Close condition.
  DataParamEntry cond_close_args[];  // Close condition argument.
  // Special struct methods.
  void OrderParams() : dummy(false), color_arrow(clrNONE), refresh_rate(10), cond_close(ORDER_COND_NONE){};
  void OrderParams(bool _dummy) : dummy(_dummy), color_arrow(clrNONE), refresh_rate(10), cond_close(ORDER_COND_NONE){};
  // Getters.
  // State checkers
  bool HasCloseCondition() { return cond_close != ORDER_COND_NONE; }
  bool IsDummy() { return dummy; }
  // Setters.
  void SetConditionClose(ENUM_ORDER_CONDITION _cond, DataParamEntry &_args[]) {
    cond_close = _cond;
    ArrayResize(cond_close_args, ArraySize(_args));
    for (int i = 0; i < ArraySize(_args); i++) {
      cond_close_args[i] = _args[i];
    }
  }
  void SetRefreshRate(unsigned short _value) { refresh_rate = _value; }
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
  unsigned long GetPositionID(unsigned long _value) { return position_id; }
  unsigned long GetPositionByID(unsigned long _value) { return position_by_id; }
  // Setters.
  void ProcessLastError() { last_error = fmax(last_error, Terminal::GetLastError()); }
  void ResetError() {
    ResetLastError();
    last_error = ERR_NO_ERROR;
  }
  void SetComment(string _value) { comment = _value; }
  void SetExpiration(datetime _exp) { expiration = _exp; }
  void SetLastError(unsigned int _value) { last_error = _value; }
  void SetLastUpdate(datetime _value) { last_update = _value; }
  void SetMagicNo(unsigned long _value) { magic = _value; }
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
  void SetState(ENUM_ORDER_STATE _state) { state = _state; }
  void SetState(long _state) { state = (ENUM_ORDER_STATE)_state; }
  void SetStopLoss(double _value) { sl = _value; }
  void SetSymbol(string _value) { symbol = _value; }
  void SetTicket(unsigned long _value) { ticket = _value; }
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
