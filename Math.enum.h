//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef MATH_ENUM_H
#define MATH_ENUM_H

/* Enumeration for Math comparison operators. */
enum ENUM_MATH_CONDITION {
  MATH_COND_EQ = 1,  // Argument values are equal.
  MATH_COND_GT = 2,  // First value is greater than second.
  MATH_COND_LE = 3,  // First value is lesser than second.
  FINAL_MATH_ENTRY = 4
};

/* Enumeration for Math operations. */
enum ENUM_MATH_OP {
  MATH_OP_ADD,
  MATH_OP_SUB,
  MATH_OP_MUL,
  MATH_OP_DIV,
  MATH_OP_SIN,
  MATH_OP_COS,
  MATH_OP_TAN,
  MATH_OP_MIN,
  MATH_OP_MAX,
  MATH_OP_AVG,
  MATH_OP_RELU,
  MATH_OP_ABS,
  MATH_OP_ABS_DIFF
};

#endif  // MATH_ENUM_H
