//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of 3D visualization classes.
 */

#ifdef __MQL5__

//#define __debug__

// Resources.
#resource "3D/Shaders/vertex.hlsl" as string ShaderSourceVS;
#resource "3D/Shaders/pixel.hlsl" as string ShaderSourcePS;

// Includes.
#include "../3D/Chart3D.h"
#include "../3D/Cube.h"
#include "../3D/Devices/MTDX/MTDXDevice.h"
#include "../3D/Devices/MTDX/MTDXIndexBuffer.h"
#include "../3D/Devices/MTDX/MTDXShader.h"
#include "../3D/Devices/MTDX/MTDXVertexBuffer.h"
#include "../3D/Frontends/MT5Frontend.h"
#include "../BufferStruct.mqh"
#include "../Chart.mqh"
#include "../Platform.h"
#include "../Serializer/Serializer.h"
#include "../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  Platform::Init();
  Ref<Device> gfx_ptr = new MTDXDevice();

  // Making a scope to ensure graphics device will be destructed as last.
  {
    Device* gfx = gfx_ptr.Ptr();

    gfx.Start(new MT5Frontend());

    Ref<Shader> _shader_v = gfx.VertexShader(ShaderSourceVS, Vertex::Layout);
    Ref<Shader> _shader_p = gfx.PixelShader(ShaderSourcePS);

    Ref<Cube<Vertex>> _mesh = new Cube<Vertex>(1.0f, 1.0f, 1.0f);
    _mesh.Ptr().SetShaderVS(_shader_v.Ptr());
    _mesh.Ptr().SetShaderPS(_shader_p.Ptr());

    Ref<Chart3D> _chart = new Chart3D(Platform::FetchDefaultCandleIndicator(), CHART3D_TYPE_CANDLES);

    unsigned int _rand_color = rand() * 1256;

    gfx.SetCameraOrtho3D(0.0f, 0.0f, 100.0f);
    gfx.SetLightDirection(0.0f, 0.0f, -1.0f);

    while (!IsStopped()) {
      if ((TerminalInfoInteger(TERMINAL_KEYSTATE_ESCAPE) & 0x8000) != 0) {
        break;
      }

      gfx.Begin(0x00FFFFFF);

      static float x = 0;
      x += 0.025f;

      TSR tsr;
      // tsr.rotation.y = (float)sin(x) / 4.0f;
      tsr.rotation.x = (float)sin(x / 2);

      gfx.PushTransform(tsr);
      _chart.Ptr().Render(gfx);
      gfx.PopTransform();

      gfx.End();

      // break;
    }
  }

  gfx_ptr.Ptr().Stop();

  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 **/
void OnTick() { Platform::Tick(); }
#else
/**
 * Implements OnInit().
 */
int OnInit() {
  // Nothing to test in non-MT5 environment.
  return (INIT_SUCCEEDED);
}
#endif
