//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

#include "Refs.rc.h"
#include "Std.h"

#ifdef EMSCRIPTEN
#include <emscripten/bind.h>
#endif

class Dynamic;
// Forward class declaration.
template <typename X>
struct WeakRef;

/**
 * Simples type of reference. Deletes object's pointer if reference goes out of the scope/is destructed.
 */
template <typename X>
struct SimpleRef {
  /**
   * Pointer to target object.
   */
  X* ptr_object;

  /**
   * Constructor.
   */
  SimpleRef(X* _ptr) { this = _ptr; }

  /**
   * Destructor.
   */
  ~SimpleRef() {
    if (ptr_object != NULL) {
      delete ptr_object;
    }
  }

  /**
   * Makes a reference to the given object.
   */
  void operator=(X* _ptr) {
    if (ptr_object == _ptr) {
      // Assigning the same object.
      return;
    }
    Unset();

    ptr_object = _ptr;
  }

  /**
   * Unbinds holding reference.
   */
  void Unset() {
    if (ptr_object != NULL) {
      delete ptr_object;
      ptr_object = NULL;
    }
  }
};

/**
 * Class used to hold strong reference to reference-counted object.
 */
template <typename X>
struct Ref {
  /**
   * Pointer to target object.
   */
  X* ptr_object;

#ifdef EMSCRIPTEN
  typedef X element_type;
#endif

 public:
  /**
   * Constructor.
   */
  Ref(X* _ptr) : ptr_object(nullptr) { THIS_REF = _ptr; }

  /**
   * Constructor.
   */
  Ref(const Ref<X>& ref) : ptr_object(nullptr) { Set(ref.Ptr()); }

  /**
   * Constructor.
   */
  Ref(WeakRef<X>& ref) : ptr_object(nullptr) { Set(ref.Ptr()); }

  /**
   * Constructor.
   */
  Ref() { ptr_object = NULL; }

  /**
   * Destructor.
   */
  ~Ref() { Unset(); }

#ifndef __MQL__
  template <typename R>
  operator Ref<R>() {
    return Ref<R>(ptr_object);
  }
#endif

  /**
   * Returns pointer to target object.
   */
  X* Ptr() const { return ptr_object; }

#ifdef EMSCRIPTEN
  X* get() const { return ptr_object; }
#endif

  /**
   * Checks whether any object is referenced.
   */
  bool IsSet() { return ptr_object != NULL; }

  /**
   * Unbinds holding reference.
   */
  void Unset() {
    if (ptr_object != NULL) {
#ifdef __MQL__
      if (CheckPointer(ptr_object) == POINTER_INVALID) {
        // Double check the pointer for invalid references. Can happen in rare circumstances.
        ptr_object = NULL;
        return;
      }
#endif
      if (PTR_ATTRIB(ptr_object, ptr_ref_counter) == NULL) {
        // Object is not reference counted. Maybe a stack-based one?
        return;
      }
      // Dropping strong reference.
      if (!--PTR_ATTRIB2(ptr_object, ptr_ref_counter, num_strong_refs)) {
#ifdef __debug_ref__
        Print(ptr_object.ptr_ref_counter.Debug());
#endif

        // No more strong references.
        if (!PTR_ATTRIB2(ptr_object, ptr_ref_counter, num_weak_refs)) {
#ifdef __MQL__
          if (CheckPointer(PTR_ATTRIB(ptr_object, ptr_ref_counter)) == POINTER_INVALID) {
            // Serious problem.
#ifndef __MQL4__
            // Bug: Avoid calling in MQL4 due to 'global initialization failed' error.
            DebugBreak();
#endif
            return;
          }
#endif

          // Also no more weak references.
          delete PTR_ATTRIB(ptr_object, ptr_ref_counter);
          PTR_ATTRIB(ptr_object, ptr_ref_counter) = NULL;
        } else {
          // Object becomes deleted, but there are some weak references.
          PTR_ATTRIB(PTR_ATTRIB(ptr_object, ptr_ref_counter), deleted) = true;
        }

        // Avoiding delete loop for cyclic references.
        X* ptr_to_delete = ptr_object;

#ifdef __MQL__
        if (CheckPointer(ptr_to_delete) == POINTER_INVALID) {
          // Serious problem.
#ifndef __MQL4__
          // Bug: Avoid calling in MQL4 due to 'global initialization failed' error.
          DebugBreak();
#endif
          return;
        }
#endif

        // Avoiding double deletion in Dynamic's destructor.
        PTR_ATTRIB(ptr_object, ptr_ref_counter) = NULL;
        ptr_object = NULL;

#ifdef __debug__
        Print("Refs: Deleting object ", ptr_to_delete);
#endif

        delete ptr_to_delete;
      }

      ptr_object = NULL;
    }
  }

  /**
   * Makes a strong reference to the given object.
   */
  X* operator=(X* _ptr) { return Set(_ptr); }
  /**
   * Makes a strong reference to the given object.
   */
  X* Set(X* _ptr) {
    if (ptr_object == _ptr) {
      // Assigning the same object.
      return Ptr();
    }

    Unset();

    ptr_object = _ptr;

    if (ptr_object != NULL) {
#ifdef __MQL__
      if (CheckPointer(ptr_object) == POINTER_INVALID) {
        return Ptr();
      }
#endif
      if (PTR_ATTRIB(ptr_object, ptr_ref_counter) == NULL) {
        // Double check the pointer for invalid references. Can happen very rarely.
        return Ptr();
      }
      ++PTR_ATTRIB(PTR_ATTRIB(ptr_object, ptr_ref_counter), num_strong_refs);
#ifdef __debug_ref__
      Print(ptr_object.ptr_ref_counter.Debug());
#endif
    }

    return Ptr();
  }

