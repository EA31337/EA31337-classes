//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Includes TaskCondition's structures.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Data.struct.h"
#include "../Std.h"
#include "Task.enum.h"

struct TaskConditionEntry {
 public:
  /* Enumerations */

  // Defines condition entry properties.
  enum ENUM_TASK_CONDITION_ENTRY_PROP {
    TASK_CONDITION_ENTRY_FLAGS,
    TASK_CONDITION_ENTRY_FREQUENCY,
    TASK_CONDITION_ENTRY_ID,
    TASK_CONDITION_ENTRY_TRIES,
    TASK_CONDITION_ENTRY_TIME_LAST_CHECK,
    TASK_CONDITION_ENTRY_TIME_LAST_SUCCESS,
  };

  // Defines condition entry flags..
  enum ENUM_TASK_CONDITION_ENTRY_FLAGS {
    TASK_CONDITION_ENTRY_FLAG_NONE = 0 << 0,
    TASK_CONDITION_ENTRY_FLAG_IS_ACTIVE = 1 << 0,
    TASK_CONDITION_ENTRY_FLAG_IS_EXPIRED = 1 << 1,
    TASK_CONDITION_ENTRY_FLAG_IS_INVALID = 1 << 2,
    TASK_CONDITION_ENTRY_FLAG_IS_READY = 1 << 3,
  };

 protected:
  unsigned char flags;    // Condition flags.
  datetime last_check;    // Time of the latest check.
  datetime last_success;  // Time of the last success.
  int freq;               // How often to run (0 for no limit).
  long id;                // Condition ID.
  short tries;            // Number of successful tries left (-1 for unlimited).
  // ENUM_TASK_CONDITION_STATEMENT next_statement;  // Statement type of the next condition.
  // ENUM_TASK_CONDITION_TYPE type;                 // Task's condition type.
  DataParamEntry args[];  // Task's condition arguments.
 protected:
  // Protected methods.
  void Init() { SetFlag(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_FLAG_IS_INVALID), id == WRONG_VALUE); }

 public:
  // Constructors.
  TaskConditionEntry() : flags(0), freq(60), id(WRONG_VALUE), tries(-1) { Init(); }
  TaskConditionEntry(long _id)
      : flags(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_FLAG_IS_ACTIVE)),
        freq(60),
        id(_id),
        last_check(0),
        last_success(0),
        tries(-1) {
    Init();
  }
  TaskConditionEntry(TaskConditionEntry &_ae) { this = _ae; }
  // Deconstructor.
  void ~TaskConditionEntry() {}
  // Getters.
  bool Get(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_FLAGS) _flag) const { return HasFlag(_flag); }
  template <typename T>
  T Get(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_PROP) _prop) const {
    switch (_prop) {
      case TASK_CONDITION_ENTRY_FLAGS:
        return (T)flags;
      case TASK_CONDITION_ENTRY_FREQUENCY:
        return (T)freq;
      case TASK_CONDITION_ENTRY_ID:
        return (T)id;
      case TASK_CONDITION_ENTRY_TRIES:
        return (T)tries;
      case TASK_CONDITION_ENTRY_TIME_LAST_CHECK:
        return (T)last_check;
      case TASK_CONDITION_ENTRY_TIME_LAST_SUCCESS:
        return (T)last_success;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  long GetId() const { return id; }
  // Setters.
  void TriesDec() { tries -= tries > 0 ? 1 : 0; }
  void Set(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_FLAGS) _flag, bool _value = true) {
    SetFlag(_flag, _value);
  }
  template <typename T>
  void Set(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_PROP) _prop, T _value) {
    switch (_prop) {
      case TASK_CONDITION_ENTRY_FLAGS:  // ID (magic number).
        flags = (unsigned char)_value;
        return;
      case TASK_CONDITION_ENTRY_FREQUENCY:
        freq = (int)_value;
        return;
      case TASK_CONDITION_ENTRY_ID:
        id = (long)_value;
        SetFlag(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_FLAG_IS_INVALID), id == WRONG_VALUE);
        return;
      case TASK_CONDITION_ENTRY_TRIES:
        tries = (short)_value;
        return;
      case TASK_CONDITION_ENTRY_TIME_LAST_CHECK:
        last_check = (datetime)_value;
        return;
      case TASK_CONDITION_ENTRY_TIME_LAST_SUCCESS:
        last_success = (datetime)_value;
        return;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  // Flag methods.
  bool HasFlag(unsigned char _flag) const { return bool(flags & _flag); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= ~_flags; }
  void SetFlag(ENUM_TASK_CONDITION_ENTRY_FLAGS _flag, bool _value) {
    if (_value)
      AddFlags(_flag);
    else
      RemoveFlags(_flag);
  }
  void SetFlags(unsigned char _flags) { flags = _flags; }
  // State methods.
  bool HasTriesLeft() const { return tries > 0 || tries == -1; }
  bool IsActive() const { return HasFlag(TASK_CONDITION_ENTRY_FLAG_IS_ACTIVE); }
  bool IsExpired() const { return HasFlag(TASK_CONDITION_ENTRY_FLAG_IS_EXPIRED); }
  bool IsReady() const { return HasFlag(TASK_CONDITION_ENTRY_FLAG_IS_READY); }
  bool IsInvalid() const { return HasFlag(TASK_CONDITION_ENTRY_FLAG_IS_INVALID); }
  bool IsValid() const { return !IsInvalid(); }
  // Setters.
  void AddArg(MqlParam &_arg) {
    // @todo: Add another value to args[].
  }
  void SetArgs(MqlParam &_args[]) {
    // @todo: for().
  }
  void SetTries(short _count) { tries = _count; }
};
