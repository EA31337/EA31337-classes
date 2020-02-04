//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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
#include "String.mqh"

#ifndef __MQLBUILD__
// Used for checking the type of the object pointer.
// @docs
// - https://docs.mql4.com/constants/namedconstants/enum_pointer_type
// - https://www.mql5.com/en/docs/constants/namedconstants/enum_pointer_type
enum ENUM_POINTER_TYPE {
  POINTER_INVALID,  // Incorrect pointer.
  POINTER_DYNAMIC,  // Pointer of the object created by the new() operator.
  POINTER_AUTOMATIC // Pointer of any objects created automatically (not using new()).
}
#endif

/**
 * Class to deal with objects.
 */
class Object {

  protected:

    void *obj;
    long id;

  public:

    /**
     * Class constructor.
     */
    Object()
      : id(rand())
    {
    }
    Object(void *_obj, long _id) {
      obj = _obj;
      id = _id;
    }

    /* Getters */

    /**
     * Get ID of the object.
     */
    long GetId() {
      return this.id;
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
      return IsValid(this.obj) ? this.obj : NULL;
    }

    /**
     * Check whether pointer is valid.
     * @docs: https://docs.mql4.com/constants/namedconstants/enum_pointer_type
     */
    static bool IsValid(void *_obj) {
      return CheckPointer(_obj) != POINTER_INVALID;
    }
    bool IsValid() {
      return IsValid(this.obj);
    }

    /**
     * Check whether pointer is dynamic.
     * @docs: https://docs.mql4.com/constants/namedconstants/enum_pointer_type
     */
    static bool IsDynamic(void *_obj) {
      return CheckPointer(_obj) == POINTER_DYNAMIC;
    }
    bool IsDynamic() {
      return IsDynamic(this.obj);
    }

    /**
     * Returns text representation of the object.
     */
    virtual string ToString() {
      return StringFormat("[Object #%04x]", GetPointer(this));
    }

    /**
     * Safely delete the object.
     */
    static void Delete(void *_obj) {
      if (CheckPointer(_obj) == POINTER_DYNAMIC) {
        delete _obj;
      }
    }
    void Delete() {
      Delete(this.obj);
    }

    /* Virtual methods */

    /**
     * Weight of the object.
     */
    virtual double GetWeight() = NULL;

};

// Initialize static global variables.
//Object *Object::list = { 0 };
#endif // OBJECT_MQH
