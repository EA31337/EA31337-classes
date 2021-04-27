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
   * Copy constructor.
   */
  Face(const Face& r) {
    flags = r.flags;
    for (int p = 0; p < 4; ++p) {
      points[p] = r.points[p];
    }
  }

  /**
   * Constructor.
   */
  Face(float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3) {
    flags = FACE_FLAGS_TRIANGLE;
    points[0].Position[0] = x1;
    points[0].Position[1] = y1;
    points[0].Position[2] = z1;
    points[1].Position[0] = x2;
    points[1].Position[1] = y2;
    points[1].Position[2] = z2;
    points[2].Position[0] = x3;
    points[2].Position[1] = y3;
    points[2].Position[2] = z3;
  }

  /**
   * Constructor.
   */
  Face(float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float x4, float y4,
       float z4) {
    flags = FACE_FLAGS_QUAD;
    points[0].Position[0] = x1;
    points[0].Position[1] = y1;
    points[0].Position[2] = z1;
    points[1].Position[0] = x2;
    points[1].Position[1] = y2;
    points[1].Position[2] = z2;
    points[2].Position[0] = x3;
    points[2].Position[1] = y3;
    points[2].Position[2] = z3;
    points[3].Position[0] = x4;
    points[3].Position[1] = y4;
    points[3].Position[2] = z4;
  }
};