//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Includes.
#include <EA31337-classes\Arrays.mqh>

// Properties.
#property strict

/**
 * Class to provide logging functionality.
 */
class Log {

public:

  // Log verbosity level.
  enum ENUM_LOG_LEVEL {
    V_NONE     = 0, // None
    V_ERROR    = 1, // Errors only
    V_WARNING  = 2, // Errors and warnings
    V_INFO     = 3, // All
    V_DEBUG    = 4, // All & debug!
    V_TRACE    = 5  // All, debug & trace!
  };

private:

  struct log_entry {
    datetime timestamp;
    ENUM_LOG_LEVEL log_level;
    string  msg;
  };
  string filename;
  log_entry data[];
  uint index;
  ENUM_LOG_LEVEL log_level;

public:

  /**
   * Class constructor.
   */
  void Log(ENUM_LOG_LEVEL user_log_level = V_INFO, string new_filename = "") {
    filename = new_filename != "" ? new_filename : "Log.txt";
    log_level = user_log_level;
    index = 0;
  }


  /**
   * Adds a log entry.
   */
  bool Add(ENUM_LOG_LEVEL entry_log_level, string msg) {
    if (entry_log_level > log_level) {
      // Ignore entry if verbosity is higher than set.
      return False;
    }
    uint size = ArraySize(data);
    if (++index >= size) {
      if (!ArrayResize(data, (size + 100), 100)) {
        return False;
      }
    }
    data[index].timestamp = TimeCurrent();
    data[index].log_level = entry_log_level;
    data[index].msg = msg;
    return True;
  }
  
  bool Add(string msg, string prefix, string suffix, ENUM_LOG_LEVEL entry_log_level = V_INFO) {
    return Add(prefix, msg, suffix, entry_log_level);
  }
  
  bool Add(double &arr[], string prefix, string suffix, ENUM_LOG_LEVEL entry_log_level = V_INFO) {
    return Add(prefix, Arrays::ArrToString(arr), suffix, entry_log_level);
  }

  bool Error(string msg) {
    return Add(V_ERROR, msg);
  }

  bool Warning(string msg) {
    return Add(V_WARNING, msg);
  }

  bool Info(string msg) {
    return Add(V_INFO, msg);
  }

  bool Debug(string msg) {
    return Add(V_DEBUG, msg);
  }

  bool Trace(string msg) {
    return Add(V_TRACE, msg);
  }

  /**
   * Prints and flushes all log entries for given log level.
   */
  void FlushAll(ENUM_LOG_LEVEL max_log_level = V_INFO) {
    for (int i = 0; i < ArraySize(data); i++) {
      Print(TimeToString(data[i].timestamp, TIME_DATE | TIME_MINUTES), ": ", data[i].msg);
    }
    index = 0;
  }
  
  /**
   * Prints and flushes all log entries.
   */
  void FlushAll() {
    FlushAll(log_level);
  }

  bool SaveToFile(string new_filename = "", ENUM_LOG_LEVEL max_log_level = V_INFO) {
    string filepath = new_filename != "" ? new_filename : filename;
    int handle = FileOpen(filepath, FILE_WRITE|FILE_CSV, ": ");
    if (handle != INVALID_HANDLE) {
      for (int i = 0; i < ArraySize(data); i++) {
        if (data[i].log_level <= log_level) {
          FileWrite(handle, TimeToString(data[i].timestamp, TIME_DATE | TIME_MINUTES), ": ", data[i].msg);
        }
      }
      FileClose(handle);
      return (1);
    } else {
      FileClose(handle);
      return (0);
    }
  }
  
  bool SaveToFile(string new_filename = "") {
    return SaveToFile(new_filename, log_level);
  }

  template <typename T>
    void Erase(T& A[], int iPos){
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
          return (1);
          break;
        }
      }
    }
    return (0);
  }

};
