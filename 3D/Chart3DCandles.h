//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
#include "Device.h"
#include "Vertex.h"

class Chart;

/**
 * 3D chart candles renderer.
 */
class Chart3DCandles : public Chart3DType {
  Ref<Cube<Vertex>> cube;

 public:
  /**
   * Constructor.
   */
  Chart3DCandles(Chart3D* _chart3d, Device* _device) : Chart3DType(_chart3d, _device) {
    cube = new Cube<Vertex>(100.0f, 100.0f, 100.0f);
  }

  /**
   * Renders chart.
   */
  virtual void Render(Device* _device) { _device.Render(cube.Ptr()); }
};