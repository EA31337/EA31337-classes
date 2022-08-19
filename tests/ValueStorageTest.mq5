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
 * Test functionality of ValueStorage class.
 */

// Defines.
#define __debug__  // Enables debug.

// Includes.
#include "../Indicators/Indi_MA.mqh"
#include "../Indicators/Price/Indi_Price.mqh"
#include "../Serializer/SerializerConverter.h"
#include "../Serializer/SerializerJson.h"
#include "../Storage/ValueStorage.h"
#include "../Test.mqh"

// Global variables.
double _test_values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};

struct ArrayCopyScenario {
  bool source_is_series;
  bool target_is_series;
  int source_shift;
  int target_shift;
  int initial_target_size;
};

/**
 * Implements Init event handler.
 */
int OnInit() {
  NativeValueStorage<double> _data_s(_test_values);
  double _data_v[];
  ArrayCopy(_data_v, _test_values);
  assertEqualOrFail(ArraySize(_data_s), ArraySize(_data_v), "ArraySize() difference!");

  ArrayResize(_data_s, 5);
  ArrayResize(_data_v, 5);
  assertEqualOrFail(ArraySize(_data_s), ArraySize(_data_v), "Difference of ArraySize() after ArrayResize()!");

  int i;

  for (i = 0; i < 5; ++i) {
    _data_s[i] = i;
    _data_v[i] = i;
  }

  for (i = 0; i < 5; ++i) {
    assertEqualOrFail(_data_s[i].Get(), _data_v[i], "Array values difference!");
  }

  ArraySetAsSeries(_data_s, true);
  ArraySetAsSeries(_data_v, true);

  for (i = 0; i < 5; ++i) {
    assertEqualOrFail(_data_s[i].Get(), _data_v[i], "Array(as series) values difference!");
  }

  ArrayCopyScenario _array_copy_scenarios[];

  for (int b = 0; b < 4; ++b) {
    bool b1 = b % 2 == 0;
    bool b2 = b % 2 == 1;
    for (int i1 = 0; i1 < 3; ++i1) {
      for (int i2 = 0; i2 < 3; ++i2) {
        for (int i3 = 0; i3 <= 30; i3 += 10) {
          ArrayResize(_array_copy_scenarios, ArraySize(_array_copy_scenarios) + 1);

          ArrayCopyScenario _scenario;
          _scenario.source_is_series = b1;
          _scenario.source_is_series = b2;
          _scenario.source_shift = i1;
          _scenario.target_shift = i2;
          _scenario.initial_target_size = i3;
          _array_copy_scenarios[ArraySize(_array_copy_scenarios) - 1] = _scenario;
        }
      }
    }
  }

  double _values[];
  ArrayCopy(_values, _test_values);

  for (i = 0; i < ArraySize(_array_copy_scenarios); ++i) {
    ArrayCopyScenario _array_copy_scenario = _array_copy_scenarios[i];

    NativeValueStorage<double> _source(_values);
    ArraySetAsSeries(_source, _array_copy_scenario.source_is_series);
    ArraySetAsSeries(_values, _array_copy_scenario.source_is_series);

    double _target1[];
    ArrayResize(_target1, _array_copy_scenario.initial_target_size);
    ArrayInitialize(_target1, 5);
    ArraySetAsSeries(_target1, _array_copy_scenario.target_is_series);
    ArrayCopy(_target1, _source, _array_copy_scenario.target_shift, _array_copy_scenario.source_shift);

    double _target2[];
    ArrayResize(_target2, _array_copy_scenario.initial_target_size);
    ArrayInitialize(_target2, 5);
    ArraySetAsSeries(_target2, _array_copy_scenario.target_is_series);
    ArrayCopy(_target2, _values, _array_copy_scenario.target_shift, _array_copy_scenario.source_shift);

    Print("ArrayCopy: src_series = ", _array_copy_scenario.source_is_series,
          ", dst_series = ", _array_copy_scenario.target_is_series,
          ", source_start = ", _array_copy_scenario.source_shift,
          ", target_start = ", _array_copy_scenario.target_shift);
#ifdef __MQL5__
    ArrayPrint(_target2, 0, ", ");
    ArrayPrint(_target1, 0, ", ");
#endif
    Print("-- = ", ArrayCompare(_target1, _target2) == 0 ? "OK" : "FAIL!");

    assertEqualOrFail(ArrayCompare(_target1, _target2), 0, "Difference in ArrayCopy!");
  }

  return _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED;
}

/**
 * Implements Tick event handler.
 */
void OnTick() {}
