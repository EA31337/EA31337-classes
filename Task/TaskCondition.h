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
 * Provides integration with task's conditions.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef TASK_CONDITION_H
#define TASK_CONDITION_H

// Includes.
#include "../Std.h"
#include "../Terminal.define.h"
#include "TaskCondition.enum.h"
#include "TaskCondition.struct.h"
#include "TaskConditionBase.h"

/**
 * TaskCondition class.
 */
template <typename TO>
class TaskCondition : public TaskConditionBase {
 public:
 protected:
  // Protected class variables.
  TaskConditionEntry entry;  // Condition entry.
  TO *obj;                   // Object to run the action on.

 public:
  /* Special methods */

  /**
   * Default class constructor.
   */
  TaskCondition() {}

  /**
   * Class constructor with an entry as argument.
   */
  TaskCondition(TaskConditionEntry &_entry, TO *_obj = NULL) : entry(_entry), obj(_obj) {}

  /* Main methods */

  /**
   * Checks a current stored condition.
   */
  bool Check() {
    bool _result = entry.IsValid() && entry.HasTriesLeft();
    _result &= obj PTR_DEREF Check(entry);
    if (_result) {
      entry.RemoveFlags(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_FLAG_IS_ACTIVE));
      entry.Set(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_TIME_LAST_CHECK), TimeCurrent());
      entry.Set(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_TIME_LAST_SUCCESS), TimeCurrent());
    } else {
      entry.AddFlags(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_FLAG_IS_INVALID));
      entry.RemoveFlags(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_FLAG_IS_ACTIVE));
      entry.Set(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_TIME_LAST_CHECK), TimeCurrent());
    }
    entry.TriesDec();
    return _result;
  }

  /* Getters */

  /**
   * Gets an entry's flag.
   */
  bool Get(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_FLAGS) _flag) const { return entry.Get(_flag); }

  /**
   * Gets an entry's property value.
   */
  template <typename T>
  T Get(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_PROP) _prop) const {
    entry.Get<T>(_prop);
  }

  /**
   * Gets a reference to the object.
   */
  TO *GetObject() { return PTR_TO_REF(obj); }

  /* Setters */

  /**
   * Sets an entry's flag.
   */
  void Set(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_FLAGS) _flag, bool _value = true) {
    entry.Set(_flag, _value);
  }

  /**
   * Sets an entry's property value.
   */
  template <typename T>
  void Set(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_PROP) _prop, T _value) {
    entry.Set(_prop, _value);
  }

  /* TaskConditionBase methods */

  /**
   * Checks a condition.
   */
  bool Check(const TaskConditionEntry &_entry) {
    switch (_entry.GetId()) {
      case 0:
        return Check();
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return false;
  }
};
#endif  // TASK_CONDITION_H
