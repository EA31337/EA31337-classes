// @todo: TimeTradeServer isn't avaliable in MQL4

class DateTime {
public:
    static int TimeDay (datetime date) {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.day;
        #else
        return TimeDay(date);
        #endif
    }
    static int TimeDayOfWeek (datetime date) {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.day_of_week;
        #else
        return TimeDayOfWeek(date);
        #endif
    }
    static int TimeDayOfYear (datetime date) {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.day_of_year;
        #else
        return TimeDayOfYear(date);
        #endif
    }
    static int TimeMonth (datetime date) {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.mon;
        #else
        return TimeMonth(date);
        #endif
    }
    static int TimeYear (datetime date) {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.year;
        #else
        return TimeYear(date);
        #endif
    }

    static int TimeHour (datetime date) {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.hour;
        #else
        return TimeHour(date);
        #endif
    }
    static int TimeMinute (datetime date) {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.min;
        #else
        return TimeMinute(date);
        #endif
    }
    static int TimeSeconds (datetime date) {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeToStruct(date, dt);
        return dt.sec;
        #else
        return TimeSeconds(date);
        #endif
    }

    static int Day() {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.day);
        #else
        return Day();
        #endif
    }
    static int DayOfWeek() {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.day_of_week);
        #else
        return DayOfWeek();
        #endif
    }
    static int DayOfYear() {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.day_of_year);
        #else
        return DayOfYear();
        #endif
    }

    static int Month() {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.mon);
        #else
        return Month();
        #endif
    }
    static int Year() {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.year);
        #else
        return Year();
        #endif
    }

    static int Hour() {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.hour);
        #else
        return Hour();
        #endif
    }
    static int Minute() {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.min);
        #else
        return Minute();
        #endif
    }
    static int Seconds() {
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeCurrent(dt);
        return(dt.sec);
        #else
        return Seconds();
        #endif
    }
};
