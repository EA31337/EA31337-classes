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
 * Generic graphics face object.
 */

#include "Math.h"

// Face flags.
enum ENUM_FACE_FLAGS { FACE_FLAGS_NONE, FACE_FLAGS_TRIANGLE, FACE_FLAGS_QUAD };

// Face (3 or 4 vertices).
template <typename T>
struct Face {
  // Flags.
  ENUM_FACE_FLAGS flags;

  // 3 or 4 points.
  T points[4];

  /**
   * Constructor.
   */
  Face() { flags = FACE_FLAGS_NONE; }

  /**
   * Constructor.
   */
  Face(float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3) {
    flags = FACE_FLAGS_TRIANGLE;
    points[0].Position.x = x1;
    points[0].Position.y = y1;
    points[0].Position.z = z1;
    points[1].Position.x = x2;
    points[1].Position.y = y2;
    points[1].Position.z = z2;
    points[2].Position.x = x3;
    points[2].Position.y = y3;
    points[2].Position.z = z3;
  }

  /**
   * Constructor.
   */
  Face(float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4,
       float z4) {
    flags = FACE_FLAGS_QUAD;
    points[0].Position.x = x1;
    points[0].Position.y = y1;
    points[0].Position.z = z1;
    points[1].Position.x = x2;
    points[1].Position.y = y2;
    points[1].Position.z = z2;
    points[2].Position.x = x3;
    points[2].Position.y = y3;
    points[2].Position.z = z3;
    points[3].Position.x = x4;
    points[3].Position.y = y4;
    points[3].Position.z = z4;
  }

  void UpdateNormal() {
    DXVector3 _normal, _v1, _v2;

    DXVec3Subtract(_v1, points[1].Position, points[0].Position);
    DXVec3Subtract(_v2, points[2].Position, points[0].Position);

    DXVec3Cross(_normal, _v1, _v2);
    DXVec3Normalize(_normal, _normal);

    for (int i = 0; i < 4; ++i) {
      points[i].Normal = _normal;
    }
  }
};
