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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef TASK_CONDITION_H
#define TASK_CONDITION_H

// Includes.
#include "../Account.mqh"
#include "../Chart.mqh"
#include "../DateTime.mqh"
#include "../DictStruct.mqh"
#include "../EA.mqh"
#include "../Indicator.mqh"
#include "../Market.mqh"
#include "../Object.mqh"
#include "../Order.mqh"

// Includes class enum and structs.
#include "TaskCondition.enum.h"
#include "TaskCondition.struct.h"

/**
 * TaskCondition class.
 */
template <typename TC>
class TaskCondition {
 public:
 protected:
  // Protected class variables.
  TaskConditionEntry entry;  // Condition entry.
  TC obj;                    // Object to run the action on.

 public:
  /* Special methods */

  /**
   * Default class constructor.
   */
  TaskCondition() {}

  /**
   * Class constructor with an entry as argument.
   */
  TaskCondition(TaskConditionEntry &_entry) : entry(_entry) {}

  /* Main methods */

  /**
   * Test conditions.
   */
  /*
  bool Test() {
    bool _result = false, _prev_result = true;
    for (DictStructIterator<short, TaskConditionEntry> iter = conds.Begin(); iter.IsValid(); ++iter) {
      bool _curr_result = false;
      TaskConditionEntry _entry = iter.Value();
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
  */

  /**
   * Checks a current condition.
   */
  bool Check() {
    bool _result = entry.IsValid() && entry.HasTriesLeft();
    _result &= obj.Check(entry);
    if (_result) {
      entry.RemoveFlags(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_FLAG_IS_ACTIVE));
      entry.Set(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_TIME_LAST_CHECK), TimeCurrent());
      entry.Set(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_TIME_LAST_SUCCESS), TimeCurrent());
    } else {
      entry.AddFlags(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_FLAG_IS_INVALID));
      entry.RemoveFlags(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_FLAG_IS_ACTIVE));
      entry.Set(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_TIME_LAST_CHECK), TimeCurrent());
    }
    entry.TriesDec();
    return _result;
  }

  /**
   * Checks a condition.
   */
  virtual bool Check(const TaskConditionEntry &_entry) {
    // @todo
    return false;
  }

  /* Getters */

  /**
   * Gets an entry's flag.
   */
  bool Get(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_FLAGS) _flag) const { return entry.Get(_flag); }

  /**
   * Gets an entry's property value.
   */
  template <typename T>
  T Get(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_PROP) _prop) const {
    entry.Get<T>(_prop);
  }

  /**
   * Gets a reference to the object.
   */
  TC *GetObject() { return GetPointer(obj); }

  /* Setters */

  /**
   * Sets an entry's flag.
   */
  void Set(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_FLAGS) _flag, bool _value = true) {
    entry.Set(_flag, _value);
  }

  /**
   * Sets an entry's property value.
   */
  template <typename T>
  void Set(STRUCT_ENUM(TaskConditionEntry, ENUM_TASK_CONDITION_ENTRY_PROP) _prop, T _value) {
    entry.Set(_prop, _value);
  }
};
#endif  // TASK_CONDITION_H
