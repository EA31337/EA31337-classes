//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * Includes Data's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

#ifndef __MQL__
/**
 * Enumeration for the Data type identifiers.
 *
 * @docs
 * - https://www.mql5.com/en/docs/constants/indicatorconstants/enum_datatype
 */
enum ENUM_DATATYPE {
  TYPE_BOOL,      // bool
  TYPE_CHAR,      // char
  TYPE_COLOR,     // color
  TYPE_DATETIME,  // datetime
  TYPE_DOUBLE,    // double
  TYPE_FLOAT,     // float
  TYPE_INT,       // int
  TYPE_LONG,      // long
  TYPE_SHORT,     // short
  TYPE_STRING,    // string
  TYPE_UCHAR,     // uchar
  TYPE_UINT,      // uint
  TYPE_ULONG,     // ulong
  TYPE_USHORT,    // ushort
};
#endif
