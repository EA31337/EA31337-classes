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
 * Structs cache per key.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "DictObject.mqh"

/**
 * Stores objects to be reused using a string-based key.
 */
template <typename C>
class ObjectsCache {
  // Dictionary of key => reference to object.
  static DictObject<string, C> objects;

 public:
  /**
   * Tries to retrieve pointer to object for a given key. Returns true if object did exist.
   */
  static bool TryGet(string& key, C*& out_ptr) {
    int position;
    if (!objects.KeyExists(key, position)) {
      out_ptr = NULL;
      return false;
    } else {
      out_ptr = objects.GetByPos(position);
      return true;
    }
  }

  /**
   * Stores object pointer with a given key.
   */
  static C* Set(string& key, C* ptr) {
    objects.Set(key, PTR_TO_REF(ptr));
    return ptr;
  }
};

template <typename C>
DictObject<string, C> ObjectsCache::objects;
