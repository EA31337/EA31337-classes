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

/**
 * @file
 * Includes Dicts's enums and defines.
 */

#ifndef __MQL__
  // Allows the preprocessor to include a header file when it is needed.
  #pragma once
#endif

#define DICT_GROW_UP_PERCENT_DEFAULT 100
#define DICT_PERFORMANCE_PROBLEM_AVG_CONFLICTS 20

/**
 * Whether Dict operates in yet uknown mode, as dict or as list.
 */
enum DictMode { DictModeUnknown, DictModeDict, DictModeList };

/**
 * Reason of call to overflow listener.
 */
enum ENUM_DICT_OVERFLOW_REASON {
  DICT_LISTENER_FULL_CAN_RESIZE,            // Dict is full. Can we grow up the dict?
  DICT_LISTENER_NOT_PERFORMANT_CAN_RESIZE,  // Dict is not performant (too many average number of conflicts). Can we
                                            // grow up the dict?
  DICT_LISTENER_CONFLICTS_CAN_OVERWRITE     // Conflict(s) when inserting new slot. Can we overwrite random used slot?
};

/**
 * Dictionary flags.
 */
enum ENUM_DICT_FLAG {
  DICT_FLAG_NONE = 0,
  DICT_FLAG_FILL_HOLES_UNSORTED = 1,
};
