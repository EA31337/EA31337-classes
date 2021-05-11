//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
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
 * Test functionality of Ticker class.
 */

// Includes.
#include "../Math.h"
#include "../Test.mqh"

/**
 * Implements initialization function.
 */
int OnInit() {
  // Test ReLU().
  assertTrueOrFail(Math::ReLU(2) == 2, __FUNCTION__);
  assertTrueOrFail(Math::ReLU(0) == 0, __FUNCTION__);
  assertTrueOrFail(Math::ReLU(-2) == 0, __FUNCTION__);

  // Test ChangeByPct().
  assertTrueOrFail(Math::ChangeByPct(0, 0) == 0, __FUNCTION__);
  assertTrueOrFail(Math::ChangeByPct(1, 0.5) == 1.5, __FUNCTION__);
  assertTrueOrFail(Math::ChangeByPct(1, 1) == 2, __FUNCTION__);
  assertTrueOrFail(Math::ChangeByPct(1, -0.5) == 0.5, __FUNCTION__);
  assertTrueOrFail(Math::ChangeByPct(1, -1) == 0, __FUNCTION__);
  assertTrueOrFail(Math::ChangeByPct(-1, -1) == -2, __FUNCTION__);
  assertTrueOrFail(Math::ChangeByPct(-1, 1) == 0, __FUNCTION__);

  // Test ChangeInPct().
  assertTrueOrFail(Math::ChangeInPct(0, 0) == 0, __FUNCTION__);
  assertTrueOrFail(Math::ChangeInPct(1, 1) == 0, __FUNCTION__);
  assertTrueOrFail(Math::ChangeInPct(1, 1.5) == 0.5, __FUNCTION__);
  assertTrueOrFail(Math::ChangeInPct(1, 2) == 1, __FUNCTION__);
  assertTrueOrFail(Math::ChangeInPct(1, 2, true) == 100, __FUNCTION__);
  assertTrueOrFail(Math::ChangeInPct(-1, -1) == 0, __FUNCTION__);
  assertTrueOrFail(Math::ChangeInPct(-1, -2) == -1, __FUNCTION__);
  assertTrueOrFail(Math::ChangeInPct(-1, 1) == 2, __FUNCTION__);
  assertTrueOrFail(Math::ChangeInPct(1, -1) == -2, __FUNCTION__);
  assertTrueOrFail(Math::ChangeInPct(1, 0) == -1, __FUNCTION__);
  assertTrueOrFail(Math::ChangeInPct(0, 1) == 1, __FUNCTION__);

  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {}

/**
 * Implements deinitialization function.
 */
void OnDeinit(const int reason) {}
