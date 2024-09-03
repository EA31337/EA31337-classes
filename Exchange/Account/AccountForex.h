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
#include "../../Serializer/Serializer.h"
#include "Account.h"
#include "AccountForex.struct.h"

/**
 * Class to provide functions that return parameters of the current account.
 */
class AccountForex : public Account<AccountForexState, AccountForexEntry> {
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
  AccountForex() { Init(); }

  /**
   * Class constructor with account params.
   */
  AccountForex(AccountParams &_aparams) : Account<AccountForexState, AccountForexEntry>(_aparams) { Init(); }

  /**
   * Class deconstructor.
   */
  ~AccountForex() {}


  /* Implementation of virtual methods */

  /**
   * Returns balance value of the current account.
   */
  float GetBalance() {
    return 0.0f;
  }

  /**
   * Returns credit value of the current account.
   */
  float GetCredit() {
    return 0.0f;
  }

  /**
   * Returns profit value of the current account.
   */
  float GetProfit() {
    return 0.0f;
  }

  /**
   * Returns equity value of the current account.
   */
  float GetEquity() {
    return 0.0f;
  }

  /**
   * Returns margin value of the current account.
   */
  float GetMarginUsed() {
    return 0.0f;
  }

  /**
   * Returns free margin value of the current account.
   */
  float GetMarginFree() {
    return 0.0f;
  }

  /**
   * Get account available margin.
   */
  float GetMarginAvail() {
    return 0.0f;
  }
};
