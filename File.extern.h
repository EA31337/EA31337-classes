//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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

// Includes.
#include "File.define.h"
#include "Terminal.define.h"

// Define external global functions.
#ifndef __MQL__
extern bool FileIsEnding(int file_handle);
extern bool FileIsExist(const string file_name, int common_flag = 0);
extern int FileClose(int file_handle);
extern int FileOpen(string file_name, int open_flags, short delimiter = '\t', uint codepage = CP_ACP);
extern int FileReadInteger(int file_handle, int size = INT_VALUE);
extern string FileReadString(int file_handle, int length = -1);
extern uint FileWriteString(int file_handle, const string text_string, int length = -1);
#endif
