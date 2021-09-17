//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

// Forward declarations.
struct DataParamEntry;

// Includes class enum and structs.
#include "Array.mqh"
#include "Data.struct.h"
#include "DateTime.enum.h"
#include "DateTime.struct.h"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compatibility).
string TimeToStr(datetime _value, int _mode) { return DateTimeStatic::TimeToStr(_value, _mode); }
#endif

/*
 * Class to provide functions that deals with date and time.
 */
class DateTime {
 public:
  // Struct variables.
  DateTimeEntry dt_curr, dt_last;

  /* Special methods */

  /**
   * Class constructor.
   */
  DateTime() { TimeToStruct(TimeCurrent(), dt_curr); }
  DateTime(DateTimeEntry &_dt) { dt_curr = _dt; }
  DateTime(MqlDateTime &_dt) { dt_curr = _dt; }
  DateTime(datetime _dt) { dt_curr.Set(_dt); }

  /**
   * Class deconstructor.
   */
  ~DateTime() {}

  /* Getters */

  /**
   * Returns the DateTimeEntry struct.
   */
  DateTimeEntry GetEntry() const { return dt_curr; }

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
  unsigned int GetStartedPeriods(bool _update = true, bool _update_last = true) {
    unsigned int _result = DATETIME_NONE;
    if (_update) {
      Update();
    }

    if (dt_curr.GetValue(DATETIME_YEAR) != dt_last.GetValue(DATETIME_YEAR)) {
      // New year started.
      _result |= DATETIME_YEAR | DATETIME_MONTH | DATETIME_DAY | DATETIME_HOUR | DATETIME_MINUTE | DATETIME_SECOND;
    } else if (dt_curr.GetValue(DATETIME_MONTH) != dt_last.GetValue(DATETIME_MONTH)) {
      // New month started.
      _result |= DATETIME_MONTH | DATETIME_DAY | DATETIME_HOUR | DATETIME_MINUTE | DATETIME_SECOND;
    } else if (dt_curr.GetValue(DATETIME_DAY) != dt_last.GetValue(DATETIME_DAY)) {
      // New day started.
      _result |= DATETIME_DAY | DATETIME_HOUR | DATETIME_MINUTE | DATETIME_SECOND;
    } else if (dt_curr.GetValue(DATETIME_HOUR) != dt_last.GetValue(DATETIME_HOUR)) {
      // New hour started.
      _result |= DATETIME_HOUR | DATETIME_MINUTE | DATETIME_SECOND;
    } else if (dt_curr.GetValue(DATETIME_MINUTE) != dt_last.GetValue(DATETIME_MINUTE)) {
      // New minute started.
      _result |= DATETIME_MINUTE | DATETIME_SECOND;
    } else if (dt_curr.GetValue(DATETIME_SECOND) != dt_last.GetValue(DATETIME_SECOND)) {
      // New second started.
      _result |= DATETIME_SECOND;
    }

    if (dt_curr.GetValue(DATETIME_DAY | DATETIME_WEEK) != dt_last.GetValue(DATETIME_DAY | DATETIME_WEEK)) {
      // New week started.
      _result |= DATETIME_WEEK;
    }

#ifdef __debug__
    string _passed =
        "time now " + (string)dt_curr.GetTimestamp() + ", time last " + (string)dt_last.GetTimestamp() + " ";

    if (_update) {
      _passed += "updating time ";
    }

    if ((_result & DATETIME_MONTH) != 0) {
      _passed += "[month passed] ";
    }

    if ((_result & DATETIME_WEEK) != 0) {
      _passed += "[week passed] ";
    }

    if ((_result & DATETIME_DAY) != 0) {
      _passed += "[day passed] ";
    }

    if ((_result & DATETIME_HOUR) != 0) {
      _passed += "[hour passed] ";
    }

    if ((_result & DATETIME_MINUTE) != 0) {
      _passed += "[minute passed] ";
    }

    if ((_result & DATETIME_SECOND) != 0) {
      _passed += "[second passed] ";
    }

    if (_update_last) {
      _passed += "(setting last time) ";
    }

    if (_passed != "") {
      Print(_passed);
    }
#endif

    if (_update_last) {
      dt_last = dt_curr;
    }

    return _result;
  }

  /* Setters */

  /**
   * Sets the new DateTimeEntry struct.
   */
  void SetEntry(DateTimeEntry &_dt) { dt_curr = _dt; }

  /* Dynamic methods */

  /**
   * Checks if new minute started.
   *
   * @return bool
   * Returns true when new minute started.
   */
  bool IsNewMinute(bool _update = true) {
    bool _result = false;
    if (_update) {
      dt_last = dt_curr;
      Update();
    }
    int _prev_secs = dt_last.GetSeconds();
    int _curr_secs = dt_curr.GetSeconds();
    if (dt_curr.GetSeconds() < dt_last.GetSeconds()) {
      _result = true;
    }
    dt_last = dt_curr;
    return _result;
  }

  /**
   * Updates datetime to the current one.
   */
  void Update() { dt_curr.Set(TimeCurrent()); }

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
  static bool CheckCondition(ENUM_DATETIME_CONDITION _cond, ARRAY_REF(DataParamEntry, _args)) {
    switch (_cond) {
      case DATETIME_COND_IS_PEAK_HOUR:
        return DateTimeStatic::IsPeakHour();
      case DATETIME_COND_NEW_HOUR:
        return DateTimeStatic::Minute() == 0;
      case DATETIME_COND_NEW_DAY:
        return DateTimeStatic::Hour() == 0 && DateTimeStatic::Minute() == 0;
      case DATETIME_COND_NEW_WEEK:
        return DateTimeStatic::DayOfWeek() == 1 && DateTimeStatic::Hour() == 0 && DateTimeStatic::Minute() == 0;
      case DATETIME_COND_NEW_MONTH:
        return DateTimeStatic::Day() == 1 && DateTimeStatic::Hour() == 0 && DateTimeStatic::Minute() == 0;
      case DATETIME_COND_NEW_YEAR:
        return DateTimeStatic::DayOfYear() == 1 && DateTimeStatic::Hour() == 0 && DateTimeStatic::Minute() == 0;
      default:
#ifdef __debug__
        Print(StringFormat("%s: Error: Invalid datetime condition: %d!", __FUNCTION__, _cond));
#endif
        return false;
    }
  }
  static bool CheckCondition(ENUM_DATETIME_CONDITION _cond) {
    ARRAY(DataParamEntry, _args);
    return DateTime::CheckCondition(_cond, _args);
  }
};
#endif  // DATETIME_MQH
