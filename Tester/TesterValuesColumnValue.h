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
 * Value for a single column for TesterValues as retrieved from Tester class.
 */

#ifdef __EMSCRIPTEN__
#include <emscripten/bind.h>
#include <emscripten/emscripten.h>
#endif

// Local includes.
#include "../Convert.extern.h"
#include "../Std.h"
#include "../Storage/String.extern.h"

/**
 * Single value for the TesterValuesColumns.
 */
struct TesterValuesColumnValue {
  // Names of the indicator value.
  string name;

  // Type of the indicator value.
  ENUM_DATATYPE type;

  // Time of the first added value.
  int64 time_open_ms;

  // Time of the last added value.
  int64 time_close_ms;

  // AGGREGATED VALUES:

  // Value of the first added value.
  double value_open;

  // Highest added value.
  double value_high;

  // Lowest added value.
  double value_low;

  // Value of the last added value.
  double value_close;

  // Average of added values.
  double value_avg;

  // Number of values added (volume of the column).
  int num_values;

  /**
   * Constructor.
   **/
  TesterValuesColumnValue(string _name = "", ENUM_DATATYPE _type = TYPE_DOUBLE, int64 _time_open_ms = 0,
                          int64 _time_close_ms = 0, double _open = 0, double _high = 0, double _low = 0,
                          double _close = 0, double _avg = 0, int _num_values = 0) {
    name = _name;
    type = _type;
    time_open_ms = _time_open_ms;
    time_close_ms = _time_close_ms;
    value_open = _open;
    value_high = _high;
    value_low = _low;
    value_close = _close;
    value_avg = _avg;
    num_values = _num_values;
  }

  /**
   * Adds value to the column.
   **/
  void Add(double _value, int64 _time_ms) {
    if (num_values == 0) {
      // Adding first value to the column.
      time_open_ms = time_close_ms = _time_ms;
      value_open = value_high = value_low = value_close = value_avg = _value;
    } else {
      // Adding another value to the column.
      if (_time_ms < time_open_ms) {
        time_open_ms = _time_ms;
        value_open = _value;
      }
      if (_time_ms > time_close_ms) {
        time_close_ms = _time_ms;
        value_close = _value;
      }
      value_high = MathMax(value_high, _value);
      value_low = MathMin(value_low, _value);
      value_avg = ((value_avg * num_values) + _value) / (num_values + 1);
    }

    ++num_values;
  }

  /**
   * Returns string representation of the structure.
   */
  string ToString(int _indent = 0) {
    string _out, _padding;
    StringInit(_padding, _indent, ' ');
    _out += _padding + "{  name: \"" + name + "\", type: " + EnumToString(type) +
            ", open: " + DoubleToString(value_open) + ", high: " + DoubleToString(value_high) +
            ", low: " + DoubleToString(value_low) + ", close: " + DoubleToString(value_close) +
            ", avg: " + DoubleToString(value_avg) + " }";
    return _out;
  }
};
