//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
 * Includes IndicatorData's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/* Defines type of source data for */
enum ENUM_IDATA_SOURCE_TYPE {
  IDATA_BUILTIN = 0,     // Platform built-in
  IDATA_CHART,           // Chart calculation
  IDATA_ICUSTOM,         // iCustom: Custom indicator file
  IDATA_ICUSTOM_LEGACY,  // iCustom: Custom, legacy, provided by MT indicator file
  IDATA_INDICATOR,       // OnIndicator: Another indicator as a source of data
  IDATA_ONCALCULATE,     // OnCalculate: Custom calculation function
  IDATA_MATH             // Math-based indicator
};

/* Defines range value data type for indicator storage. */
enum ENUM_IDATA_VALUE_RANGE {
  IDATA_RANGE_BINARY,   // E.g. 0 or 1.
  IDATA_RANGE_BITWISE,  // Bitwise
  IDATA_RANGE_MIXED,
  IDATA_RANGE_PRICE,            // Values represent price.
  IDATA_RANGE_PRICE_DIFF,       // Values represent price differences.
  IDATA_RANGE_PRICE_ON_SIGNAL,  // Values represent price on signal, otherwise zero.
  IDATA_RANGE_RANGE,            // E.g. 0 to 100.
  IDATA_RANGE_UNKNOWN
};
