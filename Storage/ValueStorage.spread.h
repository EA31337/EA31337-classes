//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
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
 * Spread getter version of ValueStorage.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Cache/ObjectsCache.h"
#include "ValueStorage.history.h"

/**
 * Storage to retrieve spread.
 */
class SpreadValueStorage : public HistoryValueStorage<int64> {
 public:
  /**
   * Constructor.
   */
  SpreadValueStorage(IndicatorBase *_indi_candle) : HistoryValueStorage<int64>(_indi_candle) {}

  /**
   * Copy constructor.
   */
  SpreadValueStorage(SpreadValueStorage &_r) : HistoryValueStorage<int64>(_r.indi_candle.Ptr()) {}

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  int64 Fetch(int _rel_shift) override { return indi_candle REF_DEREF GetSpread(RealShift(_rel_shift)); }
};
