//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
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

// Properties.
#property strict

/**
 * Class to deal with objects.
 */
class Object {
  public:
    static Object *list[];

    /**
     * Class constructor.
     */
    void Object() {
      /* @fixme
      uint _size = ArraySize(list);
      ArrayResize(list, _size + 1, 100);
      list[_size] = GetPointer(this);
      */
    }

    /* Virtual methods */

    /**
     * Weight of the object.
     */
    virtual double Weight() = NULL;

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

};

// Initialize static global variables.
//Object *Object::list = { 0 };