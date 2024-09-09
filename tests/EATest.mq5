//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
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
 * Test functionality of EA class.
 */

// Forward declaration.
struct DataParamEntry;

// Includes.
#include "../EA.mqh"
#include "../Exchange/Account/Account.struct.h"
#include "../Test.mqh"

// Defines EA classes.
class EA1 : public EA {
 public:
  EA1(EAParams &_params) : EA(_params) {}
};

class EA2 : public EA {
 public:
  EA2(EAParams &_params) : EA(_params) {}
};

class EA3 : public EA {
 public:
  EA3(EAParams &_params) : EA(_params) {}
};

// Global variables.
EA1 *ea1;
EA2 *ea2;
EA3 *ea3;

/**
 * Implements OnInit().
 */
int OnInit() {
  // Task to export to all possible formats once per hour.
  TaskEntry _task_export_per_hour(EA_ACTION_EXPORT_DATA, EA_COND_ON_NEW_HOUR);

  /* Initialize 1st custom EA */
  EAParams ea_params1("EA1");
  // Exporting to all possible formats once per hour.
  ea_params1.Set(STRUCT_ENUM(EAParams, EA_PARAM_PROP_DATA_STORE), EA_DATA_STORE_ALL);
  ea_params1.Set(STRUCT_ENUM(EAParams, EA_PARAM_PROP_DATA_EXPORT), EA_DATA_EXPORT_ALL);
  ea_params1.SetTaskEntry(_task_export_per_hour);
  ea1 = new EA1(ea_params1);
  assertTrueOrFail(ea1.Get<string>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_NAME)) == "EA1",
                   StringFormat("Invalid EA name: %s!", ea1.Get<string>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_NAME))));
  assertTrueOrFail(ea1.Get(STRUCT_ENUM(EAState, EA_STATE_FLAG_ENABLED)), "EA should be enabled by default!");

  /* Initialize 2nd custom EA */
  EAParams ea_params2("EA2");
  // Exporting to all possible formats once per hour.
  ea_params2.Set(STRUCT_ENUM(EAParams, EA_PARAM_PROP_DATA_STORE), EA_DATA_STORE_ALL);
  ea_params2.Set(STRUCT_ENUM(EAParams, EA_PARAM_PROP_DATA_EXPORT), EA_DATA_EXPORT_ALL);
  ea_params2.SetTaskEntry(_task_export_per_hour);
  ea2 = new EA2(ea_params2);
  assertTrueOrFail(ea2.Get<string>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_NAME)) == "EA2", "Invalid EA2 name!");

  /* Initialize 3rd custom EA */
  EAParams ea_params3("EA3");
  // Create an init task to disable EA when enabled.
  TaskEntry _tentry_ea_disable(EA_ACTION_DISABLE, EA_COND_IS_ENABLED);
  ea_params3.SetTaskEntry(_tentry_ea_disable);
  ea3 = new EA3(ea_params3);
  assertTrueOrFail(!ea3.Get(STRUCT_ENUM(EAState, EA_STATE_FLAG_ENABLED)), "EA should be disabled by a task!");

  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {
  ea1.ProcessTick();
  ea2.ProcessTick();
  ea3.ProcessTick();
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  delete ea1;
  delete ea2;
  delete ea3;
}
