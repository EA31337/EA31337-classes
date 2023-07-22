//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
struct AccountParam {
  int id;
  string company, currency, name, server;

  // Default constructor.
  AccountParam(string _name = "Current", string _currency = "USD", string _company = "Unknown",
               string _server = "Unknown", int _id = 0)
      : company(_company), currency(_currency), id(_id), name(_name), server(_server) {}

  /* Getters */
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
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    _s.Pass(THIS_REF, "id", id);
    _s.Pass(THIS_REF, "name", name);
    _s.Pass(THIS_REF, "company", company);
    _s.Pass(THIS_REF, "currency", currency);
    _s.Pass(THIS_REF, "server", server);
    return SerializerNodeObject;
  }
};
