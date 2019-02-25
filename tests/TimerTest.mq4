//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

// Properties.
#property strict

// Includes.
#include "../Timer.mqh"
#include "../Test.mqh"

/**
 * Test Timer 5 times, 10ms each.
 */
bool Test5x10ms() {
  PrintFormat("Testing %s...", __FUNCTION__);
  Timer *timer = new Timer(__FUNCTION__);
  assertTrueOrFail(timer.GetName() == __FUNCTION__, "Timer name is not correct!");
  for (uint i = 0; i < 5; i++) {
    timer.Start();
    Sleep(10);
    PrintFormat("Current time elapsed before stop (%d/5): %d", i + 1, timer.GetTime());
    timer.Stop();
    PrintFormat("Current time elapsed after stop (%d/5): %d", i + 1, timer.GetTime(i));
  }
  assertTrueOrReturn(timer.GetMin() >= 10, "GetMin() value not correct!", false);
  assertTrueOrReturn(timer.GetMedian() >= 10, "GetMedian() value not correct!", false);
  assertTrueOrReturn(timer.GetMax() >= 10, "GetMax() value not correct!", false);
  timer.PrintSummary();
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
  return Test5x10ms() ? (INIT_SUCCEEDED) : (INIT_FAILED);
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
