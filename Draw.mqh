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
 * Group of functions intended for working with graphic objects relating to any specified chart.
 */

// Class dependencies.
class Chart;
class Draw;

// Includes.
#include "Chart.mqh"
#include "Data.define.h"

#ifndef __MQL4__
// Defines macros (for MQL4 backward compatibility).
#define SetIndexArrow(_index, _value) (PlotIndexSetInteger(_index, PLOT_ARROW, _value))
#define SetIndexDrawBegin(_index, _value) (PlotIndexSetInteger(_index, PLOT_DRAW_BEGIN, _value))
#define SetIndexEmptyValue(_index, _value) (PlotIndexSetDouble(_index, PLOT_EMPTY_VALUE, _value))
#define SetIndexShift(_index, _value) (PlotIndexSetInteger(_index, PLOT_SHIFT, _value))
#endif

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compatibility).
bool ObjectCreate(string _name, ENUM_OBJECT _otype, int _swindow, datetime _t1, double _p1) {
  return Draw::ObjectCreate(0, _name, _otype, _swindow, _t1, _p1);
}
bool ObjectDelete(string _name) { return Draw::ObjectDelete(_name); }
bool ObjectSet(string _name, int _prop_id, double _value) { return Draw::ObjectSet(_name, _prop_id, _value); }
int ObjectsTotal(int _type = EMPTY) { return Draw::ObjectsTotal(); }
string ObjectName(int _index) { return Draw::ObjectName(_index); }
void SetIndexLabel(int _index, string _text) { Draw::SetIndexLabel(_index, _text); }
void SetIndexStyle(int _index, int _type, int _style = EMPTY, int _width = EMPTY, color _clr = CLR_NONE) {
  Draw::SetIndexStyle(_index, _type, _style, _width, _clr);
}
#endif

#define WINDOW_MAIN 0

#ifdef __MQL5__
#define OBJPROP_TIME1 ((ENUM_OBJECT_PROPERTY_INTEGER)0)
#define OBJPROP_PRICE1 1
#define OBJPROP_TIME2 2
#define OBJPROP_PRICE2 3
#define OBJPROP_TIME3 4
#define OBJPROP_PRICE3 5
#define OBJPROP_COLOR ((ENUM_OBJECT_PROPERTY_INTEGER)6)
#define OBJPROP_STYLE 7
#define OBJPROP_WIDTH 8
#define OBJPROP_BACK ((ENUM_OBJECT_PROPERTY_INTEGER)9)
#define OBJPROP_FIBOLEVELS 200
#endif

/**
 * Class to provide drawing methods working with graphic objects.
 */
class Draw : public Object {
 protected:
  // Variables.
  long chart_id;
  // Class variables.

 public:
  /**
   * Class constructor.
   */
  Draw(long _chart_id = 0) : chart_id(_chart_id != 0 ? _chart_id : ChartID()) {}

  /* Graphic object related methods */

  /* Getters */

  /**
   * Returns the name of the corresponding object.
   *
   * @return
   * Name of the object is returned in case of success.
   */
  static string ObjectName(long _chart_id, int _pos, int _sub_window = -1, int _type = -1) {
    return ::ObjectName(_chart_id, _pos, _sub_window, _type);
  }
  static string ObjectName(int _index) { return Draw::ObjectName(0, _index); }

  /**
   * Returns the number of objects in the specified chart,
   * specified subwindow, of the specified type.
   *
   * @return
   * The number of objects.
   */
  static int ObjectsTotal(long chart_id, int type = EMPTY, int window = -1) {
#ifdef __MQL4__
    return ::ObjectsTotal(chart_id, window, type);
#else
    return ::ObjectsTotal(chart_id, window, type);
#endif
  }
  static int ObjectsTotal() { return Draw::ObjectsTotal(0); }

  /* Setters */

  /**
   * Sets drawing line description for showing in the DataWindow and in the tooltip.
   *
   * @return
   * If successful, returns true, otherwise false.
   */
  static bool SetIndexLabel(int index, string text) {
#ifdef __MQL4__
    // https://docs.mql4.com/customind/setindexlabel
    ::SetIndexLabel(index, text);
    return true;
#else
    // https://www.mql5.com/en/docs/customind/plotindexsetstring
    return PlotIndexSetString(index, PLOT_LABEL, text);
#endif
  }

