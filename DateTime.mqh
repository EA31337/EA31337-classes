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

// Includes class enum and structs.
#include "DateTime.enum.h"
#include "DateTime.struct.h"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compatibility).
string TimeToStr(datetime _value, int _mode) { return DateTime::TimeToStr(_value, _mode); }
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
  DateTime(datetime _dt) { dt_curr.SetDateTime(_dt); }

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
   * Check whether market is within peak hours.
   */
  static bool IsPeakHour() {
    int hour;
#ifdef __MQL5__
    MqlDateTime dt;
    TimeCurrent(dt);
    hour = dt.hour;
#else
    hour = Hour();
#endif
    return hour >= 8 && hour <= 16;
  }

  /**
   * Updates datetime to the current one.
   */
  void Update() { dt_curr.SetDateTime(TimeCurrent()); }

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
  static bool CheckCondition(ENUM_DATETIME_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      case DATETIME_COND_IS_PEAK_HOUR:
        return IsPeakHour();
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
  static bool CheckCondition(ENUM_DATETIME_CONDITION _cond) {
    MqlParam _args[] = {};
    return DateTime::CheckCondition(_cond, _args);
  }
};
#endif  // DATETIME_MQH
