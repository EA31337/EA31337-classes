//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
 * Test functionality of TaskGetter class.
 */

// Includes.
#include "../../Test.mqh"
#include "../TaskGetter.h"

enum ENUM_TASK_GETTER_TEST {
  TASK_GETTER_TEST01 = 1,
  TASK_GETTER_TEST02 = 2,
  TASK_GETTER_TEST03 = 3,
};

struct TaskGetterTest01Data {
  int value;
  TaskGetterTest01Data() : value(0) {}
  int GetValue() { return value; }
  void SetValue(int _value) { value = _value; }
};

class TaskGetterTest01 : public TaskGetter<TaskGetterTest01Data> {
 protected:
  TaskGetterTest01Data data;

 public:
  TaskGetterTest01(){};
  // int64 GetSum() { return sum; }
  TaskGetterTest01Data Get() { return TaskGetter<TaskGetterTest01Data>::Get(); }
  TaskGetterTest01Data Get(const TaskGetterEntry &_entry) {
    data.SetValue(_entry.GetId());
    PrintFormat("Get: %s; value=%d", __FUNCSIG__, data.GetValue());
    return data;
  }
};

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  int _sum = 0;
  // Test01
  TaskGetterTest01 _test01;
  TaskGetterEntry _entry01(TASK_GETTER_TEST01);
  _result &= _entry01.Get(STRUCT_ENUM(TaskGetterEntry, TASK_GETTER_ENTRY_FLAG_IS_ACTIVE));
  _test01.Set(STRUCT_ENUM(TaskGetterEntry, TASK_GETTER_ENTRY_ID), TASK_GETTER_TEST01);
  _sum += _test01.Get().GetValue();
  _sum += _test01.Get(_entry01).GetValue();
  _test01.Set(STRUCT_ENUM(TaskGetterEntry, TASK_GETTER_ENTRY_ID), TASK_GETTER_TEST02);
  _sum += _test01.Get().GetValue();
  _sum += _test01.Get(_entry01).GetValue();
  _test01.Set(STRUCT_ENUM(TaskGetterEntry, TASK_GETTER_ENTRY_ID), TASK_GETTER_TEST03);
  _sum += _test01.Get().GetValue();
  _sum += _test01.Get(_entry01).GetValue();
  assertTrueOrFail(_result && _sum == 9, "Fail!");
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
