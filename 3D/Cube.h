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
 * Cube mesh.
 */

#include "Face.h"
#include "Mesh.h"

#ifdef __MQL5__
// Resource variables.
#resource "Shaders/cube_ps.hlsl" as string ShaderCubeSourcePS;
#resource "Shaders/cube_vs.hlsl" as string ShaderCubeSourceVS;
#endif

/**
 * Cube mesh.
 */
template <typename T>
class Cube : public Mesh<T> {
 public:
  Cube(float size_x, float size_y, float size_z, float x = 0.0f, float y = 0.0f, float z = 0.0f)
      : Mesh(MESH_TYPE_SEPARATE_POINTS) {
    float half_x = size_x / 2;
    float half_y = size_y / 2;
    float half_z = size_z / 2;

    Face<T> f1(x - half_x, y - half_y, z - half_z, x - half_x, y + half_y, z - half_z, x + half_x, y + half_y,
               z - half_z, x + half_x, y - half_y, z - half_z);

    Face<T> f2(x + half_x, y - half_y, z + half_z, x + half_x, y + half_y, z + half_z, x - half_x, y + half_y,
               z + half_z, x - half_x, y - half_y, z + half_z);

    Face<T> f3(x - half_x, y - half_y, z + half_z, x - half_x, y + half_y, z + half_z, x - half_x, y + half_y,
               z - half_z, x - half_x, y - half_y, z - half_z);

    Face<T> f4(x + half_x, y - half_y, z - half_z, x + half_x, y + half_y, z - half_z, x + half_x, y + half_y,
               z + half_z, x + half_x, y - half_y, z + half_z);

    Face<T> f5(x - half_x, y - half_y, z + half_z, x - half_x, y - half_y, z - half_z, x + half_x, y - half_y,
               z - half_z, x + half_x, y - half_y, z + half_z);

    Face<T> f6(x - half_x, y + half_y, z - half_z, x - half_x, y + half_y, z + half_z, x + half_x, y + half_y,
               z + half_z, x + half_x, y + half_y, z - half_z);

    AddFace(f1);
    AddFace(f2);
    AddFace(f3);
    AddFace(f4);
    AddFace(f5);
    AddFace(f6);
  }

#ifdef __MQL5__
  /**
   * Initializes graphics device-related things.
   */
  virtual void Initialize(Device* _device) {
    SetShaderVS(_device.VertexShader(ShaderCubeSourceVS, T::Layout));
    SetShaderPS(_device.PixelShader(ShaderCubeSourcePS));
  }
#endif
};
