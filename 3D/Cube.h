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
 * Cube mesh.
 */

#include "Face.h"
#include "Mesh.h"

/**
 * Cube mesh.
 */
template <typename T>
class Cube : public Mesh<T> {
 public:
  Cube(float x = 0.0f, float y = 0.0f, float z = 0.0f, float size_x = 1.0f, float size_y = 1.0f, float size_z = 1.0f) {
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
};