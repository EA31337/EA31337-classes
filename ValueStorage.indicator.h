//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Indicator's mode buffer version of ValueStorage.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "ValueStorage.h"

/**
 * Storage for direct access to indicator's buffer for a given mode.
 */
template <typename C>
class IndicatorBufferValueStorage : public ValueStorage<C> {
  // Pointer to indicator to access data from.
  Indicator *indicator;

  // Mode of the target indicator.
  int mode;

  // Time of the first bar possible to fetch.
  datetime start_bar_time;

  // Whether storage operates in as-series mode.
  bool is_series;

 public:
  /**
   * Constructor.
   */
  IndicatorBufferValueStorage(Indicator *_indi, int _mode = 0, bool _is_series = false)
      : indicator(_indi), mode(_mode), is_series(_is_series) {
    start_bar_time = _indi.GetBarTime(INDICATOR_BUFFER_VALUE_STORAGE_HISTORY - 1);
  }

  /**
   * Initializes storage with given value.
   */
  virtual void Initialize(C _value) {
    Print("IndicatorBufferValueStorage does not implement Initialize()!");
    DebugBreak();
  }

  /**
   * Calculates series shift from non-series index.
   */
  int RealShift(int _shift) {
    if (is_series) {
      return _shift;
    } else {
      return BarsFromStart() - _shift;
    }
  }

  /**
   * Number of bars passed from the start.
   */
  int BarsFromStart() {
    return (int)((indicator.GetBarTime(0) - start_bar_time) / (long)indicator.GetParams().tf.GetInSeconds());
  }

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  virtual C Fetch(int _shift) { return indicator.GetValue<C>(RealShift(_shift), mode); }

  /**
   * Stores value at a given shift. Takes into consideration as-series flag.
   */
  virtual void Store(int _shift, C _value) {
    Print("IndicatorBufferValueStorage does not implement Store()!");
    DebugBreak();
  }

  /**
   * Returns number of values available to fetch (size of the values buffer).
   */
  virtual int Size() { return BarsFromStart() + 1; }

  /**
   * Resizes storage to given size.
   */
  virtual void Resize(int _size, int _reserve) {
    Print("IndicatorBufferValueStorage does not implement Resize()!");
    DebugBreak();
  }

  /**
   * Checks whether storage operates in as-series mode.
   */
  virtual bool IsSeries() const { return is_series; }

  /**
   * Sets storage's as-series mode on or off.
   */
  virtual bool SetSeries(bool _value) {
    is_series = _value;
    return true;
  }
};
