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
#ifndef TASK_ACTION_H
#define TASK_ACTION_H

// Includes.
#include "../Std.h"
#include "../Terminal.define.h"
#include "TaskAction.enum.h"
#include "TaskAction.struct.h"
#include "TaskActionBase.h"

/**
 * TaskAction class.
 */
template <typename TO>
class TaskAction : public TaskActionBase {
 protected:
  // Protected class variables.
  TaskActionEntry entry;  // Action entry.
  TO *obj;                // Object to run the action on.

 public:
  /* Special methods */

  /**
   * Default class constructor.
   */
  TaskAction() {}

  /**
   * Class constructor with an entry as argument.
   */
  TaskAction(TaskActionEntry &_entry, TO *_obj = NULL) : entry(_entry), obj(_obj) {}

  /* Main methods */

  /**
   * Runs a current stored action.
   */
  bool Run() {
    bool _result = entry.IsValid() && entry.HasTriesLeft();
    _result &= obj PTR_DEREF Run(entry);
    if (_result) {
      entry.AddFlags(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_DONE));
      entry.RemoveFlags(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_ACTIVE));
      entry.Set(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_TIME_LAST_RUN), TimeCurrent());
    } else {
      entry.AddFlags(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_INVALID));
      entry.RemoveFlags(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_ACTIVE));
    }
    entry.TriesDec();
    return _result;
  }

  /* Getters */

  /**
   * Gets an entry's flag.
   */
  bool Get(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_FLAG) _flag) const { return entry.Get(_flag); }

  /**
   * Gets an entry's property value.
   */
  template <typename T>
  T Get(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_PROP) _prop) const {
    entry.Get<T>(_prop);
  }

  /**
   * Gets s reference to the object.
   */
  TO *GetObject() { return PTR_TO_REF(obj); }

  /* Setters */

  /**
   * Sets an entry's flag.
   */
  void Set(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_FLAG) _flag, bool _value = true) {
    entry.Set(_flag, _value);
  }

  /**
   * Sets an entry's property value.
   */
  template <typename T>
  void Set(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_PROP) _prop, T _value) {
    entry.Set(_prop, _value);
  }

  /* TaskActionBase methods */

  /**
   * Runs an action.
   */
  bool Run(const TaskActionEntry &_entry) {
    switch (_entry.GetId()) {
      case 0:
        return Run();
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return false;
  }
};

#endif  // TASK_ACTION_H
