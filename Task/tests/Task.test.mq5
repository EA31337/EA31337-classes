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
 * Test functionality of Task class.
 */

// Forward declaration.
struct DataParamEntry;

// Includes.
#include "../../Test.mqh"
#include "../Task.h"

// Define test classes.
class ConditionType1 : public TaskConditionBase {
 public:
  bool Check(const TaskConditionEntry &_entry) { return true; }
};
class ConditionType2 : public TaskConditionBase {
 public:
  bool Check(const TaskConditionEntry &_entry) { return true; }
};
class ActionType1 : public TaskActionBase {
 public:
  bool Run(const TaskActionEntry &_entry) { return true; }
};
class ActionType2 : public TaskActionBase {
 public:
  bool Run(const TaskActionEntry &_entry) { return true; }
};
class TaskType1 : public Taskable<MqlParam> {
  bool Check(const TaskConditionEntry &_entry) { return true; }
  MqlParam Get(const TaskGetterEntry &_entry) {
    MqlParam _result;
    return _result;
  }
  bool Run(const TaskActionEntry &_entry) { return true; }
  bool Set(const TaskSetterEntry &_entry, const MqlParam &_entry_value) { return true; }
};

// Test 1.
bool TestTask01() {
  bool _result = true;
  Task _task1;
  TaskAction<ActionType1> _taction1;
  TaskAction<ActionType2> _taction2;
  TaskCondition<ConditionType1> _tcond1;
  TaskCondition<ConditionType2> _tcond2;
  return _result;
}

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  _result &= TestTask01();
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
