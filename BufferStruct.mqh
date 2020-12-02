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

// Prevents processing this includes file for the second time.
#ifndef BUFFER_STRUCT_MQH
#define BUFFER_STRUCT_MQH

// Includes.
#include "DictStruct.mqh"
#include "Serializer.mqh"

/**
 * Class to store struct data.
 */
template <typename TStruct>
class BufferStruct : public DictStruct<long, TStruct> {
 public:
  /* Constructors */

  /**
   * Constructor.
   */
  BufferStruct() {}
  BufferStruct(BufferStruct& _right) { this = _right; }

  /**
   * Adds new value.
   */
  void Add(TStruct& _value, long _dt = 0) {
    _dt = _dt > 0 ? _dt : TimeCurrent();
    Set(_dt, _value);
  }

  /**
   * Clear entries older than given timestamp.
   */
  void Clear(long _dt = 0, bool _older = true) {
    for (DictStructIterator<long, TStruct> iter = Begin(); iter.IsValid(); ++iter) {
      long _time = iter.Key();
      if (_older && _time < _dt) {
        Unset(iter.Key());
      } else if (!_older && _time > _dt) {
        Unset(iter.Key());
      }
    }
  }
};

#endif  // BUFFER_STRUCT_MQH
