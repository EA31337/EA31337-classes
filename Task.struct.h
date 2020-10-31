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

// Includes.
#include "Task.enum.h"

// Forward class declaration.
class Action;
class Condition;

struct TaskEntry {
  Action *action;         // Action of the task.
  Condition *cond;        // Condition of the task.
  datetime expires;       // Time of expiration.
  datetime last_process;  // Time of the last process.
  datetime last_success;  // Time of the last success.
  unsigned char flags;    // Action flags.
  // Constructor.
  void TaskEntry() { Init(); }
  void TaskEntry(Condition *_c, Action *_a)
   : action(_a), cond(_c) { Init(); }
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
