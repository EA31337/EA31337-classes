//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

// Includes.
#include "Dict.mqh"

// Enums.
enum ENUM_STATS_TYPE { STATS_AVG, STATS_MIN, STATS_MED, STATS_MAX };

/**
 * Class to collect data for statistical purposes.
 */
template <typename T>
class Stats {
 public:
  long periods;  // Flags determines periods to keep data.
  Dict<long, T> *data;

  /**
   * Implements class constructor.
   *
   * @param long _periods Flags to determine periods to calculate.
   */
  Stats(long _periods = OBJ_ALL_PERIODS) : periods(_periods), data(new Dict<long, T>) {}

  /**
   * Implements class destructor.
   */
  ~Stats() {}

  /**
   * Adds new value.
   */
  void Add(T _value, long _dt = 0) {
    _dt = _dt > 0 ? _dt : TimeCurrent();
    data.Set(_dt, _value);
  }

  /**
   * Get statistics per period.
   *
   * @param ENUM_STATS_TYPE _type Specify type of calculation.
   */
  double GetStats(ENUM_STATS_TYPE _type, long _period = OBJ_ALL_PERIODS) { return WRONG_VALUE; }

  /**
   * Get count per period.
   *
   * @param ENUM_TIMEFRAMES _period Specify type of calculation.
   *
   * @return
   * Returns average count per period. When PERIOD_CURRENT, returns total number.
   */
  int GetCount(ENUM_TIMEFRAMES _period = PERIOD_CURRENT) {
    if (_period == PERIOD_CURRENT) {
      // return data.GetCount();
      return WRONG_VALUE;
    } else {
      double _psecs = PeriodSeconds(_period);
      // ...
      return WRONG_VALUE;
    }
  }

  /**
   * Get number of counted ticks.
   */
  // ulong GetTotalTicks() { return (total_ticks); }

  /**
   * Get number of ticks per bar.
   */
  // ulong GetTicksPerBar() { return (total_bars > 0 ? (total_ticks / total_bars) : 0); }

  /**
   * Get number of ticks per minute.
   */
  // ulong GetTicksPerMin() { return (total_bars > 0 ? (total_ticks / total_bars / curr_period) : 0); }

  /**
   * Get number of ticks per second.
   */
  // double GetTicksPerSec() { return round(total_bars > 0 ? (total_ticks / total_bars / curr_period) / 60 : 0); }

  /**
   * Get number of ticks per given time period.
   */
  // ulong GetTicksPerPeriod(int period = PERIOD_H1) { return (GetTicksPerMin() * period); }

  /**
   * Get number of bars per given time period.
   */
  // ulong GetBarsPerPeriod(int period = PERIOD_H1) { return (total_bars / period); }
};
