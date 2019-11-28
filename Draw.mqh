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
 * Group of functions intended for working with graphic objects relating to any specified chart.
 */

// Class dependencies.
class Chart;
class Draw;

// Includes.
#include "Chart.mqh"

#define WINDOW_MAIN 0

#ifdef __MQL5__
#define OBJPROP_TIME1        0
#define OBJPROP_PRICE1       1
#define OBJPROP_TIME2        2
#define OBJPROP_PRICE2       3
#define OBJPROP_TIME3        4
#define OBJPROP_PRICE3       5
#define OBJPROP_COLOR        6
#define OBJPROP_STYLE        7
#define OBJPROP_WIDTH        8
#define OBJPROP_BACK         9
#define OBJPROP_FIBOLEVELS 200
#endif

/**
 * Class to provide drawing methods working with graphic objects.
 */
class Draw : public Chart {
  protected:
    // Variables.
    long chart_id;
    // Class variables.

  public:

    /**
     * Class constructor.
     */
    void Draw(long _chart_id = 0)
      : chart_id(_chart_id != 0 ? _chart_id : ChartID())
      {
      }

  /* Graphic object related methods */

  /**
   * Changes the value of the specified object property.
   *
   * @see:
   * - https://docs.mql4.com/objects/objectset
   * - https://docs.mql4.com/constants/objectconstants/enum_object_property
   */
  bool ObjectSet(string name, int prop_id, double prop_value) {
    #ifdef __MQL4__
    return ::ObjectSet(name, prop_id, prop_value);
    #else // __MQL5__
    switch(prop_id) {
      // Datetime value to set/get first coordinate time part.
      case OBJPROP_TIME1:  return ObjectSetInteger(chart_id, name, OBJPROP_TIME, (long) prop_value);
      // Datetime value to set/get second coordinate time part.
      case OBJPROP_TIME2:  return ObjectSetInteger(chart_id, name, OBJPROP_TIME, 1, (long) prop_value);
      // Datetime value to set/get third coordinate time part.
      case OBJPROP_TIME3:  return ObjectSetInteger(chart_id, name, OBJPROP_TIME, 2, (long) prop_value);
      // Double value to set/get first coordinate price part.
      case OBJPROP_PRICE1: return ObjectSetDouble(chart_id, name, OBJPROP_PRICE, (double) prop_value);
      // Double value to set/get second coordinate price part.
      case OBJPROP_PRICE2: return ObjectSetDouble(chart_id, name, OBJPROP_PRICE, 1, prop_value);
      // Double value to set/get third coordinate price part.
      case OBJPROP_PRICE3: return ObjectSetDouble(chart_id, name, OBJPROP_PRICE, 2, prop_value);
      case OBJPROP_SCALE:     // Double value to set/get scale object property.
      case OBJPROP_ANGLE:     // Double value to set/get angle object property in degrees.
      case OBJPROP_DEVIATION: // Double value to set/get deviation property for Standard deviation objects.
        return ObjectSetDouble(chart_id, name, (ENUM_OBJECT_PROPERTY_DOUBLE) prop_id, (double) prop_value);
      case OBJPROP_RAY:
        // Boolean value to set/get ray flag of object.
        return ObjectSetInteger(chart_id, name, OBJPROP_RAY_RIGHT, (long) prop_value);
      case OBJPROP_FIBOLEVELS:
        // Integer value to set/get Fibonacci object level count. Can be from 0 to 32.
        return ObjectSetInteger(chart_id, name, OBJPROP_LEVELS, (long) prop_value);
      case OBJPROP_COLOR:   // Color value to set/get object color.
      case OBJPROP_STYLE:   // Value is one of the constants to set/get object line style.
      case OBJPROP_WIDTH:   // Integer value to set/get object line width. Can be from 1 to 5.
      case OBJPROP_BACK:    // Boolean value to set/get background drawing flag for object.
      case OBJPROP_ELLIPSE: // Boolean value to set/get ellipse flag for fibo arcs.
        return ObjectSetInteger(chart_id, name, (ENUM_OBJECT_PROPERTY_INTEGER) prop_id, (long) prop_value);
      case OBJPROP_ARROWCODE:  // Arrow code for the Arrow object (char).
      case OBJPROP_TIMEFRAMES: // Visibility of an object at timeframes (flags).
      case OBJPROP_FONTSIZE:   // Font size (int).
      case OBJPROP_CORNER:     // The corner of the chart to link a graphical object.
      case OBJPROP_XDISTANCE:  // The distance in pixels along the X axis from the binding corner (int).
      case OBJPROP_YDISTANCE:  // The distance in pixels along the Y axis from the binding corner (int).
      case OBJPROP_LEVELCOLOR: // Color of the line-level (color).
      case OBJPROP_LEVELSTYLE: // Style of the line-level (ENUM_LINE_STYLE).
      case OBJPROP_LEVELWIDTH: // Thickness of the line-level (int).
        return ObjectSetInteger(chart_id, name, (ENUM_OBJECT_PROPERTY_INTEGER) prop_id, (long) prop_value);
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
    return ::ObjectDelete(#ifdef __MQL5__ chart_id, #endif name);
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
    ObjectCreate(chart_id, oname, OBJ_HLINE, 0, GetBarTime(), price, 0, 0);
    ObjectSet(oname, OBJPROP_COLOR, colour);
    ObjectMove(oname, 0, GetBarTime(), price);
  }


    /**
     * Draw a MA indicator.
     */
    static void DrawMA(int _tf, double _ma_fast, double _ma_medium, double _ma_slow) {
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
   * Draw MA on chart.
   */
  /*
  bool DrawMA(int _ma_fast, int _ma_medium, int _ma_slow, ENUM_MA_METHOD _method, ENUM_APPLIED_PRICE _applied) {
    int Counter = 1;
    int shift = market.iBarShift(symbol, tf, TimeCurrent());
    while (Counter < Bars) {
      string itime = TimeToStr(market.iTime(NULL, tf, Counter));

      // FIXME: The shift parameter (Counter, Counter-1) doesn't use the real values of MA_Fast, MA_Medium and MA_Slow including MA_Shift_Fast, etc.
      double MA_Fast_Curr = iMA(symbol, tf, _ma_fast, 0, _method, _applied, Counter); // Current Bar.
      double MA_Fast_Prev = iMA(symbol, tf, _ma_fast, 0, _method, _applied, Counter-1); // Previous Bar.
      ObjectCreate("MA_Fast" + itime, OBJ_TREND, 0, iTime(symbol,0,Counter), MA_Fast_Curr, market.iTime(symbol,0,Counter-1), MA_Fast_Prev);
      ObjectSet("MA_Fast" + itime, OBJPROP_RAY, false);
      ObjectSet("MA_Fast" + itime, OBJPROP_COLOR, Yellow);

      double MA_Medium_Curr = iMA(symbol, tf, _ma_medium, 0, _method, _applied, Counter); // Current Bar.
      double MA_Medium_Prev = iMA(symbol, tf, _ma_medium, 0, _method, _applied, Counter-1); // Previous Bar.
      ObjectCreate("MA_Medium" + itime, OBJ_TREND, 0, iTime(symbol,0,Counter), MA_Medium_Curr, market.iTime(symbol,0,Counter-1), MA_Medium_Prev);
      ObjectSet("MA_Medium" + itime, OBJPROP_RAY, false);
      ObjectSet("MA_Medium" + itime, OBJPROP_COLOR, Gold);

      double MA_Slow_Curr = iMA(symbol, tf, _ma_slow, 0, _method, _applied, Counter); // Current Bar.
      double MA_Slow_Prev = iMA(symbol, tf, _ma_slow, 0, _method, _applied, Counter-1); // Previous Bar.
      ObjectCreate("MA_Slow" + itime, OBJ_TREND, 0, iTime(symbol,0,Counter), MA_Slow_Curr, market.iTime(symbol,0,Counter-1), MA_Slow_Prev);
      ObjectSet("MA_Slow" + itime, OBJPROP_RAY, false);
      ObjectSet("MA_Slow" + itime, OBJPROP_COLOR, Orange);
      Counter++;
    }
    return true;
  }
  */


  /**
   * Draw a trend line.
   */
  bool TLine(string name, double p1, double p2, datetime d1, datetime d2, color clr = clrYellow, bool ray=false) {
    if (ObjectMove(name, 0, d1, p1)) {
      ObjectMove(name, 1, d2, p2);
    }
    else if (!ObjectCreate(#ifdef __MQL5__ chart_id, #endif name, OBJ_TREND, WINDOW_MAIN, d1, p1, d2, p2)) {
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
