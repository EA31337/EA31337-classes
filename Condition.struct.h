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
 * Includes Condition's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Account/Account.enum.h"
#include "Chart.enum.h"
#include "DateTime.enum.h"
#include "EA.enum.h"
#include "Indicator.enum.h"
//#include "Market.enum.h"
#include "Order.enum.h"
#include "Strategy.enum.h"
#include "Task.enum.h"
#include "Trade.enum.h"

struct ConditionEntry {
  unsigned char flags;                      // Condition flags.
  datetime last_check;                      // Time of the latest check.
  datetime last_success;                    // Time of the last success.
  int frequency;                            // How often to check.
  long cond_id;                             // Condition ID.
  short tries;                              // Number of successful tries left.
  void *obj;                                // Reference to associated object.
  ENUM_CONDITION_STATEMENT next_statement;  // Statement type of the next condition.
  ENUM_CONDITION_TYPE type;                 // Condition type.
  DataParamEntry args[];                    // Condition arguments.
  // Constructors.
  void ConditionEntry() : type(FINAL_CONDITION_TYPE_ENTRY), cond_id(WRONG_VALUE) { Init(); }
  void ConditionEntry(long _cond_id, ENUM_CONDITION_TYPE _type) : type(_type), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ConditionEntry &_ce) { this = _ce; }
  void ConditionEntry(ENUM_ACCOUNT_CONDITION _cond_id) : type(COND_TYPE_ACCOUNT), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_CHART_CONDITION _cond_id) : type(COND_TYPE_CHART), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_DATETIME_CONDITION _cond_id) : type(COND_TYPE_DATETIME), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_EA_CONDITION _cond_id) : type(COND_TYPE_EA), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_INDICATOR_CONDITION _cond_id) : type(COND_TYPE_INDICATOR), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_MARKET_CONDITION _cond_id) : type(COND_TYPE_MARKET), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_ORDER_CONDITION _cond_id) : type(COND_TYPE_ORDER), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_STRATEGY_CONDITION _cond_id) : type(COND_TYPE_STRATEGY), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_TASK_CONDITION _cond_id) : type(COND_TYPE_TASK), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_TRADE_CONDITION _cond_id) : type(COND_TYPE_TRADE), cond_id(_cond_id) { Init(); }
  // Deconstructor.
  void ~ConditionEntry() {
    // Object::Delete(obj);
  }
  // Flag methods.
  bool HasFlag(unsigned char _flag) { return bool(flags & _flag); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= ~_flags; }
  void SetFlag(ENUM_CONDITION_ENTRY_FLAGS _flag, bool _value) {
    if (_value)
      AddFlags(_flag);
    else
      RemoveFlags(_flag);
  }
  void SetFlags(unsigned char _flags) { flags = _flags; }
  // State methods.
  bool IsActive() { return HasFlag(COND_ENTRY_FLAG_IS_ACTIVE); }
  bool IsExpired() { return HasFlag(COND_ENTRY_FLAG_IS_EXPIRED); }
  bool IsReady() { return HasFlag(COND_ENTRY_FLAG_IS_READY); }
  bool IsInvalid() { return HasFlag(COND_ENTRY_FLAG_IS_INVALID); }
  bool IsValid() { return !IsInvalid(); }
  // Getters.
  long GetId() { return cond_id; }
  ENUM_CONDITION_TYPE GetType() { return type; }
  // Setters.
  void AddArg(MqlParam &_arg) {
    // @todo: Add another value to args[].
  }
  void Init() {
    flags = COND_ENTRY_FLAG_NONE;
    frequency = 60;
    SetFlag(COND_ENTRY_FLAG_IS_ACTIVE, cond_id != WRONG_VALUE);
    SetFlag(COND_ENTRY_FLAG_IS_INVALID, cond_id == WRONG_VALUE);
    last_check = last_success = 0;
    next_statement = COND_AND;
    tries = 1;
  }
  void SetArgs(MqlParam &_args[]) {
    // @todo: for().
  }
  void SetObject(void *_obj) { obj = _obj; }
  void SetTries(short _count) { tries = _count; }
};
