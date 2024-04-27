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

/**
 * @file
 * Includes Dicts's enums and defines.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

#define DICT_GROW_UP_PERCENT_DEFAULT 25
#define DICT_PERFORMANCE_PROBLEM_AVG_CONFLICTS 10

/**
 * Whether Dict operates in yet uknown mode, as dict or as list.
 */
enum DictMode { DictModeUnknown, DictModeDict, DictModeList };

/**
 * Reason of call to overflow listener.
 */
enum ENUM_DICT_OVERFLOW_REASON {
  DICT_OVERFLOW_REASON_FULL,
  DICT_OVERFLOW_REASON_TOO_MANY_CONFLICTS,
};

/**
 * Dictionary flags.
 */
enum ENUM_DICT_FLAG {
  DICT_FLAG_NONE = 0,
  DICT_FLAG_FILL_HOLES_UNSORTED = 1,
};
