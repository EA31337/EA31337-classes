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
 * Includes AccountBase's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#include "../Serializer.enum.h"
#endif

// Forward class declaration.
class Serializer;

// Includes.
#include "../Serializer/Serializer.h"
#include "../Terminal.define.h"

// Struct for account entries.
struct AccountBaseEntry {
  datetime dtime;
  double balance;
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    _s.Pass(THIS_REF, "time", dtime, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "balance", balance, SERIALIZER_FIELD_FLAG_DYNAMIC);
    return SerializerNodeObject;
  }
  /* Getters */
  double Get(ENUM_ACCOUNT_INFO_DOUBLE _param) {
    switch (_param) {
      case ACCOUNT_BALANCE:
        // Account balance in the deposit currency (double).
        return balance;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
};

// Struct for account base.
struct AccountBaseState {
  datetime last_updated;
  double balance;
};
