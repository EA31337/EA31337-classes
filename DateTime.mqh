//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Class to provide functions that deals with date and time.
 */
class DateTime {
public:

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
      MqlDateTime dt;
      TimeToStruct(date, dt);
      return dt.day;
      #endif
    }

    /**
     * Returns the zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
     */
    static int TimeDayOfWeek(datetime date) {
        #ifdef __MQL4__
        return ::TimeDayOfWeek(date);
        #else
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.day_of_week;
        #endif
    }

    /**
     * Returns the day of year of the specified date.
     */
    static int TimeDayOfYear(datetime date) {
        #ifdef __MQL4__
        return ::TimeDayOfYear(date);
        #else
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.day_of_year;
        #endif
    }

    /**
     * Returns the month number of the specified time.
     */
    static int TimeMonth(datetime date) {
        #ifdef __MQL4__
        return ::TimeMonth(date);
        #else
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.mon;
        #endif
    }

    /**
     * Returns year of the specified date.
     */
    static int TimeYear(datetime date) {
        #ifdef __MQL4__
        return ::TimeYear(date);
        #else
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.year;
        #endif
    }

    /**
     * Returns the hour of the specified time.
     */
    static int TimeHour(datetime date) {
        #ifdef __MQL4__
        return ::TimeHour(date);
        #else
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.hour;
        #endif
    }

    /**
     * Returns the minute of the specified time.
     */
    static int TimeMinute(datetime date) {
        #ifdef __MQL4__
        return ::TimeMinute(date);
        #else
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.min;
        #endif
    }

    /**
     * Returns the amount of seconds elapsed from the beginning of the minute of the specified time.
     */
    static int TimeSeconds(datetime date) {
        #ifdef __MQL4__
        return ::TimeSeconds(date);
        #else
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.sec;
        #endif
    }

    /**
     * Returns the current day of the month (e.g. the day of month of the last known server time).
     */
    static int Day() {
        #ifdef __MQL4__
        return ::Day();
        #else
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.day);
        #endif
    }

    /**
     * Returns the current zero-based day of the week of the last known server time.
     */
    static int DayOfWeek() {
        #ifdef __MQL4__
        return ::DayOfWeek();
        #else
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.day_of_week);
        #endif
    }

    /**
     * Returns the current day of the year (e.g. the day of year of the last known server time).
     */
    static int DayOfYear() {
        #ifdef __MQL4__
        return ::DayOfYear();
        #else
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.day_of_year);
        #endif
    }


    /**
     * Returns the current month as number (e.g. the number of month of the last known server time).
     */
    static int Month() {
        #ifdef __MQL4__
        return ::Month();
        #else
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.mon);
        #endif
    }

    /**
     * Returns the current year (e.g. the year of the last known server time).
     */
    static int Year() {
        #ifdef __MQL4__
        return ::Year();
        #else
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.year);
        #endif
    }

    /**
     * Returns the hour of the last known server time by the moment of the program start.
     */
    static int Hour() {
        #ifdef __MQL4__
        return ::Hour();
        #else
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.hour);
        #endif
    }

    /**
     * Returns the current minute of the last known server time by the moment of the program start.
     */
    static int Minute() {
        #ifdef __MQL4__
        return ::Minute();
        #else
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.min);
        #endif
    }

    /**
     * Returns the amount of seconds elapsed from the beginning of the current minute of the last known server time.
     */
    static int Seconds() {
        #ifdef __MQL4__
        return ::Seconds();
        #else
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.sec);
        #endif
    }

  /**
   * Returns Time value for the bar of specified symbol with timeframe and shift.
   */
  datetime iTime(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _index) {
  #ifdef __MQL4__
    return (::iTime(_symbol,_tf,_index));
  #else
    datetime _arr_time[1] = {0};
    CopyTime(_symbol, _tf, 0, 1, _arr_time);
    return (_arr_time[0]);
  #endif
  }

  /**
   * Converts a time stamp into a string of "yyyy.mm.dd hh:mi" format.
   */
  static string TimeToStr(datetime value, int mode) {
  #ifdef __MQL4__
    return ::TimeToStr(value, mode);
  #else // __MQL5__
    return ::TimeToString(value, mode);
  #endif
  }

};