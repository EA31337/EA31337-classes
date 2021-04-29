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

// Resources.
#resource "3D/Shaders/vertex.hlsl" as string ShaderSourceVS;
#resource "3D/Shaders/pixel.hlsl" as string ShaderSourcePS;

//#define Print if (false) Print

// Includes.
#include "../3D/Cube.h"
#include "../3D/Devices/MTDX/MTDXDevice.h"
#include "../3D/Devices/MTDX/MTDXIndexBuffer.h"
#include "../3D/Devices/MTDX/MTDXShader.h"
#include "../3D/Devices/MTDX/MTDXVertexBuffer.h"
#include "../3D/Frontends/MT5Frontend.h"
#include "../Test.mqh"

// int OnStart() { return OnInit(); }

struct Vertex {
  DXVector3 Position;
  DXVector3 Normal;
  DXVector Color;

  Vertex() {
    Color.x = 1.0f;
    Color.y = 1.0f;
    Color.z = 1.0f;
    Color.w = 1.0f;
  }
};

const ShaderVertexLayout VertexLayout[] = {
    {"POSITION", 0, GFX_VAR_TYPE_FLOAT, 3, false, sizeof(Vertex), 0},
    {"NORMAL", 0, GFX_VAR_TYPE_FLOAT, 3, false, sizeof(Vertex), sizeof(float) * 3},
    {"COLOR", 0, GFX_VAR_TYPE_FLOAT, 4, false, sizeof(Vertex), sizeof(float) * 6}};

struct PSCBuffer : MVPBuffer {};

/**
 * Implements Oninit().
 */
int OnInit() {
  Ref<Device> gfx_ptr = new MTDXDevice();

  // Making a scope to ensure graphics device will be destructed as last.
  {
    Ref<Cube<Vertex>> _mesh = new Cube<Vertex>(250.0f, 250.0f, 250.0f);

    Device* gfx = gfx_ptr.Ptr();

    gfx.Start(new MT5Frontend());

    Ref<Shader> _shader_v = gfx.VertexShader(ShaderSourceVS, VertexLayout);
    Ref<Shader> _shader_p = gfx.PixelShader(ShaderSourcePS);

    unsigned int _rand_color = rand() * 1256;

    gfx.SetCameraOrtho3D();
    gfx.SetLightDirection(0, 0, -1.0f);

    while (!IsStopped()) {
      if ((TerminalInfoInteger(TERMINAL_KEYSTATE_ESCAPE) & 0x8000) != 0) {
        break;
      }

      gfx.Begin(0x777255EE);

      static float x = 0;
      x += 0.04f;

      TSR tsr;
      tsr.rotation.x = x;

      gfx.PushTransform(tsr);
      gfx.Render(_mesh.Ptr(), _shader_v.Ptr(), _shader_p.Ptr());
      gfx.PopTransform();

      tsr.translation.x = 50;
      tsr.translation.y = -180;
      tsr.rotation.z = 1.9f;

      gfx.PushTransform(tsr);
      gfx.Render(_mesh.Ptr(), _shader_v.Ptr(), _shader_p.Ptr());
      gfx.PopTransform();

      gfx.End();

      // break;
    }

    gfx.Stop();
  }

  return (INIT_SUCCEEDED);
}

#else

int OnInit() {
  // Nothing to test in non-MT5 environment.
  return (INIT_SUCCEEDED);
}

#endif