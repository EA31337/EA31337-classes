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
 * Includes IndicatorData's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/* Defines type of source data for. Also used for Indicator::GetPossibleDataModes(). */
enum ENUM_IDATA_SOURCE_TYPE {
  IDATA_BUILTIN = 1 << 0,         // Platform built-in
  IDATA_CHART = 1 << 1,           // Chart calculation
  IDATA_ICUSTOM = 1 << 2,         // iCustom: Custom indicator file
  IDATA_ICUSTOM_LEGACY = 1 << 3,  // iCustom: Custom, legacy, provided by MT indicator file
  IDATA_INDICATOR = 1 << 4,       // OnIndicator: Another indicator as a source of data
  IDATA_ONCALCULATE = 1 << 5,     // OnCalculate: Custom calculation function
  IDATA_MATH = 1 << 6             // Math-based indicator
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
