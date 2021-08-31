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
#include "Action.struct.h"
#include "Condition.struct.h"
#include "Task.enum.h"

struct TaskEntry {
  ActionEntry action;     // Action of the task.
  ConditionEntry cond;    // Condition of the task.
  datetime expires;       // Time of expiration.
  datetime last_process;  // Time of the last process.
  datetime last_success;  // Time of the last success.
  unsigned char flags;    // Action flags.
  // Constructors.
  void TaskEntry() { Init(); }
  void TaskEntry(ActionEntry &_action, ConditionEntry &_cond) : action(_action), cond(_cond) { Init(); }
  void TaskEntry(long _aid, ENUM_ACTION_TYPE _atype, long _cid, ENUM_CONDITION_TYPE _ctype)
      : action(_aid, _atype), cond(_cid, _ctype) {
    Init();
  }
  template <typename AE, typename CE>
  void TaskEntry(AE _aid, CE _cid) : action(_aid), cond(_cid) {
    Init();
  }
  // Main methods.
  void Init() {
    flags = TASK_ENTRY_FLAG_NONE;
    SetFlag(TASK_ENTRY_FLAG_IS_ACTIVE, action.IsActive() && cond.IsActive());
    SetFlag(TASK_ENTRY_FLAG_IS_INVALID, action.IsInvalid() || cond.IsInvalid());
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
  // Getters.
  long GetActionId() { return action.GetId(); }
  long GetConditionId() { return cond.GetId(); }
  ActionEntry GetAction() { return action; }
  ConditionEntry GetCondition() { return cond; }
  ENUM_ACTION_TYPE GetActionType() { return action.GetType(); }
  ENUM_CONDITION_TYPE GetConditionType() { return cond.GetType(); }
  // Setters.
  void SetActionObject(void *_obj) { action.SetObject(_obj); }
  void SetConditionObject(void *_obj) { cond.SetObject(_obj); }
};
