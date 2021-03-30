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
 * Includes DateTime's structs.
 */

// Includes.
#include "DateTime.enum.h"

#ifndef __MQLBUILD__
/**
 * The date type structure.
 *
 * @see:
 * - https://docs.mql4.com/constants/structures/mqldatetime
 * - https://www.mql5.com/en/docs/constants/structures/mqldatetime
 */
struct MqlDateTime {
  int year;         // Year.
  int mon;          // Month.
  int day;          // Day of month.
  int hour;         // Hour.
  int min;          // Minute.
  int sec;          // Second.
  int day_of_week;  // Zero-based day number of week (0-Sunday, 1-Monday, ... ,6-Saturday).
  int day_of_year;  // Zero-based day number of the year (1st Jan = 0).
};
#endif
struct DateTimeEntry : MqlDateTime {
  int week_of_year;
  // Struct constructors.
  DateTimeEntry() { SetDateTime(); }
  DateTimeEntry(datetime _dt) { SetDateTime(_dt); }
  // Getters.
  int GetDayOfMonth() { return day; }
  int GetDayOfWeek() {
    // Returns the zero-based day of week.
    // (0-Sunday, 1-Monday, ... , 6-Saturday).
    return day_of_week;
  }
  int GetDayOfYear() { return day_of_year + 1; }  // Zero-based day of year (1st Jan = 0).
  int GetHour() { return hour; }
  int GetMinute() { return min; }
  int GetMonth() { return mon; }
  int GetSeconds() { return sec; }
  // int GetWeekOfYear() { return week_of_year; } // @todo
  int GetValue(ENUM_DATETIME_UNIT _unit) {
    int _result = -1;
    switch (_unit) {
      case DATETIME_SECOND:
        return GetSeconds();
      case DATETIME_MINUTE:
        return GetMinute();
      case DATETIME_HOUR:
        return GetHour();
      case DATETIME_DAY:
        return GetDayOfMonth();
      case DATETIME_WEEK:
        return -1;  // return WeekOfYear(); // @todo
      case DATETIME_MONTH:
        return GetMonth();
      case DATETIME_YEAR:
        return GetYear();
    }
    return _result;
  }
  int GetValue(int _unit) {
    if ((_unit & (DATETIME_DAY | DATETIME_WEEK)) != 0) {
      return GetDayOfWeek();
    } else if ((_unit & (DATETIME_DAY | DATETIME_MONTH)) != 0) {
      return GetDayOfMonth();
    } else if ((_unit & (DATETIME_DAY | DATETIME_YEAR)) != 0) {
      return GetDayOfYear();
    }
    return GetValue((ENUM_DATETIME_UNIT)_unit);
  }
  int GetYear() { return year; }
  datetime GetTimestamp() { return StructToTime(this); }
  // Setters.
  void SetDateTime() { TimeToStruct(TimeCurrent(), this); }
  void SetDateTime(datetime _dt) { TimeToStruct(_dt, this); }
  void SetDayOfMonth(int _value) {
    day = _value;
    day_of_week = DateTime::TimeDayOfWeek(GetTimestamp());  // Zero-based day of week.
    day_of_year = DateTime::TimeDayOfYear(GetTimestamp());  // Zero-based day of year.
  }
  void SetDayOfYear(int _value) {
    day_of_year = _value - 1;                               // Sets zero-based day of year.
    day = DateTime::TimeDay(GetTimestamp());                // Sets day of month (1..31).
    day_of_week = DateTime::TimeDayOfWeek(GetTimestamp());  // Zero-based day of week.
  }
  void SetHour(int _value) { hour = _value; }
  void SetMinute(int _value) { min = _value; }
  void SetMonth(int _value) { mon = _value; }
  void SetSeconds(int _value) { sec = _value; }
  void SetWeekOfYear(int _value) {
    week_of_year = _value;
    // day = @todo;
    // day_of_week = @todo;
    // day_of_year = @todo;
  }
  void SetValue(ENUM_DATETIME_UNIT _unit, int _value) {
    switch (_unit) {
      case DATETIME_SECOND:
        SetSeconds(_value);
        break;
      case DATETIME_MINUTE:
        SetMinute(_value);
        break;
      case DATETIME_HOUR:
        SetHour(_value);
        break;
      case DATETIME_DAY:
        SetDayOfMonth(_value);
        break;
      case DATETIME_WEEK:
        SetWeekOfYear(_value);
        break;
      case DATETIME_MONTH:
        SetMonth(_value);
        break;
      case DATETIME_YEAR:
        SetYear(_value);
        break;
    }
  }
  void SetValue(unsigned short _unit, int _value) {
    if ((_unit & (DATETIME_DAY | DATETIME_MONTH)) != 0) {
      SetDayOfMonth(_value);
    } else if ((_unit & (DATETIME_DAY | DATETIME_YEAR)) != 0) {
      SetDayOfYear(_value);
    } else {
      SetValue((ENUM_DATETIME_UNIT)_unit, _value);
    }
  }
  void SetYear(int _value) { year = _value; }
};
