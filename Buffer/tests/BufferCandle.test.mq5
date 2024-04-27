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
 * Test functionality of BufferCandle class.
 */

// Includes
#include "../../Test.mqh"
#include "../BufferCandle.h"

/**
 * Implements OnInit().
 */
int OnInit() {
  BufferCandle<double> buffer1;          // 128
  CandleOHLC<double> _ohlc_d;    // 32
  CandleOHLC<float> _ohlc_f;     // 16
  CandleTOHLC<double> _tohlc_d;  // 32
  CandleTOHLC<float> _tohlc_f;   // 16
  // CandleEntry<double> _centry_d; // 40
  // CandleEntry<float> _centry_f; // 24
  Print("buffer1: ", sizeof(buffer1));
  Print("_ohlc_d: ", sizeof(_ohlc_d));
  Print("_ohlc_f: ", sizeof(_ohlc_f));
  Print("_tohlc_d: ", sizeof(_tohlc_d));
  Print("_tohlc_f: ", sizeof(_tohlc_f));
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
