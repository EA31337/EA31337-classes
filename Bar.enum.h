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
 * Includes Bar's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/* Pivot Point calculation method. */
enum ENUM_PP_TYPE {
  PP_CAMARILLA = 1,   // Camarilla: A set of eight levels which resemble support and resistance values
  PP_CLASSIC = 2,     // Classic pivot point
  PP_FIBONACCI = 3,   // Fibonacci pivot point
  PP_FLOOR = 4,       // Floor: Most basic and popular type of pivots used in Forex trading technical analysis
  PP_TOM_DEMARK = 5,  // Tom DeMark's pivot point (predicted lows and highs of the period)
  PP_WOODIE = 6,      // Woodie's pivot point are giving more weight to the Close price of the previous period
};
