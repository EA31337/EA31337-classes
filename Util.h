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
  static string MakeKey(const A a, const B b) {
    string _a = SerializerConversions::ValueToString(a);
    string _b = SerializerConversions::ValueToString(b);

    return SeparatedMaybe(_a) + _b;
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C>
  static string MakeKey(const A a, const B b, const C c) {
    string _a = SerializerConversions::ValueToString(a);
    string _b = SerializerConversions::ValueToString(b);
    string _c = SerializerConversions::ValueToString(c);

    return SeparatedMaybe(_a) + SeparatedMaybe(_b) + _c;
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D>
  static string MakeKey(const A a, const B b, const C c, const D d) {
    string _a = SerializerConversions::ValueToString(a);
    string _b = SerializerConversions::ValueToString(b);
    string _c = SerializerConversions::ValueToString(c);
    string _d = SerializerConversions::ValueToString(d);

    return SeparatedMaybe(_a) + SeparatedMaybe(_b) + SeparatedMaybe(_c) + _d;
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E>
  static string MakeKey(const A a, const B b, const C c, const D d, const E e) {
    string _a = SerializerConversions::ValueToString(a);
    string _b = SerializerConversions::ValueToString(b);
    string _c = SerializerConversions::ValueToString(c);
    string _d = SerializerConversions::ValueToString(d);
    string _e = SerializerConversions::ValueToString(e);

    return SeparatedMaybe(_a) + SeparatedMaybe(_b) + SeparatedMaybe(_c) + SeparatedMaybe(_d) + _e;
  }

  /**
   * Creates string with separator if string was not empty.
   */
  static string SeparatedMaybe(string _value, string _separator = "/") {
    return _value == "" ? "" : (_value + _separator);
  }
};
