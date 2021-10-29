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

// Ignore processing of this file if already included.
#ifndef DRAW_INDICATOR_MQH
#define DRAW_INDICATOR_MQH

// Includes.
#include "DictObject.mqh"
#include "Draw.mqh"
#include "Indicator.mqh"
#include "Object.mqh"

// Forward declaration.
class IndicatorBase;

class DrawPoint {
 public:
  datetime time;
  double value;
  // Operator overloading methods.
  void operator=(const DrawPoint& r) {
    time = r.time;
    value = r.value;
  }
  // Special methods.
  DrawPoint(const DrawPoint& r) : time(r.time), value(r.value) {}
  DrawPoint(datetime _time = NULL, double _value = 0) : time(_time), value(_value) {}
};

class DrawIndicator {
 protected:
  color color_line;
  Draw* draw;
  IndicatorBase* indi;

 public:
  // Object variables.
  DictObject<string, DrawPoint> last_points;

  /* Special methods */

  /**
   * Class constructor.
   */
  DrawIndicator(IndicatorBase* _indi) : indi(_indi) {
    // color_line = Object::IsValid(_indi) ? _indi.GetParams().indi_color : clrRed; // @fixme
    draw = new Draw();
  }

  /**
   * Class deconstructor.
   */
  ~DrawIndicator() {
    if (draw != NULL) {
      delete draw;
    }
    /* @fixme
    for (DictObjectIterator<string, DrawPoint> iter = indis.Begin(); iter.IsValid(); ++iter) {
     delete iter.Value();
    }
    */
  }

  /* Setters */

  /* Class methods */

  /**
   * Sets color of line.
   */
  void SetColorLine(color _clr) { color_line = _clr; }

  /**
   * Draw line from the last point.
   */
  void DrawLineTo(string _name, datetime _time, double _value, int _window = WINDOW_MAIN) {
    if (!last_points.KeyExists(_name)) {
      last_points.Set(_name, DrawPoint(_time, _value));
    } else {
      DrawPoint* last_point = last_points.GetByKey(_name);

      draw.TLine(_name + "_" + IntegerToString(_time), last_point.value, _value, last_point.time, _time, color_line,
                 false, _window);

      last_point.time = _time;
      last_point.value = _value;
    }
  }
};
#endif  // DRAW_INDICATOR_MQH
