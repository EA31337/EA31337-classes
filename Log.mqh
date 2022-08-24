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

// Prevents processing this includes file for the second time.
#ifndef LOG_MQH
#define LOG_MQH

// Forward class declaration.
template <typename K, typename V>
class DictStruct;

// Includes.
#include "Array.mqh"
#include "Collection.mqh"
#include "DateTime.mqh"
#include "DictStruct.mqh"
#include "Object.mqh"

// Define assert macros.
// Alias for function and line macros combined together.
#define __FUNCTION_LINE__ string(__FUNCTION__) + ":" + IntegerToString(__LINE__)

// Log verbosity level.
enum ENUM_LOG_LEVEL {
  V_NONE = 0,     // None
  V_ERROR = 1,    // Errors only
  V_WARNING = 2,  // Errors and warnings
  V_INFO = 3,     // All (info, errors and warnings)
  V_DEBUG = 4,    // All with debug!
  V_TRACE = 5     // All with debug and trace!
};

/**
 * Class to provide logging functionality.
 */
class Log : public Object {
 private:
  struct log_entry {
    datetime timestamp;
    ENUM_LOG_LEVEL log_level;
    string msg;
  };
  DictStruct<int, Ref<Log>> logs;
  string filename;
  ARRAY(log_entry, data);
  int last_entry;
  datetime last_flush;
  ENUM_LOG_LEVEL log_level;

 public:
  /**
   * Class constructor.
   */
  Log(ENUM_LOG_LEVEL _log_level = V_INFO, string new_filename = "")
      : last_entry(-1), last_flush(0), log_level(_log_level), filename(new_filename != "" ? new_filename : "Log.txt") {}

  /**
   * Class deconstructor.
   */
  ~Log() { Flush(); }

  /* Getters */

  /**
   * Get last message.
   */
  string GetLastMsg(ENUM_LOG_LEVEL _level = V_INFO, bool _dt = false) {
    int i;
    string _output = "";
    for (i = last_entry; i == 0; i--) {
      if (data[i].log_level <= _level) {
        _output += (_dt ? DateTimeStatic::TimeToStr(data[i].timestamp) + ": " : "") + data[i].msg;
        break;
      }
    }
    return _output;
  }

  /**
   * Returns log level.
   */
  ENUM_LOG_LEVEL GetLevel() { return log_level; }

  /**
   * Returns level name.
   */
  string GetLevelName(ENUM_LOG_LEVEL _log_level) { return StringSubstr(EnumToString(_log_level), 2); }

  /* Setters */

  /**
   * Sets new log level.
   */
  void SetLevel(ENUM_LOG_LEVEL _log_level) { log_level = _log_level; }

  /* Other methods */

  /**
   * Adds a log entry.
   */
  bool Add(ENUM_LOG_LEVEL _log_level, string msg, string prefix, string suffix) {
    if (_log_level > log_level) {
      // Ignore entry if verbosity is higher than set.
      return false;
    }
    int _size = ArraySize(data);
    if (last_entry > 0 && msg == data[last_entry].msg) {
      // Avoid adding duplicate messages.
      return false;
    }
    if (++last_entry >= _size) {
      if (!ArrayResize(data, (_size + 100), 100)) {
        return false;
      }
    }
    msg = GetLevelName(_log_level) + ": " + (prefix != "" ? prefix + ": " : "") + msg +
          (suffix != "" ? "; " + suffix : "");
    data[last_entry].timestamp = TimeCurrent();
    data[last_entry].log_level = _log_level;
    data[last_entry].msg = msg;
    return true;
  }

  /**
   * Adds a log entry.
   */
  bool Add(string msg, string prefix, string suffix, ENUM_LOG_LEVEL entry_log_level = V_INFO) {
    return Add(prefix, msg, suffix, entry_log_level);
  }
  bool Add(ARRAY_REF(double, arr), string prefix, string suffix, ENUM_LOG_LEVEL entry_log_level = V_INFO) {
    return Add(prefix, Array::ArrToString(arr), suffix, entry_log_level);
  }

  /**
   * Reports an last error.
   */
  bool AddLastError(string prefix = "", string suffix = "");
  bool AddLastError(string prefix, long suffix);

  /**
   * Reports an error.
   */
  bool Error(string msg, string prefix = "", string suffix = "") { return Add(V_ERROR, msg, prefix, suffix); }

  /**
   * Reports a warning.
   */
  bool Warning(string msg, string prefix = "", string suffix = "") { return Add(V_WARNING, msg, prefix, suffix); }

  /**
   * Reports an info message.
   */
  bool Info(string msg, string prefix = "", string suffix = "") { return Add(V_INFO, msg, prefix, suffix); }

  /**
   * Reports a debug message for debugging purposes.
   */
  bool Debug(string msg, string prefix = "", string suffix = "") { return Add(V_DEBUG, msg, prefix, suffix); }

  /**
   * Reports a debug message for debugging purposes.
   */
  bool Trace(string msg, string prefix = "", string suffix = "") { return Add(V_TRACE, msg, prefix, suffix); }

