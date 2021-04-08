//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
 * Defines for Terminal class.
 */

/* Defines */

// Custom user errors.
// @docs
// - https://docs.mql4.com/common/setusererror
// - https://www.mql5.com/en/docs/common/SetUserError
#define ERR_USER_ARRAY_IS_EMPTY 1
#define ERR_USER_INVALID_BUFF_NUM 2
#define ERR_USER_INVALID_HANDLE 3
#define ERR_USER_ITEM_NOT_FOUND 4
#define ERR_USER_NOT_SUPPORTED 5

// The resolution of display on the screen in a number of Dots in a line per Inch (DPI).
// By knowing the value, you can set the size of graphical objects,
// so they can look the same on monitors with different resolution characteristics.
#ifndef TERMINAL_SCREEN_DPI
#define TERMINAL_SCREEN_DPI 27
#endif

// The last known value of a ping to a trade server in microseconds.
// One second comprises of one million microseconds.
#ifndef TERMINAL_PING_LAST
#define TERMINAL_PING_LAST 28
#endif
