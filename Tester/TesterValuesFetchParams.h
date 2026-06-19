//+------------------------------------------------------------------+
//|                                                     FX31337 wasm |
//|                                 Copyright 2022-2022, EA31337 Ltd |
//|                          https://github.com/FX31337/FX31337-wasm |
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
 * Parameters to pass into lib.Tester.GetValues(). Could be calculated by
 */

#ifdef __EMSCRIPTEN__
#include <emscripten/bind.h>
#include <emscripten/emscripten.h>
#endif

// Local includes.
#include "../Std.h"
#include "../Storage/String.extern.h"

/**
 * Parameters to pass into lib.Tester.GetValues(). Could be calculated by
 * Tester::GetTimeByScrollAndZoom(float scroll, float zoom, int visible_intervals).
 */
struct TesterValuesFetchParams {
  // Beginning range (inclusive) of the values to be returned.
  int64 timeFromMs;

  // Ending range (inclusive) of the values to be returned.
  int64 timeToMs;

  // Width of the single column in structure retrieved from Tester::GetValues(). If more that one value fits the column,
  // values will be aggregated (min/max values will be generated).
  int timeStepSecs;

  /**
   * Returns string representation of the structure.
   */
  string ToString() {
    return "{ timeFromMs: " + IntegerToString(timeFromMs) + ", timeToMs: " + IntegerToString(timeToMs) +
           ", timeStepSecs: " + IntegerToString(timeStepSecs) + " }";
  }
};