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

// Forward declarations.
class IndicatorData;

// Includes.
#include "../Indicator/IndicatorData.h"
#include "ValueStorage.history.h"

/**
 * Storage for direct access to indicator's buffer for a given mode.
 */
template <typename C>
class IndicatorBufferValueStorage : public HistoryValueStorage<C> {
  // Mode of the target indicator.
  int mode;

 public:
  /**
   * Constructor.
   */
  IndicatorBufferValueStorage(IndicatorData* _indi_candle, int _mode = 0, bool _is_series = false)
      : mode(_mode), HistoryValueStorage(_indi_candle) {}

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  C Fetch(int _rel_shift) override { return indi_candle REF_DEREF GetValue<C>(mode, RealShift(_rel_shift)); }
};
