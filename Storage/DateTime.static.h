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

// Includes.
#include "../Platform/PlatformTime.h"

/*
 * Struct to provide static date and time methods.
 */
struct DateTimeStatic {
  /**
   * Returns the current day of the month (e.g. the day of month of the last known server time).
   */
  static int Day(datetime dt = 0) {
    if (dt == (datetime)0) {
      dt = (datetime)PlatformTime::CurrentTimestamp();
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
  static int DayOfWeek(datetime dt = 0) {
    if (dt == (datetime)0) {
      dt = (datetime)PlatformTime::CurrentTimestamp();
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
  static int DayOfYear(datetime dt = 0) {
    if (dt == (datetime)0) {
      dt = (datetime)PlatformTime::CurrentTimestamp();
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
  static int Hour(datetime dt = 0) {
    if (dt == (datetime)0) {
      dt = (datetime)PlatformTime::CurrentTimestamp();
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
  static int Minute(datetime dt = 0) {
    if (dt == (datetime)0) {
      dt = (datetime)PlatformTime::CurrentTimestamp();
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
  static int Month(datetime dt = 0) {
    if (dt == (datetime)0) {
      dt = (datetime)PlatformTime::CurrentTimestamp();
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
  static int Seconds(datetime dt = 0) {
    if (dt == (datetime)0) {
      dt = (datetime)PlatformTime::CurrentTimestamp();
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
  static string TimeToStr(int mode = TIME_DATE | TIME_MINUTES | TIME_SECONDS) {
    return TimeToStr(PlatformTime::CurrentTimestamp(), mode);
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
   * Returns the current year (e.g. the year of the last known server time).
   */
  static int Year(datetime dt = 0) {
    if (dt == (datetime)0) {
      dt = (datetime)PlatformTime::CurrentTimestamp();
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
