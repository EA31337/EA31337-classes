//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
 * Time getter version of ValueStorage.
 */

// Includes.
#include "../Util.h"
#include "ObjectsCache.h"
#include "ValueStorage.history.h"

/**
 * Storage to retrieve time.
 */
class TimeValueStorage : public HistoryValueStorage<datetime> {
 public:
  /**
   * Constructor.
   */
  TimeValueStorage(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : HistoryValueStorage(_symbol, _tf) {}

  /**
   * Copy constructor.
   */
  TimeValueStorage(const TimeValueStorage &_r) : HistoryValueStorage(_r.symbol, _r.tf) {}

  /**
   * Returns pointer to TimeValueStorage of a given symbol and time-frame.
   */
  static TimeValueStorage *GetInstance(string _symbol, ENUM_TIMEFRAMES _tf) {
    TimeValueStorage *_storage;
    string _key = Util::MakeKey(_symbol, (int)_tf);
    if (!ObjectsCache<TimeValueStorage>::TryGet(_key, _storage)) {
      _storage = ObjectsCache<TimeValueStorage>::Set(_key, new TimeValueStorage(_symbol, _tf));
    }
    return _storage;
  }

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  virtual datetime Fetch(int _shift) { return iTime(symbol, tf, RealShift(_shift)); }
};
