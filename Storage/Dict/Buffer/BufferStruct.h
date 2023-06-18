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

// Prevents processing this includes file for the second time.
#ifndef BUFFER_STRUCT_H
#define BUFFER_STRUCT_H

// Includes.
#include "../DictBase.h"
#include "../DictStruct.h"
#include "../../../Serializer/Serializer.h"

/**
 * Implements BufferStruct's Overflow Listener.
 *
 * @see DictBase
 */
bool BufferStructOverflowListener(ENUM_DICT_OVERFLOW_REASON _reason, int _size, int _num_conflicts) {
  static int cache_limit = 86400;
  switch (_reason) {
    case DICT_LISTENER_FULL_CAN_RESIZE:
    case DICT_LISTENER_NOT_PERFORMANT_CAN_RESIZE:
      // We allow resize if dictionary size is less than 86400 slots.
      return _size < cache_limit;
    case DICT_LISTENER_CONFLICTS_CAN_OVERWRITE:
      // We start to overwrite slots when we can't make dict bigger and there is at least 10 consecutive conflicts while
      // inserting new value.
      return _size >= cache_limit && _num_conflicts >= 10;
  }
  return true;
}

/**
 * Class to store struct data.
 */
template <typename TStruct>
class BufferStruct : public DictStruct<long, TStruct> {
 protected:
  long min, max;

 public:
  /* Constructors */

  /**
   * Constructor.
   */
  BufferStruct() : min(INT_MAX), max(INT_MIN) { THIS_ATTR SetOverflowListener(BufferStructOverflowListener, 10); }
  BufferStruct(const BufferStruct& _right) : min(INT_MAX), max(INT_MIN) {
    this = _right;
    THIS_ATTR SetOverflowListener(BufferStructOverflowListener, 10);
  }

  /**
   * Adds new value.
   */
  void Add(TStruct& _value, long _dt = 0) {
    _dt = _dt > 0 ? _dt : (long)TimeCurrent();
    if (THIS_ATTR Set(_dt, _value)) {
      min = _dt < min ? _dt : min;
      max = _dt > max ? _dt : max;
    }
  }

  /**
   * Clear entries older than given timestamp.
   */
  void Clear(long _dt = 0, bool _older = true) {
    min = INT_MAX;
    max = INT_MIN;
    if (_dt > 0) {
      for (DictStructIterator<long, TStruct> iter(THIS_ATTR Begin()); iter.IsValid(); ++iter) {
        long _time = iter.Key();
        if (_older && _time < _dt) {
          Unset(iter.Key());
          continue;
        } else if (!_older && _time > _dt) {
          Unset(iter.Key());
          continue;
        }
        min = _time < min ? _time : min;
        max = _time > max ? _time : max;
      }
    } else {
      DictStruct<long, TStruct>::Clear();
    }
  }

  /* Getters */

  /**
   * Gets the newest timestamp.
   */
  long GetMax() { return max; }

  /**
   * Gets the oldest timestamp.
   */
  long GetMin() { return min; }
};

#endif  // BUFFER_STRUCT_H
