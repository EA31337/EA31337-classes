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

// Prevents processing this includes file for the second time.
#ifndef ACCOUNTFOREX_H
#define ACCOUNTFOREX_H

// Includes.
#include "../Serializer/Serializer.h"
#include "Account.h"
#include "AccountForex.struct.h"

/**
 * Class to provide functions that return parameters of the current account.
 */
class AccountForex : public Account<AccountForexState, AccountForexEntry> {
 protected:
  // AP AccountParams;
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
   * Class deconstructor.
   */
  ~AccountForex() {}
};
#endif  // ACCOUNTFOREX_H
