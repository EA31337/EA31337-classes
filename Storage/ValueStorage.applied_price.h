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
 * Price getter version of ValueStorage.
 */

// Includes.
#include "../Chart.struct.h"
#include "ObjectsCache.h"
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
  AppliedPriceValueStorage(const AppliedPriceValueStorage &_r) : ap(_r.ap), HistoryValueStorage(_r.indi_candle.Ptr()) {}

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  virtual double Fetch(int _shift) {
    switch (ap) {
      case PRICE_OPEN:
      case PRICE_HIGH:
      case PRICE_LOW:
      case PRICE_CLOSE:
        return Fetch(ap, _shift);
      case PRICE_MEDIAN:
        return (Fetch(PRICE_HIGH, _shift) + Fetch(PRICE_LOW, _shift)) / 2;
      case PRICE_TYPICAL:
        return (Fetch(PRICE_HIGH, _shift) + Fetch(PRICE_LOW, _shift) + Fetch(PRICE_CLOSE, _shift)) / 3;
      case PRICE_WEIGHTED:
        return (Fetch(PRICE_HIGH, _shift) + Fetch(PRICE_LOW, _shift) + (2 * Fetch(PRICE_CLOSE, _shift))) / 4;
      default:
        Print("We shouldn't be here!");
        DebugBreak();
    }
    return 0.0;
  }

  double Fetch(ENUM_APPLIED_PRICE _ap, int _shift) { return indi_candle REF_DEREF GetPrice(_ap, RealShift(_shift)); }

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
