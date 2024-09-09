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
 * Price getter version of ValueStorage.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Platform/Chart/Chart.struct.h"
#include "Cache/ObjectsCache.h"
#include "ValueStorage.history.h"

// Forward declarations.
class ChartBase;

/**
 * Storage to retrieve OHLC from Candle indicator.
 */
class AppliedPriceValueStorage : public HistoryValueStorage<double> {
  // Time-frame to fetch price for.
  ENUM_APPLIED_PRICE ap;

 public:
  /**
   * Constructor.
   */
  AppliedPriceValueStorage(IndicatorBase *_indi_candle, ENUM_APPLIED_PRICE _ap = PRICE_OPEN)
      : ap(_ap), HistoryValueStorage(_indi_candle) {}

  /**
   * Copy constructor.
   */
  AppliedPriceValueStorage(AppliedPriceValueStorage &_r) : ap(_r.ap), HistoryValueStorage(_r.indi_candle.Ptr()) {}

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  double Fetch(int _rel_shift) override {
    switch (ap) {
      case PRICE_OPEN:
      case PRICE_HIGH:
      case PRICE_LOW:
      case PRICE_CLOSE:
        return Fetch(ap, _rel_shift);
      case PRICE_MEDIAN:
        return (Fetch(PRICE_HIGH, _rel_shift) + Fetch(PRICE_LOW, _rel_shift)) / 2;
      case PRICE_TYPICAL:
        return (Fetch(PRICE_HIGH, _rel_shift) + Fetch(PRICE_LOW, _rel_shift) + Fetch(PRICE_CLOSE, _rel_shift)) / 3;
      case PRICE_WEIGHTED:
        return (Fetch(PRICE_HIGH, _rel_shift) + Fetch(PRICE_LOW, _rel_shift) + (2 * Fetch(PRICE_CLOSE, _rel_shift))) /
               4;
      default:
        Print("We shouldn't be here!");
        DebugBreak();
    }
    return 0.0;
  }

  double Fetch(ENUM_APPLIED_PRICE _ap, int _rel_shift) {
    return indi_candle REF_DEREF GetPrice(_ap, RealShift(_rel_shift));
  }

  static double GetApplied(ValueStorage<double> &_open, ValueStorage<double> &_high, ValueStorage<double> &_low,
                           ValueStorage<double> &_close, int _shift, ENUM_APPLIED_PRICE _ap) {
    switch (_ap) {
      case PRICE_OPEN:
        return _open.Fetch(_shift);
      case PRICE_HIGH:
        return _high.Fetch(_shift);
      case PRICE_LOW:
        return _low.Fetch(_shift);
      case PRICE_CLOSE:
        return _close.Fetch(_shift);
    }
    Alert("Wrong applied price for ValueStorage-based iPrice()!");
    DebugBreak();
    return 0;
  }
};
