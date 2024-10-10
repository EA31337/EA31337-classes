//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
 * Includes Account's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward class declaration.
class Serializer;

// Includes.
#include "../../Platform/Terminal.define.h"
#include "../../Serializer/Serializer.enum.h"
#include "../../Serializer/Serializer.h"
#include "../../Serializer/SerializerConverter.h"
#include "../../Serializer/SerializerJson.h"
#include "Account.enum.h"

// Struct for account entries.
struct AccountEntry {
  datetime dtime;
  double balance;
  double credit;
  double equity;
  double profit;
  double margin_used;
  double margin_free;
  double margin_avail;

  // Default constructor.
  AccountEntry() {}

  // Constructor.
  AccountEntry(const AccountEntry& r)
      : dtime(r.dtime),
        balance(r.balance),
        credit(r.credit),
        equity(r.equity),
        profit(r.profit),
        margin_used(r.margin_used),
        margin_free(r.margin_free),
        margin_avail(r.margin_avail) {}

  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    _s.Pass(THIS_REF, "time", dtime, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "balance", balance, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "credit", credit, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "equity", equity, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "profit", profit, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "margin_used", margin_used, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "margin_free", margin_free, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "margin_avail", margin_avail, SERIALIZER_FIELD_FLAG_DYNAMIC);
    return SerializerNodeObject;
  }
  /* Getters */
  double Get(ENUM_ACCOUNT_INFO_DOUBLE _param) {
    switch (_param) {
      case ACCOUNT_BALANCE:
        // Account balance in the deposit currency (double).
        return balance;
      case ACCOUNT_CREDIT:
        // Account credit in the deposit currency (double).
        return credit;
      case ACCOUNT_PROFIT:
        // Current profit of an account in the deposit currency (double).
        return profit;
      case ACCOUNT_EQUITY:
        // Account equity in the deposit currency (double).
        return equity;
      case ACCOUNT_MARGIN:
        // Account margin used in the deposit currency (double).
        return margin_used;
      case ACCOUNT_MARGIN_FREE:
        // Free margin of an account in the deposit currency (double).
        return margin_free;
      case ACCOUNT_MARGIN_LEVEL:
        // Account margin level in percents (double).
        return margin_avail;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
};

// Struct for account parameters.
struct AccountParams {
  ENUM_ACCOUNT_MARGIN_MODE margin_mode;
  ENUM_ACCOUNT_STOPOUT_MODE margin_so_mode;
  ENUM_ACCOUNT_TRADE_MODE trade_mode;
  bool trade_allowed, trade_expert;
  int currency_digits, fifo_close, leverage, limit_orders, login;
  string company, currency, name, server;

  // Default constructor.
  AccountParams(int _login = 0, string _name = "Current", string _currency = "USD", string _company = "Unknown",
                string _server = "Unknown")
      : company(_company), currency(_currency), login(_login), name(_name), server(_server) {}
  // Constructor based on JSON string.
  AccountParams(string _entry) { SerializerConverter::FromString<SerializerJson>(_entry).ToStruct(THIS_REF); }
  // Copy constructor.
  AccountParams(const AccountParams& _aparams) { THIS_REF = _aparams; }
  /* Getters */
  template <typename T>
  T Get(ENUM_ACCOUNT_PARAM_INTEGER _param) {
    switch (_param) {
      case ACCOUNT_PARAM_CURRENCY_DIGITS:
        // The number of decimal places in the account currency (int).
        return (T)currency_digits;
      case ACCOUNT_PARAM_FIFO_CLOSE:
        // An indication showing that positions can only be closed by FIFO rule (bool).
        return (T)fifo_close;
      case ACCOUNT_PARAM_LEVERAGE:
        // Account leverage (long).
        return (T)leverage;
      case ACCOUNT_PARAM_LIMIT_ORDERS:
        // Maximum allowed number of active pending orders (int).
        return (T)limit_orders;
      case ACCOUNT_PARAM_LOGIN:
        // Account number (long).
        return (T)login;
      case ACCOUNT_PARAM_MARGIN_MODE:
        // Margin calculation mode (ENUM_ACCOUNT_MARGIN_MODE).
        return (T)margin_mode;
      case ACCOUNT_PARAM_MARGIN_SO_MODE:
        // Mode for setting the minimal allowed margin (ENUM_ACCOUNT_STOPOUT_MODE).
        return (T)margin_so_mode;
      case ACCOUNT_PARAM_TRADE_ALLOWED:
        // Allowed trade for the current account (bool).
        return (T)trade_allowed;
      case ACCOUNT_PARAM_TRADE_EXPERT:
        // Allowed trade for an Expert Advisor (bool).
        return (T)trade_expert;
      case ACCOUNT_PARAM_TRADE_MODE:
        // Account trade mode (ENUM_ACCOUNT_TRADE_MODE).
        return (T)trade_mode;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  string Get(ENUM_ACCOUNT_INFO_STRING _param) {
    switch (_param) {
      case ACCOUNT_NAME:
        // Client name (string).
        return name;
      case ACCOUNT_COMPANY:
        // Name of a company that serves the account (string).
        return company;
      case ACCOUNT_CURRENCY:
        // Account currency (string).
        return currency;
      case ACCOUNT_SERVER:
        // Trade server name (string).
        return server;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return "";
  }
  template <typename T>
  void Set(ENUM_ACCOUNT_PARAM_INTEGER _param, T _value) {
    switch (_param) {
      case ACCOUNT_PARAM_CURRENCY_DIGITS:
        // The number of decimal places in the account currency (int).
        ConvertBasic::Convert(_value, currency_digits);
        return;
      case ACCOUNT_PARAM_FIFO_CLOSE:
        // An indication showing that positions can only be closed by FIFO rule (bool).
        ConvertBasic::Convert(_value, fifo_close);
        return;
      case ACCOUNT_PARAM_LEVERAGE:
        // Account leverage (long).
        ConvertBasic::Convert(_value, leverage);
        return;
      case ACCOUNT_PARAM_LIMIT_ORDERS:
        // Maximum allowed number of active pending orders (int).
        ConvertBasic::Convert(_value, limit_orders);
        return;
      case ACCOUNT_PARAM_LOGIN:
        // Account number (long).
        ConvertBasic::Convert(_value, login);
        return;
      case ACCOUNT_PARAM_MARGIN_MODE:
        // Margin calculation mode (ENUM_ACCOUNT_MARGIN_MODE).
        ConvertBasic::Convert(_value, margin_mode);
        return;
      case ACCOUNT_PARAM_MARGIN_SO_MODE:
        // Mode for setting the minimal allowed margin (ENUM_ACCOUNT_STOPOUT_MODE).
        ConvertBasic::Convert(_value, margin_so_mode);
        return;
      case ACCOUNT_PARAM_TRADE_ALLOWED:
        // Allowed trade for the current account (bool).
        ConvertBasic::Convert(_value, trade_allowed);
        return;
      case ACCOUNT_PARAM_TRADE_EXPERT:
        // Allowed trade for an Expert Advisor (bool).
        ConvertBasic::Convert(_value, trade_expert);
        return;
      case ACCOUNT_PARAM_TRADE_MODE:
        // Account trade mode (ENUM_ACCOUNT_TRADE_MODE).
        ConvertBasic::Convert(_value, trade_mode);
        return;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    _s.Pass(THIS_REF, "company", company);
    _s.Pass(THIS_REF, "currency", currency);
    _s.Pass(THIS_REF, "currency_digits", currency_digits);
    _s.Pass(THIS_REF, "fifo_close", fifo_close);
    _s.Pass(THIS_REF, "leverage", leverage);
    _s.Pass(THIS_REF, "limit_orders", limit_orders);
    _s.Pass(THIS_REF, "login", login);
    _s.Pass(THIS_REF, "name", name);
    _s.Pass(THIS_REF, "server", server);
    _s.Pass(THIS_REF, "trade_allowed", trade_allowed);  // Convert to states.
    _s.Pass(THIS_REF, "trade_expert", trade_expert);    // Convert to states.
    _s.PassEnum(THIS_REF, "margin_mode", margin_mode);
    _s.PassEnum(THIS_REF, "margin_so_mode", margin_so_mode);
    _s.PassEnum(THIS_REF, "trade_mode", trade_mode);
    return SerializerNodeObject;
  }
};
