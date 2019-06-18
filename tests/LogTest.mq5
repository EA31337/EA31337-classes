//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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
 * Test functionality of Log class.
 */

// Properties.
#property strict

// Includes.
#include "../Collection.mqh"
#include "../Log.mqh"
#include "../Test.mqh"

// Variables.
Collection *logs;

/**
 * Implements OnInit().
 */
int OnInit() {
  logs = new Collection();
  Log *log_trace = logs.Add(new Log(V_TRACE));
  Log *log_debug = logs.Add(new Log(V_DEBUG));
  Log *log_info  = logs.Add(new Log(V_INFO));
  Log *log_warn  = logs.Add(new Log(V_WARNING));
  Log *log_error = logs.Add(new Log(V_ERROR));

  log_trace.Trace("Trace", "Prefix", "Suffix");
  log_debug.Debug("Debug", "Prefix", "Suffix");
  log_info.Info("Info", "Prefix", "Suffix");
  log_warn.Warning("Warning", "Prefix", "Suffix");
  log_error.Error("Error", "Prefix", "Suffix");
  Print(logs.ToString(0, "\n"));
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  Object::Delete(logs);
}
