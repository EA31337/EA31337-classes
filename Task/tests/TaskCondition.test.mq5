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
 * Test functionality of TaskCondition class.
 */

// Includes.
#include "../../DictObject.mqh"
#include "../TaskCondition.h"
#include "../TaskConditionBase.h"

enum ENUM_TASK_CONDITION_TEST {
  TASK_CONDITION_TEST01 = 1,
  TASK_CONDITION_TEST02 = 2,
  TASK_CONDITION_TEST03 = 3,
};

class TaskConditionTest01 : public TaskConditionBase {
 protected:
  long sum;

 public:
  TaskConditionTest01() : sum(0){};
  long GetSum() { return sum; }
  bool Check(const TaskConditionEntry &_entry) {
    sum += _entry.GetId();
    PrintFormat("Checks: %s; sum=%d", __FUNCSIG__, sum);
    return true;
  }
};

class TaskConditionTest02 : public TaskConditionBase {
 protected:
  long sum;

 public:
  TaskConditionTest02() : sum(0){};
  long GetSum() { return sum; }
  bool Check(const TaskConditionEntry &_entry) {
    sum += _entry.GetId();
    PrintFormat("Checks: %s; sum=%d", __FUNCSIG__, sum);
    return true;
  }
};

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  // Test01
  TaskConditionEntry _entry01(TASK_CONDITION_TEST01);
  TaskCondition<TaskConditionTest01> _cond01(_entry01);
  _cond01.Check();
  //_cond01.Set(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_ID), TASK_CONDITION_TEST02);
  _cond01.Check();
  //_cond01.Set(STRUCT_ENUM(TaskConditionEntry, TASK_CONDITION_ENTRY_ID), TASK_CONDITION_TEST03);
  _cond01.Check();
  // assertTrueOrFail(_cond01.GetObject().GetSum() == 6, "Fail!");
  _result &= GetLastError() == ERR_NO_ERROR;
  return (_result ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements Tick event handler.
 */
void OnTick() {}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {}
