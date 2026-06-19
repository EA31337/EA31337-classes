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
#include "../Storage/Array.extern.h"
#include "../Storage/String.extern.h"
#include "TesterValuesColumns.h"

/**
 * Structure returned by Tester::GetValues();
 */
struct TesterValues {
  // Values that fit passed timeStep.
  ARRAY(TesterValuesColumns, timestep_based);

  // Values that don't fit passed timeStep.
  ARRAY(TesterValuesColumns, loose);

  /**
   * Returns string representation of the structure.
   */
  string ToString(int _indent = 0) {
    int i;
    string _out, _padding_outer, _padding_inner;
    StringInit(_padding_outer, _indent, ' ');
    StringInit(_padding_inner, _indent + 2, ' ');

    _out += _padding_outer + "{\n";
    _out += _padding_inner + "timestep_based: [\n";

    for (i = 0; i < ArraySize(timestep_based); ++i) {
      _out += timestep_based[i].ToString(_indent + 4) + "\n";
    }

    _out += _padding_inner + "],\n";
    _out += _padding_inner + "loose: [\n";

    for (i = 0; i < ArraySize(loose); ++i) {
      _out += loose[i].ToString(_indent + 4) + "\n";
    }

    _out += _padding_inner + "]\n";
    _out += _padding_outer + "}";
    return _out;
  }
};