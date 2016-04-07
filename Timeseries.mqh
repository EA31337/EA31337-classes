/*
 * Timeseries class
 * Docs: https://docs.mql4.com/series
 */

class Timeseries
{
public:
    #ifdef __MQL5__
    static ENUM_TIMEFRAMES TFMigrate(int tf) {
        switch(tf) {
            case 0: return(PERIOD_CURRENT);
            case 1: return(PERIOD_M1);
            case 5: return(PERIOD_M5);
            case 15: return(PERIOD_M15);
            case 30: return(PERIOD_M30);
            case 60: return(PERIOD_H1);
            case 240: return(PERIOD_H4);
            case 1440: return(PERIOD_D1);
            case 10080: return(PERIOD_W1);
            case 43200: return(PERIOD_MN1);
            case 2: return(PERIOD_M2);
            case 3: return(PERIOD_M3);
            case 4: return(PERIOD_M4);
            case 6: return(PERIOD_M6);
            case 10: return(PERIOD_M10);
            case 12: return(PERIOD_M12);
            case 16385: return(PERIOD_H1);
            case 16386: return(PERIOD_H2);
            case 16387: return(PERIOD_H3);
            case 16388: return(PERIOD_H4);
            case 16390: return(PERIOD_H6);
            case 16392: return(PERIOD_H8);
            case 16396: return(PERIOD_H12);
            case 16408: return(PERIOD_D1);
            case 32769: return(PERIOD_W1);
            case 49153: return(PERIOD_MN1);
            default: return(PERIOD_CURRENT);
        }
    }
    #endif

    static bool RefreshRates ()
    {
        #ifdef __MQL5__
        return true;
        #else
        return RefreshRates();
        #endif
    }

    static int iBars(string symbol, int tf) {
        #ifdef __MQL5__
        ENUM_TIMEFRAMES timeframe = TFMigrate (tf);
        return(Bars(symbol, timeframe));
        #else
        return iBars(symbol, tf);
        #endif
    }

    static int iBarShift (string symbol, int tf, datetime time, bool exact = false) {
        #ifdef __MQL5__
        if (time < 0)
            return -1;

        ENUM_TIMEFRAMES timeframe = TFMigrate (tf);

        datetime Arr[], time1;

        CopyTime (symbol, timeframe, 0, 1, Arr);

        time1 = Arr[0];

        if (CopyTime (symbol, timeframe, time, time1, Arr) > 0)
        {
            if (ArraySize (Arr) > 2)
                return ArraySize (Arr) - 1;

            if (time < time1)
                return 1;
            else
                return 0;
        }
        else
            return -1;
        #else
        return iBarShift(symbol, tf, time, exact);
        #endif
    }

    static double iClose(string symbol,int tf,int index) {
        #ifdef __MQL5__
        if(index < 0) return(-1);
        double Arr[];
        ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
        if(CopyClose(symbol,timeframe, index, 1, Arr)>0)
            return(Arr[0]);
        else return(-1);
        #else
        return iClose(symbol, tf, index);
        #endif
    }

    static double iHigh(string symbol,int tf,int index) {
        #ifdef __MQL5__
        if(index < 0) return(-1);
        double Arr[];
        ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
        if(CopyHigh(symbol,timeframe, index, 1, Arr)>0)
            return(Arr[0]);
        else return(-1);
        #else
        return iHigh(symbol, tf, index);
        #endif
    }

