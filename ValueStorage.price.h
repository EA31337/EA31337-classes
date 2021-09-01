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
#include "Chart.struct.h"
#include "ObjectsCache.h"
#include "ValueStorage.history.h"

/**
 * Storage to retrieve OHLC.
 */
class PriceValueStorage : public HistoryValueStorage<double> {
  // Time-frame to fetch price for.
  ENUM_APPLIED_PRICE ap;

 public:
  /**
   * Constructor.
   */
  PriceValueStorage(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, ENUM_APPLIED_PRICE _ap = PRICE_OPEN)
      : ap(_ap), HistoryValueStorage(_symbol, _tf) {}

  /**
   * Copy constructor.
   */
  PriceValueStorage(const PriceValueStorage &_r) : ap(_r.ap), HistoryValueStorage(_r.symbol, _r.tf) {}

  /**
   * Returns pointer to PriceValueStorage of a given symbol and time-frame.
   */
  static PriceValueStorage *GetInstance(string _symbol, ENUM_TIMEFRAMES _tf, ENUM_APPLIED_PRICE _ap) {
    PriceValueStorage *_storage;
    string _key = _symbol + "/" + IntegerToString((int)_tf) + "/" + IntegerToString((int)_ap);
    if (!ObjectsCache<PriceValueStorage>::TryGet(_key, _storage)) {
      _storage = ObjectsCache<PriceValueStorage>::Set(_key, new PriceValueStorage(_symbol, _tf, _ap));
    }
    return _storage;
  }

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  virtual double Fetch(int _shift) {
    switch (ap) {
      case PRICE_OPEN:
        return iOpen(symbol, tf, _shift);
      case PRICE_HIGH:
        return iHigh(symbol, tf, _shift);
      case PRICE_LOW:
        return iLow(symbol, tf, _shift);
      case PRICE_CLOSE:
        return iClose(symbol, tf, _shift);
    }
    return 0.0;
  }
};
