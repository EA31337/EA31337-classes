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
 * List of columns (values) for TesterValues as retrieved from Tester class.
 */

#ifdef __EMSCRIPTEN__
#include <emscripten/bind.h>
#include <emscripten/emscripten.h>
#endif

// Local includes.
#include "../Std.h"
#include "../Storage/Array.extern.h"
#include "../Storage/String.extern.h"
#include "TesterValuesColumnValue.h"
#include "TesterIndicatorInfo.h"

/**
 * Chart column data. A part of TesterValues items array.
 */
struct TesterValuesColumns {
  // Details about the indicator for which values are retrieved.
  TesterIndicatorInfo indicator_info;

  // Time in ms of data in the column.
  int64 time_ms;

  // List of values for each column.
  ARRAY(TesterValuesColumnValue, values);

  /**
   * Constructor.
   **/
  TesterValuesColumns(int64 _time_ms = 0) : time_ms(_time_ms) {}

  /**
   * Returns string representation of the structure.
   */
  string ToString(int _indent = 0) {
    int i;
    string _out, _padding_outer, _padding_inner;
    StringInit(_padding_outer, _indent, ' ');
    StringInit(_padding_inner, _indent + 2, ' ');

    _out += _padding_outer + "{\n";
    _out += _padding_inner + "time_ms: " + IntegerToString(time_ms) + ",\n";
    _out += _padding_inner + "values: [\n";

    for (i = 0; i < ArraySize(values); ++i) {
      _out += values[i].ToString(_indent + 4) + "\n";
    }

    _out += _padding_inner + "]\n";
    _out += _padding_outer + "}";
    return _out;
  }
};