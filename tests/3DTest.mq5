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

// Resources.
#resource "3D/Shaders/vertex.hlsl" as string ShaderSourceVS;
#resource "3D/Shaders/pixel.hlsl" as string ShaderSourcePS;

// Includes.
#include "../3D/Frontends/MT5Frontend.h"
#include "../3D/Devices/MTDX/MTDXDevice.h"
#include "../3D/Devices/MTDX/MTDXIndexBuffer.h"
#include "../3D/Devices/MTDX/MTDXShader.h"
#include "../3D/Devices/MTDX/MTDXVertexBuffer.h"
#include "../Test.mqh"

struct Vertex {
  float position[4];
};

const ShaderVertexLayout VertexLayout[1] = {
  { "POSITION", 0, GFX_VAR_TYPE_FLOAT, 4, false, sizeof(Vertex), 0 }
};

/**
 * Implements OnStart().
 */
int OnStart() {
  Ref<Device> gfx_ptr = new MTDXDevice();
  Device* gfx = gfx_ptr.Ptr();
  
  gfx.Start(new MT5Frontend());
  
  Ref<Shader> _shader_v = gfx.VertexShader(ShaderSourceVS, VertexLayout);
  Ref<Shader> _shader_p = gfx.PixelShader(ShaderSourcePS);

  Vertex vertices[]= {{{-1,-1,0.5,1.0}},{{-1,1,0.5,1.0}},{{1,1,0.5,1.0}},{{1,-1,0.5,1.0}}};
  
  while (!IsStopped())
  {
    gfx.Begin().Clear();
    
    gfx.End();
  }
  

  gfx.Stop();

  return (INIT_SUCCEEDED);
}
