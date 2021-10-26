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
 * Test functionality of Taskable class.
 */

// Includes.
#include "../../Test.mqh"
#include "../Taskable.h"

class TaskTest01 : public Taskable {
 protected:
  long sum;

 public:
  TaskTest01() : sum(0){};
  long GetSum() { return sum; }

  /**
   * Checks a condition.
   */
  bool Check(const TaskConditionEntry &_entry) {
    sum += _entry.GetId();
    PrintFormat("Checks: %s; sum=%d", __FUNCSIG__, sum);
    return true;
  }

  /* Main methods */

  /**
   * Runs an action.
   */
  virtual bool Run(const TaskActionEntry &_entry) {
    sum += _entry.GetId();
    PrintFormat("Runs: %s; sum=%d", __FUNCSIG__, sum);
    return true;
  }
};

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  TaskTest01 _test01;
  // Checks dummy condition.
  TaskConditionEntry _entry_cond(2);
  _result &= _test01.Check(_entry_cond);
  // Runs dummy action.
  TaskActionEntry _entry_action(2);
  _result &= _test01.Run(_entry_action);
  // Checks the results.
  assertTrueOrFail(_result && _test01.GetSum() == 4, "Fail!");
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
