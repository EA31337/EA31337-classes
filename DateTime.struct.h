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
 * Includes DateTime's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward declarations.
struct DateTimeStatic;

// Includes.
#include "DateTime.enum.h"
#include "Std.h"

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

/*
 * Struct to provide static date and time methods.
 */
struct DateTimeStatic {
  /**
   * Returns the current day of the month (e.g. the day of month of the last known server time).
   */
  static int Day(datetime dt = NULL) {
    if (dt == 0) {
      dt = TimeCurrent();
    }
#ifdef __MQL4__
    return ::TimeDay(dt);
#else
    MqlDateTime _dt;
    TimeToStruct(dt, _dt);
    return _dt.day;
#endif
  }

  /**
   * Returns the current zero-based day of the week of the last known server time.
   */
  static int DayOfWeek(datetime dt = NULL) {
    if (dt == 0) {
      dt = TimeCurrent();
    }
#ifdef __MQL4__
    return ::DayOfWeek();
#else
    MqlDateTime _dt;
    TimeToStruct(dt, _dt);
    return _dt.day_of_week;
#endif
  }

  /**
   * Returns the current day of the year (e.g. the day of year of the last known server time).
   */
  static int DayOfYear(datetime dt = NULL) {
    if (dt == 0) {
      dt = TimeCurrent();
    }
#ifdef __MQL4__
    return ::DayOfYear();
#else
    MqlDateTime _dt;
    TimeToStruct(dt, _dt);
    return _dt.day_of_year + 1;
#endif
  }

  /**
   * Returns the hour of the last known server time by the moment of the program start.
   */
  static int Hour(datetime dt = NULL) {
    if (dt == 0) {
      dt = TimeCurrent();
    }
#ifdef __MQL4__
    return ::Hour();
#else
    MqlDateTime _dt;
    TimeToStruct(dt, _dt);
    return _dt.hour;
#endif
  }

  /**
   * Check whether market is within peak hours.
   */
  static bool IsPeakHour() {
    MqlDateTime dt;
    TimeToStruct(::TimeGMT(), dt);
    return dt.hour >= 8 && dt.hour <= 16;
  }

  /**
   * Returns the current minute of the last known server time by the moment of the program start.
   */
  static int Minute(datetime dt = NULL) {
    if (dt == 0) {
      dt = TimeCurrent();
    }
#ifdef __MQL4__
    return ::Minute();
#else
    MqlDateTime _dt;
    TimeToStruct(dt, _dt);
    return _dt.min;
#endif
  }

  /**
   * Returns the current month as number (e.g. the number of month of the last known server time).
   */
  static int Month(datetime dt = NULL) {
    if (dt == 0) {
      dt = TimeCurrent();
    }
#ifdef __MQL4__
    return ::Month();
#else
    MqlDateTime _dt;
    TimeToStruct(dt, _dt);
    return _dt.mon;
#endif
  }

  /**
   * Returns the amount of seconds elapsed from the beginning of the current minute of the last known server time.
   */
  static int Seconds(datetime dt = NULL) {
    if (dt == 0) {
      dt = TimeCurrent();
    }
#ifdef __MQL4__
    return ::Seconds();
#else
    MqlDateTime _dt;
    TimeToStruct(dt, _dt);
    return _dt.sec;
#endif
  }

  /**
   * Converts a time stamp into a string of "yyyy.mm.dd hh:mi" format.
   */
  static string TimeToStr(datetime value, int mode = TIME_DATE | TIME_MINUTES | TIME_SECONDS) {
#ifdef __MQL4__
    return ::TimeToStr(value, mode);
#else  // __MQL5__
    // #define TimeToStr(value, mode) DateTime::TimeToStr(value, mode)
    return ::TimeToString(value, mode);
#endif
  }
  static string TimeToStr(int mode = TIME_DATE | TIME_MINUTES | TIME_SECONDS) { return TimeToStr(TimeCurrent(), mode); }

  /**
   * Returns the current time of the trade server.
   */
  static datetime TimeTradeServer() {
#ifdef __MQL4__
    // Unlike MQL5 TimeTradeServer(),
    // TimeCurrent() returns the last known server time.
    return ::TimeCurrent();
#else
    // The calculation of the time value is performed in the client terminal
    // and depends on the time settings of your computer.
    return ::TimeTradeServer();
#endif
  }

  /**
   * Returns the current year (e.g. the year of the last known server time).
   */
  static int Year(datetime dt = NULL) {
    if (dt == 0) {
      dt = TimeCurrent();
    }
#ifdef __MQL4__
    return ::Year();
#else
    MqlDateTime _dt;
    TimeToStruct(dt, _dt);
    return _dt.year;
#endif
  }
};

struct DateTimeEntry : MqlDateTime {
  int week_of_year;
  // Struct constructors.
  DateTimeEntry() { Set(); }
  DateTimeEntry(datetime _dt) { Set(_dt); }
  DateTimeEntry(MqlDateTime& _dt) {
    Set(_dt);
#ifndef __MQL__
    throw NotImplementedException();
#endif
  }
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
      default:
        break;
    }
    return _result;
  }
  unsigned int GetValue(unsigned int _unit) {
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
  datetime GetTimestamp() { return StructToTime(THIS_REF); }
  // Setters.
  void Set() {
    TimeToStruct(::TimeCurrent(), THIS_REF);
    // @fixit Should also set day of week.
  }
  void SetGMT() {
    TimeToStruct(::TimeGMT(), THIS_REF);
    // @fixit Should also set day of week.
  }
  // Set date and time.
  void Set(datetime _time) {
    TimeToStruct(_time, THIS_REF);
    // @fixit Should also set day of week.
  }
  // Set date and time.
  void Set(MqlDateTime& _time) {
    THIS_REF = _time;
    // @fixit Should also set day of week.
  }
  void SetDayOfMonth(int _value) {
    day = _value;
    day_of_week = DateTimeStatic::DayOfWeek();  // Zero-based day of week.
    day_of_year = DateTimeStatic::DayOfYear();  // Zero-based day of year.
  }
  void SetDayOfYear(int _value) {
    day_of_year = _value - 1;                   // Sets zero-based day of year.
    day = DateTimeStatic::Month();              // Sets day of month (1..31).
    day_of_week = DateTimeStatic::DayOfWeek();  // Zero-based day of week.
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
      default:
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
