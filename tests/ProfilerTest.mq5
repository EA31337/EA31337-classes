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
 * Test functionality of Profiler class.
 */

// Includes.
#include "../Profiler.mqh"
#include "../Test.mqh"

/**
 * Test function for profiling.
 */
void TestProfiler1() {
  PROFILER_START
  Sleep(rand() % 10 + 1);
  PROFILER_STOP
}

/**
 * Test function for profiling.
 */
void TestProfiler2() {
  PROFILER_START
  Sleep(rand() % 10 + 1);
  PROFILER_STOP_PRINT
}

/**
 * Implements OnInit().
 */
int OnInit() {
  unsigned int _i;
  for (_i = 0; _i < 20; _i++) {
    TestProfiler1();
  }
  for (_i = 0; _i < 20; _i++) {
    TestProfiler2();
  }
  PROFILER_SET_MIN(5)
  PROFILER_PRINT
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) { PROFILER_DEINIT }
