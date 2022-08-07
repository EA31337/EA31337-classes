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
 * Test functionality of Log class.
 */

// Includes.
#include "../DictStruct.mqh"
#include "../Log.mqh"
#include "../Refs.struct.h"
#include "../Test.mqh"

// Variables.
DictStruct<int, Ref<Log>> logs;

/**
 * Implements OnInit().
 */
int OnInit() {
  Ref<Log> log_trace = new Log(V_TRACE);
  Ref<Log> log_debug = new Log(V_DEBUG);
  Ref<Log> log_info = new Log(V_INFO);
  Ref<Log> log_warning = new Log(V_WARNING);
  Ref<Log> log_error = new Log(V_ERROR);

  logs.Push(log_trace);
  logs.Push(log_debug);
  logs.Push(log_info);
  logs.Push(log_warning);
  logs.Push(log_error);

  Ref<Log> sub_log_trace = new Log(V_TRACE);
  log_trace.Ptr().Link(sub_log_trace.Ptr());

  log_trace.Ptr().Trace("Trace", "Prefix", "Suffix");
  log_debug.Ptr().Debug("Debug", "Prefix", "Suffix");
  log_info.Ptr().Info("Info", "Prefix", "Suffix");
  log_warning.Ptr().Warning("Warning", "Prefix", "Suffix");

  return (INIT_SUCCEEDED);
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {}
