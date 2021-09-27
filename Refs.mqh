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
#ifndef REFS_MQH
#define REFS_MQH

// Includes.
#include "Refs.struct.h"
#include "Std.h"

/**
 * For explanation about difference between strong(Ref) and weak(WeakRef) references please look at:
 * @see https://medium.com/@elliotchance/strong-vs-weak-references-70356d37dfd2
 *
 *
 *
 * Usage:
 *
 * class Node : public Dynamic {
 *
 * protected:
 *
 *   WeakRef<Node> parentNode;
 *   Dict<Ref<Node>> childNodes;
 *
 * public:
 *
 *   void AddChild(Node* _node) {
 *     _node.parentNode = this;
 *
 *     Ref<Node> ref = _node;
 *     childNodes.Push(ref);
 *   }
 * };
 *
 *
 * Ref<Node> root = new Node();
 *
 * Ref<Node> child1 = new Node();
 * Ref<Node> child2 = new Node();
 *
 * root.childNodes.Push(child1);
 * root.childNodes.Push(child2);
 */

// Forward class declaration.
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

/**
 * Base class for reference-counted objects.
 */
class Dynamic {
 public:
  /**
   * Pointer to object holding reference counts.
   */
  ReferenceCounter* ptr_ref_counter;

  /**
   * Constructor.
   */
  Dynamic() {
#ifdef __MQL__
    if (CheckPointer(GetPointer(this)) == POINTER_DYNAMIC) {
#else
    // For other languages we just assume that user knows what he does and creates all Dynamic instances on the heap.
    if (true) {
#endif
      // Only dynamic objects are reference-counted.
      ptr_ref_counter = ReferenceCounter::alloc();
      PTR_ATTRIB(ptr_ref_counter, ptr_object) = THIS_PTR;
    } else {
      // For objects allocated on the stack we don't use reference counting.
      ptr_ref_counter = NULL;
    }
  }

  /**
   * Destructor.
   */
  ~Dynamic() {
    if (ptr_ref_counter != NULL && PTR_ATTRIB(ptr_ref_counter, num_strong_refs) == 0 &&
        PTR_ATTRIB(ptr_ref_counter, num_weak_refs) == 0) {
#ifdef __MQL__
      if (CheckPointer(ptr_ref_counter) == POINTER_DYNAMIC) {
#else
      // For other languages we just assume that user knows what he does and creates all Dynamic instances on the heap.
      if (true) {
#endif
        // Object never been referenced.
        if (ptr_ref_counter != NULL) {
          delete ptr_ref_counter;
        }
      }
    }
  }

  Dynamic(const Dynamic& right) {
    ptr_ref_counter = NULL;
#ifdef __MQL__
    if (CheckPointer(THIS_PTR) != POINTER_DYNAMIC && CheckPointer(&right) == POINTER_DYNAMIC) {
      Print(
          "Dynamic object misuse: Invoking copy constructor: STACK OBJECT = HEAP OBJECT. Remember that you can only "
          "assign heap-allocated objects to heap-allocated objects!");
    }
#endif
  }

  void operator=(const Dynamic& right) {
    if (right.ptr_ref_counter != NULL /*&& CheckPointer(&right) == POINTER_DYNAMIC*/) {
      Print(
          "Dynamic class misuse: Invoking assignment operator for stack object with heap-allocated object on the right "
          "side.");
    }
  }
};

#endif
