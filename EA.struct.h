//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Includes EA's structs.
 */

// Includes.
#include "DateTime.mqh"
#include "Task.struct.h"

/* Defines EA config parameters. */
struct EAParams {
  float risk_margin_max;       // Max margin to risk in percentage.
  string author;               // EA's author.
  string desc;                 // EA's description.
  string name;                 // EA's name.
  string symbol;               // Symbol to trade on.
  string ver;                  // EA's version.
  unsigned int flags;          // EA param flags.
  unsigned short data_export;  // Format to export the data.
  unsigned short data_store;   // Type of data to store.
  ENUM_LOG_LEVEL log_level;    // Log verbosity level.
  int chart_info_freq;         // Updates info on chart (in secs, 0 - off).
  TaskEntry task_entry;        // Task entry to add on init.
  // Struct special methods.
  EAParams(string _name = __FILE__, ENUM_LOG_LEVEL _ll = V_INFO, unsigned long _magic = 0)
      : author("unknown"),
        data_store(EA_DATA_STORE_NONE),
        flags(EA_PARAM_FLAG_NONE),
        risk_margin_max(5),
        name(_name),
        desc("..."),
        symbol(_Symbol),
        ver("v1.00"),
        log_level(_ll),
        chart_info_freq(0) {}
  // Flag methods.
  bool CheckFlag(unsigned int _flag) { return bool(flags & _flag); }
  void AddFlags(unsigned int _flags) { flags |= _flags; }
  void RemoveFlags(unsigned int _flags) { flags &= ~_flags; }
  void SetFlag(ENUM_EA_PARAM_FLAGS _flag, bool _value) {
    if (_value) {
      AddFlags(_flag);
    } else {
      RemoveFlags(_flag);
    }
  }
  void SetFlags(unsigned int _flags) { flags = _flags; }
  // Getters.
  template <typename T>
  T Get(ENUM_EA_PARAM _param) {
    switch (_param) {
      case EA_PARAM_AUTHOR:
        return (T)author;
      case EA_PARAM_CHART_INFO_FREQ:
        return (T)chart_info_freq;
      case EA_PARAM_DATA_EXPORT:
        return (T)data_export;
      case EA_PARAM_DATA_STORE:
        return (T)data_store;
      case EA_PARAM_DESC:
        return (T)desc;
      case EA_PARAM_LOG_LEVEL:
        return (T)log_level;
      case EA_PARAM_NAME:
        return (T)name;
      case EA_PARAM_RISK_MARGIN_MAX:
        return (T)risk_margin_max;
      case EA_PARAM_SYMBOL:
        return (T)symbol;
      // case EA_PARAM_TASK_ENTRY: return (T) task_entry;
      case EA_PARAM_VER:
        return (T)ver;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return (T)WRONG_VALUE;
  }
  // Setters.
  template <typename T>
  void Set(ENUM_EA_PARAM _param, T _value) {
    switch (_param) {
      case EA_PARAM_AUTHOR:
        author = (string)_value;
        return;
      case EA_PARAM_CHART_INFO_FREQ:
        chart_info_freq = (int)_value;
        return;
      case EA_PARAM_DATA_EXPORT:
        data_export = (unsigned short)_value;
        return;
      case EA_PARAM_DATA_STORE:
        data_store = (unsigned short)_value;
        return;
      case EA_PARAM_DESC:
        desc = (string)_value;
        return;
      case EA_PARAM_LOG_LEVEL:
        log_level = (ENUM_LOG_LEVEL)_value;
        return;
      case EA_PARAM_NAME:
        name = (string)_value;
        return;
      case EA_PARAM_RISK_MARGIN_MAX:
        risk_margin_max = (float)_value;
        return;
      case EA_PARAM_SYMBOL:
        symbol = (string)_value;
        return;
      // case EA_PARAM_TASK_ENTRY: SetTaskEntry(_value); return;
      case EA_PARAM_VER:
        ver = (string)_value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void SetTaskEntry(TaskEntry &_task_entry) { task_entry = _task_entry; }
  // Printers.
  string ToString(string _dlm = ",") { return StringFormat("%s v%s by %s (%s)", name, ver, author, desc); }
};

/* Defines struct to store results for EA processing. */
struct EAProcessResult {
  unsigned int last_error;               // Last error code.
  unsigned short stg_errored;            // Number of errored strategies.
  unsigned short stg_processed;          // Number of processed strategies.
  unsigned short stg_processed_periods;  // Number of new period processed.
  unsigned short stg_suspended;          // Number of suspended strategies.
  unsigned short tasks_processed;        // Number of tasks processed.
  EAProcessResult() { Reset(); }
  void Reset() {
    stg_errored = stg_processed = stg_suspended = 0;
    ResetError();
  }
  void ResetError() {
    ResetLastError();
    last_error = ERR_NO_ERROR;
  }
  string ToString() { return StringFormat("%d", last_error); }
};

/* Defines EA state variables. */
struct EAState {
  unsigned short flags;      // Action flags.
  unsigned short new_periods; // Started periods.
  DateTime last_updated;     // Last updated.
  // Constructor.
  EAState() { AddFlags(EA_STATE_FLAG_ACTIVE | EA_STATE_FLAG_ENABLED); }
  // Struct methods.
  // Flag methods.
  bool CheckFlag(unsigned short _flag) { return bool(flags & _flag); }
  void AddFlags(unsigned short _flags) { flags |= _flags; }
  void RemoveFlags(unsigned short _flags) { flags &= ~_flags; }
  void SetFlag(ENUM_EA_STATE_FLAGS _flag, bool _value) {
    if (_value) {
      AddFlags(_flag);
    } else {
      RemoveFlags(_flag);
    }
  }
  void SetFlags(unsigned short _flags) { flags = _flags; }
  // State methods.
  bool IsActive() { return CheckFlag(EA_STATE_FLAG_ACTIVE); }
  bool IsConnected() { return CheckFlag(EA_STATE_FLAG_CONNECTED); }
  bool IsEnabled() { return CheckFlag(EA_STATE_FLAG_ENABLED); }
  bool IsLibsAllowed() { return CheckFlag(EA_STATE_FLAG_LIBS_ALLOWED); }
  bool IsOnInit() { return CheckFlag(EA_STATE_FLAG_ON_INIT); }
  bool IsOnQuit() { return CheckFlag(EA_STATE_FLAG_ON_QUIT); }
  bool IsOptimizationMode() { return CheckFlag(EA_STATE_FLAG_OPTIMIZATION); }
  bool IsTestingMode() { return CheckFlag(EA_STATE_FLAG_TESTING); }
  bool IsTradeAllowed() { return CheckFlag(EA_STATE_FLAG_TRADE_ALLOWED); }
  bool IsVisualMode() { return CheckFlag(EA_STATE_FLAG_VISUAL_MODE); }
  // Setters.
  void Enable(bool _state = true) { SetFlag(EA_STATE_FLAG_ENABLED, _state); }
};
