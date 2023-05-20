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
enum ENUM_STATS_TYPE { STATS_CALC_AVG, STATS_CALC_MIN, STATS_CALC_MED, STATS_CALC_MAX };

/**
 * Class to calculate minimum, average and maximum values.
 */
template <typename T>
class Stats {
 public:
  double data[];
  double avg, min, max;
  datetime period_start, period_end;
  int max_buff;

  /**
   * Implements class constructor.
   *
   * @param long _periods Flags to determine periods to calculate.
   */
  Stats(int _max_buff = 1000) : max_buff(_max_buff) {}

  /**
   * Implements class destructor.
   */
  ~Stats() {}

  /**
   * Parse the new value.
   */
  void Add(double _value, datetime _dt = 0) {
    period_start = fmin(_dt, period_start);
    period_end = fmax(_dt, period_end);
    _dt = _dt > 0 ? _dt : TimeCurrent();
    // avg = (_value + last) / 2;
  }

  /**
   * Get statistics per period.
   *
   * @param ENUM_STATS_TYPE _type Specify type of calculation.
   */
  double GetStats(ENUM_STATS_TYPE _type = STATS_CALC_AVG) {
    // @todo
    return WRONG_VALUE;
  }

  /**
   * Gets total count.
   *
   * @return
   * Returns total count of all values.
   */
  int GetCount() {
    // return data.GetCount();
    return WRONG_VALUE;
  }

  /**
   * Get average count per period.
   *
   * @param ENUM_TIMEFRAMES _period Specify type of calculation.
   *
   * @return
   * Returns average count per period. When PERIOD_CURRENT, returns total number.
   */
  int GetCount(ENUM_TIMEFRAMES _period) {
    double _psecs = PeriodSeconds(_period);
    // ...data
    return WRONG_VALUE;
  }
};
