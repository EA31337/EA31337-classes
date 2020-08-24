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

// Actions for action class.
enum ENUM_TASK_ACTION {
  TASK_ACTION_NONE = 0,  // Does nothing.
  TASK_ACTION_PROCESS,   // Process tasks.
  FINAL_TASK_ACTION_ENTRY
};

// Action conditions.
enum ENUM_TASK_CONDITION {
  TASK_COND_NONE = 0,     // Empty condition.
  TASK_COND_IS_ACTIVE,    // Is active.
  TASK_COND_IS_DONE,      // Is done.
  TASK_COND_IS_FAILED,    // Is failed.
  TASK_COND_IS_FINISHED,  // Is finished.
  TASK_COND_IS_INVALID,   // Is invalid.
  FINAL_TASK_CONDITION_ENTRY
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
  Ref<Log> logger;

 public:
  // Class variables.
  DictStruct<short, TaskEntry> tasks;

  /* Special methods */

  /**
   * Class constructor.
   */
  Task() {}
  Task(TaskEntry &_entry) { Add(_entry); }

  /**
   * Class copy constructor.
   */
  Task(Task &_task) { tasks = _task.GetTasks(); }

  /**
   * Class deconstructor.
   */
  ~Task() {}

  Log *Logger() { return logger.Ptr(); }

  /* Main methods */

  /**
   * Adds new task.
   */
  void Add(TaskEntry &_entry) { tasks.Push(_entry); }

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

  /* State methods */

  /**
   * Check if task is active.
   */
  bool IsActive() {
    // The whole task is active when at least one task is active.
    return GetFlagCount(TASK_ENTRY_FLAG_IS_ACTIVE) > 0;
  }

  /**
   * Check if task is done.
   */
  bool IsDone() {
    // The whole task is done when all tasks has been executed successfully.
    return GetFlagCount(TASK_ENTRY_FLAG_IS_DONE) == tasks.Size();
  }

  /**
   * Check if task is failed.
   */
  bool IsFailed() {
    // The whole task is failed when at least one task failed.
    return GetFlagCount(TASK_ENTRY_FLAG_IS_FAILED) > 0;
  }

  /**
   * Check if task is finished.
   */
  bool IsFinished() {
    // The whole task is finished when there are no more active tasks.
    return GetFlagCount(TASK_ENTRY_FLAG_IS_ACTIVE) == 0;
  }

  /**
   * Check if task is invalid.
   */
  bool IsInvalid() {
    // The whole task is invalid when at least one task is invalid.
    return GetFlagCount(TASK_ENTRY_FLAG_IS_INVALID) > 0;
  }

  /* Getters */

  /**
   * Returns tasks.
   */
  DictStruct<short, TaskEntry> *GetTasks() { return &tasks; }

  /**
   * Count entry flags.
   */
  unsigned int GetFlagCount(ENUM_TASK_ENTRY_FLAGS _flag) {
    unsigned int _counter = 0;
    for (DictStructIterator<short, TaskEntry> iter = tasks.Begin(); iter.IsValid(); ++iter) {
      TaskEntry _entry = iter.Value();
      if (_entry.HasFlag(_flag)) {
        _counter++;
      }
    }
    return _counter;
  }

  /* Setters */

  /**
   * Sets entry flags.
   */
  bool SetFlags(ENUM_TASK_ENTRY_FLAGS _flag, bool _value = true) {
    unsigned int _counter = 0;
    for (DictStructIterator<short, TaskEntry> iter = tasks.Begin(); iter.IsValid(); ++iter) {
      TaskEntry _entry = iter.Value();
      switch (_value) {
        case false:
          if (_entry.HasFlag(_flag)) {
            _entry.SetFlag(_flag, _value);
            _counter++;
          }
          break;
        case true:
          if (!_entry.HasFlag(_flag)) {
            _entry.SetFlag(_flag, _value);
            _counter++;
          }
          break;
      }
    }
    return _counter > 0;
  }

  /* Conditions and actions */

  /**
   * Checks for Task condition.
   *
   * @param ENUM_TASK_CONDITION _cond
   *   Task condition.
   * @return
   *   Returns true when the condition is met.
   */
  bool Condition(ENUM_TASK_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      case TASK_COND_IS_ACTIVE:
        // Is active;
        return IsActive();
      case TASK_COND_IS_DONE:
        // Is done.
        return IsDone();
      case TASK_COND_IS_FAILED:
        // Is failed.
        return IsFailed();
      case TASK_COND_IS_FINISHED:
        // Is finished.
        return IsFinished();
      case TASK_COND_IS_INVALID:
        // Is invalid.
        return IsInvalid();
      default:
        Logger().Error(StringFormat("Invalid Task condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool Condition(ENUM_TASK_CONDITION _cond) {
    MqlParam _args[] = {};
    return Task::Condition(_cond, _args);
  }

  /**
   * Execute Task action.
   *
   * @param ENUM_TASK_ACTION _action
   *   Task action to execute.
   * @return
   *   Returns true when the action has been executed successfully.
   */
  bool ExecuteAction(ENUM_TASK_ACTION _action, MqlParam &_args[]) {
    bool _result = true;
    switch (_action) {
      case TASK_ACTION_PROCESS:
        // Process tasks.
        return Process();
      default:
        Logger().Error(StringFormat("Invalid Task action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
    }
    return _result;
  }
  bool ExecuteAction(ENUM_TASK_ACTION _action) {
    MqlParam _args[] = {};
    return Task::ExecuteAction(_action, _args);
  }

  /* Other methods */
};
#endif  // TASK_MQH
