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
#ifndef TASK_GETTER_H
#define TASK_GETTER_H

// Includes.
//#include "TaskGetter.enum.h"
#include "../Terminal.define.h"
#include "TaskGetter.struct.h"
#include "TaskGetterBase.h"

/**
 * TaskGetter class.
 */
template <typename TS>
class TaskGetter : public TaskGetterBase<TS> {
 protected:
  // Protected class variables.
  TaskGetterEntry entry;  // Getter entry.

 public:
  /* Special methods */

  /**
   * Default class constructor.
   */
  TaskGetter() {}

  /**
   * Class constructor with an entry as argument.
   */
  TaskGetter(TaskGetterEntry &_entry) : entry(_entry) {}

  /* Main methods */

  /**
   * Runs a current stored action.
   */
  TS Get() {
    TS _result = Get(entry);
    entry.Set(STRUCT_ENUM(TaskGetterEntry, TASK_GETTER_ENTRY_TIME_LAST_GET), TimeCurrent());
    entry.TriesDec();
    return _result;
  }

  /* Getters */

  /**
   * Gets an entry's flag.
   */
  bool Get(STRUCT_ENUM(TaskGetterEntry, ENUM_TASK_GETTER_ENTRY_FLAG) _flag) const { return entry.Get(_flag); }

  /**
   * Gets an entry's property value.
   */
  template <typename T>
  T Get(STRUCT_ENUM(TaskGetterEntry, ENUM_TASK_GETTER_ENTRY_PROP) _prop) const {
    entry.Get<T>(_prop);
  }

  /* Setters */

  /**
   * Sets an entry's flag.
   */
  void Set(STRUCT_ENUM(TaskGetterEntry, ENUM_TASK_GETTER_ENTRY_FLAG) _flag, bool _value = true) {
    entry.Set(_flag, _value);
  }

  /**
   * Sets an entry's property value.
   */
  template <typename T>
  void Set(STRUCT_ENUM(TaskGetterEntry, ENUM_TASK_GETTER_ENTRY_PROP) _prop, T _value) {
    entry.Set(_prop, _value);
  }

  /* TaskGetterBase methods */

  /**
   * Gets a copy of structure.
   */
  TS Get(const TaskGetterEntry &_entry) {
    TS _result;
    switch (_entry.GetId()) {
      case 0:
        _result = Get();
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _result;
  }
};

#endif  // TASK_GETTER_H