    static int iHighest(string symbol, int tf, int type, int count=WHOLE_ARRAY, int start=0) {
        #ifdef __MQL5__
        if(start<0) return(-1);
        ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
        if(count<=0) count=Bars(symbol,timeframe);
        if(type<=MODE_OPEN)
        {
            double Open[];
            ArraySetAsSeries(Open,true);
            CopyOpen(symbol,timeframe,start,count,Open);
            return(ArrayMaximum(Open,0,count)+start);
        }
        if(type==MODE_LOW)
        {
            double Low[];
            ArraySetAsSeries(Low,true);
            CopyLow(symbol,timeframe,start,count,Low);
            return(ArrayMaximum(Low,0,count)+start);
        }
        if(type==MODE_HIGH)
        {
            double High[];
            ArraySetAsSeries(High,true);
            CopyHigh(symbol,timeframe,start,count,High);
            return(ArrayMaximum(High,0,count)+start);
        }
        if(type==MODE_CLOSE)
        {
            double Close[];
            ArraySetAsSeries(Close,true);
            CopyClose(symbol,timeframe,start,count,Close);
            return(ArrayMaximum(Close,0,count)+start);
        }
        if(type==MODE_VOLUME)
        {
            long Volume[];
            ArraySetAsSeries(Volume,true);
            CopyTickVolume(symbol,timeframe,start,count,Volume);
            return(ArrayMaximum(Volume,0,count)+start);
        }
        if(type>=MODE_TIME)
        {
            datetime Time[];
            ArraySetAsSeries(Time,true);
            CopyTime(symbol,timeframe,start,count,Time);
            return(ArrayMaximum(Time,0,count)+start);
        }
        return(0);
        #else
        return iHighest(symbol, tf, type, count, start);
        #endif
    }

    static double iLow(string symbol,int tf,int index) {
        #ifdef __MQL5__
        if(index < 0) return(-1);
        double Arr[];
        ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
        if(CopyLow(symbol,timeframe, index, 1, Arr)>0)
            return(Arr[0]);
        else return(-1);
        #else
        return iLow(symbol, tf, index);
        #endif
    }

    static int iLowest(string symbol, int tf, int type, int count=WHOLE_ARRAY, int start=0) {
        #ifdef __MQL5__
        if(start<0) return(-1);
        ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
        if(count<=0) count=Bars(symbol,timeframe);
        if(type<=MODE_OPEN)
        {
            double Open[];
            ArraySetAsSeries(Open,true);
            CopyOpen(symbol,timeframe,start,count,Open);
            return(ArrayMinimum(Open,0,count)+start);
        }
        if(type==MODE_LOW)
        {
            double Low[];
            ArraySetAsSeries(Low,true);
            CopyLow(symbol,timeframe,start,count,Low);
            return(ArrayMinimum(Low,0,count)+start);
        }
        if(type==MODE_HIGH)
        {
            double High[];
            ArraySetAsSeries(High,true);
            CopyHigh(symbol,timeframe,start,count,High);
            return(ArrayMinimum(High,0,count)+start);
        }
        if(type==MODE_CLOSE)
        {
            double Close[];
            ArraySetAsSeries(Close,true);
            CopyClose(symbol,timeframe,start,count,Close);
            return(ArrayMinimum(Close,0,count)+start);
        }
        if(type==MODE_VOLUME)
        {
            long Volume[];
            ArraySetAsSeries(Volume,true);
            CopyTickVolume(symbol,timeframe,start,count,Volume);
            return(ArrayMinimum(Volume,0,count)+start);
        }
        if(type>=MODE_TIME)
        {
            datetime Time[];
            ArraySetAsSeries(Time,true);
            CopyTime(symbol,timeframe,start,count,Time);
            return(ArrayMinimum(Time,0,count)+start);
        }
        return(0);
        #else
        return iLowest(symbol, tf, type, count, start);
        #endif
    }

    static double iOpen(string symbol,int tf,int index)

    {
        #ifdef __MQL5__
        if(index < 0) return(-1);
        double Arr[];
        ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
        if(CopyOpen(symbol,timeframe, index, 1, Arr)>0)
            return(Arr[0]);
        else return(-1);
        #else
        return iOpen(symbol, tf, index);
        #endif
    }

    static datetime iTime(string symbol,int tf,int index)
    {
        #ifdef __MQL5__
        if(index < 0) return(-1);
        ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
        datetime Arr[];
        if(CopyTime(symbol, timeframe, index, 1, Arr)>0)
            return(Arr[0]);
        else return(-1);
        #else
        return iTime(symbol, tf, index);
        #endif
    }

    static long iVolume(string symbol,int tf,int index)
    {
        #ifdef __MQL5__
        if(index < 0) return(-1);
        long Arr[];
        ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
        if(CopyTickVolume(symbol, timeframe, index, 1, Arr)>0)
            return(Arr[0]);
        else return(-1);
        #else
        return iVolume(symbol, tf, index);
        #endif
    }
};
