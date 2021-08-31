//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * Stores values fetchable and storeable in native arrays or custom data storages.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Array.mqh"
#include "ValueStorage.accessor.h"

/**
 * Value storage settable/gettable via indexation operator.
 */
template <typename C>
class ValueStorage {
 public:
  /**
   * Indexation operator.
   */
  ValueStorageAccessor<C> operator[](int _index) {
    ValueStorageAccessor<C> _accessor(THIS_PTR, _index);
    return _accessor;
  }

  /**
   * We don't user to accidentally copy whole buffer.
   */
  void operator=(const ValueStorage<C>&) = delete;

  /**
   * Initializes storage with given value.
   */
  virtual void Initialize(C _value) {}

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  virtual C Fetch(int _shift) {
    Alert(__FUNCSIG__, " is not supported!");
    DebugBreak();
    return (C)0;
  }

  /**
   * Stores value at a given shift. Takes into consideration as-series flag.
   */
  virtual void Store(int _shift, C _value) {
    Alert(__FUNCSIG__, " is not supported!");
    DebugBreak();
  }

  /**
   * Returns number of values available to fetch (size of the values buffer).
   */
  virtual int Size() {
    Alert(__FUNCSIG__, " is not supported!");
    DebugBreak();
    return 0;
  }

  /**
   * Resizes storage to given size.
   */
  virtual void Resize(int _size, int _reserve) {
    Alert(__FUNCSIG__, " is not supported!");
    DebugBreak();
  }

  /**
   * Checks whether storage operates in as-series mode.
   */
  virtual bool IsSeries() const {
    Alert(__FUNCSIG__, " is not supported!");
    DebugBreak();
    return false;
  }

  /**
   * Sets storage's as-series mode on or off.
   */
  virtual bool SetSeries(bool _value) {
    Alert(__FUNCSIG__, " is not supported!");
    DebugBreak();
    return false;
  }
};

/**
 * ValueStorage-compatible wrapper for ArrayGetAsSeries.
 */
template <typename C>
bool ArrayGetAsSeries(const ValueStorage<C>& _storage) {
  return _storage.IsSeries();
}

/**
 * ValueStorage-compatible wrapper for ArraySetAsSeries.
 */
template <typename C>
bool ArraySetAsSeries(ValueStorage<C>& _storage, bool _value) {
  return _storage.SetSeries(_value);
}

/**
 * ValueStorage-compatible wrapper for ArrayInitialize.
 */
template <typename C>
void ArrayInitialize(ValueStorage<C>& _storage, C _value) {
  _storage.Initialize(_value);
}

/**
 * ValueStorage-compatible wrapper for ArrayResize.
 */
template <typename C>
int ArrayResize(ValueStorage<C>& _storage, int _size, int _reserve = 100) {
  _storage.Resize(_size, _reserve);
  return _size;
}

/**
 * ValueStorage-compatible wrapper for ArraySize.
 */
template <typename C>
int ArraySize(ValueStorage<C>& _storage) {
  return _storage.Size();
}

/**
 * ValueStorage-compatible wrapper for ArrayCopy.
 */
template <typename C, typename D>
int ArrayCopy(D& _target[], ValueStorage<C>& _source, int _dst_start = 0, int _src_start = 0, int count = WHOLE_ARRAY) {
  if (count == WHOLE_ARRAY) {
    count = ArraySize(_source);
  }

  if (ArrayGetAsSeries(_target)) {
    if ((ArraySize(_target) == 0 && _dst_start != 0) ||
        (ArraySize(_target) != 0 && ArraySize(_target) < _dst_start + count)) {
      // The receiving array is declared as AS_SERIES, and it is of insufficient size.
      SetUserError(ERR_SMALL_ASSERIES_ARRAY);
      ArrayResize(_target, 0);
      return 0;
    }
  }

  int _pre_fill = _dst_start;

  count = MathMin(count, ArraySize(_source) - _src_start);

  int _dst_required_size = _dst_start + count;

  if (ArraySize(_target) < _dst_required_size) {
    ArrayResize(_target, _dst_required_size, 32);
  }

  int _num_copied, t, s;

  for (_num_copied = 0, t = _dst_start, s = _src_start; _num_copied < count; ++_num_copied, ++t, ++s) {
    if (s >= ArraySize(_source)) {
      // No more data to copy.
      break;
    }

    bool _reverse = ArrayGetAsSeries(_target) != ArrayGetAsSeries(_source);

    int _source_idx = _reverse ? (ArraySize(_source) - s - 1 + _src_start) : s;

    _target[t] = _source[_source_idx].Get();
  }

  return _num_copied;
}
