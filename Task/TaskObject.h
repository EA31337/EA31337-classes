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
class TaskObject : protected Task {
 protected:
  TaskAction<TA> action;
  TaskCondition<TC> condition;

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  TaskObject(TaskActionEntry &_aentry, TaskConditionEntry &_centry) : action(_aentry), condition(_centry) {}

  /**
   * Class deconstructor.
   */
  ~TaskObject() {}

  /* Main methods */

  /**
   * Process task entry.
   *
   * @return
   *   Returns true when tasks has been processed.
   */
  static bool Process(TaskEntry &_entry) {
    bool _result = false;
    // @todo
    return _result;
  }

  /* Other methods */
};
#endif  // TASK_OBJECT_H
