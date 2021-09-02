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
    return SerializerConversions::ValueToString(a) + "/" + SerializerConversions::ValueToString(b);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C>
  static string MakeKey(const A a, const B b, const C c) {
    return SerializerConversions::ValueToString(a) + "/" + SerializerConversions::ValueToString(b) + "/" +
           SerializerConversions::ValueToString(c);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D>
  static string MakeKey(const A a, const B b, const C c, const D d) {
    return SerializerConversions::ValueToString(a) + "/" + SerializerConversions::ValueToString(b) + "/" +
           SerializerConversions::ValueToString(c) + "/" + SerializerConversions::ValueToString(d);
  }

  /**
   * Creates string-based key using given variables.
   */
  template <typename A, typename B, typename C, typename D, typename E>
  static string MakeKey(const A a, const B b, const C c, const D d, const E e) {
    return SerializerConversions::ValueToString(a) + "/" + SerializerConversions::ValueToString(b) + "/" +
           SerializerConversions::ValueToString(c) + "/" + SerializerConversions::ValueToString(d) + "/" +
           SerializerConversions::ValueToString(e);
  }
};
