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
 * Math methods.
 *
 * @docs
 * - https://docs.mql4.com/dateandtime
 * - https://www.mql5.com/en/docs/dateandtime
 */

// Prevents processing this includes file for the second time.
#ifndef DATETIMEHELPER_MQH
#define DATETIMEHELPER_MQH

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compatibility).
string TimeToStr(datetime _value, int _mode) { return DateTimeHelper::TimeToStr(_value, _mode); }
#endif

/*
 * struct to provide functions that deals with date and time.
 */
struct DateTimeHelper {
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
   * Returns the current day of the month (e.g. the day of month of the last known server time).
   */
  static int Day(datetime dt = NULL) {
    if (dt == NULL) {
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
    if (dt == NULL) {
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
    if (dt == NULL) {
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
   * Returns the current month as number (e.g. the number of month of the last known server time).
   */
  static int Month(datetime dt = NULL) {
    if (dt == NULL) {
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
   * Returns the current year (e.g. the year of the last known server time).
   */
  static int Year(datetime dt = NULL) {
    if (dt == NULL) {
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

  /**
   * Returns the hour of the last known server time by the moment of the program start.
   */
  static int Hour(datetime dt = NULL) {
    if (dt == NULL) {
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
   * Returns the current minute of the last known server time by the moment of the program start.
   */
  static int Minute(datetime dt = NULL) {
    if (dt == NULL) {
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
   * Returns the amount of seconds elapsed from the beginning of the current minute of the last known server time.
   */
  static int Seconds(datetime dt = NULL) {
    if (dt == NULL) {
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
};
#endif  // DATETIMEHELPER_MQH
