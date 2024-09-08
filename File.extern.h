//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "File.define.h"
#include "Platform/Terminal.define.h"
#include "Storage/MemoryFileSystem.h"
#include "Storage/String.extern.h"

// Define external global functions.
#ifndef __MQL__
MemoryFileSystem _memfs;

extern bool FileIsEnding(int file_handle);

extern bool FileIsExist(const string file_name, int common_flag = 0);

void FileClose(int file_handle) { _memfs.FileClose(file_handle); }

int FileOpen(string file_name, int open_flags, short delimiter = '\t', unsigned int codepage = CP_ACP) {
  return _memfs.FileOpen(file_name, open_flags, delimiter, codepage);
}

extern int FileReadInteger(int file_handle, int size = INT_VALUE);

extern string FileReadString(int file_handle, int length = -1);

unsigned int FileWriteString(int file_handle, const string text_string, int length = -1) {
  return _memfs.FileWrite(file_handle, text_string);
}

template <typename Arg, typename... Args>
unsigned int FileWrite(int file_handle, Arg&& arg, Args&&... args) {
  return _memfs.FileWrite(file_handle, arg, args...);
}

#endif