  /**
   * Makes a strong reference to the given weakly-referenced object.
   */
  X* operator=(const WeakRef<X>& right) { return Set((X*)right.Ptr()); }

  /**
   * Makes a strong reference to the strongly-referenced object.
   */
  X* operator=(const Ref<X>& right) { return Set((X*)right.Ptr()); }

  /**
   * Equality operator.
   */
  bool operator==(const Ref<X>& r) { return ptr_object != NULL && ptr_object == r.ptr_object; }

  /**
   * Returns information about object references counter.
   */
  string ToString() {
    if (ptr_object == nullptr) return "Empty pointer";

    return ptr_object PTR_DEREF ToString();
  }
};

#ifdef __cplusplus
template <class T, class... Types>
Ref<T> make_ref(Types&&... Args) {
  return new T(std::forward<Types>(Args)...);
}
#endif

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
  WeakRef(X* _ptr = NULL) : ptr_ref_counter(nullptr) { THIS_REF = _ptr; }

  /**
   * Constructor.
   */
  WeakRef(const WeakRef<X>& ref) : ptr_ref_counter(nullptr) { THIS_REF = ref.Ptr(); }

  /**
   * Constructor.
   */
  WeakRef(Ref<X>& ref) : ptr_ref_counter(nullptr) { THIS_REF = ref.Ptr(); }

  /**
   * Destructor.
   */
  ~WeakRef() { Unset(); }

  bool ObjectExists() const { return ptr_ref_counter != NULL && !PTR_ATTRIB(ptr_ref_counter, deleted); }

  X* Ptr() const { return ObjectExists() ? (X*)(PTR_ATTRIB(ptr_ref_counter, ptr_object)) : NULL; }

  /**
   * Makes a weak reference to the given object.
   */
  X* operator=(X* _ptr) {
    if (ptr_ref_counter == (_ptr == NULL ? NULL : PTR_ATTRIB(_ptr, ptr_ref_counter))) {
      // Assigning the same object or the same NULL.
      return Ptr();
    }

    Unset();

    if (_ptr == NULL) {
      // Assigning NULL.
      return Ptr();
    }

    if (PTR_ATTRIB2(_ptr, ptr_ref_counter, deleted)) {
      // Assigning already deleted object.
      ptr_ref_counter = NULL;
      return Ptr();
    }

    ptr_ref_counter = PTR_ATTRIB(_ptr, ptr_ref_counter);

#ifdef __debug_ref__
    Print(ptr_ref_counter.Debug());
#endif

    ++PTR_ATTRIB(ptr_ref_counter, num_weak_refs);
    return Ptr();
  }

  /**
   * Makes a weak reference to the given weakly-referenced object.
   */
  X* operator=(WeakRef<X>& right) {
    THIS_REF = right.Ptr();
    return Ptr();
  }

  /**
   * Makes a weak reference to the given weakly-referenced object.
   */
  X* operator=(const WeakRef<X>& right) {
    THIS_REF = right.Ptr();
    return Ptr();
  }

  /**
   * Makes a weak reference to the strongly-referenced object.
   */
  X* operator=(Ref<X>& right) {
    THIS_REF = right.Ptr();
    return Ptr();
  }

  /**
   * Makes a weak reference to the strongly-referenced object.
   */
  X* operator=(const Ref<X>& right) {
    THIS_REF = right.Ptr();
    return Ptr();
  }

  /**
   * Equality operator.
   */
  bool operator==(const WeakRef<X>& r) const { return ptr_ref_counter != NULL && ptr_ref_counter == r.ptr_ref_counter; }

  /**
   * Unbinds holding reference.
   */
  void Unset() {
    if (ptr_ref_counter != NULL) {
      // Dropping weak reference.
      if (!--PTR_ATTRIB(ptr_ref_counter, num_weak_refs)) {
        // No more weak references.
#ifdef __debug_ref__
        Print(ptr_ref_counter.Debug());
#endif

        if (!PTR_ATTRIB(ptr_ref_counter, num_strong_refs)) {
          // There are also no strong references.
          ReferenceCounter* stored_ptr_ref_counter = ptr_ref_counter;
          if (!ptr_ref_counter PTR_DEREF deleted) {
            // It is safe to delete object and reference counter object.
            // Avoiding double deletion in Dynamic's destructor.
            ptr_ref_counter PTR_DEREF ptr_object PTR_DEREF ptr_ref_counter = NULL;

#ifdef __debug_ref__
            Print("Refs: Deleting object ", ptr_ref_counter.ptr_object);
#endif

#ifdef __MQL__
            // We can't check pointer validity in C++ (other than check for NULL).
            if (CheckPointer(ptr_ref_counter PTR_DEREF ptr_object) == POINTER_INVALID) {
              // Serious problem.
#ifndef __MQL4__
              // Bug: Avoid calling in MQL4 due to 'global initialization failed' error.
              DebugBreak();
#endif
              return;
            }
#endif
            delete ptr_ref_counter PTR_DEREF ptr_object;
          }

#ifdef __MQL__
          // We can't check pointer validity in C++ (other than check for NULL).
          if (CheckPointer(stored_ptr_ref_counter) == POINTER_INVALID) {
            // Serious problem.
#ifndef __MQL4__
            // Bug: Avoid calling in MQL4 due to 'global initialization failed' error.
            DebugBreak();
#endif
            return;
          }
#endif

          delete stored_ptr_ref_counter;
        }
      }
    }

    ptr_ref_counter = NULL;
  }
};
