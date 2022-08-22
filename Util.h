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
#include "Serializer/SerializerConversions.h"

/**
 * Utility methods.
 */
class Util {
 public:
  /**
   * Replaces content of the given array with items from another array. It is a non-const r-value version, as MQL's
   * built-in ArrayCopy does not support such source arrays.
   */
  template <typename T>
  static void ArrayCopy(ARRAY_REF(T, _dst_array), ARRAY_REF(T, _src_array)) {
#ifdef __MQL__
    ::ArrayResize(_dst_array, ::ArraySize(_src_array));
    for (int i = 0; i < ArraySize(_src_array); ++i) {
      _dst_array[i] = _src_array[i];
    }
#else
    _dst_array = _src_array;
#endif
  }

  /**
   * Resizes native array and reserves space for further items by some fixed step.
   */
  template <typename T>
  static void ArrayResize(ARRAY_REF(T, _array), int _new_size, int _resize_pool = 32) {
    ::ArrayResize(_array, _new_size, (_new_size / _resize_pool + 1) * _resize_pool);
  }

  /**
   * Pushes item into the native array and reserves space for further items by some fixed step.
   */
  template <typename T, typename V>
  static int ArrayPush(ARRAY_REF(T, _array), V& _value, int _resize_pool = 32) {
    Util::ArrayResize(_array, ArraySize(_array) + 1, _resize_pool);
    _array[ArraySize(_array) - 1] = _value;
    return ArraySize(_array) - 1;
  }

  /**
   * Resizes native array and reserves space for further items by some fixed step.
   */
  template <typename T>
  static T ArrayPop(ARRAY_REF(T, _array)) {
    T _result = _array[ArraySize(_array) - 1];
    ::ArrayResize(_array, ArraySize(_array) - 1);
    return _result;
  }

  /**
   * Removes value from the array.
   */
  template <typename T>
  static bool ArrayRemove(ARRAY_REF(T, _array), int index) {
    if (index < 0 || index >= ArraySize(_array)) {
      // Index out of array bounds.
      return false;
    }
    for (int i = index; i < ArraySize(_array) - 1; ++i) {
      _array[i] = _array[i + 1];
    }
    Util::ArrayResize(_array, ArraySize(_array) - 1);
    return true;
  }

  /**
   * Removes value from the array.
   */
  template <typename T>
  static bool ArrayRemoveFirst(ARRAY_REF(T, _array), T& value) {
    for (int i = 0; i < ArraySize(_array); ++i) {
      if (_array[i] == value) {
        Util::ArrayRemove(_array, i);
        return true;
      }
    }
    return false;
  }

  template <typename T>
  static T Print(ARRAY_REF(T, _array)) {
    string _result;
    for (int i = 0; i < ArraySize(_array); ++i) {
      _result += IntegerToString(i) + ": " + (string)_array[i];
    }
    return _result;
  }

  /**
   * Splits prints by newlines on MT4.
   */
  static void Print(string _value) {
#ifdef __MQL4__
    string _segments[];
    StringSplit(_value, '\n', _segments);
    for (int i = 0; i < ArraySize(_segments); ++i) {
      ::Print(_segments[i]);
    }
#else
    ::Print(_value);
#endif
  }

  /**
   * Checks whether array has given value.
   */
  template <typename T, typename V>
  static bool ArrayContains(ARRAY_REF(T, _array), const V& _value) {
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
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f, const G _g,
                        const H _h) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_f)) + SerializerConversions::ValueToString(_g) +
           SerializerConversions::ValueToString(_h);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f, const G _g, const H _h,
                        const I _i) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_f)) + SerializerConversions::ValueToString(_g) +
           SerializerConversions::ValueToString(_h) + SerializerConversions::ValueToString(_i);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f, const G _g, const H _h,
                        const I _i, const J _j) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_f)) + SerializerConversions::ValueToString(_g) +
           SerializerConversions::ValueToString(_h) + SerializerConversions::ValueToString(_i) +
           SerializerConversions::ValueToString(_j);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f, const G _g, const H _h,
                        const I _i, const J _j, const K _k) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_f)) + SerializerConversions::ValueToString(_g) +
           SerializerConversions::ValueToString(_h) + SerializerConversions::ValueToString(_i) +
           SerializerConversions::ValueToString(_j) + SerializerConversions::ValueToString(_k);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K, typename L>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f, const G _g, const H _h,
                        const I _i, const J _j, const K _k, const L _l) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_f)) + SerializerConversions::ValueToString(_g) +
           SerializerConversions::ValueToString(_h) + SerializerConversions::ValueToString(_i) +
           SerializerConversions::ValueToString(_j) + SerializerConversions::ValueToString(_k) +
           SerializerConversions::ValueToString(_l);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K, typename L, typename M>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f, const G _g, const H _h,
                        const I _i, const J _j, const K _k, const L _l, const M _m) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_f)) + SerializerConversions::ValueToString(_g) +
           SerializerConversions::ValueToString(_h) + SerializerConversions::ValueToString(_i) +
           SerializerConversions::ValueToString(_j) + SerializerConversions::ValueToString(_k) +
           SerializerConversions::ValueToString(_l) + SerializerConversions::ValueToString(_m);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K, typename L, typename M, typename N>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f, const G _g, const H _h,
                        const I _i, const J _j, const K _k, const L _l, const M _m, const N _n) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_f)) + SerializerConversions::ValueToString(_g) +
           SerializerConversions::ValueToString(_h) + SerializerConversions::ValueToString(_i) +
           SerializerConversions::ValueToString(_j) + SerializerConversions::ValueToString(_k) +
           SerializerConversions::ValueToString(_l) + SerializerConversions::ValueToString(_m) +
           SerializerConversions::ValueToString(_n);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K, typename L, typename M, typename N, typename O>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f, const G _g, const H _h,
                        const I _i, const J _j, const K _k, const L _l, const M _m, const N _n, const O _o) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_f)) + SerializerConversions::ValueToString(_g) +
           SerializerConversions::ValueToString(_h) + SerializerConversions::ValueToString(_i) +
           SerializerConversions::ValueToString(_j) + SerializerConversions::ValueToString(_k) +
           SerializerConversions::ValueToString(_l) + SerializerConversions::ValueToString(_m) +
           SerializerConversions::ValueToString(_n) + SerializerConversions::ValueToString(_o);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K, typename L, typename M, typename N, typename O, typename P>
  static string MakeKey(const A _a, const B _b, const C _c, const D _d, const E _e, const F _f, const G _g, const H _h,
                        const I _i, const J _j, const K _k, const L _l, const M _m, const N _n, const O _o,
                        const P _p) {
    return SeparatedMaybe(SerializerConversions::ValueToString(_a)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_b)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_c)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_d)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_e)) +
           SeparatedMaybe(SerializerConversions::ValueToString(_f)) + SerializerConversions::ValueToString(_g) +
           SerializerConversions::ValueToString(_h) + SerializerConversions::ValueToString(_i) +
           SerializerConversions::ValueToString(_j) + SerializerConversions::ValueToString(_k) +
           SerializerConversions::ValueToString(_l) + SerializerConversions::ValueToString(_m) +
           SerializerConversions::ValueToString(_n) + SerializerConversions::ValueToString(_o) +
           SerializerConversions::ValueToString(_p);
  }

  /**
   * Creates string with separator if string was not empty.
   */
  static string SeparatedMaybe(string _value, string _separator = ", ") {
    return _value == "" ? "" : (_value + _separator);
  }
};
