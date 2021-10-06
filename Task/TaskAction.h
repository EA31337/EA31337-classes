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
 * Provides integration with actions.
 */

// Prevents processing this includes file for the second time.
#ifndef TASK_ACTION_MQH
#define TASK_ACTION_MQH

// Includes.
#include "TaskAction.enum.h"
#include "TaskAction.struct.h"

/**
 * TaskAction class.
 */
template <typename TO>
class TaskAction : TaskActionBase {
 public:
  // Class variables.
  TaskActionEntry entry;  // Action entry.
  TO obj;                 // Object to run the action on.

  /* Special methods */

  /**
   * Class constructor.
   */
  TaskAction() {}
  TaskAction(TaskActionEntry &_entry) : entry(_entry) {}

  /* Main methods */

  /**
   * Runs an action.
   */
  bool Run() {
    bool _result = entry.IsValid() && entry.HasTriesLeft();
    _result &= obj.Run(entry);
    if (_result) {
      entry.TriesDec();
      entry.AddFlags(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_DONE));
      entry.RemoveFlags(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_ACTIVE));
      entry.Set(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_TIME_LAST_RUN), TimeCurrent());
    } else {
      entry.TriesDec();
      if (!entry.HasTriesLeft()) {
        entry.AddFlags(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_INVALID));
        entry.RemoveFlags(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_ACTIVE));
      }
    }
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
   * Gets an reference to the object.
   */
  TO *GetObject() { return GetPointer(obj); }

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
};

#endif  // TASK_ACTION_MQH
