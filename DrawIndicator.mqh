//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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

// Forward declaration.
class Indicator;

class DrawPoint {
 public:
  datetime time;
  double value;

  DrawPoint(const DrawPoint& r) : time(r.time), value(r.value) {}
  DrawPoint(datetime _time = NULL, double _value = 0) : time(_time), value(_value) {}
};

class DrawIndicator {
 protected:
  DictObject<string, DrawPoint> last_points;
  Draw* draw;
  Indicator* indi;

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  DrawIndicator(Indicator* _indi) : indi(_indi) { draw = new Draw(); }

  /**
   * Class deconstructor.
   */
  ~DrawIndicator() {
    if (draw != NULL) {
      delete draw;
    }
    /* @fixme?
    for (DictIterator<string, DrawPoint> iter = indis.Begin(); iter.IsValid(); ++iter) {
     delete iter.Value();
    }
    */
  }

  /* Class methods */

  /**
   * Draw line from the last point.
   */
  void DrawLineTo(string name, datetime time, double value) {
    if (!last_points.KeyExists(name)) {
      last_points.Set(name, DrawPoint(time, value));
    } else {
      DrawPoint* last_point = last_points.GetByKey(name);

      draw.TLine(name + "_" + IntegerToString(time), last_point.value, value, last_point.time, time, clrMagenta, false);

      last_point.time = time;
      last_point.value = value;
    }
  }
};
#endif  // DRAW_INDICATOR_MQH