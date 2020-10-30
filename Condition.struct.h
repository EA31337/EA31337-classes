//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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

struct ConditionEntry {
  unsigned char flags;                      // Condition flags.
  datetime last_check;                      // Time of the latest check.
  datetime last_success;                    // Time of the last success.
  long cond_id;                             // Condition ID.
  short tries;                              // Number of successful tries left.
  void *obj;                                // Reference to associated object.
  ENUM_CONDITION_STATEMENT next_statement;  // Statement type of the next condition.
  ENUM_CONDITION_TYPE type;                 // Condition type.
  ENUM_TIMEFRAMES frequency;                // How often to check.
  MqlParam args[];                          // Condition arguments.
  // Constructor.
  void ConditionEntry() : type(FINAL_CONDITION_TYPE_ENTRY), cond_id(WRONG_VALUE) { Init(); }
  void ConditionEntry(long _cond_id, ENUM_CONDITION_TYPE _type) : type(_type), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_ACCOUNT_CONDITION _cond_id) : type(COND_TYPE_ACCOUNT), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_CHART_CONDITION _cond_id) : type(COND_TYPE_CHART), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_DATETIME_CONDITION _cond_id) : type(COND_TYPE_DATETIME), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_INDICATOR_CONDITION _cond_id) : type(COND_TYPE_INDICATOR), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_MARKET_CONDITION _cond_id) : type(COND_TYPE_MARKET), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_ORDER_CONDITION _cond_id) : type(COND_TYPE_ORDER), cond_id(_cond_id) { Init(); }
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
  bool IsValid() { return !HasFlag(COND_ENTRY_FLAG_IS_INVALID); }
  // Setter methods.
  void AddArg(MqlParam &_arg) {
    // @todo: Add another value to args[].
  }
  void Init() {
    flags = COND_ENTRY_FLAG_NONE;
    AddFlags(COND_ENTRY_FLAG_IS_ACTIVE);
    last_check = last_success = 0;
    next_statement = COND_AND;
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
