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
 * Includes DateTime's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward declarations.
struct DateTimeStatic;

// Includes.
#include "DateTime.enum.h"
#include "Std.h"

#ifndef __MQLBUILD__
/**
 * The date type structure.
 *
 * @see:
 * - https://docs.mql4.com/constants/structures/mqldatetime
 * - https://www.mql5.com/en/docs/constants/structures/mqldatetime
 */
struct MqlDateTime {
  int year;         // Year.
  int mon;          // Month.
  int day;          // Day of month.
  int hour;         // Hour.
  int min;          // Minute.
  int sec;          // Second.
  int day_of_week;  // Zero-based day number of week (0-Sunday, 1-Monday, ... ,6-Saturday).
  int day_of_year;  // Zero-based day number of the year (1st Jan = 0).
};
#endif
