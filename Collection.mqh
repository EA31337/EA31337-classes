//+------------------------------------------------------------------+
//|                                                EA31337 framework |
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

// Properties.
#property strict

// Includes.
#include "Object.mqh"

/**
 * Class to deal with collection of objects.
 */
class Collection {

  protected:

    // Variables.
    string name;
    void *data[];

  public:

    /**
     * Class constructor.
     */
    void Collection() { }
    void Collection(string _name) : name(_name) { }
    void ~Collection() {
      for (int i = 0; i < ArraySize(data); i++) {
        if (CheckPointer(data[i]) == POINTER_DYNAMIC) {
          Object::Delete(data[i]);
        }
      }
    }

    /**
     * Add the object into the collection.
     */
    void *Add(void *_object) {
      uint _size = ArraySize(data);
      ArrayResize(data, _size + 1, 100);
      data[_size] = _object;
      return _object;
    }

    /**
     * Returns pointer to the collection item.
     */
    void *Get(void *_object) {
      if (CheckPointer(_object) != POINTER_INVALID && CheckPointer(_object) == POINTER_DYNAMIC) {
        for (int i = 0; i < ArraySize(data); i++) {
          if (CheckPointer(data[i]) == POINTER_DYNAMIC && GetPointer(_object) == GetPointer(data[i])) {
            return data[i];
          }
        }
        return Add(_object);
      }
      return NULL;
    }

    /**
     * Fetch object textual data by calling each ToString() method.
     */
    string ToString(double _min_weight = 0, string _dlm = ";") {
      string _out = name + ": ";
      for (int i = 0; i < ArraySize(data); i++) {
        // @fixme: incorrect casting of pointers (GH-41).
        if (Object::IsValid((Object *) data[i])) {
          if (((Object *) data[i]).Weight() >= _min_weight) {
            _out += ((Object *) data[i]).ToString() + _dlm;
          }
        }
      }
      return _out;
    }

};
