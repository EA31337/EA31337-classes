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
 * Spread getter version of ValueStorage.
 */

// Includes.
#include "ObjectsCache.h"
#include "ValueStorage.h"

/**
 * Storage to retrieve spread.
 */
class SpreadValueStorage : public ValueStorage<long> {
  // Symbol to fetch spread for.
  string symbol;

  // Time-frame to fetch spread for.
  ENUM_TIMEFRAMES tf;

 public:
  /**
   * Constructor.
   */
  SpreadValueStorage(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {}

  /**
   * Copy constructor.
   */
  SpreadValueStorage(const SpreadValueStorage &_r) : symbol(_r.symbol), tf(_r.tf) {}

  /**
   * Returns pointer to SpreadValueStorage of a given symbol and time-frame.
   */
  static SpreadValueStorage *GetInstance(string _symbol, ENUM_TIMEFRAMES _tf) {
    SpreadValueStorage *_storage;
    string _key = _symbol + "/" + IntegerToString((int)_tf);
    if (!ObjectsCache<SpreadValueStorage>::TryGet(_key, _storage)) {
      _storage = ObjectsCache<SpreadValueStorage>::Set(_key, new SpreadValueStorage(_symbol, _tf));
    }
    return _storage;
  }

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  virtual long Fetch(int _shift) { return iSpread(symbol, tf, _shift); }

  /**
   * Checks whether storage operates in as-series mode.
   */
  virtual bool IsSeries() const { return true; }

  /**
   * Sets storage's as-series mode on or off.
   */
  virtual bool SetSeries(bool _value) {
    if (!_value) {
      Alert(__FUNCSIG__, " can only work as series!");
      DebugBreak();
    }
    return true;
  }
};
