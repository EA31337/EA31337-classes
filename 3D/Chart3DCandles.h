//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
 * 3D chart candles renderer.
 */

#include "Chart3DType.h"
#include "Cube.h"
#include "Device.h"
#include "Vertex.h"

class Chart3D;

/**
 * 3D chart candles renderer.
 */
class Chart3DCandles : public Chart3DType {
  Ref<Cube<Vertex>> cube1;
  Ref<Cube<Vertex>> cube2;
  Ref<Cube<Vertex>> cube3;

 public:
  /**
   * Constructor.
   */
  Chart3DCandles(Chart3D* _chart3d, Device* _device) : Chart3DType(_chart3d, _device) {
    cube1 = new Cube<Vertex>(1.0f, 1.0f, 1.0f);
    cube2 = new Cube<Vertex>(0.10f, 1.0f, 0.10f);
    cube3 = new Cube<Vertex>(1.0f, 0.075f, 0.075f);
  }

  /**
   * Renders chart.
   */
  virtual void Render(Device* _device) {
    TSR _tsr;

    for (int _shift = chart3d.GetBarsVisibleShiftStart(); _shift != chart3d.GetBarsVisibleShiftEnd(); --_shift) {
      BarOHLC _ohlc = chart3d.GetPrice(PERIOD_CURRENT, _shift);

      float _height = chart3d.GetPriceScale(_ohlc.GetMaxOC()) - chart3d.GetPriceScale(_ohlc.GetMinOC());
      float higher = _ohlc.IsBear();

      cube1.Ptr().GetTSR().translation.x = chart3d.GetBarPositionX(_shift);
      cube1.Ptr().GetTSR().translation.y = chart3d.GetPriceScale(_ohlc.GetMinOC()) + _height / 2;
      cube1.Ptr().GetTSR().scale.y = _height;

      // Print(cube1.Ptr().GetTSR().translation.y);

      cube1.Ptr().GetMaterial().SetColor(higher ? 0x22FF11 : 0xFF1122);
      _device.Render(cube1.Ptr());

      cube2.Ptr().GetTSR().translation.x = chart3d.GetBarPositionX(_shift);
      float _line_height = chart3d.GetPriceScale(_ohlc.GetHigh()) - chart3d.GetPriceScale(_ohlc.GetLow());
      cube2.Ptr().GetTSR().translation.y = chart3d.GetPriceScale(_ohlc.GetLow()) + _line_height / 2;
      cube2.Ptr().GetTSR().scale.y = _line_height;
      cube2.Ptr().GetMaterial().SetColor(higher ? 0x22FF11 : 0xFF1122);
      _device.Render(cube2.Ptr());
    }

    int _digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
    float _pip_pow = (float)MathPow(10, _digits);
    float _pip_size = 1.0f / (float)MathPow(10, _digits);
    float _pip_size_m1 = 1.0f / (float)MathPow(10, _digits - 1);
    float _start = float(int(chart3d.GetMinBarsPrice() * _pip_pow) * _pip_size);
    float _end = float(int(chart3d.GetMaxBarsPrice() * _pip_pow) * _pip_size);

    // Rendering price lines.
    for (double _s = _start; _s < _end + _pip_size_m1; _s += _pip_size * 10) {
      float _y = chart3d.GetPriceScale((float)_s);

      cube3.Ptr().GetTSR().translation.y = _y;
      cube3.Ptr().GetTSR().scale.x = 200.0f;

      _device.DrawText(5, _y, StringFormat("%." + IntegerToString(_digits) + "f", _s), 0x90FFFFFF, TA_LEFT | TA_VCENTER,
                       GFX_DRAW_TEXT_FLAG_2D_COORD_X);

      cube3.Ptr().GetMaterial().SetColor(0x333333);
      _device.Render(cube3.Ptr());
    }
  }
};
