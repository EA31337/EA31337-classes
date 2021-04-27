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

/*
 * @file
 * Utility methods.
 */

class Util {
  /**
   * Resizes native array and reserves space for further items by some fixed step.
   */
  template <typename T>
  static void ArrayResize(T& _array[], int _new_size, int _resize_pool = 32) {
    ::ArrayResize(_array, _new_size, (_new_size / _resize_pool + 1) * _resize_pool);
  }

  /**
   * Pushes item into the native array and reserves space for further items by some fixed step.
   */
  template <typename T, typename V>
  static int ArrayPush(T& _array[], const V& _value, int _resize_pool = 32) {
    Util::ArrayResize(_array, ArraySize(_array) + 1, _resize_pool);
    _array[ArraySize(_array) - 1] = _value;
    return ArraySize(_array) - 1;
  }
};