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
 * 3D Chart.
 */

#include "../Bar.struct.h"
#include "../Refs.mqh"
#include "../SerializerConverter.mqh"
#include "../SerializerJson.mqh"
#include "Chart3DCandles.h"
#include "Chart3DType.h"
#include "Cube.h"
#include "Device.h"

// Resources.
#resource "Shaders/chart3d_vs.hlsl" as string Chart3DShaderSourceVS;
#resource "Shaders/chart3d_ps.hlsl" as string Chart3DShaderSourcePS;

typedef BarOHLC (*Chart3DPriceFetcher)(ENUM_TIMEFRAMES, int);

// Type of the currently rendered 3d chart.
enum ENUM_CHART3D_TYPE {
  CHART3D_TYPE_BARS,
  CHART3D_TYPE_CANDLES,
  CHART3D_TYPE_LINES,
};

/**
 * 3D chart renderer.
 */
class Chart3D : public Dynamic {
  // Camera offset. Z component indicates number of bars per screen's width.
  DXVector3 offset;

  // Current chart type.
  ENUM_CHART3D_TYPE type;

  // References to chart type renderers.
  Ref<Chart3DType> renderers[3];

  // OHLC prices fetcher callback.
  Chart3DPriceFetcher price_fetcher;

  // Whether graphics were initialized.
  bool initialized;

  // Shaders.
  Ref<Shader> shader_vs;
  Ref<Shader> shader_ps;

 public:
  /**
   * Constructor.
   */
  Chart3D(Chart3DPriceFetcher _price_fetcher, ENUM_CHART3D_TYPE _type = CHART3D_TYPE_CANDLES) {
    price_fetcher = _price_fetcher;
    type = _type;
    offset.x = offset.y = 0.0f;
    offset.z = 25.0f;
    initialized = false;
  }

  Shader* GetShaderVS() { return shader_vs.Ptr(); }

  Shader* GetShaderPS() { return shader_ps.Ptr(); }

  Chart3DType* GetRenderer(Device* _device) {
    if (!initialized) {
      // shader_vs = _device.VertexShader(Chart3DShaderSourceVS, Vertex::Layout);
      // shader_ps = _device.PixelShader(Chart3DShaderSourcePS);
      initialized = true;
    }

    if (!renderers[type].IsSet()) {
      switch (type) {
        case CHART3D_TYPE_BARS:
          // renderers[type] = new Chart3DBars(_device);
          break;
        case CHART3D_TYPE_CANDLES:
          renderers[type] = new Chart3DCandles(&this, _device);
          break;
        case CHART3D_TYPE_LINES:
          // renderers[type] = new Chart3DLines(_device);
          break;
        default:
          Alert("Internal error: Wrong type for Chart3D in Chart3D::GetRenderer()!");
          DebugBreak();
          return NULL;
      }
    }

    return renderers[type].Ptr();
  }

  BarOHLC GetPrice(ENUM_TIMEFRAMES _tf, int _shift) { return price_fetcher(_tf, _shift); }

  int GetBarsVisibleShiftStart() { return 20; }

  int GetBarsVisibleShiftEnd() { return 0; }

  int GetBarsVisibleCount() { return GetBarsVisibleShiftStart() - GetBarsVisibleShiftEnd() + 1; }

  float GetBarPositionX(int _shift) { return -(float)GetBarsVisibleCount() * 1.1f / 2.0f + 1.1f * _shift; }

  float GetPriceScale(float price) {
    float _scale_y = 1.0f;
    float _price_min = 1.194f;
    float _price_max = 1.20f;
    // Print(price);
    return _scale_y / (_price_max - _price_min) * (price - _price_min);
  }

  /**
   * Renders chart.
   */
  void Render(Device* _device) {
    Chart3DType* _type_renderer = GetRenderer(_device);

    BarOHLC _ohlc = price_fetcher(PERIOD_CURRENT, 0);

#ifdef __debug__
    Print(SerializerConverter::FromObject(_ohlc).ToString<SerializerJson>());
#endif

    _type_renderer.Render(_device);
  }
};