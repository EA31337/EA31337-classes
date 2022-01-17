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
 * Provides task management.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef TASK_MANAGER_H
#define TASK_MANAGER_H

// Includes.
#include "../DictObject.mqh"
#include "TaskObject.h"

class TaskManager {
 protected:
  DictObject<int, Task> tasks;
  // DictObject<int, TaskObject<Task, Task>> tasks;
  // DictObject<int, TaskObject<Taskable, Taskable>> tasks; // @todo: Which one?

  /* Protected methods */

  /**
   * Init code (called on constructor).
   */
  void Init() {}

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  TaskManager() { Init(); }

  /**
   * Class deconstructor.
   */
  ~TaskManager() {}

  /* Adder methods */

  /**
   * Adds new task.
   */
  bool Add(Task &_task) { return tasks.Push(_task); }

  /**
   * Adds new object task.
   */
  template <typename TA, typename TC>
  bool Add(TaskObject<TA, TC> &_task_obj) {
    return tasks.Push(_task_obj);
  }

  /* Processing methods */

  /**
   * Process tasks.
   */
  bool Process() {
    bool _result = true;
    for (DictObjectIterator<int, Task> _iter = tasks.Begin(); _iter.IsValid(); ++_iter) {
      TaskObject<Task, Task> *_task = _iter.Value();
      _result &= _task.Process();
    }
    return _result;
  }
};

#endif  // TASK_MANAGER_H
