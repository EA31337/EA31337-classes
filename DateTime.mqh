//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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

/**
 * @file
 * Class to work with data of datetime type.
 *
 * @docs
 * - https://docs.mql4.com/dateandtime
 * - https://www.mql5.com/en/docs/dateandtime
 */

// Prevents processing this includes file for the second time.
#ifndef DATETIME_MQH
#define DATETIME_MQH

// Includes class enum and structs.
#include "DateTime.enum.h"
#include "DateTime.struct.h"
#include "DateTimeHelper.h"
#include "Indicator.struct.h"

/*
 * Class to provide functions that deals with date and time.
 */
class DateTime {
 public:
  // Struct variables.
  DateTimeEntry dt;

  /* Special methods */

  /**
   * Class constructor.
   */
  DateTime() { TimeToStruct(TimeCurrent(), dt); }
  DateTime(DateTimeEntry &_dt) { dt = _dt; }
  DateTime(MqlDateTime &_dt) { dt = _dt; }
  DateTime(datetime _dt) { dt.SetDateTime(_dt); }

  /**
   * Class deconstructor.
   */
  ~DateTime() {}

  /* Getters */

  /**
   * Returns the DateTimeEntry struct.
   */
  DateTimeEntry GetEntry() const { return dt; }

  /**
   * Returns started periods (e.g. new minute, hour).
   *
   * @param
   * _unit - given periods to check
   * _update - whether to update datetime before check
   *
   * @return int
   * Returns bitwise flag of started periods.
   */
  unsigned short GetStartedPeriods(bool _update = true) {
    unsigned short _result = DATETIME_NONE;
    static DateTimeEntry _prev_dt = dt;
    if (_update) {
      Update();
    }
    if (dt.GetValue(DATETIME_SECOND) < _prev_dt.GetValue(DATETIME_SECOND)) {
      // New minute started.
      _result |= DATETIME_MINUTE;
      if (dt.GetValue(DATETIME_MINUTE) < _prev_dt.GetValue(DATETIME_MINUTE)) {
        // New hour started.
        _result |= DATETIME_HOUR;
        if (dt.GetValue(DATETIME_HOUR) < _prev_dt.GetValue(DATETIME_HOUR)) {
          // New day started.
          _result |= DATETIME_DAY;
          if (dt.GetValue(DATETIME_DAY | DATETIME_WEEK) < _prev_dt.GetValue(DATETIME_DAY | DATETIME_WEEK)) {
            // New week started.
            _result |= DATETIME_WEEK;
          }
          if (dt.GetValue(DATETIME_DAY) < _prev_dt.GetValue(DATETIME_DAY)) {
            // New month started.
            _result |= DATETIME_MONTH;
            if (dt.GetValue(DATETIME_MONTH) < _prev_dt.GetValue(DATETIME_MONTH)) {
              // New year started.
              _result |= DATETIME_YEAR;
            }
          }
        }
      }
    }
    _prev_dt = dt;
    return _result;
  }

  /* Setters */

  /**
   * Sets the new DateTimeEntry struct.
   */
  void SetEntry(DateTimeEntry &_dt) { dt = _dt; }

  /* Dynamic methods */

  /**
   * Checks if new minute started.
   *
   * @return bool
   * Returns true when new minute started.
   */
  bool IsNewMinute(bool _update = true) {
    bool _result = false;
    static DateTimeEntry _prev_dt = dt;
    if (_update) {
      Update();
    }
    int _prev_secs = _prev_dt.GetSeconds();
    int _curr_secs = dt.GetSeconds();
    if (dt.GetSeconds() < _prev_dt.GetSeconds()) {
      _result = true;
    }
    _prev_dt = dt;
    return _result;
  }

  /**
   * Updates datetime to the current one.
   */
  void Update() { dt.SetDateTime(TimeCurrent()); }

  /* Conditions */

  /**
   * Checks for datetime condition.
   *
   * @param ENUM_DATETIME_CONDITION _cond
   *   Datetime condition.
   * @param MqlParam[] _args
   *   Condition arguments.
   * @return
   *   Returns true when the condition is met.
   */
  static bool CheckCondition(ENUM_DATETIME_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      case DATETIME_COND_IS_PEAK_HOUR:
        return DateTimeHelper::IsPeakHour();
      case DATETIME_COND_NEW_HOUR:
        return DateTimeHelper::Minute() == 0;
      case DATETIME_COND_NEW_DAY:
        return DateTimeHelper::Hour() == 0 && DateTimeHelper::Minute() == 0;
      case DATETIME_COND_NEW_WEEK:
        return DateTimeHelper::DayOfWeek() == 1 && DateTimeHelper::Hour() == 0 && DateTimeHelper::Minute() == 0;
      case DATETIME_COND_NEW_MONTH:
        return DateTimeHelper::Day() == 1 && DateTimeHelper::Hour() == 0 && DateTimeHelper::Minute() == 0;
      case DATETIME_COND_NEW_YEAR:
        return DateTimeHelper::DayOfYear() == 1 && DateTimeHelper::Hour() == 0 && DateTimeHelper::Minute() == 0;
      default:
#ifdef __debug__
        Print(StringFormat("%s: Error: Invalid datetime condition: %d!", __FUNCTION__, _cond));
#endif
        return false;
    }
  }
  static bool CheckCondition(ENUM_DATETIME_CONDITION _cond) {
    MqlParam _args[] = {};
    return DateTime::CheckCondition(_cond, _args);
  }
};
#endif  // DATETIME_MQH
