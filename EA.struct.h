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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "DateTime.mqh"
#include "Task.struct.h"

/* Defines EA config parameters. */
struct EAParams {
 protected:
  float risk_margin_max;       // Max margin to risk in percentage.
  string author;               // EA's author.
  string desc;                 // EA's description.
  string name;                 // EA's name.
  string symbol;               // Symbol to trade on.
  string ver;                  // EA's version.
  unsigned int flags;          // EA's param flags.
  unsigned int signal_filter;  // EA's signal filter.
  unsigned short data_export;  // Format to export the data.
  unsigned short data_store;   // Type of data to store.
  ENUM_LOG_LEVEL log_level;    // Log verbosity level.
  int chart_info_freq;         // Updates info on chart (in secs, 0 - off).
  TaskEntry task_init;         // Task entry to add and process on EA init.

 public:
  // Defines enumeration for EA params properties.
  enum ENUM_EA_PARAM_PROP {
    EA_PARAM_PROP_NONE = 0,         // None
    EA_PARAM_PROP_AUTHOR,           // Author
    EA_PARAM_PROP_CHART_INFO_FREQ,  // Chart frequency
    EA_PARAM_PROP_DATA_EXPORT,      // Data export
    EA_PARAM_PROP_DATA_STORE,       // Data store
    EA_PARAM_PROP_DESC,             // Description
    EA_PARAM_PROP_FLAGS,            // Flags
    EA_PARAM_PROP_LOG_LEVEL,        // Log level
    EA_PARAM_PROP_NAME,             // Name
    EA_PARAM_PROP_RISK_MARGIN_MAX,  // Maximum margin to risk
    EA_PARAM_PROP_SIGNAL_FILTER,    // Signal filter
    EA_PARAM_PROP_SYMBOL,           // Symbol
    EA_PARAM_PROP_VER,              // Version
  };
  // Defines enumeration for EA params structs.
  enum ENUM_EA_PARAM_STRUCT {
    EA_PARAM_STRUCT_NONE = 0,    // None
    EA_PARAM_STRUCT_TASK_ENTRY,  // Task entry
  };
  // Defines enumeration for strategy signal filters.
  enum ENUM_EA_PARAM_SIGNAL_FILTER {
    EA_PARAM_SIGNAL_FILTER_NONE = 0 << 0,         // None flags.
    EA_PARAM_SIGNAL_FILTER_FIRST = 1 << 0,        // First signal only
    EA_PARAM_SIGNAL_FILTER_OPEN_M_IF_H = 1 << 1,  // Minute-based confirmed by hourly signal
  };

