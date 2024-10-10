//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
//|                                        https://ea31337.github.io |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of AccountForex class.
 */

// Includes.
#include "../../../Test.mqh"
#include "../AccountForex.h"

// Test classes.
class AccountForexTest : public Account<AccountForexState, AccountForexEntry> {
  /**
   * Returns balance value of the current account.
   */
  float GetBalance() { return 0; }

  /**
   * Returns credit value of the current account.
   */
  float GetCredit() { return 0; }

  /**
   * Returns profit value of the current account.
   */
  float GetProfit() { return 0; }

  /**
   * Returns equity value of the current account.
   */
  float GetEquity() { return 0; }

  /**
   * Returns margin value of the current account.
   */
  float GetMarginUsed() { return 0; }

  /**
   * Returns free margin value of the current account.
   */
  float GetMarginFree() { return 0; }

  /**
   * Get account available margin.
   */
  float GetMarginAvail() { return 0; }
};

/**
 * Implements OnInit().
 */
int OnInit() {
  bool _result = true;
  // AccountForexTest acc1;
  // ...
  return _result && GetLastError() == 0 ? INIT_SUCCEEDED : INIT_FAILED;
}

/**
 * Implements Tick event handler.
 */
void OnTick() {}
