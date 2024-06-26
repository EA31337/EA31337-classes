//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
// Defines.
#ifndef __MQL__
#pragma once

// File constants to read the whole value of char, short or int type.
#define CHAR_VALUE 1
#define INT_VALUE 4
#define SHORT_VALUE 2
// Used for checking file handles (see FileOpen() and FileFindFirst()).
#define INVALID_HANDLE -1

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
