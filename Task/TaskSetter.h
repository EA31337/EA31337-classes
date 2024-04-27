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
 * Provides integration with task's actions.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef TASK_SETTER_H
#define TASK_SETTER_H

// Includes.
//#include "TaskSetter.enum.h"
#include "TaskSetter.struct.h"
#include "TaskSetterBase.h"

/**
 * TaskSetter class.
 */
template <typename TO, typename TS>
class TaskSetter : protected TaskSetterBase<TS> {
 protected:
  // Protected class variables.
  TaskSetterEntry entry;  // Setter entry.
  TO obj;                 // Object to run the action on.

 public:
  /* Special methods */

  /**
   * Default class constructor.
   */
  TaskSetter() {}

  /**
   * Class constructor with an entry as argument.
   */
  TaskSetter(TaskSetterEntry &_entry) : entry(_entry) {}

  /* Main methods */

  /**
   * Runs a current stored action.
   */
  bool Set(const TS &_entry_value) {
    bool _result = obj.Set(entry, _entry_value);
    entry.Set(STRUCT_ENUM(TaskSetterEntry, TASK_SETTER_ENTRY_TIME_LAST_GET), TimeCurrent());
    entry.TriesDec();
    return _result;
  }

  /* Setters */

  /**
   * Gets an entry's flag.
   */
  bool Get(STRUCT_ENUM(TaskSetterEntry, ENUM_TASK_SETTER_ENTRY_FLAG) _flag) const { return entry.Get(_flag); }

  /**
   * Gets an entry's property value.
   */
  template <typename T>
  T Get(STRUCT_ENUM(TaskSetterEntry, ENUM_TASK_SETTER_ENTRY_PROP) _prop) const {
    entry.Get<T>(_prop);
  }

  /**
   * Gets a reference to the object.
   */
  TO *GetObject() { return GetPointer(obj); }

  /* Setters */

  /**
   * Sets an entry's flag.
   */
  void Set(STRUCT_ENUM(TaskSetterEntry, ENUM_TASK_SETTER_ENTRY_FLAG) _flag, bool _value = true) {
    entry.Set(_flag, _value);
  }

  /**
   * Sets an entry's property value.
   */
  template <typename T>
  void Set(STRUCT_ENUM(TaskSetterEntry, ENUM_TASK_SETTER_ENTRY_PROP) _prop, T _value) {
    entry.Set(_prop, _value);
  }

  /* TaskSetterBase methods */

  /**
   * Sets an entry value.
   */
  bool Set(const TaskSetterEntry &_entry, const TS &_entry_value) {
    bool _result = false;
    switch (_entry.GetId()) {
      case 0:
        _result = Set(_entry_value);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _result;
  }
};

#endif  // TASK_SETTER_H
