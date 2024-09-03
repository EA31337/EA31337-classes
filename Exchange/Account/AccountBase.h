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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../../Refs.mqh"
#include "../../Serializer/SerializerConverter.h"
#include "../../Serializer/SerializerJson.h"
#include "AccountBase.struct.h"

/**
 * Class to provide functions that return parameters of the current account.
 */
class AccountBase : public Dynamic {
 protected:
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
  AccountBase() { Init(); }

  /**
   * Class constructor.
   */
  AccountBase(AccountBase &_account) { THIS_REF = _account; }

  /**
   * Class deconstructor.
   */
  ~AccountBase() {}

  /* Printer methods */

  /**
   * Returns textual representation of the object instance.
   */
  virtual string ToString() { return SerializerConverter::FromObject(THIS_REF).ToString<SerializerJson>(); }

  /* Serializers */

  /**
   * Returns serialized representation of the object instance.
   */
  virtual SerializerNodeType Serialize(Serializer &_s) = 0;

  /* Virtual methods */

  /**
   * Returns balance value of the current account.
   */
  virtual datetime GetDateTime() { return TimeCurrent(); };

  /**
   * Returns balance value of the current account.
   */
  virtual float GetBalance() = 0;

  /**
   * Returns credit value of the current account.
   */
  virtual float GetCredit() = 0;

  /**
   * Returns profit value of the current account.
   */
  virtual float GetProfit() = 0;

  /**
   * Returns equity value of the current account.
   */
  virtual float GetEquity() = 0;

  /**
   * Returns margin value of the current account.
   */
  virtual float GetMarginUsed() = 0;

  /**
   * Returns free margin value of the current account.
   */
  virtual float GetMarginFree() = 0;

  /**
   * Get account available margin.
   */
  virtual float GetMarginAvail() = 0;
};
