//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
 * Provides integration with tasks (manages conditions and actions).
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef TASK_OBJECT_H
#define TASK_OBJECT_H

// Includes.
#include "Task.h"

template <typename TA, typename TC>
class TaskObject : public Task {
 protected:
  TA *obja;
  TC *objc;

 public:
  /* Special methods */

  /**
   * Default class constructor.
   */
  TaskObject() {}

  /**
   * Class constructor with task entry as argument.
   */
  TaskObject(TaskEntry &_tentry, TA *_obja = NULL, TC *_objc = NULL) : obja(_obja), objc(_objc), Task(_tentry) {}

  /**
   * Class deconstructor.
   */
  ~TaskObject() {}

  /* Virtual methods */

  /**
   * Process tasks.
   *
   * @return
   *   Returns true when tasks has been processed.
   */
  virtual bool Process() {
    bool _result = true;
    for (DictStructIterator<short, TaskEntry> iter = tasks.Begin(); iter.IsValid(); ++iter) {
      TaskEntry _entry = iter.Value();
      _result &= Process(_entry);
    }
    return _result;
  }

  /**
   * Process task entry.
   *
   * @return
   *   Returns true when tasks has been processed.
   */
  virtual bool Process(TaskEntry &_entry) {
    bool _result = false;
    if (_entry.IsActive()) {
      if (Object::IsValid(objc) && objc.Check(_entry.GetCondition()) && Object::IsValid(obja)) {
        obja.Run(_entry.GetAction());
        _entry.Set(STRUCT_ENUM(TaskEntry, TASK_ENTRY_PROP_LAST_PROCESS), TimeCurrent());
        if (_entry.IsDone()) {
          _entry.SetFlag(TASK_ENTRY_FLAG_IS_DONE,
                         _entry.Get(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_DONE)));
          _entry.SetFlag(TASK_ENTRY_FLAG_IS_FAILED,
                         _entry.Get(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_FAILED)));
          _entry.SetFlag(TASK_ENTRY_FLAG_IS_INVALID,
                         _entry.Get(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_INVALID)));
          _entry.RemoveFlags(TASK_ENTRY_FLAG_IS_ACTIVE);
        }
        _result = true;
      }
    }
    return _result;
  }

  /* Other methods */
};
#endif  // TASK_OBJECT_H
