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
 * Time getter version of ValueStorage.
 */

// Includes.
#include "ObjectsCache.h"
#include "ValueStorage.h"

/**
 * Storage to retrieve time.
 */
class TimeValueStorage : public ValueStorage<datetime> {
  // Symbol to fetch time for.
  string symbol;

  // Time-frame to fetch time for.
  ENUM_TIMEFRAMES tf;

 public:
  /**
   * Default constructor.
   */
  TimeValueStorage() {}

  /**
   * Copy constructor.
   */
  TimeValueStorage(const TimeValueStorage &_r) : symbol(_r.symbol), tf(_r.tf) {}

  /**
   * Constructor.
   */
  TimeValueStorage(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {}

  /**
   * Returns pointer to TimeValueStorage of a given symbol and time-frame.
   */
  ValueStorage<datetime> *GetInstance(string _symbol, ENUM_TIMEFRAMES _tf) {
    TimeValueStorage *_time;
    string _key = _symbol + "/" + IntegerToString(_tf);
    if (!ObjectsCache<TimeValueStorage>::TryGet(_key, _time)) {
      _time = ObjectsCache<TimeValueStorage>::Set(_key, new TimeValueStorage(_symbol, _tf));
    }
    return _time;
  }

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  virtual datetime Fetch(int _shift) { return iTime(symbol, tf, _shift); }

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
