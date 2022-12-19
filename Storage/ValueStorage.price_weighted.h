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
 * Weighted price version of ValueStorage.
 */

// Includes.
#include "ObjectsCache.h"
#include "ValueStorage.history.h"

/**
 * Storage for weighted price.
 */
class PriceWeightedValueStorage : public HistoryValueStorage<double> {
 public:
  /**
   * Constructor.
   */
  PriceWeightedValueStorage(IndicatorBase *_indi_candle) : HistoryValueStorage(_indi_candle) {}

  /**
   * Copy constructor.
   */
  PriceWeightedValueStorage(PriceWeightedValueStorage &_r) : HistoryValueStorage(_r.indi_candle.Ptr()) {}

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  double Fetch(int _rel_shift) override {
    ResetLastError();
    double _value = indi_candle REF_DEREF GetOHLC(RealShift(_rel_shift)).GetWeighted();
    if (_LastError != ERR_NO_ERROR) {
      Print("Cannot fetch OHLC! Error: ", _LastError);
      DebugBreak();
    }
    return _value;
  }
};
