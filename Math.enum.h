//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
 * Includes Math's enums.
 */

// Prevents processing this includes file for the second time.
#ifndef MATH_ENUM_H
#define MATH_ENUM_H

#ifndef __MQLBUILD__
//
// Data type identifiers.
// @docs
// - https://www.mql5.com/en/docs/constants/indicatorconstants/enum_datatype
enum ENUM_DATATYPE {
  TYPE_BOOL,
  TYPE_CHAR,
  TYPE_UCHAR,
  TYPE_SHORT,
  TYPE_USHORT,
  TYPE_COLOR,
  TYPE_INT,
  TYPE_UINT,
  TYPE_DATETIME,
  TYPE_LONG,
  TYPE_ULONG,
  TYPE_FLOAT,
  TYPE_DOUBLE,
  TYPE_STRING
};
#endif

// Math conditions.
enum ENUM_MATH_CONDITION {
  MATH_COND_EQ = 1,  // Argument values are equal.
  MATH_COND_GT = 2,  // First value is greater than second.
  MATH_COND_LE = 3,  // First value is lesser than second.
  FINAL_MATH_ENTRY = 4
};

#endif  // MATH_ENUM_H
