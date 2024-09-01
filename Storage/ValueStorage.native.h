//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
 * Native array version of ValueStorage.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "ValueStorage.h"

/**
 * Storage containing dynamic native array.
 */
template <typename C>
class NativeValueStorage : public ValueStorage<C> {
  // Dynamic native array.
  ARRAY(C, _values);
  int _values_size;

 public:
  /**
   * Constructor.
   */
  NativeValueStorage() {}

  /**
   * Destructor.
   */
  NativeValueStorage(ARRAY_REF(C, _arr)) { SetData(_arr); }

  /**
   * Initializes array with given one.
   */
  void SetData(CONST_ARRAY_REF(C, _arr)) {
    bool _was_series = ArrayGetAsSeries(_arr);
    ArraySetAsSeries(_arr, false);
    ArraySetAsSeries(_values, false);
    ArrayResize(_values, 0);
    ArrayCopy(_values, _arr);
    _values_size = ArraySize(_arr);
    ArraySetAsSeries(_arr, _was_series);
    ArraySetAsSeries(_values, _was_series);
  }

  /**
   * Initializes storage with given value.
   */
  void Initialize(C _value) override { ArrayInitialize(_values, _value); }

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   *
   * Note that this storage type operates on absolute shifts!
   */
  C Fetch(int _abs_shift) override {
    if (_abs_shift < 0 || _abs_shift >= Size()) {
      // Alert("Error: NativeValueStorage: Invalid buffer data index: ", _shift, ". Buffer size: ", Size());
      // DebugBreak();
      return (C)EMPTY_VALUE;
    }

    return _values[_abs_shift];
  }

  /**
   * Stores value at a given shift. Takes into consideration as-series flag.
   */
  void Store(int _shift, C _value) override { Array::ArrayStore(_values, _shift, _value, 4096); }

  /**
   * Inserts new value at the end of the buffer. If buffer works as As-Series,
   * then new value will act as the one at index 0.
   */
  void Append(C _value) override {
    Resize(Size() + 1, 4096);
    Store(Size() - 1, _value);
  }

  /**
   * Returns number of values available to fetch (size of the values buffer).
   */
  int Size() override { return _values_size; }

  /**
   * Resizes storage to given size.
   */
  void Resize(int _size, int _reserve) override { ArrayResize(_values, _size, _reserve); }

  /**
   * Checks whether storage operates in as-series mode.
   */
  bool IsSeries() const override { return ArrayGetAsSeries(_values); }

  /**
   * Sets storage's as-series mode on or off.
   */
  bool SetSeries(bool _value) override {
    ArraySetAsSeries(_values, _value);
    return true;
  }
};
