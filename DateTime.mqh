//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
 * Class to work with data of datetime type.
 *
 * @docs
 * - https://docs.mql4.com/dateandtime
 * - https://www.mql5.com/en/docs/dateandtime
 */

// Prevents processing this includes file for the second time.
#ifndef DATETIME_MQH
#define DATETIME_MQH

// Includes.
#include "Condition.enums.h"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compatibility).
string TimeToStr(datetime _value, int _mode) { return DateTime::TimeToStr(_value, _mode); }
#endif

// Define enums.
enum ENUM_DATETIME_UNIT {
  DATETIME_NONE = 0,         // None
  DATETIME_SECOND = 1 << 0,  // Second
  DATETIME_MINUTE = 1 << 1,  // Minute
  DATETIME_HOUR = 1 << 2,    // Hour
  DATETIME_DAY = 1 << 3,     // Day
  DATETIME_WEEK = 1 << 4,    // Week
  DATETIME_MONTH = 1 << 5,   // Month
  DATETIME_YEAR = 1 << 6,    // Year
  DATETIME_HMS = DATETIME_HOUR | DATETIME_MINUTE | DATETIME_SECOND,
  DATETIME_YMD = DATETIME_YEAR | DATETIME_MONTH | DATETIME_DAY,
  DATETIME_ALL = DATETIME_HMS | DATETIME_WEEK | DATETIME_YMD,
};

