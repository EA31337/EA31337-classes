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
 * Includes DateTime's enums.
 */

// Defines datetime conditions.
enum ENUM_DATETIME_CONDITION {
  DATETIME_COND_IS_PEAK_HOUR = 1,  // On peak hour
  DATETIME_COND_NEW_HOUR,          // On new hour
  DATETIME_COND_NEW_DAY,           // On new day
  DATETIME_COND_NEW_WEEK,          // On new week
  DATETIME_COND_NEW_MONTH,         // On new month
  DATETIME_COND_NEW_YEAR,          // On new year
  FINAL_ENUM_DATETIME_CONDITION_ENTRY
};

enum ENUM_DATETIME_UNIT {
  DATETIME_NONE = 0 << 0,    // None
  DATETIME_SECOND = 1 << 0,  // Second
  DATETIME_MINUTE = 1 << 1,  // Minute
  DATETIME_HOUR = 1 << 2,    // Hour
  DATETIME_DAY = 1 << 3,     // Day
  DATETIME_WEEK = 1 << 4,    // Week
  DATETIME_MONTH = 1 << 5,   // Month
  DATETIME_YEAR = 1 << 6,    // Year
  DATETIME_HMS = DATETIME_HOUR | DATETIME_MINUTE | DATETIME_SECOND,
  DATETIME_YMD = DATETIME_YEAR | DATETIME_MONTH | DATETIME_DAY,
  DATETIME_ALL = DATETIME_HMS | DATETIME_WEEK | DATETIME_YMD,
};
