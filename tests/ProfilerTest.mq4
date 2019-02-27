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
#include "../Profiler.mqh"
#include "../Test.mqh"

/**
 * Test function for profiling.
 */
void TestProfiler1() {
  PROFILER_START
  Sleep(rand()%10);
  PROFILER_STOP
}

/**
 * Test function for profiling.
 */
void TestProfiler2() {
  PROFILER_START
  Sleep(rand()%10);
  PROFILER_STOP_PRINT
}

/**
 * Implements OnInit().
 */
int OnInit() {
  for (uint i = 0; i < 20; i++) {
    TestProfiler1();
  }
  for (uint i = 0; i < 20; i++) {
    TestProfiler2();
  }
  PROFILER_SET_MIN(5)
  PROFILER_PRINT
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  PROFILER_DEINIT
}
