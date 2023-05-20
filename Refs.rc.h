//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

/**
 * @file
 * Includes Refs' ReferenceCounter struct.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "String.mqh"

// Forward declarations.
class Dynamic;

class ReferenceCounter {
 public:
  /**
   * Number of weak references to target object.
   */
  unsigned int num_weak_refs;

  /**
   * Number of strong references to target object.
   */
  unsigned int num_strong_refs;

  /**
   * Target object pointer.
   */
  Dynamic* ptr_object;

  /**
   * Whether object has been deleted (but still have weak references).
   */
  bool deleted;

  /**
   * Constructor.
   */
  ReferenceCounter() {
    num_weak_refs = 0;
    num_strong_refs = 0;
    ptr_object = NULL;
    deleted = false;
  }

  string Debug() { return StringFormat("%d: %d strong, %d weak", ptr_object, num_strong_refs, num_weak_refs); }

  /**
   * ReferenceCounter class allocator.
   */
  static ReferenceCounter* alloc();
};

/**
 * ReferenceCounter class allocator.
 */
ReferenceCounter* ReferenceCounter::alloc() {
  // @todo Enhance with linked-list object reuse.
  return new ReferenceCounter();
}
