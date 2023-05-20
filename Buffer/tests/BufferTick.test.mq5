//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of BufferTick class.
 */

// Includes
#include "../../Test.mqh"
#include "../BufferTick.h"

/**
 * Implements OnInit().
 */
int OnInit() {
  MqlTick mql_tick;             // 60
  TickAB<double> _tick_ab_d;    // 16
  TickAB<float> _tick_ab_f;     // 8
  TickTAB<double> _tick_tab_d;  // 24
  TickTAB<float> _tick_tab_f;   // 16
  Print("mql_tick: ", sizeof(mql_tick));
  Print("_tick_ab_d: ", sizeof(_tick_ab_d));
  Print("_tick_ab_f: ", sizeof(_tick_ab_f));
  Print("_tick_tab_d: ", sizeof(_tick_tab_d));
  Print("_tick_tab_f: ", sizeof(_tick_tab_f));
  // @todo
  return (GetLastError() > 0 ? INIT_FAILED : INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {}
