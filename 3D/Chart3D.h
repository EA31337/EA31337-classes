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
#include "../Indicator/IndicatorData.h"
#include "../Indicators/Indi_MA.mqh"
#include "../Instances.h"
#include "../Refs.mqh"
#include "../SerializerConverter.mqh"
#include "../SerializerJson.mqh"
#include "Chart3DCandles.h"
#include "Chart3DType.h"
#include "Cube.h"
#include "Device.h"
#include "Interface.h"

#ifdef __MQL5__
// Resource variables.
#resource "Shaders/chart3d_vs.hlsl" as string Chart3DShaderSourceVS;
#resource "Shaders/chart3d_ps.hlsl" as string Chart3DShaderSourcePS;
#endif

typedef BarOHLC (*Chart3DPriceFetcher)(ENUM_TIMEFRAMES, int);

// Type of the currently rendered 3d chart.
enum ENUM_CHART3D_TYPE {
  CHART3D_TYPE_BARS,
  CHART3D_TYPE_CANDLES,
  CHART3D_TYPE_LINES,
};

class Chart3D;

void chart3d_interface_listener(InterfaceEvent& _event, void* _target) {
  Chart3D* chart3d = (Chart3D*)_target;
  chart3d.OnInterfaceEvent(_event);
}

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

  // Whether graphics were initialized.
  bool initialized;

  // Shaders.
  Ref<Shader> shader_vs;
  Ref<Shader> shader_ps;

  Chart3DType* current_renderer;

  Instances<Chart3D> instances;
  Ref<IndicatorData> source;

 public:
  /**
   * Constructor.
   */
  Chart3D(IndicatorData* _source, ENUM_CHART3D_TYPE _type = CHART3D_TYPE_CANDLES) : instances(&this) {
    type = _type;
    offset.x = offset.y = 0.0f;
    offset.z = 25.0f;
    initialized = false;
    source = _source;
#ifdef __MQL5__
    Interface::AddListener(chart3d_interface_listener, &this);
#endif
  }

  void OnInterfaceEvent(InterfaceEvent& _event) {
    if (GetCurrentRenderer() == NULL) {
      return;
    }

    Device* _gfx = GetCurrentRenderer().GetDevice();

    _gfx.DrawText(10, 10, "Event!");
  }

  Shader* GetShaderVS() { return shader_vs.Ptr(); }

  Shader* GetShaderPS() { return shader_ps.Ptr(); }

  Chart3DType* GetCurrentRenderer() { return current_renderer; }

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

    current_renderer = renderers[type].Ptr();

    return renderers[type].Ptr();
  }

  /**
   * Returns given bar's OHLC.
   */
  BarOHLC GetPrice(ENUM_TIMEFRAMES _tf, int _shift) {
    BarOHLC _ohlc;
    return _ohlc;
    // return price_fetcher(_tf, _shift); // @fixme: 'price_fetcher' - internal error #%d
  }

  /**
   * Return first shift that are visible on the screen. Values is away from 0.
   */
  int GetBarsVisibleShiftStart() { return 80; }

  /**
   * Return last shift that are visible on the screen. Value is closer to 0.
   */
  int GetBarsVisibleShiftEnd() { return 0; }

  /**
   * Returns lowest price of bars on the screen.
   */
  float GetMinBarsPrice() {
    return (float)ChartStatic::iLow(
        Symbol(), PERIOD_CURRENT,
        source REF_DEREF GetLowest(MODE_LOW, GetBarsVisibleShiftStart() - GetBarsVisibleShiftEnd(),
                                   GetBarsVisibleShiftEnd()));
  }

  /**
   * Returns highest price of bars on the screen.
   */
  float GetMaxBarsPrice() {
    return (float)ChartStatic::iHigh(
        Symbol(), PERIOD_CURRENT,
        source REF_DEREF GetHighest(MODE_HIGH, GetBarsVisibleShiftStart() - GetBarsVisibleShiftEnd(),
                                    GetBarsVisibleShiftEnd()));
  }

  /**
   * Returns number of bars that are visible on te screen.
   */
  int GetBarsVisibleCount() { return GetBarsVisibleShiftStart() - GetBarsVisibleShiftEnd() + 1; }

  /**
   * Returns absolute x coordinate of bar on the screen. Must not be affected by camera's x offset.
   */
  float GetBarPositionX(int _shift) { return -(float)GetBarsVisibleCount() * 1.35f / 2.0f + 1.35f * _shift; }

  /**
   * Returns y coordinate of price on the screen. Takes into consideration zoom and min/max prices on the screen.
   */
  float GetPriceScale(float price) {
    float _scale_y = 40.0f;
    float _price_min = GetMinBarsPrice();
    float _price_max = GetMaxBarsPrice();
    float _result = 1.0f / (_price_max - _price_min) * (price - _price_min) * _scale_y - (_scale_y / 2);
    return _result;
  }

  /**
   * Renders chart.
   */
  void Render(Device* _device) {
    Chart3DType* _type_renderer = GetRenderer(_device);

    BarOHLC _ohlc;
    // BarOHLC _ohlc = price_fetcher(PERIOD_CURRENT, 0);  // @fixme: 'price_fetcher' - internal error #%d

#ifdef __debug__
    Print(SerializerConverter::FromObject(_ohlc).ToString<SerializerJson>());
#endif

    _type_renderer.Render(_device);
  }
};
