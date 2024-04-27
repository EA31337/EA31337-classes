//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
 * Test functionality of TaskAction class.
 */

// Includes.
#include "../../Test.mqh"
#include "../TaskAction.h"

enum ENUM_TASK_ACTION_TEST {
  TASK_ACTION_TEST01 = 1,
  TASK_ACTION_TEST02 = 2,
  TASK_ACTION_TEST03 = 3,
};

class TaskActionTest01 : public TaskActionBase {
 protected:
  long sum;

 public:
  TaskActionTest01() : sum(0){};
  long GetSum() { return sum; }
  bool Run(const TaskActionEntry &_entry) {
    sum += _entry.GetId();
    PrintFormat("%s; sum=%d", __FUNCSIG__, sum);
    return true;
  }
};

class TaskActionTest02 : public TaskActionBase {
 protected:
  long sum;

 public:
  TaskActionTest02() : sum(0){};
  long GetSum() { return sum; }
  bool Run(const TaskActionEntry &_entry) {
    sum += _entry.GetId();
    PrintFormat("%s; sum=%d", __FUNCSIG__, sum);
    return true;
  }
};

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  // Test01
  TaskActionTest01 _atest01;
  TaskActionEntry _entry01(TASK_ACTION_TEST01);
  TaskAction<TaskActionTest01> _action01(_entry01, &_atest01);
  _action01.Run();
  _action01.Set(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_ID), TASK_ACTION_TEST02);
  _action01.Run();
  _action01.Set(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_ID), TASK_ACTION_TEST03);
  _action01.Run();
  assertTrueOrFail(_result && _action01.GetObject().GetSum() == 6, "Fail!");
  // Test02.
  TaskActionTest02 _atest02;
  TaskActionEntry _entry02(TASK_ACTION_TEST02);
  TaskAction<TaskActionTest02> _action02(_entry02, &_atest02);
  _action02.Run();
  _action02.Set(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_ID), TASK_ACTION_TEST02);
  _action02.Run();
  _action02.Set(STRUCT_ENUM(TaskActionEntry, TASK_ACTION_ENTRY_ID), TASK_ACTION_TEST03);
  _action02.Run();
  assertTrueOrFail(_result && _action02.GetObject().GetSum() == 7, "Fail!");
  _result &= GetLastError() == 0;
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
