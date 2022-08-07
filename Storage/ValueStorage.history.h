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
#include "../Indicator/IndicatorData.h"
#include "ValueStorage.h"

// Forward declarations.
class IndicatorData;
template <typename C>
class ValueStorage;

/**
 * Storage for direct access to indicator's buffer for a given mode.
 */
template <typename C>
class HistoryValueStorage : public ValueStorage<C> {
 protected:
  // Indicator used as an OHLC source, e.g. IndicatorCandle.
  WeakRef<IndicatorData> indi_candle;

  // Whether storage operates in as-series mode.
  bool is_series;

 public:
  /**
   * Constructor.
   */
  HistoryValueStorage(IndicatorData* _indi_candle, bool _is_series = false)
      : indi_candle(_indi_candle), is_series(_is_series) {
    if (_indi_candle == nullptr) {
      Print("You have to pass IndicatorCandle-compatible indicator as parameter to HistoryValueStorage!");
      DebugBreak();
    }
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
  int BarsFromStart() {
    if (!indi_candle.ObjectExists()) {
      return 0;
    }
    return indi_candle REF_DEREF GetBars();
  }

  /**
   * Returns number of values available to fetch (size of the values buffer).
   */
  int Size() override { return BarsFromStart(); }

  /**
   * Resizes storage to given size.
   */
  void Resize(int _size, int _reserve) override {
    Print("HistoryValueStorage does not implement Resize()!");
    DebugBreak();
  }

  /**
   * Checks whether storage operates in as-series mode.
   */
  bool IsSeries() const override { return is_series; }

  /**
   * Sets storage's as-series mode on or off.
   */
  bool SetSeries(bool _value) override {
    is_series = _value;
    return true;
  }
};
