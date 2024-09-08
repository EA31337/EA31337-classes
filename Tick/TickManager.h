//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
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
 * Implements TickManager class.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Storage/Dict/Buffer/BufferStruct.h"
#include "Tick.struct.h"
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
  void Init() { SetOverflowListener(BufferStructOverflowListener, 10); }

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
};
