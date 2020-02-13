//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Prevents processing this includes file for the second time.
#ifndef BUFFER_MQH
#define BUFFER_MQH

// Includes.
#include "Dict.mqh"

/**
 * Class to store data values.
 */
template <typename T>
class Buffer : public Dict<long, T> {

 public:
  void Buffer() {}

  /**
   * Adds new value.
   */
  void Add(T _value, long _dt = 0) {
    _dt = _dt > 0 ? _dt : TimeCurrent();
    Set(_dt, _value);
  }
};
#endif  // BUFFER_MQH