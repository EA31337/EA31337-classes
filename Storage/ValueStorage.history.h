//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

// Forward declarations.
template <typename C>
class ValueStorage;

/**
 * Storage for direct access to indicator's buffer for a given mode.
 */
template <typename C>
class HistoryValueStorage : public ValueStorage<C> {
 protected:
  // Symbol to fetch history for.
  string symbol;

  // Time-frame to fetch history for.
  ENUM_TIMEFRAMES tf;

  // Time of the first bar possible to fetch.
  datetime start_bar_time;

  // Whether storage operates in as-series mode.
  bool is_series;

 public:
  /**
   * Constructor.
   */
  HistoryValueStorage(string _symbol, ENUM_TIMEFRAMES _tf, bool _is_series = false)
      : symbol(_symbol), tf(_tf), is_series(_is_series) {
    start_bar_time = ChartStatic::iTime(_symbol, _tf, BarsFromStart() - 1);
  }

  /**
   * Initializes storage with given value.
   */
  virtual void Initialize(C _value) {
    Print("HistoryValueStorage does not implement Initialize()!");
    DebugBreak();
  }

  /**
   * Calculates shift from the given value index.
   */
  int RealShift(int _shift) {
    if (is_series) {
      return _shift;
    } else {
      return BarsFromStart() - _shift - 1;
    }
  }

  /**
   * Number of bars passed from the start. There will be a single bar at the start.
   */
  int BarsFromStart() const { return Bars(symbol, tf); }

  /**
   * Returns number of values available to fetch (size of the values buffer).
   */
  virtual int Size() const { return BarsFromStart(); }

  /**
   * Resizes storage to given size.
   */
  virtual void Resize(int _size, int _reserve) {
    Print("HistoryValueStorage does not implement Resize()!");
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
