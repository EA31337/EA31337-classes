//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

#ifndef __MQL__
// @note Values differ from the documentation at
// https://www.mql5.com/en/docs/matrix/matrix_initialization/matrix_copyticks
// @see https://www.mql5.com/en/forum/448933
enum ENUM_COPY_TICKS {
  COPY_TICKS_INFO = 1,
  COPY_TICKS_TRADE = 2,
  COPY_TICKS_ALL = 3,
  COPY_TICKS_VERTICAL = 32768,
  COPY_TICKS_TIME_MS = 65536,
  COPY_TICKS_BID = 131072,
  COPY_TICKS_ASK = 262144,
  COPY_TICKS_LAST = 524288,
  COPY_TICKS_VOLUME = 1048576,
  COPY_TICKS_FLAGS = 2097152
};
#endif

// Platform actions.
enum ENUM_PLATFORM_ACTION {
  PLATFORM_ACTION_ADD_EXCHANGE = 1,  // Add Exchange
  FINAL_ENUM_PLATFORM_ACTION_ENTRY
};

// Platform conditions.
enum ENUM_PLATFORM_CONDITION {
  PLATFORM_COND_IS_ACTIVE = 1,  // Is active
  FINAL_ENUM_PLATFORM_CONDITION_ENTRY
};
