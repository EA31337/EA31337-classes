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
 * Includes Action's structs.
 */

// Includes.
#include "Account.enum.h"
#include "Chart.enum.h"
#include "EA.enum.h"
#include "Indicator.enum.h"
//#include "Market.enum.h"
#include "Order.enum.h"
#include "Strategy.enum.h"
#include "Task.enum.h"
#include "Trade.enum.h"

/* Entry for Action class. */
struct ActionEntry {
  unsigned char flags;       /* Action flags. */
  datetime last_success;     /* Time of the previous check. */
  long action_id;            /* Action ID. */
  short tries;               /* Number of retries left. */
  void *obj;                 /* Reference to associated object. */
  ENUM_ACTION_TYPE type;     /* Action type. */
  ENUM_TIMEFRAMES frequency; /* How often to check. */
  MqlParam args[];           /* Action arguments. */
  // Constructors.
  void ActionEntry() : type(FINAL_ACTION_TYPE_ENTRY), action_id(WRONG_VALUE) { Init(); }
  void ActionEntry(long _action_id, ENUM_ACTION_TYPE _type) : type(_type), action_id(_action_id) { Init(); }
  void ActionEntry(ActionEntry &_ae) { this = _ae; }
  void ActionEntry(ENUM_EA_ACTION _action_id) : type(ACTION_TYPE_EA), action_id(_action_id) { Init(); }
  void ActionEntry(ENUM_ORDER_ACTION _action_id) : type(ACTION_TYPE_ORDER), action_id(_action_id) { Init(); }
  void ActionEntry(ENUM_INDICATOR_ACTION _action_id) : type(ACTION_TYPE_INDICATOR), action_id(_action_id) { Init(); }
  void ActionEntry(ENUM_STRATEGY_ACTION _action_id) : type(ACTION_TYPE_STRATEGY), action_id(_action_id) { Init(); }
  void ActionEntry(ENUM_TASK_ACTION _action_id) : type(ACTION_TYPE_TASK), action_id(_action_id) { Init(); }
  void ActionEntry(ENUM_TRADE_ACTION _action_id) : type(ACTION_TYPE_TRADE), action_id(_action_id) { Init(); }
  // Deconstructor.
  void ~ActionEntry() {
    // Object::Delete(obj);
  }
  // Flag methods.
  bool HasFlag(unsigned char _flag) { return bool(flags & _flag); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= ~_flags; }
  void SetFlag(ENUM_ACTION_ENTRY_FLAGS _flag, bool _value) {
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
  bool IsInvalid() { return HasFlag(ACTION_ENTRY_FLAG_IS_INVALID); }
  bool IsValid() { return !IsInvalid(); }
  // Getters.
  ENUM_ACTION_TYPE GetType() { return type; }
  // Setter methods.
  void AddArg(MqlParam &_arg) {
    // @todo: Add another value to args[].
  }
  void Init() {
    flags = ACTION_ENTRY_FLAG_NONE;
    SetFlag(ACTION_ENTRY_FLAG_IS_ACTIVE, action_id != WRONG_VALUE);
    SetFlag(ACTION_ENTRY_FLAG_IS_INVALID, action_id == WRONG_VALUE);
    last_success = 0;
    tries = 1;
  }
  void SetArgs(MqlParam &_args[]) {
    // @todo: for().
  }
  void SetObject(void *_obj) {
    Object::Delete(obj);
    obj = _obj;
  }
  void SetTries(short _count) { tries = _count; }
};
