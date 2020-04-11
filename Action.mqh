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
 * Provides integration with actions.
 */

// Prevents processing this includes file for the second time.
#ifndef ACTION_MQH
#define ACTION_MQH

// Includes.
#include "EA.mqh"
#include "Strategy.mqh"
#include "Trade.mqh"

// Enums.
// Defines condition entry flags.
enum ENUM_ACTION_ENTRY_FLAGS {
  ACTION_ENTRY_FLAG_NONE = 0,
  ACTION_ENTRY_FLAG_IS_ACTIVE = 1,
  ACTION_ENTRY_FLAG_IS_DONE = 2,
  ACTION_ENTRY_FLAG_IS_FAILED = 4,
  ACTION_ENTRY_FLAG_IS_INVALID = 8
};

// Defines action types.
enum ENUM_ACTION_TYPE {
  ACTION_TYPE_EA = 1,    // EA action.
  ACTION_TYPE_ORDER,     // Order action.
  ACTION_TYPE_STRATEGY,  // Strategy action.
  ACTION_TYPE_TRADE,     // Trade action.
  FINAL_ACTION_TYPE_ENTRY
};

// Structs.
struct ActionEntry {
  unsigned char flags;        // Action flags.
  datetime last_success;      // Time of the previous check.
  long action_id;             // Action ID.
  short tries;                // Number of retries left.
  void *obj;                  // Reference to associated object.
  ENUM_ACTION_TYPE type;      // Action type.
  ENUM_TIMEFRAMES frequency;  // How often to check.
  MqlParam args[];            // Action arguments.
  // Constructor.
  void ActionEntry() : type(FINAL_ACTION_TYPE_ENTRY), action_id(WRONG_VALUE) { Init(); }
  void ActionEntry(long _action_id, ENUM_ACTION_TYPE _type) : type(_type), action_id(_action_id) { Init(); }
  void ActionEntry(ENUM_EA_ACTION _action_id) : type(ACTION_TYPE_EA), action_id(_action_id) { Init(); }
  // void ActionEntry(ENUM_ORDER_ACTION _action_id) : type(ACTION_TYPE_ORDER), action_id(_action_id) { Init(); }
  // void ActionEntry(ENUM_STRATEGY_ACTION _action_id) : type(ACTION_TYPE_STRATEGY), action_id(_action_id) { Init(); }
  // void ActionEntry(ENUM_TRADE_ACTION _action_id) : type(ACTION_TYPE_TRADE), action_id(_action_id) { Init(); }
  // Deconstructor.
  void ~ActionEntry() {
    // Object::Delete(obj);
  }
  // Flag methods.
  bool CheckFlag(unsigned char _flag) { return bool(flags & _flag); }
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
  bool IsActive() { return CheckFlag(ACTION_ENTRY_FLAG_IS_ACTIVE); }
  bool IsDone() { return CheckFlag(ACTION_ENTRY_FLAG_IS_DONE); }
  bool IsFailed() { return CheckFlag(ACTION_ENTRY_FLAG_IS_FAILED); }
  bool IsValid() { return !CheckFlag(ACTION_ENTRY_FLAG_IS_INVALID); }
  // Setter methods.
  void AddArg(MqlParam &_arg) {
    // @todo: Add another value to args[].
  }
  void Init() {
    flags = ACTION_ENTRY_FLAG_NONE;
    AddFlags(ACTION_ENTRY_FLAG_IS_ACTIVE);
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

/**
 * Action class.
 */
class Action {
 public:
 protected:
  // Class variables.
  Log *logger;

 public:
  // Class variables.
  DictStruct<short, ActionEntry> *actions;

  /* Special methods */

  /**
   * Class constructor.
   */
  Action() { Init(); }
  Action(ActionEntry &_entry) {
    Init();
    actions.Push(_entry);
  }
  Action(long _action_id, ENUM_ACTION_TYPE _type) {
    Init();
    ActionEntry _entry(_action_id, _type);
    actions.Push(_entry);
  }
  template <typename T>
  Action(T _action_id, void *_obj = NULL) {
    Init();
    ActionEntry _entry(_action_id);
    if (_obj != NULL) {
      _entry.SetObject(_obj);
    }
    actions.Push(_entry);
  }
  template <typename T>
  Action(T _action_id, MqlParam &_args[], void *_obj = NULL) {
    Init();
    ActionEntry _entry(_action_id);
    _entry.SetArgs(_args);
    if (_obj != NULL) {
      _entry.SetObject(_obj);
    }
    actions.Push(_entry);
  }

  /**
   * Class copy constructor.
   */
  Action(Action &_cond) {
    Init();
    actions = _cond.GetActions();
  }

  /**
   * Class deconstructor.
   */
  ~Action() {}

  /**
   * Initialize class variables.
   */
  void Init() { actions = new DictStruct<short, ActionEntry>(); }

  /* Main methods */

  /**
   * Execute actions.
   */
  bool Execute() {
    bool _result = true, _executed = false;
    for (DictStructIterator<short, ActionEntry> iter = actions.Begin(); iter.IsValid(); ++iter) {
      bool _curr_result = false;
      ActionEntry _entry = iter.Value();
      if (!_entry.IsValid()) {
        // Ignore invalid entries.
        continue;
      }
      if (_entry.IsActive()) {
        _executed = _result &= Execute(_entry);
      }
    }
    return _result && _executed;
  }

  /**
   * Execute specific action.
   */
  bool Execute(ActionEntry &_entry) {
    bool _result = false;
    switch (_entry.type) {
      case ACTION_TYPE_EA:
        if (Object::IsValid(_entry.obj)) {
          _result = ((EA *)_entry.obj).Action((ENUM_EA_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case ACTION_TYPE_ORDER:
        if (Object::IsValid(_entry.obj)) {
          //_result = ((Order *)_entry.obj).Action((ENUM_ORDER_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case ACTION_TYPE_STRATEGY:
        if (Object::IsValid(_entry.obj)) {
          //_result = ((Strategy *)_entry.obj).Action((ENUM_STRATEGY_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case ACTION_TYPE_TRADE:
        if (Object::IsValid(_entry.obj)) {
          //_result = ((Trade *)_entry.obj).Action((ENUM_TRADE_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
    }
    if (_result) {
      _entry.last_success = TimeCurrent();
    } else {
      _entry.tries--;
    }
    return _result;
  }

  /* Other methods */

  /* Getters */

  /**
   * Returns conditions.
   */
  DictStruct<short, ActionEntry> *GetActions() { return actions; }

  /* Setters */
};
#endif  // ACTION_MQH
