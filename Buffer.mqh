//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

  /**
   * Returns the lowest value.
   */
  T GetMin() {
    T min = NULL;

    for (DictIterator<long, T> iter = Begin(); iter.IsValid(); ++iter)
      if (min == NULL || min > iter.Value()) min = iter.Value();

    return min;
  }

  /**
   * Returns the highest value.
   */
  T GetMax() {
    T max = NULL;

    for (DictIterator<long, T> iter = Begin(); iter.IsValid(); ++iter)
      if (max == NULL || max < iter.Value()) max = iter.Value();

    return max;
  }

  /**
   * Returns average value.
   */
  T GetAvg() {
    T sum = 0;
    unsigned int numValues = 0;

    for (DictIterator<long, T> iter = Begin(); iter.IsValid(); ++iter) {
      sum += iter.Value();
      ++numValues;
    }

    return T(sum / numValues);
  }

  /**
   * Returns median of values.
   */
  T GetMed() {
    T array[];

    ArrayResize(array, Size());

    for (DictIterator<long, T> iter = Begin(); iter.IsValid(); ++iter) {
      array[iter.Index()] = iter.Value();
    }

    ArraySort(array);

    double median;

    int len = ArraySize(array);

    if (len % 2 == 0)
      median = (array[len / 2] + array[(len / 2) - 1]) / 2;
    else
      median = array[len / 2];

    return (T)median;
  }
};
#endif  // BUFFER_MQH
