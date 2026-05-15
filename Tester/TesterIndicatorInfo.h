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
 * Details about given indicator. Retrieved from Tester class.
 */

#ifdef __EMSCRIPTEN__
#include <emscripten/bind.h>
#include <emscripten/emscripten.h>
#endif

// Local includes.
#include "../Std.h"

/**
 * Details about given indicator. Retrieved from Tester class.
 *
 * We can later user Tester::GetIndicatorData(int indi_index, int abs_shift, int mode = 0) to retrieve data from the
 * indicator.
 */
struct TesterIndicatorInfo {
  // Name of the indicator.
  string name;

  // Index of the indicator in the Platform.
  int index;

  // Number of values calculated for this indicator.
  int num_values;

  // Symbol pair indicator works on.
  string symbol;

  // Time-frame indicator works on.
  ENUM_TIMEFRAMES tf;

  // Constructor.
  TesterIndicatorInfo(string _name = "", int _index = -1, int _num_values = 0, string _symbol = "",
                      ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
      : name(_name), index(_index), num_values(_num_values), symbol(_symbol), tf(_tf) {}
};
