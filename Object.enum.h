//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
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
 * Includes enumerations used for objects.
 */

#ifndef __MQLBUILD__
// Used for checking the type of the object pointer.
// @docs
// - https://docs.mql4.com/constants/namedconstants/enum_pointer_type
// - https://www.mql5.com/en/docs/constants/namedconstants/enum_pointer_type
enum ENUM_POINTER_TYPE {
  POINTER_INVALID,   // Incorrect pointer.
  POINTER_DYNAMIC,   // Pointer of the object created by the new() operator.
  POINTER_AUTOMATIC  // Pointer of any objects created automatically (not using new()).
};
#endif
