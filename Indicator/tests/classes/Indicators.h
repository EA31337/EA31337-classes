//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
 * Helper class to store all indicators and call OnTick() on them.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../../../Indicator/IndicatorData.h"
#include "../../../Refs.mqh"

/**
 * Helper class to store all indicators and call OnTick() on them.
 */
class Indicators {
  DictStruct<int, Ref<IndicatorData>> _indis;

 public:
  void Add(IndicatorData* _indi) {
    Ref<IndicatorData> _ref = _indi;
    _indis.Push(_ref);
  }

  void Add(Ref<IndicatorData>& _indi) { Add(_indi.Ptr()); }

  IndicatorData* Get(int index) { return _indis[index].Ptr(); }

  IndicatorData* operator[](int index) { return Get(index); }

  int Size() { return (int)_indis.Size(); }

  void Clear() { _indis.Clear(); }

  /**
   * Executes OnTick() on every added indicator.
   */
  void Tick(int _global_tick_index) {
    for (unsigned int i = 0; i < _indis.Size(); ++i) {
      _indis[i].Ptr() PTR_DEREF OnTick(_global_tick_index);
    }
  }

  /**
   * Prints indicators' values at the given shift.
   */
  string ToString(int _shift = 0) {
    string _result;
    for (unsigned int i = 0; i < _indis.Size(); ++i) {
      IndicatorDataEntry _entry = _indis[i].Ptr() PTR_DEREF GetEntry(_shift);
      _result += _indis[i].Ptr() PTR_DEREF GetFullName() + " = " + _entry.ToString<double>() + "\n";
    }
    return _result;
  }
};
