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

/**
 * @file
 * Includes Refs' structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward class declaration.
class Refs;

/**
 * Class used to hold strong reference to reference-counted object.
 */
template <typename X>
struct Ref {
  /**
   * Pointer to target object.
   */
  X* ptr_object;

 public:
  /**
   * Constructor.
   */
  Ref(X* _ptr) { this = _ptr; }

  /**
   * Constructor.
   */
  Ref(Ref<X>& ref) { this = ref.Ptr(); }

  /**
   * Constructor.
   */
  Ref(WeakRef<X>& ref) { this = ref.Ptr(); }

  /**
   * Destructor.
   */
  Ref() { ptr_object = NULL; }

  /**
   * Destructor.
   */
  ~Ref() { Unset(); }

  /**
   * Returns pointer to target object.
   */
  X* Ptr() { return ptr_object; }

  /**
   * Checks whether any object is referenced.
   */
  bool IsSet() { return ptr_object != NULL; }

  /**
   * Unbinds holding reference.
   */
  void Unset() {
    if (ptr_object != NULL) {
      // Dropping strong reference.
      if (!--ptr_object.ptr_ref_counter.num_strong_refs) {
#ifdef __debug__
        Print(ptr_object.ptr_ref_counter.Debug());
#endif

        // No more strong references.
        if (!ptr_object.ptr_ref_counter.num_weak_refs) {
          // Also no more weak references.
          delete ptr_object.ptr_ref_counter;
          ptr_object.ptr_ref_counter = NULL;
        } else {
          // Object becomes deleted, but there are some weak references.
          ptr_object.ptr_ref_counter.deleted = true;
        }

        // Avoiding delete loop for cyclic references.
        X* ptr_to_delete = ptr_object;

        // Avoiding double deletion in Dynamic's destructor.
        ptr_object.ptr_ref_counter = NULL;
        ptr_object = NULL;

        delete ptr_to_delete;
      }

      ptr_object = NULL;
    }
  }

  /**
   * Makes a strong reference to the given object.
   */
  void operator=(X* _ptr) {
    if (ptr_object == _ptr) {
      // Assigning the same object.
      return;
    }

    Unset();

    ptr_object = _ptr;

    if (ptr_object != NULL) {
      ++ptr_object.ptr_ref_counter.num_strong_refs;
#ifdef __debug__
      Print(ptr_object.ptr_ref_counter.Debug());
#endif
    }
  }

  /**
   * Makes a strong reference to the given weakly-referenced object.
   */
  void operator=(WeakRef<X>& right) { this = right.Ptr(); }

  /**
   * Makes a strong reference to the strongly-referenced object.
   */
  void operator=(Ref<X>& right) { this = right.Ptr(); }
};

/**
 * Class used to hold weak reference to reference-counted object.
 */
template <typename X>
struct WeakRef {
  /**
   * Pointer to object holding reference counts.
   */
  ReferenceCounter* ptr_ref_counter;

 public:
  /**
   * Constructor.
   */
  WeakRef(X* _ptr = NULL) { this = _ptr; }

  /**
   * Constructor.
   */
  WeakRef(WeakRef<X>& ref) { this = ref.Ptr(); }

  /**
   * Constructor.
   */
  WeakRef(Ref<X>& ref) { this = ref.Ptr(); }

  /**
   * Destructor.
   */
  ~WeakRef() { Unset(); }

  bool ObjectExists() { return ptr_ref_counter != NULL && !ptr_ref_counter.deleted; }

  X* Ptr() { return ObjectExists() ? (X*)ptr_ref_counter.ptr_object : NULL; }

  /**
   * Makes a strong reference to the given object.
   */
  void operator=(X* _ptr) {
    if (ptr_ref_counter == (_ptr == NULL ? NULL : _ptr.ptr_ref_counter)) {
      // Assigning the same object or the same NULL.
      return;
    }

    Unset();

    if (_ptr == NULL) {
      // Assigning NULL.
      return;
    }

    if (_ptr.ptr_ref_counter.deleted) {
      // Assigning already deleted object.
      ptr_ref_counter = NULL;
      return;
    }

    ptr_ref_counter = _ptr.ptr_ref_counter;

#ifdef __debug__
    Print(ptr_ref_counter.Debug());
#endif

    ++ptr_ref_counter.num_weak_refs;
  }

  /**
   * Makes a weak reference to the given weakly-referenced object.
   */
  void operator=(WeakRef<X>& right) { this = right.Ptr(); }

  /**
   * Makes a weak reference to the strongly-referenced object.
   */
  void operator=(Ref<X>& right) { this = right.Ptr(); }

  /**
   * Unbinds holding reference.
   */
  void Unset() {
    if (ptr_ref_counter != NULL) {
      // Dropping weak reference.
      if (!--ptr_ref_counter.num_weak_refs) {
        // No more weak references.
#ifdef __debug__
        Print(ptr_ref_counter.Debug());
#endif

        if (!ptr_ref_counter.num_strong_refs) {
          // There are also no strong references.
          ReferenceCounter* stored_ptr_ref_counter = ptr_ref_counter;
          if (!ptr_ref_counter.deleted) {
            // It is safe to delete object and reference counter object.
            // Avoiding double deletion in Dynamic's destructor.
            ptr_ref_counter.ptr_object.ptr_ref_counter = NULL;

#ifdef __debug__
            Print("Refs: Deleting object ", ptr_ref_counter.ptr_object);
#endif

            delete ptr_ref_counter.ptr_object;
          }
          delete stored_ptr_ref_counter;
        }
      }
    }

    ptr_ref_counter = NULL;
  }
};
