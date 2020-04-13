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

// Enums.
// Defines task entry flags.
enum ENUM_TASK_ENTRY_FLAGS {
  TASK_ENTRY_FLAG_NONE = 0,
  TASK_ENTRY_FLAG_IS_ACTIVE = 1,
  TASK_ENTRY_FLAG_IS_DONE = 2,
  TASK_ENTRY_FLAG_IS_EXPIRED = 4,
  TASK_ENTRY_FLAG_IS_FAILED = 8,
  TASK_ENTRY_FLAG_IS_INVALID = 16
};

// Structs.
struct TaskEntry {
  Action *action;         // Action of the task.
  Condition *cond;        // Condition of the task.
  datetime expires;       // Time of expiration.
  datetime last_process;  // Time of the last process.
  datetime last_success;  // Time of the last success.
  unsigned char flags;    // Action flags.
  // Constructor.
  void ActionEntry() {}
  void Init() {
    flags = TASK_ENTRY_FLAG_NONE;
    AddFlags(TASK_ENTRY_FLAG_IS_ACTIVE);
    expires = last_process = last_success = 0;
  }
  // Flag methods.
  bool HasFlag(unsigned char _flag) { return bool(flags & _flag); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= ~_flags; }
  void SetFlag(ENUM_TASK_ENTRY_FLAGS _flag, bool _value) {
    if (_value)
      AddFlags(_flag);
    else
      RemoveFlags(_flag);
  }
  void SetFlags(unsigned char _flags) { flags = _flags; }
  // State methods.
  bool IsActive() { return HasFlag(ACTION_ENTRY_FLAG_IS_ACTIVE); }
  bool IsDone() { return HasFlag(ACTION_ENTRY_FLAG_IS_DONE); }
  bool IsFailed() { return HasFlag(ACTION_ENTRY_FLAG_IS_FAILED); }
  bool IsValid() { return !HasFlag(ACTION_ENTRY_FLAG_IS_INVALID); }
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

  /* Main methods */

  /**
   * Process tasks.
   *
   * @return
   *   Returns true when tasks has been processed.
   */
  bool Process() {
    bool _result = false;
    for (DictStructIterator<short, TaskEntry> iter = tasks.Begin(); iter.IsValid(); ++iter) {
      bool _curr_result = false;
      TaskEntry _entry = iter.Value();
      if (_entry.IsActive()) {
        if (_entry.cond.Test()) {
          _entry.action.Execute();
          if (_entry.action.IsFinished()) {
            _entry.SetFlag(TASK_ENTRY_FLAG_IS_DONE, _entry.action.IsDone());
            _entry.SetFlag(TASK_ENTRY_FLAG_IS_FAILED, _entry.action.IsFailed());
            _entry.SetFlag(TASK_ENTRY_FLAG_IS_INVALID, _entry.action.IsInvalid());
            _entry.RemoveFlags(TASK_ENTRY_FLAG_IS_ACTIVE);
          }
        }
        _entry.last_process = TimeCurrent();
        _result = true;
      }
    }
    return _result;
  }

  /* Other methods */

  /* Getters */

  /**
   * Returns task.
   */
  DictStruct<short, TaskEntry> *GetTasks() { return tasks; }

  /* Setters */
};
#endif  // TASK_MQH