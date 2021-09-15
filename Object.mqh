//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
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
#ifndef OBJECT_MQH
#define OBJECT_MQH

// Includes.
#include "Refs.mqh"
#include "String.mqh"

#ifndef __MQLBUILD__
// Used for checking the type of the object pointer.
// @docs
// - https://docs.mql4.com/constants/namedconstants/enum_pointer_type
// - https://www.mql5.com/en/docs/constants/namedconstants/enum_pointer_type
enum ENUM_POINTER_TYPE {
  POINTER_INVALID,   // Incorrect pointer.
  POINTER_DYNAMIC,   // Pointer of the object created by the new() operator.
  POINTER_AUTOMATIC  // Pointer of any objects created automatically (not using new()).
};
#endif

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
    Object()
      : id(rand()), obj(THIS_PTR)
    {
    }
    Object(void *_obj, long _id = __LINE__) {
      obj = _obj;
      id = _id;
    }

    /* Getters */

    /**
     * Get ID of the object.
     */
    virtual long GetId() {
      return id;
    }

    /* Setters */

    /**
     * Set ID of the object.
     */
    void SetId(long _id) {
      id = _id;
    }

    /**
     * Get the object handler.
     */
    static void *Get(void *_obj) {
      return Object::IsValid(_obj) ? _obj : NULL;
    }
    void *Get() {
      return IsValid(obj) ? obj : NULL;
    }

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
    bool IsValid() {
      return IsValid(obj);
    }

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
    bool IsDynamic() {
      return IsDynamic(obj);
    }

    /**
     * Returns text representation of the object.
     */
    virtual const string ToString() {
      return StringFormat("[Object #%04x]", GetPointer(this));
    }

    /**
     * Returns text representation of the object.
     */
    virtual const string ToJSON() {
      return StringFormat("{ \"type\": \"%s\" }", typename(this));
    }

    /**
     * Safely delete the object.
     */
    static void Delete(void *_obj) {
    #ifdef __MQL__
      if (CheckPointer(_obj) == POINTER_DYNAMIC) {
    #else
      if (true) {
    #endif
        delete _obj;
      }
    }
    void Delete() {
      Delete(obj);
    }

    /* Virtual methods */

    /**
     * Weight of the object.
     */
    virtual double GetWeight() {
      return 0;
    };

};

// Initialize static global variables.
//Object *Object::list = { 0 };
#endif // OBJECT_MQH