  /**
   * Sets the new type, style, width and color for a given indicator line.
   *
   */
  static void SetIndexStyle(int index, int type, int style = EMPTY, int width = EMPTY, color clr = CLR_NONE) {
#ifdef __MQL4__
    // https://docs.mql4.com/customind/setindexstyle
    ::SetIndexStyle(index, type, style, width, clr);
#else
    if (width != EMPTY) {
      PlotIndexSetInteger(index, PLOT_LINE_WIDTH, width);
    }
    if (clr != CLR_NONE) {
      PlotIndexSetInteger(index, PLOT_LINE_COLOR, clr);
    }
    PlotIndexSetInteger(index, PLOT_DRAW_TYPE, type);
    PlotIndexSetInteger(index, PLOT_LINE_STYLE, style);
#endif
  }

  /**
   * Changes the value of the specified object property.
   *
   * @see:
   * - https://docs.mql4.com/objects/objectset
   * - https://docs.mql4.com/constants/objectconstants/enum_object_property
   */
  static bool ObjectSet(string name, int prop_id, double prop_value, long chart_id = 0) {
#ifdef __MQL4__
    return ::ObjectSet(name, prop_id, prop_value);
#else  // __MQL5__
    switch (prop_id) {
      // Datetime value to set/get first coordinate time part.
      case OBJPROP_TIME1:
        return ObjectSetInteger(chart_id, name, OBJPROP_TIME, (long)prop_value);
      // Datetime value to set/get second coordinate time part.
      case OBJPROP_TIME2:
        return ObjectSetInteger(chart_id, name, OBJPROP_TIME, 1, (long)prop_value);
      // Datetime value to set/get third coordinate time part.
      case OBJPROP_TIME3:
        return ObjectSetInteger(chart_id, name, OBJPROP_TIME, 2, (long)prop_value);
      // Double value to set/get first coordinate price part.
      case OBJPROP_PRICE1:
        return ObjectSetDouble(chart_id, name, OBJPROP_PRICE, (double)prop_value);
      // Double value to set/get second coordinate price part.
      case OBJPROP_PRICE2:
        return ObjectSetDouble(chart_id, name, OBJPROP_PRICE, 1, prop_value);
      // Double value to set/get third coordinate price part.
      case OBJPROP_PRICE3:
        return ObjectSetDouble(chart_id, name, OBJPROP_PRICE, 2, prop_value);
      case OBJPROP_ANGLE:      // Double value to set/get angle object property in degrees.
      case OBJPROP_DEVIATION:  // Double value to set/get deviation property for Standard deviation objects.
      case OBJPROP_SCALE:      // Double value to set/get scale object property.
        return ObjectSetDouble(chart_id, name, (ENUM_OBJECT_PROPERTY_DOUBLE)prop_id, (double)prop_value);
      case OBJPROP_RAY:
        // Boolean value to set/get ray flag of object.
        return ObjectSetInteger(chart_id, name, OBJPROP_RAY_RIGHT, (long)prop_value);
      case OBJPROP_FIBOLEVELS:
        // Integer value to set/get Fibonacci object level count. Can be from 0 to 32.
        return ObjectSetInteger(chart_id, name, OBJPROP_LEVELS, (long)prop_value);
      case OBJPROP_ARROWCODE:   // Arrow code for the Arrow object (char).
      case OBJPROP_BACK:        // Boolean value to set/get background drawing flag for object.
      case OBJPROP_COLOR:       // Color value to set/get object color.
      case OBJPROP_CORNER:      // The corner of the chart to link a graphical object.
      case OBJPROP_ELLIPSE:     // Boolean value to set/get ellipse flag for fibo arcs.
      case OBJPROP_FONTSIZE:    // Font size (int).
      case OBJPROP_LEVELCOLOR:  // Color of the line-level (color).
      case OBJPROP_LEVELSTYLE:  // Style of the line-level (ENUM_LINE_STYLE).
      case OBJPROP_LEVELWIDTH:  // Thickness of the line-level (int).
      case OBJPROP_STYLE:       // Value is one of the constants to set/get object line style.
      case OBJPROP_TIMEFRAMES:  // Visibility of an object at timeframes (flags).
      case OBJPROP_WIDTH:       // Integer value to set/get object line width. Can be from 1 to 5.
      case OBJPROP_XDISTANCE:   // The distance in pixels along the X axis from the binding corner (int).
      case OBJPROP_YDISTANCE:   // The distance in pixels along the Y axis from the binding corner (int).
        return ObjectSetInteger(chart_id, name, (ENUM_OBJECT_PROPERTY_INTEGER)prop_id, (long)prop_value);
      default:
        break;
    }
    return (false);
#endif
  }

