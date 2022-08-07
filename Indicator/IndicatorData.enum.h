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

/* Indicator entry flags. */
enum INDICATOR_ENTRY_FLAGS {
  INDI_ENTRY_FLAG_NONE = 0 << 0,
  INDI_ENTRY_FLAG_IS_BITWISE = 1 << 0,
  INDI_ENTRY_FLAG_IS_DOUBLED = 1 << 1,  // Type is doubled in size (e.g. double or long).
  INDI_ENTRY_FLAG_IS_EXPIRED = 1 << 2,
  INDI_ENTRY_FLAG_IS_REAL = 1 << 3,  // Type is real (float or double).
  INDI_ENTRY_FLAG_IS_PRICE = 1 << 4,
  INDI_ENTRY_FLAG_IS_UNSIGNED = 1 << 5,  // Type is unsigned (unsigned int or unsigned long).
  INDI_ENTRY_FLAG_IS_VALID = 1 << 6,
  INDI_ENTRY_FLAG_INSUFFICIENT_DATA = 1 << 7,  // Entry has missing value for that shift and probably won't ever have.
};

/* Define indicator index. */
enum ENUM_INDICATOR_INDEX {
  CURR = 0,
  PREV = 1,
  PPREV = 2,
  FINAL_ENUM_INDICATOR_INDEX = 3  // Should be the last one. Used to calculate the number of enum items.
};

// Storage type for IndicatorBase::GetSpecificValueStorage().
enum ENUM_INDI_VS_TYPE {
  INDI_VS_TYPE_NONE,            // Not set.
  INDI_VS_TYPE_TIME,            // Candle.
  INDI_VS_TYPE_TICK_VOLUME,     // Candle.
  INDI_VS_TYPE_VOLUME,          // Candle.
  INDI_VS_TYPE_SPREAD,          // Candle.
  INDI_VS_TYPE_PRICE_OPEN,      // Candle.
  INDI_VS_TYPE_PRICE_HIGH,      // Candle.
  INDI_VS_TYPE_PRICE_LOW,       // Candle.
  INDI_VS_TYPE_PRICE_CLOSE,     // Candle.
  INDI_VS_TYPE_PRICE_MEDIAN,    // Candle.
  INDI_VS_TYPE_PRICE_TYPICAL,   // Candle.
  INDI_VS_TYPE_PRICE_WEIGHTED,  // Candle.
  INDI_VS_TYPE_PRICE_BID,       // Tick.
  INDI_VS_TYPE_PRICE_ASK,       // Tick.
                                // Indexed value storages, available if indicator have buffer at this index:
  INDI_VS_TYPE_INDEX_0,
  INDI_VS_TYPE_INDEX_1,
  INDI_VS_TYPE_INDEX_2,
  INDI_VS_TYPE_INDEX_4,
  INDI_VS_TYPE_INDEX_5,
  INDI_VS_TYPE_INDEX_6,
  INDI_VS_TYPE_INDEX_7,
  INDI_VS_TYPE_INDEX_8,
  INDI_VS_TYPE_INDEX_9,
  INDI_VS_TYPE_INDEX_FIRST = INDI_VS_TYPE_INDEX_0,
  INDI_VS_TYPE_INDEX_LAST = INDI_VS_TYPE_INDEX_9
};

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
