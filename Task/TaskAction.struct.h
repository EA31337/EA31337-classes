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
 * Includes TaskAction's structures.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Data.struct.h"
#include "../Serializer/Serializer.define.h"
#include "../Std.h"
#include "../Terminal.define.h"
#include "Task.enum.h"

// Forward declarations.
class Serializer;

/* Entry for TaskAction class. */
struct TaskActionEntry {
 public:
  /* Enumerations */

  // Defines action entry properties.
  enum ENUM_TASK_ACTION_ENTRY_PROP {
    TASK_ACTION_ENTRY_FLAGS,
    TASK_ACTION_ENTRY_FREQUENCY,
    TASK_ACTION_ENTRY_ID,
    TASK_ACTION_ENTRY_TRIES,
    TASK_ACTION_ENTRY_TIME_LAST_RUN,
  };
  // Defines action entry flags.
  enum ENUM_TASK_ACTION_ENTRY_FLAG {
    TASK_ACTION_ENTRY_FLAG_NONE = 0 << 0,
    TASK_ACTION_ENTRY_FLAG_IS_ACTIVE = 1 << 0,
    TASK_ACTION_ENTRY_FLAG_IS_DONE = 1 << 1,
    TASK_ACTION_ENTRY_FLAG_IS_FAILED = 1 << 2,
    TASK_ACTION_ENTRY_FLAG_IS_INVALID = 1 << 3,
  };

 protected:
  ARRAY(DataParamEntry, args); /* TaskAction arguments. */
  unsigned char flags;         /* TaskAction flags. */
  int freq;                    /* How often to run (0 for no limit). */
  int id;                      /* TaskAction's enum ID. */
  datetime time_last_run;      /* Time of the successful run. */
  short tries;                 /* Number of retries left (-1 for unlimited). */
 protected:
  // Protected methods.
  void Init() {
    SetFlag(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_INVALID), id == InvalidEnumValue<int>::value());
  }

 public:
  // Constructors.
  TaskActionEntry() : flags(0), freq(60), id(InvalidEnumValue<int>::value()), time_last_run(0), tries(-1) { Init(); }
  TaskActionEntry(int _id)
      : flags(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_ACTIVE)),
        freq(60),
        id(_id),
        time_last_run(0),
        tries(-1) {
    Init();
  }
  TaskActionEntry(const TaskActionEntry &_ae) { THIS_REF = _ae; }
  // Flag methods.
  bool HasFlag(unsigned char _flag) const { return bool(flags & _flag); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= (unsigned char)~_flags; }
  void SetFlag(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_FLAG) _flag, bool _value) {
    if (_value) {
      AddFlags(_flag);
    } else {
      RemoveFlags(_flag);
    }
  }
  void SetFlags(unsigned char _flags) { flags = _flags; }
  // State methods.
  bool HasTriesLeft() const { return tries > 0 || tries == -1; }
  bool IsActive() const { return HasFlag(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_ACTIVE)); }
  bool IsDone() const { return HasFlag(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_DONE)); }
  bool IsFailed() const { return HasFlag(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_FAILED)); }
  bool IsInvalid() const { return HasFlag(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_INVALID)); }
  bool IsValid() const { return !IsInvalid(); }
  // Getters.
  bool Get(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_FLAG) _flag) const { return HasFlag(_flag); }
  template <typename T>
  T Get(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_PROP) _prop) const {
    switch (_prop) {
      case TASK_ACTION_ENTRY_FLAGS:
        return (T)flags;
      case TASK_ACTION_ENTRY_FREQUENCY:
        return (T)freq;
      case TASK_ACTION_ENTRY_ID:
        return (T)id;
      case TASK_ACTION_ENTRY_TRIES:
        return (T)tries;
      case TASK_ACTION_ENTRY_TIME_LAST_RUN:
        return (T)time_last_run;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return InvalidEnumValue<STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_PROP)>::value();
  }
  DataParamEntry GetArg(int _index) const { return args[_index]; }
  int GetId() const { return id; }
  // Setters.
  void TriesDec() {
    if (tries > 0) --tries;
  }
  void Set(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_FLAG) _flag, bool _value = true) {
    SetFlag(_flag, _value);
  }
  template <typename T>
  void Set(STRUCT_ENUM(TaskActionEntry, ENUM_TASK_ACTION_ENTRY_PROP) _prop, T _value) {
    switch (_prop) {
      case TASK_ACTION_ENTRY_FLAGS:  // ID (magic number).
        flags = (unsigned char)_value;
        return;
      case TASK_ACTION_ENTRY_FREQUENCY:
        freq = (int)_value;
        return;
      case TASK_ACTION_ENTRY_ID:
        id = (int)_value;
        SetFlag(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_FLAG_IS_INVALID), id == InvalidEnumValue<int>::value());
        return;
      case TASK_ACTION_ENTRY_TRIES:
        tries = (short)_value;
        return;
      case TASK_ACTION_ENTRY_TIME_LAST_RUN:
        time_last_run = (datetime)_value;
        return;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  // Methods for arguments.
  void ArgAdd(DataParamEntry &_arg) { ArgSet(_arg, ::ArraySize(args)); }
  void ArgsGet(ARRAY_REF(DataParamEntry, _args)) {
    ::ArrayResize(_args, ::ArraySize(args));
    for (int i = 0; i < ::ArraySize(_args); i++) {
      _args[i] = args[i];
    }
  }
  void ArgSet(DataParamEntry &_arg, int _index = 0) {
    if (::ArraySize(args) <= _index) {
      ::ArrayResize(args, _index + 1);
    }
    args[_index] = _arg;
  }
  void ArgsSet(ARRAY_REF(DataParamEntry, _args)) {
    ::ArrayResize(args, ::ArraySize(_args));
    for (int i = 0; i < ::ArraySize(_args); i++) {
      args[i] = _args[i];
    }
  }
  void ArgRemove(int _index) {
    for (int i = 1; i < ::ArraySize(args); i++) {
      ArgSet(args[i], i - 1);
    }
    ::ArrayResize(args, _index - 1);
  }
  // Serializers
  SerializerNodeType Serialize(Serializer &s);

  SERIALIZER_EMPTY_STUB;
};
