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
 * Implements TickManager class.
 */

// Includes.
#include "../BufferStruct.mqh"
#include "TickManager.h"
//#include "TickManager.struct.h"

/**
 * Class to store and manage tick data.
 */
class TickManager : public BufferStruct<MqlTick> {
 protected:
  /* Protected methods */

  /**
   * Init code (called on constructor).
   */
  void Init() {
    AddFlags(DICT_FLAG_FILL_HOLES_UNSORTED);
    SetOverflowListener(TickManagerOverflowListener, 10);
  }

 public:
  /**
   * Default class constructor.
   */
  TickManager() { Init(); }

  /**
   * Class constructor with parameters.
   */
  // TickManager(TickManagerParams &_params) : params(_params) { Init(); }

  /* Getters */

  /**
   * Gets a property value.
   */
  // template <typename T>
  // T Get(STRUCT_ENUM(TickManagerParams, ENUM_TSM_PARAMS_PROP) _prop)
  // { return params.Get<T>(_prop); }

  /* Setters */

  /**
   * Sets a property value.
   */
  // template <typename T>
  // void Set(STRUCT_ENUM(TickManagerParams, ENUM_TSM_PARAMS_PROP) _prop, T _value)
  // { params.Set<T>(_prop, _value); }

  /* Other methods */

  /**
   * Function should return true if resize can be made, or false to overwrite current slot.
   */
  static bool TickManagerOverflowListener(ENUM_DICT_OVERFLOW_REASON _reason, int _size, int _num_conflicts) {
    switch (_reason) {
      case DICT_OVERFLOW_REASON_FULL:
        // We allow resize if dictionary size is less than 86400 slots.
        return _size < 86400;
      case DICT_OVERFLOW_REASON_TOO_MANY_CONFLICTS:
      default:
        // When there is too many conflicts, we just reject doing resize, so first conflicting slot will be reused.
        break;
    }
    return false;
  }
};
