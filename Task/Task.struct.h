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
 * Includes Task's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Platform/Terminal.define.h"
#include "Task.enum.h"
#include "TaskAction.struct.h"
#include "TaskCondition.struct.h"

struct TaskEntry {
 public:
  /* Enumerations */
  enum ENUM_TASK_ENTRY_PROP {
    TASK_ENTRY_PROP_NONE = 0,      // None
    TASK_ENTRY_PROP_EXPIRES,       // Expires
    TASK_ENTRY_PROP_LAST_PROCESS,  // Last process
    TASK_ENTRY_PROP_LAST_SUCCESS,  // Last success
  };

 protected:
  TaskActionEntry action;   // TaskAction of the task.
  TaskConditionEntry cond;  // TaskCondition of the task.
  datetime expires;         // Time of expiration.
  datetime last_process;    // Time of the last process.
  datetime last_success;    // Time of the last success.
  unsigned char flags;      // TaskAction flags.
 protected:
  // Protected methods.
  void Init() {
    flags = TASK_ENTRY_FLAG_NONE;
    SetFlag(TASK_ENTRY_FLAG_IS_ACTIVE, action.IsActive() && cond.IsActive());
    SetFlag(TASK_ENTRY_FLAG_IS_INVALID, action.IsInvalid() || cond.IsInvalid());
    expires = last_process = last_success = 0;
  }

 public:
  // Constructors.
  TaskEntry() { Init(); }
  TaskEntry(const TaskEntry &_entry)
      : action(_entry.action),
        cond(_entry.cond),
        expires(_entry.expires),
        last_process(_entry.last_process),
        last_success(_entry.last_success),
        flags(_entry.flags) {
    Init();
  }
  TaskEntry(const TaskActionEntry &_action, const TaskConditionEntry &_cond) : action(_action), cond(_cond) { Init(); }
  template <typename AE, typename CE>
  TaskEntry(AE _aid, CE _cid) : action(_aid), cond(_cid) {
    Init();
  };
  // Getters.
  template <typename T>
  T Get(ENUM_TASK_ENTRY_PROP _prop) {
    switch (_prop) {
      case TASK_ENTRY_PROP_EXPIRES:  // Expires
        return (T)expires;
      case TASK_ENTRY_PROP_LAST_PROCESS:  // Last process
        return (T)last_process;
      case TASK_ENTRY_PROP_LAST_SUCCESS:  // Last success
        return (T)last_success;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return (T) false;
  };
  bool Get(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_FLAG) _flag) { return action.Get(_flag); };
  template <typename T>
  bool Get(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_PROP) _prop) {
    return action.Get<bool>(_prop);
  };
  // bool Get(ENUM_TASK_ENTRY_FLAGS _flag) { return HasFlag(_flag); }
  TaskActionEntry GetActionEntry() { return action; }
  TaskConditionEntry GetConditionEntry() { return cond; }
  // Setters.
  template <typename T>
  void Set(ENUM_TASK_ENTRY_PROP _prop, T _value) {
    switch (_prop) {
      case TASK_ENTRY_PROP_EXPIRES:  // Expires
        expires = (T)_value;
        break;
      case TASK_ENTRY_PROP_LAST_PROCESS:  // Last process
        last_process = (T)_value;
        break;
      case TASK_ENTRY_PROP_LAST_SUCCESS:  // Last success
        last_success = (T)_value;
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
  };
  // Flag methods.
  bool HasFlag(unsigned char _flag) { return bool(flags & _flag); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= (unsigned char)~_flags; }
  void SetFlag(ENUM_TASK_ENTRY_FLAGS _flag, bool _value) {
    if (_value)
      AddFlags(_flag);
    else
      RemoveFlags(_flag);
  }
  void SetFlags(unsigned char _flags) { flags = _flags; }
  // State methods.
  bool IsActive() { return HasFlag(TASK_ENTRY_FLAG_IS_ACTIVE); }
  bool IsDone() { return HasFlag(TASK_ENTRY_FLAG_IS_DONE); }
  bool IsFailed() { return HasFlag(TASK_ENTRY_FLAG_IS_FAILED); }
  bool IsValid() { return action.IsValid() && cond.IsValid(); }
  // Getters.
  int GetActionId() { return action.GetId(); }
  int GetConditionId() { return cond.GetId(); }
  TaskActionEntry GetAction() { return action; }
  TaskConditionEntry GetCondition() { return cond; }

 public:
  SerializerNodeType Serialize(Serializer &s) {
    s.PassStruct(THIS_REF, "aentry", action);
    s.PassStruct(THIS_REF, "centry", cond);
    return SerializerNodeObject;
  }

  SERIALIZER_EMPTY_STUB;
};

#ifdef EMSCRIPTEN
#include <emscripten/bind.h>

EMSCRIPTEN_BINDINGS(TaskEntry) { emscripten::class_<TaskEntry>("TaskEntry").constructor(); }

#endif
