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
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of Platform class.
 */

// Includes.
#include "../../Test.mqh"
#include "../Platform.h"

// Test Platform tasks.
bool TestPlatform01() {
  bool _result = true;
  // Initialize a dummy Exchange instance.
  PlatformParams _pparams;
  Ref<Platform> platform = new Platform(_pparams);
  // Add exchange01 via task.
  TaskActionEntry _task_add_ex_01(PLATFORM_ACTION_ADD_EXCHANGE);
  // DataParamEntry _ex_01_entry = "";
  //_task_add_ex_01.ArgAdd(_ex_01_entry);
  platform.Ptr().Run(_task_add_ex_01);
  Print(platform.Ptr().ToString());
  return _result;
}

/**
 * Implements OnInit().
 */
int OnInit() {
  bool _result = true;
  assertTrueOrFail(TestPlatform01(), "Fail!");
  return _result && GetLastError() == 0 ? INIT_SUCCEEDED : INIT_FAILED;
}

/**
 * Implements Tick event handler.
 */
void OnTick() {}
