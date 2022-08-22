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
 * File class to manage files.
 *
 * Notes:
 * - For security reasons, work with files is strictly controlled in the MQL language.
 * - Files with which file operations are conducted means cannot be outside the file sandbox.
 */

// Includes.
#include "File.define.h"
#include "File.extern.h"
#include "Std.h"
#include "Terminal.define.h"
#include "Terminal.enum.h"
#include "Terminal.extern.h"

#ifndef __MQL__
enum ENUM_FILE_PROPERTY_INTEGER {
  FILE_EXISTS,
  FILE_CREATE_DATE,
  FILE_MODIFY_DATE,
  FILE_ACCESS_DATE,
  FILE_SIZE,
  FILE_POSITION,
  FILE_END,
  FILE_LINE_END,
  FILE_IS_COMMON,
  FILE_IS_TEXT,
  FILE_IS_BINARY,
  FILE_IS_CSV,
  FILE_IS_ANSI,
  FILE_IS_READABLE,
  FILE_IS_WRITABLE,
};
enum ENUM_FILE_OPEN_FLAGS {
  FILE_READ = 1,
  FILE_WRITE = 2,
  FILE_BIN = 4,
  FILE_CSV = 8,
  FILE_TXT = 16,
  FILE_ANSI = 32,
  FILE_UNICODE = 64,
  FILE_SHARE_READ = 128,
  FILE_SHARE_WRITE = 256,
  FILE_REWRITE = 512,
  FILE_COMMON = 4096,
};
#endif

/**
 * Class to provide a group of functions for working with files.
 */
class File {
 public:
  /**
   * Read file and return its content.
   *
   * @param string dlm
   *   Delimiter to separate the items.
   *
   * @return string
   *   Content of the file.
   */
  static string ReadContent(string file_name, int open_flags = FILE_TXT, short dlm = ';', bool verbose = true) {
    int file_handle = FileOpen(file_name, open_flags, dlm);
    int str_size;
    string str;
    if (file_handle < 0) {
      if (verbose) {
        PrintFormat("%s: Error: Failed to open %s file: %i", __FUNCTION__, C_STR(file_name), GetLastError());
      }
      return "";
    }
    ResetLastError();
    while (!FileIsEnding(file_handle)) {
      // Find out how many symbols are used for writing the time.
      str_size = FileReadInteger(file_handle, INT_VALUE);
      // Read the string.
      str += FileReadString(file_handle, str_size);
    }
    FileClose(file_handle);
    return str;
  }

  static bool FileIsExist(string file_name, int common_flag = 0) { return ::FileIsExist(file_name, common_flag); }

  /**
   * Loads file as ANSI string. Converts newlines to "\n".
   */
  static string ReadFile(string path) {
    int handle = FileOpen(path, FILE_READ | FILE_ANSI, 0);
    ResetLastError();

    if (handle == INVALID_HANDLE) {
      string terminalDataPath = TerminalInfoString(TERMINAL_DATA_PATH);
#ifdef __MQL5__
      string terminalSubfolder = "MQL5";
#else
      string terminalSubfolder = "MQL4";
#endif
      Print("Cannot open file \"", path, "\" for reading. Error code: ", GetLastError(),
            ". Consider using path relative to \"" + terminalDataPath + "\\" + terminalSubfolder +
                "\\Files\\\" as absolute paths may not work.");
      return NULL;
    }

    string data = "";

    while (!FileIsEnding(handle)) {
      data += FileReadString(handle) + "\n";
    }

    FileClose(handle);

    return data;
  }

  /**
   * Saves ANSI string into file.
   */
  static bool SaveFile(string path, string data, bool binary = false) {
    ResetLastError();

    int handle = FileOpen(path, FILE_WRITE | (binary ? FILE_BIN : FILE_ANSI));

    if (handle == INVALID_HANDLE) {
      string terminalDataPath = TerminalInfoString(TERMINAL_DATA_PATH);
#ifdef __MQL5__
      string terminalSubfolder = "MQL5";
#else
      string terminalSubfolder = "MQL4";
#endif
      Print("Cannot open file \"", path, "\" for writing. Error code: ", GetLastError(),
            ". Consider using path relative to \"" + terminalDataPath + "\\" + terminalSubfolder +
                "\\Files\\\" as absolute paths may not work.");
      return false;
    }

    FileWriteString(handle, data);

    FileClose(handle);

    return GetLastError() == ERR_NO_ERROR;
  }
};
