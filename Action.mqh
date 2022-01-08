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
 * Provides integration with actions.
 */

// Prevents processing this includes file for the second time.
#ifndef ACTION_MQH
#define ACTION_MQH

// Forward class declaration.
class Action;

// Includes.
#include "Action.enum.h"
#include "Action.struct.h"
#include "Condition.enum.h"
#include "EA.mqh"

/**
 * Action class.
 */
class Action {
 public:
 protected:
  // Class variables.
  Ref<Log> logger;

 public:
  // Class variables.
  DictStruct<short, ActionEntry> actions;

  /* Special methods */

  /**
   * Class constructor.
   */
  Action() {}
  Action(ActionEntry &_entry) { actions.Push(_entry); }
  Action(long _action_id, ENUM_ACTION_TYPE _type) {
    ActionEntry _entry(_action_id, _type);
    actions.Push(_entry);
  }
  template <typename T>
  Action(T _action_id, void *_obj = NULL) {
    ActionEntry _entry(_action_id);
    if (_obj != NULL) {
      _entry.SetObject(_obj);
    }
    actions.Push(_entry);
  }
  template <typename T>
  Action(T _action_id, MqlParam &_args[], void *_obj = NULL) {
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
  Action(Action &_cond) { actions = _cond.GetActions(); }

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
  static bool Execute(ActionEntry &_entry) {
    bool _result = false;
    switch (_entry.type) {
      case ACTION_TYPE_ACTION:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Action *)_entry.obj).ExecuteAction((ENUM_ACTION_ACTION)_entry.action_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case ACTION_TYPE_EA:
        if (Object::IsValid(_entry.obj)) {
          _result = ((EA *)_entry.obj).ExecuteAction((ENUM_EA_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
#ifdef ORDER_MQH
      case ACTION_TYPE_ORDER:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Order *)_entry.obj).ExecuteAction((ENUM_ORDER_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
#endif
#ifdef INDICATOR_MQH
      case ACTION_TYPE_INDICATOR:
        if (Object::IsValid(_entry.obj)) {
          _result = ((IndicatorBase *)_entry.obj).ExecuteAction((ENUM_INDICATOR_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
#endif
#ifdef STRATEGY_MQH
      case ACTION_TYPE_STRATEGY:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Strategy *)_entry.obj).ExecuteAction((ENUM_STRATEGY_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
#endif
#ifdef TASK_MQH
      case ACTION_TYPE_TASK:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Task *)_entry.obj).ExecuteAction((ENUM_TASK_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
#endif
      case ACTION_TYPE_TRADE:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Trade *)_entry.obj).ExecuteAction((ENUM_TRADE_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
#ifdef TERMINAL_MQH
      case ACTION_TYPE_TERMINAL:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Terminal *)_entry.obj).ExecuteAction((ENUM_TERMINAL_ACTION)_entry.action_id);
        } else {
          _result = false;
          _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        }
        break;
#endif
    }
    if (_result) {
      _entry.AddFlags(ACTION_ENTRY_FLAG_IS_DONE);
      _entry.RemoveFlags(ACTION_ENTRY_FLAG_IS_ACTIVE);
      _entry.last_success = TimeCurrent();
    } else {
      if (--_entry.tries <= 0) {
        _entry.AddFlags(ACTION_ENTRY_FLAG_IS_INVALID);
        _entry.RemoveFlags(ACTION_ENTRY_FLAG_IS_ACTIVE);
      }
    }
    return _result;
  }

  /* State methods */

  /**
   * Check if action is active.
   */
  bool IsActive() {
    // The whole action is active when at least one action is active.
    return GetFlagCount(ACTION_ENTRY_FLAG_IS_ACTIVE) > 0;
  }

  /**
   * Check if action is done.
   */
  bool IsDone() {
    // The whole action is done when all actions has been executed successfully.
    return GetFlagCount(ACTION_ENTRY_FLAG_IS_DONE) == actions.Size();
  }

  /**
   * Check if action has failed.
   */
  bool IsFailed() {
    // The whole action is failed when at least one action failed.
    return GetFlagCount(ACTION_ENTRY_FLAG_IS_FAILED) > 0;
  }

  /**
   * Check if action is finished.
   */
  bool IsFinished() {
    // The whole action is finished when there are no more active actions.
    return GetFlagCount(ACTION_ENTRY_FLAG_IS_ACTIVE) == 0;
  }

  /**
   * Check if action is invalid.
   */
  bool IsInvalid() {
    // The whole action is invalid when at least one action is invalid.
    return GetFlagCount(ACTION_ENTRY_FLAG_IS_INVALID) > 0;
  }

  /* Getters */

  /**
   * Returns actions.
   */
  DictStruct<short, ActionEntry> *GetActions() { return &actions; }

  /**
   * Count entry flags.
   */
  unsigned int GetFlagCount(ENUM_ACTION_ENTRY_FLAGS _flag) {
    unsigned int _counter = 0;
    for (DictStructIterator<short, ActionEntry> iter = actions.Begin(); iter.IsValid(); ++iter) {
      ActionEntry _entry = iter.Value();
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
  bool SetFlags(ENUM_ACTION_ENTRY_FLAGS _flag, bool _value = true) {
    unsigned int _counter = 0;
    for (DictStructIterator<short, ActionEntry> iter = actions.Begin(); iter.IsValid(); ++iter) {
      ActionEntry _entry = iter.Value();
      switch (_value) {
        case false:
          if (_entry.HasFlag(_flag)) {
            _entry.SetFlag(_flag, _value);
            _counter++;
          }
          break;
        case true:
          if (!_entry.HasFlag(_flag)) {
            _entry.SetFlag(_flag, _value);
            _counter++;
          }
          break;
      }
    }
    return _counter > 0;
  }

  /* Conditions and actions */

  /**
   * Checks for Task condition.
   *
   * @param ENUM_ACTION_CONDITION _cond
   *   Action condition.
   * @return
   *   Returns true when the condition is met.
   */
  bool CheckCondition(ENUM_ACTION_CONDITION _cond, DataParamEntry &_args[]) {
    bool _result = false;
    switch (_cond) {
      case ACTION_COND_IS_ACTIVE:
        // Is active;
        return IsActive();
      case ACTION_COND_IS_DONE:
        // Is done.
        return IsDone();
      case ACTION_COND_IS_FAILED:
        // Is failed.
        return IsFailed();
      case ACTION_COND_IS_FINISHED:
        // Is finished.
        return IsFinished();
      case ACTION_COND_IS_INVALID:
        // Is invalid.
        return IsInvalid();
      default:
        logger.Ptr().Error(StringFormat("Invalid Action condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        break;
    }
    return _result;
  }
  bool CheckCondition(ENUM_ACTION_CONDITION _cond) {
    ARRAY(DataParamEntry, _args);
    return Action::CheckCondition(_cond, _args);
  }

  /**
   * Execute action of action.
   *
   * @param ENUM_ACTION_ACTION _action
   *   Action of action to execute.
   * @return
   *   Returns true when the action has been executed successfully.
   */
  bool ExecuteAction(ENUM_ACTION_ACTION _action, DataParamEntry &_args[]) {
    bool _result = false;
    switch (_action) {
      case ACTION_ACTION_DISABLE:
        // Disable action.
        return SetFlags(ACTION_ENTRY_FLAG_IS_ACTIVE, false);
      case ACTION_ACTION_EXECUTE:
        // Execute action.
        return Execute();
      case ACTION_ACTION_MARK_AS_DONE:
        // Marks as done.
        return SetFlags(ACTION_ENTRY_FLAG_IS_DONE);
      case ACTION_ACTION_MARK_AS_FAILED:
        // Mark as failed.
        return SetFlags(ACTION_ENTRY_FLAG_IS_FAILED);
      case ACTION_ACTION_MARK_AS_FINISHED:
        // Mark as finished.
        return SetFlags(ACTION_ENTRY_FLAG_IS_ACTIVE, false);
      case ACTION_ACTION_MARK_AS_INVALID:
        // Mark as invalid.
        return SetFlags(ACTION_ENTRY_FLAG_IS_INVALID);
      default:
        logger.Ptr().Error(StringFormat("Invalid action of action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        break;
    }
    return _result;
  }
  bool ExecuteAction(ENUM_ACTION_ACTION _action) {
    ARRAY(DataParamEntry, _args);
    return Action::ExecuteAction(_action, _args);
  }

  /* Other methods */
};

#endif  // ACTION_MQH
