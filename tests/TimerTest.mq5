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
 * Test functionality of Timer class.
 */

// Includes.
#include "../Test.mqh"
#include "../Timer.mqh"

/**
 * Test Timer 5 times, 16ms each.
 */
bool Test5x16ms() {
  PrintFormat("Testing %s...", __FUNCTION__);
  Timer *timer = new Timer(__FUNCTION__);
  assertTrueOrReturn(timer.GetName() == __FUNCTION__, "Timer name is not correct!", false);
  for (uint i = 0; i < 5; i++) {
    timer.Start();
    Sleep(16);
    PrintFormat("Current time elapsed before stop (%d/5): %d", i + 1, timer.GetTime());
    timer.Stop();
    PrintFormat("Current time elapsed after stop (%d/5): %d", i + 1, timer.GetTime(i));
  }
  timer.PrintSummary();
  assertTrueOrReturn(
      timer.GetMin() > 0,
      "GetMin() value not correct! Got " + DoubleToString(timer.GetMin()) + " which should be greater than 0!", false);
  assertTrueOrReturn(
      timer.GetMedian() > 0,
      "GetMedian() value not correct! Got " + DoubleToString(timer.GetMedian()) + " which should be greater than 0!",
      false);
  assertTrueOrReturn(
      timer.GetMax() > 0,
      "GetMax() value not correct! Got " + DoubleToString(timer.GetMax()) + " which should be greater than 0!", false);
  delete timer;
  return true;
}

/**
 * Implements OnInit().
 */
int OnInit() {
  // Test OnInit() timer.
  PrintFormat("Testing %s...", __FUNCTION__);
  Timer *timer = new Timer(__FUNCTION__);
  assertTrueOrFail(timer.GetName() == __FUNCTION__, "Timer name is not correct!");
  PrintFormat("Starting timer %s...", timer.GetName());
  timer.Start();
  PrintFormat("Stopping timer %s...", timer.GetName());
  timer.Stop();
  Print(timer.ToString());
  delete timer;
  // Test another timer.
  return Test5x16ms() ? (INIT_SUCCEEDED) : (INIT_FAILED);
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  // Test OnDeinit() timer.
  Timer *timer = new Timer(__FUNCTION__);
  assertTrueOrExit(timer.GetName() == __FUNCTION__, "Timer name is not correct!");
  PrintFormat("Starting timer %s...", timer.GetName());
  timer.Start();
  PrintFormat("Stopping timer %s...", timer.GetName());
  timer.Stop();
  Print(timer.ToString());
  delete timer;
}
