//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
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

/**
 * @file
 * Class to work with data of datetime type.
 *
 * @docs
 * - https://docs.mql4.com/dateandtime
 * - https://www.mql5.com/en/docs/dateandtime
 */

// Properties.
#property strict

/*
 * Class to provide functions that deals with date and time.
 */
class DateTime { // : public Terminal {

  public:
    // Struct variables.
    MqlDateTime dt;

    /**
     * Class constructor.
     */
    void DateTime(MqlDateTime &_dt) {
      dt = _dt;
    }
    void DateTime(datetime date) {
      TimeToStruct(date, dt);
    }

    /**
     * Class deconstructor.
     */
    void ~DateTime() {
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
     * Returns the day of month (1-31) of the specified date.
     */
    static int TimeDay(datetime date) {
      #ifdef __MQL4__
      return ::TimeDay(date);
      #else
      MqlDateTime _dt;
      TimeToStruct(date, _dt);
      return _dt.day;
      #endif
    }

    /**
     * Returns the zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
     */
    static int TimeDayOfWeek(datetime date) {
        #ifdef __MQL4__
        return ::TimeDayOfWeek(date);
        #else
        MqlDateTime _dt;
        TimeToStruct(date, _dt);
        return _dt.day_of_week;
        #endif
    }

    /**
     * Returns the day of year of the specified date.
     */
    static int TimeDayOfYear(datetime date) {
        #ifdef __MQL4__
        return ::TimeDayOfYear(date);
        #else
        MqlDateTime _dt;
        TimeToStruct(date, _dt);
        return _dt.day_of_year;
        #endif
    }

    /**
     * Returns the month number of the specified time.
     */
    static int TimeMonth(datetime date) {
        #ifdef __MQL4__
        return ::TimeMonth(date);
        #else
        MqlDateTime _dt;
        TimeToStruct(date, _dt);
        return _dt.mon;
        #endif
    }

    /**
     * Returns year of the specified date.
     */
    static int TimeYear(datetime date) {
        #ifdef __MQL4__
        return ::TimeYear(date);
        #else
        MqlDateTime _dt;
        TimeToStruct(date, _dt);
        return _dt.year;
        #endif
    }

    /**
     * Returns the hour of the specified time.
     */
    static int TimeHour(datetime date) {
        #ifdef __MQL4__
        return ::TimeHour(date);
        #else
        MqlDateTime _dt;
        TimeToStruct(date, _dt);
        return _dt.hour;
        #endif
    }

    /**
     * Returns the minute of the specified time.
     */
    static int TimeMinute(datetime date) {
        #ifdef __MQL4__
        return ::TimeMinute(date);
        #else
        MqlDateTime _dt;
        TimeToStruct(date, _dt);
        return _dt.min;
        #endif
    }

    /**
     * Returns the amount of seconds elapsed from the beginning of the minute of the specified time.
     */
    static int TimeSeconds(datetime date) {
        #ifdef __MQL4__
        return ::TimeSeconds(date);
        #else
        MqlDateTime _dt;
        TimeToStruct(date, _dt);
        return _dt.sec;
        #endif
    }

    /**
     * Returns the current day of the month (e.g. the day of month of the last known server time).
     */
    static int Day() {
        #ifdef __MQL4__
        return ::Day();
        #else
        MqlDateTime _dt;
        TimeCurrent(_dt);
        return(_dt.day);
        #endif
    }

    /**
     * Returns the current zero-based day of the week of the last known server time.
     */
    static int DayOfWeek() {
        #ifdef __MQL4__
        return ::DayOfWeek();
        #else
        MqlDateTime _dt;
        TimeCurrent(_dt);
        return(_dt.day_of_week);
        #endif
    }

    /**
     * Returns the current day of the year (e.g. the day of year of the last known server time).
     */
    static int DayOfYear() {
        #ifdef __MQL4__
        return ::DayOfYear();
        #else
        MqlDateTime _dt;
        TimeCurrent(_dt);
        return(_dt.day_of_year);
        #endif
    }


    /**
     * Returns the current month as number (e.g. the number of month of the last known server time).
     */
    static int Month() {
        #ifdef __MQL4__
        return ::Month();
        #else
        MqlDateTime _dt;
        TimeCurrent(_dt);
        return(_dt.mon);
        #endif
    }

    /**
     * Returns the current year (e.g. the year of the last known server time).
     */
    static int Year() {
        #ifdef __MQL4__
        return ::Year();
        #else
        MqlDateTime _dt;
        TimeCurrent(_dt);
        return(_dt.year);
        #endif
    }

    /**
     * Returns the hour of the last known server time by the moment of the program start.
     */
    static int Hour() {
        #ifdef __MQL4__
        return ::Hour();
        #else
        MqlDateTime _dt;
        TimeCurrent(_dt);
        return(_dt.hour);
        #endif
    }

    /**
     * Returns the current minute of the last known server time by the moment of the program start.
     */
    static int Minute() {
        #ifdef __MQL4__
        return ::Minute();
        #else
        MqlDateTime _dt;
        TimeCurrent(_dt);
        return(_dt.min);
        #endif
    }

    /**
     * Returns the amount of seconds elapsed from the beginning of the current minute of the last known server time.
     */
    static int Seconds() {
        #ifdef __MQL4__
        return ::Seconds();
        #else
        MqlDateTime _dt;
        TimeCurrent(_dt);
        return(_dt.sec);
        #endif
    }

    /**
     * Converts a time stamp into a string of "yyyy.mm.dd hh:mi" format.
     */
    static string TimeToStr(datetime value, int mode = TIME_DATE | TIME_MINUTES | TIME_SECONDS) {
      #ifdef __MQL4__
      return ::TimeToStr(value, mode);
      #else // __MQL5__
      // #define TimeToStr(value, mode) DateTime::TimeToStr(value, mode)
      return ::TimeToString(value, mode);
      #endif
    }
    string TimeToStr(int mode = TIME_DATE | TIME_MINUTES | TIME_SECONDS) {
      return TimeToStr(TimeCurrent(), mode);
    }
};