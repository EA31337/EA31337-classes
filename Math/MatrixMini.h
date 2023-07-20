//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Platform/Platform.extern.h"

template <typename T>
class MatrixMini2d {
 public:
  ARRAY(T, data);
  int size_x;
  int size_y;

  MatrixMini2d() {}
  MatrixMini2d(int _size_x, int _size_y) : size_x(_size_x), size_y(_size_y) { Resize(_size_x, _size_y); }

  void Resize(int _size_x, int _size_y) {
    ArrayResize(data, _size_x * _size_y);
    size_x = _size_x;
    size_y = _size_y;
  }

  T Get(int _x, int _y) { return data[(size_x * _y) + _x]; }

  void Set(int _x, int _y, T _value) {
    int index = (size_x * _y) + _x;

    if (index < 0 || index >= (size_x * size_y)) {
      Alert("Array out of range!");
    }

    data[index] = _value;
  }

  int SizeX() { return size_x; }

  int SizeY() { return size_y; }
};
