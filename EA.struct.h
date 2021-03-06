//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
#include "Task.struct.h"

/** 
  * Defines EA config parameters.
  */
struct EAParams {
  float lot_size;              // Lot size to use when lotsize auto flag is on.
  float risk_margin_max;       // Max margin to risk in percentage.
  string author;               // EA's author.
  string desc;                 // EA's description.
  string name;                 // EA's name.
  string symbol;               // Symbol to trade on.
  string ver;                  // EA's version.
  unsigned int flags;          // EA param flags.
  unsigned long magic_no;      // Magic number.
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
        lot_size(0.0f),
        risk_margin_max(5),
        name(_name),
        desc("..."),
        symbol(_Symbol),
        ver("v1.00"),
        log_level(_ll),
        magic_no(_magic > 0 ? _magic : rand()),
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
  float GetLotSize() { return lot_size; }
  float GetRiskMarginMax() { return risk_margin_max; }
  string GetAuthor() { return author; }
  string GetName() { return name; }
  string GetSymbol() { return symbol; }
  string GetDesc() { return desc; }
  string GetVersion() { return ver; }
  unsigned long GetMagicNo() { return magic_no; }
  unsigned short GetDataStore() { return data_store; }
  unsigned short GetDataExport() { return data_export; }
  ENUM_LOG_LEVEL GetLogLevel() { return log_level; }
  // Setters.
  void SetAuthor(string _author) { author = _author; }
  void SetChartInfoFreq(bool _secs) { chart_info_freq = _secs; }
  void SetDataExport(unsigned short _dexport) { data_export = _dexport; }
  void SetDataStore(unsigned short _dstores) { data_store = _dstores; }
  void SetDesc(string _desc) { desc = _desc; }
  void SetLogLevel(ENUM_LOG_LEVEL _level) { log_level = _level; }
  void SetLotSize(float _value) { lot_size = _value; }
  void SetName(string _name) { name = _name; }
  void SetRiskMarginMax(float _value) { risk_margin_max = _value; }
  void SetTaskEntry(TaskEntry &_task_entry) { task_entry = _task_entry; }
  void SetVersion(string _ver) { ver = _ver; }
  // Printers.
  string ToString(string _dlm = ",") { return StringFormat("%s v%s by %s (%s)", name, ver, author, desc); }
};

/** 
  * Defines struct to store results for EA processing.
  */
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

/** 
  * Defines EA state variables.
  */
struct EAState {
  unsigned short flags;        // Action flags.
  unsigned short new_periods;  // Started periods.
  DateTime last_updated;       // Last updated.
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
