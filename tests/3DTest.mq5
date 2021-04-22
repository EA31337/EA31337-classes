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

int OnStart() {
  return OnInit();
}

struct Vertex {
  float Position[3];
  float Color[4];
};

const ShaderVertexLayout VertexLayout[] = {
  { "POSITION", 0, GFX_VAR_TYPE_FLOAT, 3, false, sizeof(Vertex), 0 },
  { "COLOR",    0, GFX_VAR_TYPE_FLOAT, 4, false, sizeof(Vertex), sizeof(float)*3 },
};

struct PSCBuffer
{
  DXMatrix world;
  DXMatrix view;
  DXMatrix proj;
};

/**
 * Implements OnStart().
 */
int OnInit() {
  Ref<Device> gfx_ptr = new MTDXDevice();
  Device* gfx = gfx_ptr.Ptr();
  
  gfx.Start(new MT5Frontend());
  
  Ref<Shader> _shader_v = gfx.VertexShader(ShaderSourceVS, VertexLayout);
  Ref<Shader> _shader_p = gfx.PixelShader(ShaderSourcePS);
  
  Vertex vertices[]= {
    {
      {-0.5, -0.5,  0.0},
      { 1.0,  0.0,  0.0, 1.0},
    },
    {
      {-0.5,  0.5,  0.0},
      { 0.0,  0.1,  0.0, 1.0},
    },
    {
      { 0.5,  0.5,  0.0},
      { 0.0,  0.0,  1.0, 1.0},
    },
    {
      { 0.5, -0.5,  0.0},
      { 0.5,  0.5,  1.0, 1.0},
    }
  };
  
  unsigned int indices[] = {
    0, 1, 2,
    2, 3, 0
  };

  Ref<VertexBuffer> _vbuff = gfx.VertexBuffer<Vertex>(vertices);
  Ref<IndexBuffer>  _ibuff = gfx.IndexBuffer(indices);
  
  unsigned int _rand_color = rand() * 1256;
  
  while (!IsStopped())
  {
    if ((TerminalInfoInteger(TERMINAL_KEYSTATE_ESCAPE) & 0x8000) != 0) {
      break;
    }
    
    gfx.Begin(_rand_color);
    
    PSCBuffer psCBuffer;
    
    DXMatrixIdentity(psCBuffer.world);
    DXMatrixIdentity(psCBuffer.view);
    DXMatrixIdentity(psCBuffer.proj);    
    DXMatrixPerspectiveFovLH(psCBuffer.proj, (float)M_PI/6, 1.5f, 0.1f, 100.0f);    
    DXMatrixLookAtLH(psCBuffer.view, DXVector3(0, 0, -5), DXVector3(0, 0, 0), DXVector3(0, 1, 0));
    
    DXMatrix rotate;
    static float x = 0;     x += 0.1f;
    DXMatrixRotationZ(rotate, x);
    
    DXMatrixMultiply(psCBuffer.world, psCBuffer.world, rotate);
    
    
    _shader_v.Ptr().SetCBuffer(psCBuffer);
    gfx.SetShader(_shader_p.Ptr(), _shader_v.Ptr());
    gfx.Render(_vbuff.Ptr(), _ibuff.Ptr());
    
    gfx.End();
  }

  gfx.Stop();

  return (INIT_SUCCEEDED);
}
