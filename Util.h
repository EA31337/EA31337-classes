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
 * Utility methods.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "SerializerConversions.h"

/**
 * Utility methods.
 */
class Util {
 public:
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
  static int ArrayPush(T& _array[], V& _value, int _resize_pool = 32) {
    Util::ArrayResize(_array, ArraySize(_array) + 1, _resize_pool);
    _array[ArraySize(_array) - 1] = _value;
    return ArraySize(_array) - 1;
  }

  /**
   * Resizes native array and reserves space for further items by some fixed step.
   */
  template <typename T>
  static T ArrayPop(T& _array[]) {
    T _result = _array[ArraySize(_array) - 1];
    ::ArrayResize(_array, ArraySize(_array) - 1);
    return _result;
  }

  template <typename T>
  static T Print(T& _array[]) {
    string _result;
    for (int i = 0; i < ArraySize(_array); ++i) {
      _result += IntegerToString(i) + ": " + (string)_array[i];
    }
    return _result;
  }

  /**
   * Checks whether array has given value.
   */
  template <typename T, typename V>
  static bool ArrayContains(T& _array[], const V& _value) {
    for (int i = 0; i < ArraySize(_array); ++i) {
      if (_array[i] == _value) {
        return true;
      }
    }

    return false;
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A>
  static string MakeKey(const A a) {
    return SerializerConversions::ValueToString(a);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B>
  static string MakeKey(const A _a, const B _b) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) + SerializerConversions::ValueToString(_b);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C>
  static string MakeKey(const A _a, const B _b, const C _c) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) + SerializerConversions::ValueToString(_c);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) + SerializerConversions::ValueToString(_d);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) + SerializerConversions::ValueToString(_e);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) + SerializerConversions::ValueToString(_f);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f, const G _g) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_f)) + SerializerConversions::ValueToString(_g);
  }

  /**
   * Creates string with separator if string was not empty.
   */
  static string SeparatedMaybe(string _value, string _separator = "/") {
    return _value == "" ? "" : (_value + _separator);
  }
};