  /**
   * Link this instance with another log instance.
   */
  void Link(Log *_log) {
    PTR_ATTRIB(_log, SetLevel(log_level));  // Sets the same level as this instance.
    // @todo: Make sure we're not linking the same instance twice.
    logs.Push(_log);
  }

  /**
   * Copy logs into another array.
   */
  bool Copy(ARRAY_REF(log_entry, _logs)) {
    // @fixme
    // Error: 'ArrayCopy<log_entry>' - cannot to apply function template
    // Array::ArrayCopy(_logs, data, 0, 0, WHOLE_ARRAY);
    if (!ArrayResize(_logs, last_entry)) {
      return false;
    }
    for (int i = 0; i < last_entry; i++) {
      _logs[i] = data[i];
    }
    return ArraySize(_logs) > 0;
  }

  /**
   * Append logs into another array.
   */
  bool Append(ARRAY_REF(log_entry, _logs)) {
    // @fixme
    // Error: 'ArrayCopy<log_entry>' - cannot to apply function template
    // Array::ArrayCopy(_logs, data, 0, 0, WHOLE_ARRAY);
    unsigned int _size = ArraySize(_logs);
    if (!ArrayResize(_logs, _size + last_entry)) {
      return false;
    }
    for (int i = 0; i < last_entry; i++) {
      _logs[_size + i] = data[i];
    }
    return ArraySize(_logs) > 0;
  }

/**
 * Flushes all log entries by printing them to the output.
 */
#ifdef __MQL__
  template <>
#endif
  void Flush(int _freq = 0, bool _dt = true) {
    if (_freq > 0 && last_flush + _freq >= TimeCurrent()) {
      // Avoids flushing logs too often.
      return;
    }
    for (int i = 0; i <= last_entry; i++) {
      if (data[i].timestamp > last_flush) {
        Print((_dt ? DateTimeStatic::TimeToStr(data[i].timestamp) + ": " : ""), data[i].msg);
      }
    }
    // Flush logs from another linked instances.
    for (DictStructIterator<int, Ref<Log>> _li = logs.Begin(); _li.IsValid(); ++_li) {
      Log *_log = _li.Value().Ptr();
      if (Object::IsValid(_log)) {
        PTR_ATTRIB(_log, Flush());
      }
    }

    last_entry = -1;
    last_flush = TimeCurrent();
  }

  /**
   * Flushes all log entries by printing them to the output.
   */
  /*
 void Flush(bool _dt = true) {
   Flush(log_level, _dt);
 }
 */

  string ToString() override {
    string result;

    unsigned int lid;
    int i;
    for (i = 0; i <= last_entry; i++) {
      result += DateTimeStatic::TimeToStr(data[i].timestamp) + ": " + data[i].msg + "\n";
    }

    Log *_log;
    // Flush logs from another linked instances.
    for (lid = 0; lid < logs.Size(); lid++) {
      _log = logs[lid].Ptr();
      if (Object::IsValid(_log)) {
        result += PTR_ATTRIB(_log, ToString());
      }
    }

    return result;
  }

  /**
   * Save logs to file in CSV format.
   */
  bool SaveToFile(string new_filename, ENUM_LOG_LEVEL _log_level) {
    string filepath = new_filename != "" ? new_filename : filename;
    int handle = FileOpen(filepath, FILE_WRITE | FILE_CSV, ':');
    if (handle != INVALID_HANDLE) {
      for (int i = 0; i < ArraySize(data); i++) {
        if (data[i].log_level <= _log_level) {
          FileWrite(handle, TimeToString(data[i].timestamp, TIME_DATE | TIME_MINUTES), ": ", data[i].msg);
        }
      }
      FileClose(handle);
      return true;
    } else {
      FileClose(handle);
      return false;
    }
  }

  bool SaveToFile(string new_filename = "") { return SaveToFile(new_filename, log_level); }

  template <typename T>
  void Erase(ARRAY_REF(T, A), int iPos) {
    int iLast = ArraySize(A) - 1;
    A[iPos].timestamp = A[iLast].timestamp;
    A[iPos].msg = A[iLast].msg;
    ArrayResize(A, iLast);
  }

  bool DeleteByTimestamp(datetime timestamp) {
    int size = ArraySize(data);
    if (size > 0) {
      int offset = 0;
      for (int i = 0; i < size; i++) {
        if (data[i].timestamp == timestamp) {
          Erase(data, i);
          return true;
          break;
        }
      }
    }
    return false;
  }
};

#include "Terminal.mqh"

/**
 * Reports last error.
 */
bool Log::AddLastError(string prefix, string suffix) {
  return Add(V_ERROR, Terminal::GetLastErrorText(), prefix, suffix);
}
bool Log::AddLastError(string prefix, long suffix) {
  return Add(V_ERROR, Terminal::GetLastErrorText(), prefix, StringFormat("%d", suffix));
}

#endif