  /* Object methods */

  /**
   * Creates an object with the specified name, type, and the initial coordinates.
   */
  static bool ObjectCreate(long _cid, string _name, ENUM_OBJECT _otype, int _swindow, datetime _t1, double _p1) {
#ifdef __MQL4__
    // https://docs.mql4.com/objects/objectcreate
    return ::ObjectCreate(_name, _otype, _swindow, _t1, _p1);
#else
    // https://www.mql5.com/en/docs/objects/objectcreate
    return ::ObjectCreate(_cid, _name, _otype, _swindow, _t1, _p1);
#endif
  }
  static bool ObjectCreate(long _cid, string _name, ENUM_OBJECT _otype, int _swindow, datetime _t1, double _p1,
                           datetime _t2, double _p2) {
#ifdef __MQL4__
    // https://docs.mql4.com/objects/objectcreate
    return ::ObjectCreate(_name, _otype, _swindow, _t1, _p1, _t2, _p2);
#else
    // https://www.mql5.com/en/docs/objects/objectcreate
    return ::ObjectCreate(_cid, _name, _otype, _swindow, _t1, _p1, _t2, _p2);
#endif
  }

  /**
   * Moves an object coordinate in the chart.
   */
  bool ObjectMove(string name, int point, datetime time1, double price1) {
#ifdef __MQL4__
    return ::ObjectMove(name, point, time1, price1);
#else
    return ::ObjectMove(chart_id, name, point, time1, price1);
#endif
  }

  /**
   * Deletes object via name.
   */
  static bool ObjectDelete(long chart_id, string name) {
#ifdef __MQL4__
    // https://docs.mql4.com/objects/objectdelete
    return ::ObjectDelete(name);
#else
    // https://www.mql5.com/en/docs/objects/objectdelete
    return ::ObjectDelete(chart_id, name);
#endif
  }
  static bool ObjectDelete(string name) { return Draw::ObjectDelete(0, name); }

  /**
   * Draw a vertical line.
   */
  bool DrawVLine(string oname, datetime tm) {
    bool result = Draw::ObjectCreate(NULL, oname, OBJ_VLINE, 0, tm, 0);
    if (!result) PrintFormat("%(): Can't create vertical line! code #", __FUNCTION__, GetLastError());
    return (result);
  }

  /**
   * Draw a horizontal line.
   */
  bool DrawHLine(string oname, double value) {
    bool result = Draw::ObjectCreate(NULL, oname, OBJ_HLINE, 0, 0, value);
    if (!result) PrintFormat("%(): Can't create horizontal line! code #", __FUNCTION__, GetLastError());
    return (result);
  }

  /**
   * Delete a vertical line.
   */
  bool DeleteVertLine(string oname) {
    bool result = Draw::ObjectDelete(NULL, oname);
    if (!result) PrintFormat("%(): Can't delete vertical line! code #", __FUNCTION__, GetLastError());
    return (result);
  }

  /**
   * Draw a line given the price.
   */
  void ShowLine(string oname, double price, int colour = Yellow) {
    /** @TODO
    Draw::ObjectCreate(chart_id, oname, OBJ_HLINE, 0, GetBarTime(), price);
    Draw::ObjectSet(oname, OBJPROP_COLOR, colour);
    Draw::ObjectMove(oname, 0, GetBarTime(), price);
    */
  }

  /**
   * Draw a trend line.
   */
  bool TLine(string name, double p1, double p2, datetime d1, datetime d2, color clr = clrYellow, bool ray = false,
             int window = WINDOW_MAIN) {
    if (ObjectFind(chart_id, name) >= 0 && Draw::ObjectMove(name, 0, d1, p1)) {
      Draw::ObjectMove(name, 1, d2, p2);
    } else if (!Draw::ObjectCreate(chart_id, name, OBJ_TREND, window, d1, p1, d2, p2)) {
      // Note: In case of error, check the message by GetLastError().
      if (GetLastError() == 4206) {
        // No specified subwindow.
        ResetLastError();
      }
      return false;
    }

    if (!Draw::ObjectSet(name, OBJPROP_RAY, ray)) {
      return false;
    }

    if (clr && !Draw::ObjectSet(name, OBJPROP_COLOR, clr)) {
      return false;
    }

    ResetLastError();
    return true;
  }
};