#ifndef __MQLBUILD__
// The date type structure.
// @docs
// - https://docs.mql4.com/constants/structures/mqldatetime
// - https://www.mql5.com/en/docs/constants/structures/mqldatetime
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
      default:
        if ((bool)(_unit & (DATETIME_DAY | DATETIME_WEEK))) {
          return GetDayOfWeek();
        } else if ((bool)(_unit & (DATETIME_DAY | DATETIME_MONTH))) {
          return GetDayOfMonth();
        } else if ((bool)(_unit & (DATETIME_DAY | DATETIME_YEAR))) {
          return GetDayOfYear();
        }
    }
    return _result;
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
      default:
        if ((bool)(_unit & (DATETIME_DAY | DATETIME_MONTH))) {
          SetDayOfMonth(_value);
        } else if ((bool)(_unit & (DATETIME_DAY | DATETIME_YEAR))) {
          SetDayOfYear(_value);
        }
    }
  }
  void SetYear(int _value) { year = _value; }
};

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
  DateTimeEntry GetEntry() { return dt; }

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
  int GetStartedPeriods(bool _update = true) {
    bool _result = DATETIME_NONE;
    static DateTimeEntry _prev_dt = dt;
    if (_update) {
      Update();
    }
    if (dt.GetValue(DATETIME_SECOND) < _prev_dt.GetValue(DATETIME_SECOND)) {
      _result |= DATETIME_MINUTE;
      if (dt.GetValue(DATETIME_MINUTE) < _prev_dt.GetValue(DATETIME_MINUTE)) {
        _result |= DATETIME_HOUR;
        if (dt.GetValue(DATETIME_HOUR) < _prev_dt.GetValue(DATETIME_HOUR)) {
          _result |= DATETIME_DAY;
          if (dt.GetValue(DATETIME_DAY) < _prev_dt.GetValue(DATETIME_DAY)) {
            _result |= DATETIME_MONTH;
            if (dt.GetValue(DATETIME_MONTH) < _prev_dt.GetValue(DATETIME_MONTH)) {
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

  /* Static methods */

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
   * Returns the day of month (1-31) of the specified date.
   */
  static int TimeDay(datetime date) {
#ifdef __MQL4__
    return ::TimeDay(date);
#else
    DateTimeEntry _dt;
    TimeToStruct(date, _dt);
    return _dt.GetDayOfMonth();
#endif
  }

  /**
   * Returns the zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
  static int TimeDayOfWeek(datetime date) {
#ifdef __MQL4__
    return ::TimeDayOfWeek(date);
#else
    DateTimeEntry _dt;
    TimeToStruct(date, _dt);
    return _dt.GetDayOfWeek();
#endif
  }

  /**
   * Returns the day of year of the specified date.
   */
  static int TimeDayOfYear(datetime date) {
#ifdef __MQL4__
    return ::TimeDayOfYear(date);
#else
    DateTimeEntry _dt;
    TimeToStruct(date, _dt);
    return _dt.GetDayOfYear();
#endif
  }

  /**
   * Returns the month number of the specified time.
   */
  static int TimeMonth(datetime date) {
#ifdef __MQL4__
    return ::TimeMonth(date);
#else
    DateTimeEntry _dt;
    TimeToStruct(date, _dt);
    return _dt.GetMonth();
#endif
  }

  /**
   * Returns year of the specified date.
   */
  static int TimeYear(datetime date) {
#ifdef __MQL4__
    return ::TimeYear(date);
#else
    DateTimeEntry _dt;
    TimeToStruct(date, _dt);
    return _dt.GetYear();
#endif
  }

  /**
   * Returns the hour of the specified time.
   */
  static int TimeHour(datetime date) {
#ifdef __MQL4__
    return ::TimeHour(date);
#else
    DateTimeEntry _dt;
    TimeToStruct(date, _dt);
    return _dt.GetHour();
#endif
  }

  /**
   * Returns the minute of the specified time.
   */
  static int TimeMinute(datetime date) {
#ifdef __MQL4__
    return ::TimeMinute(date);
#else
    DateTimeEntry _dt;
    TimeToStruct(date, _dt);
    return _dt.GetMinute();
#endif
  }

  /**
   * Returns the amount of seconds elapsed from the beginning of the minute of the specified time.
   */
  static int TimeSeconds(datetime date) {
#ifdef __MQL4__
    return ::TimeSeconds(date);
#else
    DateTimeEntry _dt;
    TimeToStruct(date, _dt);
    return _dt.GetSeconds();
#endif
  }

  /**
   * Returns the current day of the month (e.g. the day of month of the last known server time).
   */
  static int Day() {
#ifdef __MQL4__
    return ::Day();
#else
    DateTimeEntry _dt;
    TimeCurrent(_dt);
    return (_dt.GetDayOfMonth());
#endif
  }

  /**
   * Returns the current zero-based day of the week of the last known server time.
   */
  static int DayOfWeek() {
#ifdef __MQL4__
    return ::DayOfWeek();
#else
    DateTimeEntry _dt;
    TimeCurrent(_dt);
    return (_dt.GetDayOfWeek());
#endif
  }

  /**
   * Returns the current day of the year (e.g. the day of year of the last known server time).
   */
  static int DayOfYear() {
#ifdef __MQL4__
    return ::DayOfYear();
#else
    DateTimeEntry _dt;
    TimeCurrent(_dt);
    return (_dt.GetDayOfYear());
#endif
  }

  /**
   * Returns the current month as number (e.g. the number of month of the last known server time).
   */
  static int Month() {
#ifdef __MQL4__
    return ::Month();
#else
    DateTimeEntry _dt;
    TimeCurrent(_dt);
    return (_dt.GetMonth());
#endif
  }

  /**
   * Returns the current year (e.g. the year of the last known server time).
   */
  static int Year() {
#ifdef __MQL4__
    return ::Year();
#else
    DateTimeEntry _dt;
    TimeCurrent(_dt);
    return (_dt.GetYear());
#endif
  }

  /**
   * Returns the hour of the last known server time by the moment of the program start.
   */
  static int Hour() {
#ifdef __MQL4__
    return ::Hour();
#else
    DateTimeEntry _dt;
    TimeCurrent(_dt);
    return (_dt.GetHour());
#endif
  }

  /**
   * Returns the current minute of the last known server time by the moment of the program start.
   */
  static int Minute() {
#ifdef __MQL4__
    return ::Minute();
#else
    DateTimeEntry _dt;
    TimeCurrent(_dt);
    return (_dt.GetMinute());
#endif
  }

  /**
   * Returns the amount of seconds elapsed from the beginning of the current minute of the last known server time.
   */
  static int Seconds() {
#ifdef __MQL4__
    return ::Seconds();
#else
    DateTimeEntry _dt;
    TimeCurrent(_dt);
    return (_dt.GetSeconds());
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
  static bool Condition(ENUM_DATETIME_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      case DATETIME_COND_NEW_HOUR:
        return Minute() == 0;
      case DATETIME_COND_NEW_DAY:
        return Hour() == 0 && Minute() == 0;
      case DATETIME_COND_NEW_WEEK:
        return DayOfWeek() == 1 && Hour() == 0 && Minute() == 0;
      case DATETIME_COND_NEW_MONTH:
        return Day() == 1 && Hour() == 0 && Minute() == 0;
      case DATETIME_COND_NEW_YEAR:
        return DayOfYear() == 1 && Hour() == 0 && Minute() == 0;
      default:
#ifdef __debug__
        Print(StringFormat("%s: Error: Invalid datetime condition: %d!", __FUNCTION__, _cond));
#endif
        return false;
    }
  }
  static bool Condition(ENUM_DATETIME_CONDITION _cond) {
    MqlParam _args[] = {};
    return DateTime::Condition(_cond, _args);
  }
};
#endif  // DATETIME_MQH
