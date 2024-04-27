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
 * Native array version of ValueStorage.
 */

// Includes.
#include "ValueStorage.h"

/**
 * Storage containing dynamic native array.
 */
template <typename C>
class NativeValueStorage : public ValueStorage<C> {
  // Dynamic native array.
  C _values[];
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
  void SetData(ARRAY_REF(C, _arr)) {
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
  virtual void Initialize(C _value) { ArrayInitialize(_values, _value); }

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  virtual C Fetch(int _shift) {
    if (_shift < 0 || _shift >= _values_size) {
      return (C)EMPTY_VALUE;
      // Print("Invalid buffer data index: ", _shift, ". Buffer size: ", ArraySize(_values));
      // DebugBreak();
    }

    return _values[_shift];
  }

  /**
   * Stores value at a given shift. Takes into consideration as-series flag.
   */
  virtual void Store(int _shift, C _value) { Array::ArrayStore(_values, _shift, _value, 4096); }

  /**
   * Returns number of values available to fetch (size of the values buffer).
   */
  virtual int Size() const { return _values_size; }

  /**
   * Resizes storage to given size.
   */
  virtual void Resize(int _size, int _reserve) { ArrayResize(_values, _size, _reserve); }

  /**
   * Checks whether storage operates in as-series mode.
   */
  virtual bool IsSeries() const { return ArrayGetAsSeries(_values); }

  /**
   * Sets storage's as-series mode on or off.
   */
  virtual bool SetSeries(bool _value) {
    ArraySetAsSeries(_values, _value);
    return true;
  }
};
