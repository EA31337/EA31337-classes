//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Provides integration with tasks (manages conditions and actions).
 */

// Prevents processing this includes file for the second time.
#ifndef TASK_MQH
#define TASK_MQH

// Forward class declaration.
class Task;

// Includes.
#include "Action.mqh"
#include "Condition.mqh"

// Structs.
struct TaskEntry {
  Action *action;        // Action of the task.
  Condition *cond;       // Condition of the task.
  datetime last_process; // Time of the last process.
  datetime last_success; // Time of the last success.
};

class Task {
 protected:
  // Class variables.
  Log *logger;

 public:
  // Class variables.
  DictStruct<short, TaskEntry> *tasks;

  /* Special methods */

  /**
   * Class constructor.
   */
  Task() { Init(); }
  Task(TaskEntry &_entry) {
    Init();
    tasks.Push(_entry);
  }

  /**
   * Class copy constructor.
   */
  Task(Task &_task) {
    Init();
    tasks = _task.GetTasks();
  }

  /**
   * Class deconstructor.
   */
  ~Task() {}

  /**
   * Initialize class variables.
   */
  void Init() { tasks = new DictStruct<short, TaskEntry>(); }

  /* Other methods */

  /* Getters */

  /**
   * Returns task.
   */
  DictStruct<short, TaskEntry> *GetTasks() { return tasks; }

  /* Setters */

};
#endif  // TASK_MQH