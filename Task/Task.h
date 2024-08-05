//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

// Includes.
#include "../DictStruct.mqh"
#include "../Refs.mqh"
#include "../Terminal.define.h"
#include "Task.enum.h"
#include "Task.struct.h"
#include "TaskAction.h"
#include "TaskCondition.h"
#include "Taskable.h"

class Task : public Taskable<TaskEntry> {
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
  Task(const Task &_task) { tasks = PTR_TO_REF(_task.GetTasks()); }

  /**
   * Class deconstructor.
   */
  ~Task() {}

  /* Main methods */

  /**
   * Adds new task.
   */
  void Add(TaskEntry &_entry) { tasks.Push(_entry); }

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
    return _result;
  }

  /* Task methods */

  /**
   * Checks a condition.
   */
  virtual bool Check(const TaskConditionEntry &_entry) {
    bool _result = true;
    switch (_entry.GetId()) {
      default:
        _result = false;
        break;
    }
    return _result;
  }

  /**
   * Gets a copy of structure.
   */
  virtual TaskEntry Get(const TaskGetterEntry &_entry) {
    TaskEntry _result;
    switch (_entry.GetId()) {
      default:
        break;
    }
    return _result;
  }

  /**
   * Runs an action.
   */
  virtual bool Run(const TaskActionEntry &_entry) {
    bool _result = true;
    switch (_entry.GetId()) {
      default:
        _result = false;
        break;
    }
    return _result;
  }

  /**
   * Sets an entry value.
   */
  virtual bool Set(const TaskSetterEntry &_entry, const TaskEntry &_entry_value) {
    bool _result = true;
    switch (_entry.GetId()) {
      default:
        _result = false;
        break;
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
  const DictStruct<short, TaskEntry> *GetTasks() const { return &tasks; }

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
      if (!_value) {
        if (_entry.HasFlag(_flag)) {
          _entry.SetFlag(_flag, _value);
          _counter++;
        }
      } else {
        if (!_entry.HasFlag(_flag)) {
          _entry.SetFlag(_flag, _value);
          _counter++;
        }
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
  bool CheckCondition(ENUM_TASK_CONDITION _cond, ARRAY_REF(DataParamEntry, _args)) {
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
        return false;
    }
  }
  bool CheckCondition(ENUM_TASK_CONDITION _cond) {
    ARRAY(DataParamEntry, _args);
    return Task::CheckCondition(_cond, _args);
  }

  /**
   * Execute Task action.
   *
   * @param ENUM_TASK_ACTION _action
   *   Task action to execute.
   * @return
   *   Returns true when the action has been executed successfully.
   */
  bool ExecuteAction(ENUM_TASK_ACTION _action, ARRAY_REF(DataParamEntry, _args)) {
    bool _result = true;
    switch (_action) {
      case TASK_ACTION_PROCESS:
        // Process tasks.
        return Process();
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        return false;
    }
    return _result;
  }
  bool ExecuteAction(ENUM_TASK_ACTION _action) {
    ARRAY(DataParamEntry, _args);
    return Task::ExecuteAction(_action, _args);
  }

  /* Other methods */
};

#ifdef EMSCRIPTEN
#include <emscripten.h>
#include <emscripten/bind.h>

EMSCRIPTEN_BINDINGS(Task) {
  emscripten::class_<Task>("Task").smart_ptr<Ref<Task>>("Ref<Task>").constructor(emscripten::optional_override([]() {
    return Ref<Task>(new Task());
  }))
      //.function("Add", optional_override([](Task &self, Ref<Task> task) { self.Add(task.Ptr()); }))
      ;
}

#endif
