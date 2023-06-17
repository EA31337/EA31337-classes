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
 * In-memory file-system used e.g., to create files in C++ and access them in JS via Emscripten.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once

// Includes.
#include <sstream>

#include "../Storage/Dict/DictStruct.h"
#include "../File.define.h"
#include "../Storage/String.h"

class MemoryFileSystemFile : public Dynamic {
 public:
  // FILE_* flags from MQL.
  unsigned int flags;

  // Whether file is already opened.
  bool opened;

  // MemoryFileSystemFile handle index.
  int handle;

  // Auto-incremented handle index.
  static unsigned int last_handle;

  // String-based buffer.
  string buffer;

  // Current cursor offset.
  int offset;

  /**
   * Constructor.
   */
  MemoryFileSystemFile(string data = "") {
    handle = last_handle++;
    buffer = data;
  }
};

unsigned int MemoryFileSystemFile::last_handle = 0;

class MemoryFileSystem {
  // Files by path.
  DictStruct<string, Ref<MemoryFileSystemFile>> files_by_path;

  // Files by handle.
  DictStruct<int, Ref<MemoryFileSystemFile>> files_by_handle;

 public:
  MemoryFileSystem() {
    int _ea_version_handle = FileOpen("EA.txt", FILE_WRITE);
    FileWrite(_ea_version_handle, "Hello world!");
    FileClose(_ea_version_handle);
  }

  /**
   * Opens file for reading/writing and returns its handle.
   */
  int FileOpen(string _path, int _flags, short _delimiter = ';', unsigned int codepage = CP_ACP) {
    Ref<MemoryFileSystemFile> _file;

    if (files_by_path.KeyExists("_path")) {
      _file = files_by_path.GetByKey(_path);

      if (_file REF_DEREF opened) {
        // MemoryFileSystemFile is already opened.
        Print("Error: MemoryFileSystemFile \"" + _path + "\" is already opened!");
        DebugBreak();
        return INVALID_HANDLE;
      }

      if ((_flags & FILE_WRITE) != 0) {
        // Truncating file.
        _file REF_DEREF buffer = "";
      }
    } else {
      if ((_flags & FILE_READ) != 0) {
        // MemoryFileSystemFile doesn't exit.
        Print("Error: MemoryFileSystemFile \"" + _path + "\" doesn't exist!");
        DebugBreak();
        return INVALID_HANDLE;
      }

      _file = new MemoryFileSystemFile();
      files_by_path.Set(_path, _file);
      files_by_handle.Set(_file REF_DEREF handle, _file);
    }

    return _file REF_DEREF handle;
  }

  /**
   * Closes file by the handle given.
   */
  void FileClose(int handle) {
    if (!files_by_handle.KeyExists(handle)) {
      Print("Error: MemoryFileSystemFile handle ", handle, " is not opened!");
      DebugBreak();
      return;
    }

    files_by_handle.Unset(handle);
  }

  template <typename Arg, typename... Args>
  unsigned int FileWrite(int file_handle, Arg&& arg, Args&&... args) {
    if (!files_by_handle.KeyExists(file_handle)) {
      Print("Error: MemoryFileSystemFile handle ", file_handle, " is not opened!");
      DebugBreak();
      return 0;
    }

    std::stringstream str;
    PrintTo(str, arg, args...);
    string data = str.str();
    Ref<MemoryFileSystemFile> _file = files_by_handle.GetByKey(file_handle);
    _file REF_DEREF buffer += data;
    return data.size();
  }
};

#endif
