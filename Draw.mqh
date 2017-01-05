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

/**
 * @file
 * Group of functions intended for working with graphic objects relating to any specified chart.
 */

// Includes.
#include "Market.mqh"

// Properties.
#property strict

#define WINDOW_MAIN 0

/**
 * Class to provide drawing methods working with graphic objects.
 */
class Draw {
protected:
  // Variables.
  string symbol;
  ENUM_TIMEFRAMES tf;
  long chart_id;
  // Class variables.
  Market *market;
public:

  /**
   * Class constructor.
   */
  void Draw(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, long _chart_id = 0) :
    symbol(_symbol == NULL ? _Symbol : _symbol),
    tf(_tf == 0 ? PERIOD_CURRENT : _tf),
    chart_id(_chart_id),
    market(new Market(symbol))
  {
  }

  /* Graphic object related methods */

  /**
   * Changes the value of the specified object property.
   */
  bool ObjectSet(string name, int prop_id, double prop_value) {
    #ifdef __MQL4__
    return ::ObjectSet(name, prop_id, prop_value);
    #else // __MQL5__
    switch(prop_id) {
      case OBJPROP_TIME1:
        return ObjectSetInteger(0, name, OBJPROP_TIME, (long) prop_value);
      case OBJPROP_TIME2:
        return ObjectSetInteger(0, name, OBJPROP_TIME, 1, (long) prop_value);
      case OBJPROP_TIME3:
        return ObjectSetInteger(0, name, OBJPROP_TIME, 2, (long) prop_value);
      case OBJPROP_PRICE1:
        return ObjectSetDouble(0, name, OBJPROP_PRICE, (double) prop_value);
      case OBJPROP_PRICE2:
        return ObjectSetDouble(0, name, OBJPROP_PRICE, 1, prop_value);
      case OBJPROP_PRICE3:
        return ObjectSetDouble(0, name, OBJPROP_PRICE, 2, prop_value);
      case OBJPROP_SCALE:
      case OBJPROP_ANGLE:
      case OBJPROP_DEVIATION:
        return ObjectSetDouble(0, name, prop_id, (double) prop_value);
      case OBJPROP_RAY:
        return ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, (long) prop_value);
      case OBJPROP_FIBOLEVELS:
        return ObjectSetInteger(0, name, OBJPROP_LEVELS, (long) prop_value);
      case OBJPROP_COLOR:
      case OBJPROP_STYLE:
      case OBJPROP_WIDTH:
      case OBJPROP_BACK:
      case OBJPROP_ELLIPSE:
        return ObjectSetInteger(0, name, prop_id, (long) prop_value);
      case OBJPROP_ARROWCODE:
      case OBJPROP_TIMEFRAMES:
      case OBJPROP_FONTSIZE:
      case OBJPROP_CORNER:
      case OBJPROP_XDISTANCE:
      case OBJPROP_YDISTANCE:
      case OBJPROP_LEVELCOLOR:
      case OBJPROP_LEVELSTYLE:
      case OBJPROP_LEVELWIDTH:
        return ObjectSetInteger(0, name, prop_id, (long) prop_value);
      default:
        break;
    }
    return (false);
    #endif
  }

  /**
   * Moves an object coordinate in the chart.
   */
  bool ObjectMove(string name, int point, datetime time1, double price1) {
    return ::ObjectMove(#ifdef __MQL5__ chart_id, #endif name, point, time1, price1);
  }

  /**
   * Deletes object via name.
   */
  bool ObjectDelete(string name) {
    return ::ObjectDelete(#ifdef __MQL5__chart_id, #endif name);
  }

  /**
   * Draw a vertical line.
   */
  bool DrawVLine(string oname, datetime tm) {
      bool result = ObjectCreate(NULL, oname, OBJ_VLINE, 0, tm, 0);
      if (!result) PrintFormat("%(): Can't create vertical line! code #", __FUNCTION__, GetLastError());
      return (result);
  }

  /**
   * Draw a horizontal line.
   */
  bool DrawHLine(string oname, double value) {
      bool result = ObjectCreate(NULL, oname, OBJ_HLINE, 0, 0, value);
      if (!result) PrintFormat("%(): Can't create horizontal line! code #", __FUNCTION__, GetLastError());
      return (result);
  }

  /**
   * Delete a vertical line.
   */
  bool DeleteVertLine(string oname) {
      bool result = ObjectDelete(NULL, oname);
      if (!result) PrintFormat("%(): Can't delete vertical line! code #", __FUNCTION__, GetLastError());
      return (result);
  }

  /**
   * Draw a line given the price.
   */
  void ShowLine(string oname, double price, int colour = Yellow) {
    ObjectCreate(ChartID(), oname, OBJ_HLINE, 0, Time[0], price, 0, 0);
    ObjectSet(oname, OBJPROP_COLOR, colour);
    ObjectMove(oname, 0, Time[0], price);
  }

    /**
     * Draw a MA indicator.
     */
    static void DrawMA(int _tf, double ma_fast, double ma_medium, double ma_slow) {
    /*
      int Counter = 1;
      int shift=iBarShift(Symbol(), _tf, TimeCurrent());
      while(Counter < Bars) {
        string itime = TimeToStr(iTime(NULL, _tf, Counter), TIME_DATE|TIME_SECONDS);

        // FIXME: The shift parameter (Counter, Counter-1) doesn't use the real values of MA_Fast, MA_Medium and MA_Slow including MA_Shift_Fast, etc.
        double MA_Fast_Curr = iMA(NULL, _tf, ma_fast, 0, MA_Method, MA_Applied_Price, Counter); // Current Bar.
        double MA_Fast_Prev = iMA(NULL, _tf, ma_fast, 0, MA_Method, MA_Applied_Price, Counter-1); // Previous Bar.
        ObjectCreate("MA_Fast" + itime, OBJ_TREND, 0, iTime(NULL,0,Counter), MA_Fast_Curr, iTime(NULL,0,Counter-1), MA_Fast_Prev);
        ObjectSet("MA_Fast" + itime, OBJPROP_RAY, false);
        ObjectSet("MA_Fast" + itime, OBJPROP_COLOR, Yellow);

        double MA_Medium_Curr = iMA(NULL, _tf, ma_medium, 0, MA_Method, MA_Applied_Price, Counter); // Current Bar.
        double MA_Medium_Prev = iMA(NULL, _tf, ma_medium, 0, MA_Method, MA_Applied_Price, Counter-1); // Previous Bar.
        ObjectCreate("MA_Medium" + itime, OBJ_TREND, 0, iTime(NULL,0,Counter), MA_Medium_Curr, iTime(NULL,0,Counter-1), MA_Medium_Prev);
        ObjectSet("MA_Medium" + itime, OBJPROP_RAY, false);
        ObjectSet("MA_Medium" + itime, OBJPROP_COLOR, Gold);

        double MA_Slow_Curr = iMA(NULL, _tf, ma_slow, 0, MA_Method, MA_Applied_Price, Counter); // Current Bar.
        double MA_Slow_Prev = iMA(NULL, _tf, ma_slow, 0, MA_Method, MA_Applied_Price, Counter-1); // Previous Bar.
        ObjectCreate("MA_Slow" + itime, OBJ_TREND, 0, iTime(NULL,0,Counter), MA_Slow_Curr, iTime(NULL,0,Counter-1), MA_Slow_Prev);
        ObjectSet("MA_Slow" + itime, OBJPROP_RAY, false);
        ObjectSet("MA_Slow" + itime, OBJPROP_COLOR, Orange);
        Counter++;
      }
    */
    }

  /**
   * Draw a trend line.
   */
  bool TLine(string name, double p1, double p2, datetime d1, datetime d2, color clr = clrYellow, bool ray=false) {
    if (ObjectMove(name, 0, d1, p1)) {
      ObjectMove(name, 1, d2, p2);
    }
    else if (!ObjectCreate( name, OBJ_TREND, WINDOW_MAIN, d1, p1, d2, p2)) {
      // Note: In case of error, check the message by GetLastError().
      return false;
    }
    else if (!ObjectSet(name, OBJPROP_RAY, ray)) {
      return false;
    }
    if (clr && !ObjectSet(name, OBJPROP_COLOR, clr)) {
      return false;
    }
    return true;
  }

};
