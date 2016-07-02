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
 * Class to provide drawing methods.
 */
class Draw {
public:

    /*
     * Draw a vertical line.
     */
    static bool DrawVLine(string oname, datetime tm) {
        bool result = ObjectCreate(NULL, oname, OBJ_VLINE, 0, tm, 0);
        if (!result) PrintFormat("%(): Can't create vertical line! code #", __FUNCTION__, GetLastError());
        return (result);
    }

    /*
     * Draw a horizontal line.
     */
    static bool DrawHLine(string oname, double value) {
        bool result = ObjectCreate(NULL, oname, OBJ_HLINE, 0, 0, value);
        if (!result) PrintFormat("%(): Can't create horizontal line! code #", __FUNCTION__, GetLastError());
        return (result);
    }

    /*
     * Delete a vertical line.
     */
    static bool DeleteVertLine(string oname) {
        bool result = ObjectDelete(NULL, oname);
        if (!result) PrintFormat("%(): Can't delete vertical line! code #", __FUNCTION__, GetLastError());
        return (result);
    }

    /*
     * Draw a line given the price.
     */
    static void ShowLine(string oname, double price, int colour = Yellow) {
        ObjectCreate(ChartID(), oname, OBJ_HLINE, 0, Time[0], price, 0, 0);
        ObjectSet(oname, OBJPROP_COLOR, colour);
        ObjectMove(oname, 0, Time[0], price);
    }

    /*
     * Draw a MA indicator.
     */
    static void DrawMA(int timeframe) {
        int Counter = 1;
        int shift=iBarShift(Symbol(), timeframe, time_current);
        while(Counter < Bars) {
            string itime = TimeToStr(iTime(NULL, timeframe, Counter), TIME_DATE|TIME_SECONDS);

            // FIXME: The shift parameter (Counter, Counter-1) doesn't use the real values of MA_Fast, MA_Medium and MA_Slow including MA_Shift_Fast, etc.
            double MA_Fast_Curr = iMA(NULL, timeframe, MA_Period_Fast, 0, MA_Method, MA_Applied_Price, Counter); // Current Bar.
            double MA_Fast_Prev = iMA(NULL, timeframe, MA_Period_Fast, 0, MA_Method, MA_Applied_Price, Counter-1); // Previous Bar.
            ObjectCreate("MA_Fast" + itime, OBJ_TREND, 0, iTime(NULL,0,Counter), MA_Fast_Curr, iTime(NULL,0,Counter-1), MA_Fast_Prev);
            ObjectSet("MA_Fast" + itime, OBJPROP_RAY, False);
            ObjectSet("MA_Fast" + itime, OBJPROP_COLOR, Yellow);

            double MA_Medium_Curr = iMA(NULL, timeframe, MA_Period_Medium, 0, MA_Method, MA_Applied_Price, Counter); // Current Bar.
            double MA_Medium_Prev = iMA(NULL, timeframe, MA_Period_Medium, 0, MA_Method, MA_Applied_Price, Counter-1); // Previous Bar.
            ObjectCreate("MA_Medium" + itime, OBJ_TREND, 0, iTime(NULL,0,Counter), MA_Medium_Curr, iTime(NULL,0,Counter-1), MA_Medium_Prev);
            ObjectSet("MA_Medium" + itime, OBJPROP_RAY, False);
            ObjectSet("MA_Medium" + itime, OBJPROP_COLOR, Gold);

            double MA_Slow_Curr = iMA(NULL, timeframe, MA_Period_Slow, 0, MA_Method, MA_Applied_Price, Counter); // Current Bar.
            double MA_Slow_Prev = iMA(NULL, timeframe, MA_Period_Slow, 0, MA_Method, MA_Applied_Price, Counter-1); // Previous Bar.
            ObjectCreate("MA_Slow" + itime, OBJ_TREND, 0, iTime(NULL,0,Counter), MA_Slow_Curr, iTime(NULL,0,Counter-1), MA_Slow_Prev);
            ObjectSet("MA_Slow" + itime, OBJPROP_RAY, False);
            ObjectSet("MA_Slow" + itime, OBJPROP_COLOR, Orange);
            Counter++;
        }
    }


};
