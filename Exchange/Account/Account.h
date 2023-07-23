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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../../Serializer/Serializer.h"
#include "../../Storage/Dict/Buffer/BufferStruct.h"
#include "Account.struct.h"
#include "AccountBase.h"

/**
 * Class to provide functions that return parameters of the current account.
 */
template <typename AS, typename AE>
class Account : public AccountBase {
 protected:
  AccountParams aparams;
  AS state;
  BufferStruct<AE> entries;

  /**
   * Init code (called on constructor).
   */
  void Init() {
    // ...
  }

 public:
  /**
   * Class constructor.
   */
  Account() { Init(); }

  /**
   * Class constructor with parameters.
   */
  Account(AccountParams &_aparams) : aparams(_aparams) { Init(); }

  /**
   * Class copy constructor.
   */
  Account(Account &_account) {
    state = _account.state;
    // @todo: Copy entries.
  }

  /**
   * Class deconstructor.
   */
  ~Account() {}

  /* Serializers */

  /**
   * Returns serialized representation of the object instance.
   */
  virtual SerializerNodeType Serialize(Serializer &_s) {
    _s.PassStruct(THIS_REF, "state", state);
    return SerializerNodeObject;
  }
};
