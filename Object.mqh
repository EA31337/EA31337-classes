//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
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

// Prevents processing this includes file for the second time.
#ifndef OBJECT_MQH
#define OBJECT_MQH

#define nullptr NULL

// Includes.
#include "Object.enum.h"
#include "Object.extern.h"
#include "Refs.mqh"
#include "Refs.struct.h"
#include "String.mqh"

/**
 * Class to deal with objects.
 */
class Object : public Dynamic {

 protected:

  void *obj;
  long id;

 public:

  /**
   * Class constructor.
   */
  Object() : obj(THIS_PTR), id(rand()) {}
  Object(void *_obj, long _id = __LINE__) {
    obj = _obj;
    id = _id;
  }

  /* Getters */

  /**
   * Get ID of the object.
   */
  virtual long GetId() { return id; }

  /* Setters */

  /**
   * Set ID of the object.
   */
  void SetId(long _id) { id = _id; }

  /**
   * Get the object handler.
   */
  static void *Get(void *_obj) { return Object::IsValid(_obj) ? _obj : NULL; }
  void *Get() { return IsValid(obj) ? obj : NULL; }

  /**
   * Check whether pointer is valid.
   * @docs: https://docs.mql4.com/constants/namedconstants/enum_pointer_type
   */
  static bool IsValid(void *_obj) {
#ifdef __MQL__
    return CheckPointer(_obj) != POINTER_INVALID;
#else
    return _obj != nullptr;
#endif
  }
  bool IsValid() { return IsValid(obj); }

  /**
   * Check whether pointer is dynamic.
   * @docs: https://docs.mql4.com/constants/namedconstants/enum_pointer_type
   */
  static bool IsDynamic(void *_obj) {
#ifdef __MQL__
    return CheckPointer(_obj) == POINTER_DYNAMIC;
#else
    // In C++ we can't check it.
    // @fixme We should fire a warning here so user won't use this method anymore.
    return true;
#endif
  }
  bool IsDynamic() { return IsDynamic(obj); }

  /**
   * Returns text representation of the object.
   */
  virtual string const ToString() { return StringFormat("[Object #%04x]", THIS_PTR); }

  /**
   * Returns text representation of the object.
   */
  virtual string ToJSON() { return StringFormat("{ \"type\": \"%s\" }", typename(this)); }

  /**
   * Safely delete the object.
   */
  template <typename T>
  static void Delete(T *_obj) {
#ifdef __cplusplus
    static_assert(!std::is_same<decltype(_obj), void *>::value,
                  "Please avoid deleting void* pointers as no destructor will be called!");
#endif
#ifdef __MQL__
    if (CheckPointer(_obj) == POINTER_DYNAMIC) {
#else
    if (true) {
#endif
      delete _obj;
    }
  }

  /* Virtual methods */

  /**
   * Weight of the object.
   */
  virtual double GetWeight() { return 0; };
};

// Initialize static global variables.
// Object *Object::list = { 0 };
#endif  // OBJECT_MQH
