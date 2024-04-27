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
 * Test functionality of TaskSetter class.
 */

// Includes.
#include "../../Test.mqh"
#include "../TaskSetter.h"

enum ENUM_TASK_SETTER_TEST {
  TASK_SETTER_TEST01 = 1,
  TASK_SETTER_TEST02 = 2,
  TASK_SETTER_TEST03 = 3,
};

struct TaskSetterTest01Data {
  int value;
  TaskSetterTest01Data(int _value) : value(_value) {}
  int GetValue() const { return value; }
  void SetValue(int _value) { value = _value; }
};

class TaskSetterTest01 : protected TaskSetterBase<TaskSetterTest01Data> {
 protected:
  TaskSetterTest01Data data;

 public:
  TaskSetterTest01() : data(0){};
  int GetValue() const { return data.GetValue(); }
  bool Set(const TaskSetterEntry &_entry, const TaskSetterTest01Data &_entry_value) {
    data.SetValue(data.GetValue() + _entry_value.GetValue());
    PrintFormat("Set: %s; value=%d", __FUNCSIG__, data.GetValue());
    return true;
  }
};

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  // Test01
  TaskSetterEntry _entry01(TASK_SETTER_TEST01);
  TaskSetterTest01 _test01;
  TaskSetterTest01Data _data_entry(1);
  _result &= _test01.Set(_entry01, _data_entry);
  _data_entry.SetValue(2);
  _result &= _test01.Set(_entry01, _data_entry);
  _data_entry.SetValue(3);
  _result &= _test01.Set(_entry01, _data_entry);
  assertTrueOrFail(_result && _test01.GetValue() == 6, "Fail!");
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