  // Struct special methods.
  EAParams(string _name = __FILE__, ENUM_LOG_LEVEL _ll = V_INFO, unsigned long _magic = 0)
      : author("unknown"),
        data_store(EA_DATA_STORE_NONE),
        flags(EA_PARAM_FLAG_NONE),
        risk_margin_max(5),
        name(_name),
        desc("..."),
        signal_filter(EA_PARAM_SIGNAL_FILTER_NONE),
        symbol(_Symbol),
        ver("v1.00"),
        log_level(_ll),
        chart_info_freq(0) {}
  // Flag methods.
  bool CheckFlag(unsigned int _flag) { return bool(flags & _flag); }
  bool CheckFlagDataStore(unsigned int _flag) { return bool(data_store & _flag); }
  bool CheckSignalFilter(unsigned int _flag) { return bool(signal_filter & _flag); }
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
  T Get(unsigned int _param) {
    switch (_param) {
      case EA_PARAM_PROP_AUTHOR:
        return (T)author;
      case EA_PARAM_PROP_CHART_INFO_FREQ:
        return (T)chart_info_freq;
      case EA_PARAM_PROP_DATA_EXPORT:
        return (T)data_export;
      case EA_PARAM_PROP_DATA_STORE:
        return (T)data_store;
      case EA_PARAM_PROP_DESC:
        return (T)desc;
      case EA_PARAM_PROP_LOG_LEVEL:
        return (T)log_level;
      case EA_PARAM_PROP_NAME:
        return (T)name;
      case EA_PARAM_PROP_RISK_MARGIN_MAX:
        return (T)risk_margin_max;
      case EA_PARAM_PROP_SIGNAL_FILTER:
        return (T)signal_filter;
      case EA_PARAM_PROP_SYMBOL:
        return (T)symbol;
      case EA_PARAM_PROP_VER:
        return (T)ver;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return (T)WRONG_VALUE;
  }
  template <typename T>
  T GetStruct(unsigned int _param) {
    switch (_param) {
      case EA_PARAM_STRUCT_TASK_ENTRY:
        return (T)task_init;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    T _empty();
    return _empty;
  }
  // Setters.
  template <typename T>
  void Set(STRUCT_ENUM(EAParams, ENUM_EA_PARAM_PROP) _param, T _value) {
    switch (_param) {
      case EA_PARAM_PROP_AUTHOR:
        author = (string)_value;
        return;
      case EA_PARAM_PROP_CHART_INFO_FREQ:
        chart_info_freq = (int)_value;
        return;
      case EA_PARAM_PROP_DATA_EXPORT:
        data_export = (unsigned short)_value;
        return;
      case EA_PARAM_PROP_DATA_STORE:
        data_store = (unsigned short)_value;
        return;
      case EA_PARAM_PROP_DESC:
        desc = (string)_value;
        return;
      case EA_PARAM_PROP_LOG_LEVEL:
        log_level = (ENUM_LOG_LEVEL)_value;
        return;
      case EA_PARAM_PROP_NAME:
        name = (string)_value;
        return;
      case EA_PARAM_PROP_RISK_MARGIN_MAX:
        risk_margin_max = (float)_value;
        return;
      case EA_PARAM_PROP_SIGNAL_FILTER:
        signal_filter = (unsigned int)_value;
        return;
      case EA_PARAM_PROP_SYMBOL:
        symbol = (string)_value;
        return;
      // case EA_PARAM_TASK_ENTRY: SetTaskEntry(_value); return;
      case EA_PARAM_PROP_VER:
        ver = (string)_value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  // Sets EA's details (name, description, version and author).
  void SetDetails(string _name = "", string _desc = "", string _ver = "", string _author = "") {
    name = _name;
    desc = _desc;
    ver = _ver;
    author = _author;
  }
  void SetTaskEntry(TaskEntry &_task_entry) { task_init = _task_entry; }
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
 public:                  // @todo: Move to protected.
  DateTime last_updated;  // Last updated.
 protected:
  unsigned int flags;        // Action flags.
  unsigned int new_periods;  // Started periods.
 public:
  /* Struct's enumerations */

  /* Defines EA state flags. */
  enum ENUM_EA_STATE_FLAGS {
    EA_STATE_FLAG_NONE = 0 << 0,           // None flags.
    EA_STATE_FLAG_ACTIVE = 1 << 0,         // Is active (can trade).
    EA_STATE_FLAG_CONNECTED = 1 << 1,      // Indicates connectedness to a trade server.
    EA_STATE_FLAG_ENABLED = 1 << 2,        // Is enabled.
    EA_STATE_FLAG_LIBS_ALLOWED = 1 << 3,   // Indicates the permission to use external libraries (such as DLL).
    EA_STATE_FLAG_ON_INIT = 1 << 4,        // Indicates EA is during initializing procedure (constructor).
    EA_STATE_FLAG_ON_QUIT = 1 << 5,        // Indicates EA is during exiting procedure (deconstructor).
    EA_STATE_FLAG_OPTIMIZATION = 1 << 6,   // Indicates EA runs in optimization mode.
    EA_STATE_FLAG_TESTING = 1 << 7,        // Indicates EA runs in testing mode.
    EA_STATE_FLAG_TRADE_ALLOWED = 1 << 8,  // Indicates the permission to trade on the chart.
    EA_STATE_FLAG_VISUAL_MODE = 1 << 9,    // Indicates EA runs in visual testing mode.
  };

  // Enumeration for strategy signal properties.
  enum ENUM_EA_STATE_PROP {
    EA_STATE_PROP_FLAGS = 1,
    EA_STATE_PROP_LAST_UPDATED,
    EA_STATE_PROP_NEW_PERIODS,
    EA_STATE_PROP_TIMESTAMP,
  };

  /* Constructors */

  // Constructor.
  EAState() { EAState::AddFlags(EA_STATE_FLAG_ACTIVE | EA_STATE_FLAG_ENABLED); }
  // Struct methods.
  /* Getters */
  template <typename T>
  T Get(STRUCT_ENUM(EAState, ENUM_EA_STATE_PROP) _prop) {
    switch (_prop) {
      case EA_STATE_PROP_FLAGS:
        return (T)flags;
      /* @fixme
      case EA_STATE_PROP_LAST_UPDATED:
        return (T)last_updated;
      */
      case EA_STATE_PROP_NEW_PERIODS:
        return (T)new_periods;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return (T)WRONG_VALUE;
  }
  bool Get(STRUCT_ENUM(EAState, ENUM_EA_STATE_FLAGS) _prop) { return CheckFlag(_prop); }
  /* Setters */
  template <typename T>
  void Set(STRUCT_ENUM(EAState, ENUM_EA_STATE_PROP) _prop, T _value) {
    switch (_prop) {
      case EA_STATE_PROP_FLAGS:
        flags = (unsigned int)_value;
        return;
      /* @fixme
      case EA_STATE_PROP_LAST_UPDATED:
        last_updated = (unsigned int)_value;
        return;
      */
      case EA_STATE_PROP_NEW_PERIODS:
        new_periods = (unsigned int)_value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void Set(STRUCT_ENUM(EAState, ENUM_EA_STATE_FLAGS) _prop, bool _value) { SetFlag(_prop, _value); }
  // Flag methods.
  bool CheckFlag(unsigned int _flag) { return bool(flags & _flag); }
  void AddFlags(unsigned int _flags) { flags |= _flags; }
  void RemoveFlags(unsigned int _flags) { flags &= ~_flags; }
  void SetFlag(ENUM_EA_STATE_FLAGS _flag, bool _value) {
    if (_value) {
      AddFlags(_flag);
    } else {
      RemoveFlags(_flag);
    }
  }
  void SetFlags(unsigned int _flags) { flags = _flags; }
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
