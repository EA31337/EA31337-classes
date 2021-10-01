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
 * Provides integration with conditions.
 */

// Prevents processing this includes file for the second time.
#ifndef CONDITION_MQH
#define CONDITION_MQH

// Includes.
#include "Account.mqh"
#include "Chart.mqh"
#include "DateTime.mqh"
#include "DictStruct.mqh"
#include "EA.mqh"
#include "Indicator.mqh"
#include "Market.mqh"
#include "Object.mqh"
#include "Order.mqh"

// Includes class enum and structs.
#include "Condition.enum.h"
#include "Condition.struct.h"

/**
 * Condition class.
 */
class Condition {
 public:
 protected:
  // Class variables.
  Ref<Log> logger;

 public:
  // Class variables.
  DictStruct<short, ConditionEntry> conds;

  /* Special methods */

  /**
   * Class constructor.
   */
  Condition() {}
  Condition(ConditionEntry &_entry) { conds.Push(_entry); }
  Condition(long _cond_id, ENUM_CONDITION_TYPE _type) {
    ConditionEntry _entry(_cond_id, _type);
    conds.Push(_entry);
  }
  template <typename T>
  Condition(T _cond_id, void *_obj = NULL) {
    ConditionEntry _entry(_cond_id);
    if (_obj != NULL) {
      _entry.SetObject(_obj);
    }
    conds.Push(_entry);
  }
  template <typename T>
  Condition(T _cond_id, MqlParam &_args[], void *_obj = NULL) {
    Init();
    ConditionEntry _entry(_cond_id);
    _entry.SetArgs(_args);
    if (_obj != NULL) {
      _entry.SetObject(_obj);
    }
    conds.Push(_entry);
  }

  /**
   * Class copy constructor.
   */
  Condition(Condition &_cond) { conds = _cond.GetConditions(); }

  /* Main methods */

  /**
   * Test conditions.
   */
  bool Test() {
    bool _result = false, _prev_result = true;
    for (DictStructIterator<short, ConditionEntry> iter = conds.Begin(); iter.IsValid(); ++iter) {
      bool _curr_result = false;
      ConditionEntry _entry = iter.Value();
      if (!_entry.IsValid()) {
        // Ignore invalid entries.
        continue;
      }
      if (_entry.IsActive()) {
        switch (_entry.next_statement) {
          case COND_AND:
            _curr_result = _prev_result && this.Test(_entry);
            break;
          case COND_OR:
            _curr_result = _prev_result || this.Test(_entry);
            break;
          case COND_SEQ:
            _curr_result = this.Test(_entry);
            if (!_curr_result) {
              // Do not check further conditions when the current condition is false.
              return false;
            }
        }
        _result = _prev_result = _curr_result;
      }
    }
    return _result;
  }

  /**
   * Test specific condition.
   */
  static bool Test(ConditionEntry &_entry) {
    bool _result = false;
    switch (_entry.type) {
      case COND_TYPE_ACCOUNT:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Account *)_entry.obj).CheckCondition((ENUM_ACCOUNT_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case COND_TYPE_CHART:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Chart *)_entry.obj).CheckCondition((ENUM_CHART_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case COND_TYPE_DATETIME:
        if (Object::IsValid(_entry.obj)) {
          _result = ((DateTime *)_entry.obj).CheckCondition((ENUM_DATETIME_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = DateTime::CheckCondition((ENUM_DATETIME_CONDITION)_entry.cond_id, _entry.args);
        }
        break;
      case COND_TYPE_EA:
        if (Object::IsValid(_entry.obj)) {
          _result = ((EA *)_entry.obj).CheckCondition((ENUM_EA_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
#ifdef INDICATOR_MQH
      case COND_TYPE_INDICATOR:
        if (Object::IsValid(_entry.obj)) {
          _result = ((IndicatorBase *)_entry.obj).CheckCondition((ENUM_INDICATOR_CONDITION)_entry.cond_id, _entry.args);
        } else {
          // Static method not supported.
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
#endif
      case COND_TYPE_MARKET:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Market *)_entry.obj).CheckCondition((ENUM_MARKET_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
#ifdef MATH_H
      case COND_TYPE_MATH:
        /*
          if (Object::IsValid(_entry.obj)) {
            _result = ((Math *)_entry.obj).CheckCondition((ENUM_MATH_CONDITION)_entry.cond_id, _entry.args);
          } else {
            _result = false;
            _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
          }
          */
        return false;
        break;
#endif  // MATH_M
#ifdef ORDER_MQH
      case COND_TYPE_ORDER:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Order *)_entry.obj).CheckCondition((ENUM_ORDER_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
#endif
#ifdef STRATEGY_MQH
      case COND_TYPE_STRATEGY:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Strategy *)_entry.obj).CheckCondition((ENUM_STRATEGY_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
#endif
#ifdef TASK_MQH
      case COND_TYPE_TASK:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Task *)_entry.obj).CheckCondition((ENUM_TASK_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
#endif
      case COND_TYPE_TRADE:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Trade *)_entry.obj).CheckCondition((ENUM_TRADE_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
#ifdef TERMINAL_MQH
      case COND_TYPE_TERMINAL:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Terminal *)_entry.obj).CheckCondition((ENUM_TERMINAL_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
#endif
    }
    if (_result) {
      _entry.last_success = TimeCurrent();
      _entry.tries--;
    }
    _entry.last_check = TimeCurrent();
    return _result;
  }

  /* Other methods */

  /* Getters */

  /**
   * Returns conditions.
   */
  DictStruct<short, ConditionEntry> *GetConditions() { return &conds; }

  /* Setters */
};
#endif  // CONDITION_MQH
