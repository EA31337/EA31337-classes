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
 * Includes Indicator's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Indicator.define.h"

/* Indicator actions. */
enum ENUM_INDICATOR_ACTION {
  INDI_ACTION_CLEAR_CACHE,  // Clear cache.
  INDI_ACTION_SET_VALUE,    // Sets buffers' values (from second argument to the last one).
  FINAL_INDICATOR_ACTION_ENTRY
};

/* Define type of indicators. */
enum ENUM_INDICATOR_TYPE {
  INDI_NONE = 0,             // (None)
  INDI_AC,                   // Accelerator Oscillator
  INDI_AD,                   // Accumulation/Distribution
  INDI_ADX,                  // Average Directional Index
  INDI_ADXW,                 // ADX by Welles Wilder
  INDI_ALLIGATOR,            // Alligator
  INDI_AMA,                  // Adaptive Moving Average
  INDI_APPLIED_PRICE,        // Applied Price over OHLC Indicator
  INDI_AO,                   // Awesome Oscillator
  INDI_ASI,                  // Accumulation Swing Index
  INDI_ATR,                  // Average True Range
  INDI_BANDS,                // Bollinger Bands
  INDI_BANDS_ON_PRICE,       // Bollinger Bands (on Price)
  INDI_BEARS,                // Bears Power
  INDI_BULLS,                // Bulls Power
  INDI_BWMFI,                // Market Facilitation Index
  INDI_BWZT,                 // Bill Williams' Zone Trade
  INDI_CANDLE,               // Candle Pattern Detector
  INDI_CCI,                  // Commodity Channel Index
  INDI_CCI_ON_PRICE,         // Commodity Channel Index (CCI) (on Price)
  INDI_CHAIKIN,              // Chaikin Oscillator
  INDI_CHAIKIN_V,            // Chaikin Volatility
  INDI_COLOR_BARS,           // Color Bars
  INDI_COLOR_CANDLES_DAILY,  // Color Candles Daily
  INDI_COLOR_LINE,           // Color Line
  INDI_CUSTOM,               // Custom indicator
  INDI_CUSTOM_MOVING_AVG,    // Custom Moving Average
  INDI_DEMA,                 // Double Exponential Moving Average
  INDI_DEMARKER,             // DeMarker
  INDI_DEMO,                 // Demo/Dummy Indicator
  INDI_DETRENDED_PRICE,      // Detrended Price Oscillator
  INDI_DRAWER,               // Drawer (Socket-based) Indicator
  INDI_ENVELOPES,            // Envelopes
  INDI_ENVELOPES_ON_PRICE,   // Evelopes (on Price)
  INDI_FORCE,                // Force Index
  INDI_FRACTALS,             // Fractals
  INDI_FRAMA,                // Fractal Adaptive Moving Average
  INDI_GATOR,                // Gator Oscillator
  INDI_HEIKENASHI,           // Heiken Ashi
  INDI_ICHIMOKU,             // Ichimoku Kinko Hyo
  INDI_KILLZONES,            // Killzones
  INDI_MA,                   // Moving Average
  INDI_MACD,                 // MACD
  INDI_MA_ON_PRICE,          // Moving Average (on Price).
  INDI_MARKET_FI,            // Market Facilitation Index
  INDI_MASS_INDEX,           // Mass Index
  INDI_MFI,                  // Money Flow Index
  INDI_MOMENTUM,             // Momentum
  INDI_MOMENTUM_ON_PRICE,    // Momentum (on Price)
  INDI_OBV,                  // On Balance Volume
  INDI_OHLC,                 // OHLC (Open-High-Low-Close)
  INDI_OSMA,                 // OsMA
  INDI_PATTERN,              // Pattern Detector
  INDI_PIVOT,                // Pivot Detector
  INDI_PRICE,                // Price
  INDI_PRICE_CHANNEL,        // Price Channel
  INDI_PRICE_FEEDER,         // Indicator which returns prices from custom array
  INDI_PRICE_VOLUME_TREND,   // Price and Volume Trend
  INDI_RATE_OF_CHANGE,       // Rate of Change
  INDI_RS,                   // Indi_Math-based RSI indicator.
  INDI_RSI,                  // Relative Strength Index
  INDI_RSI_ON_PRICE,         // Relative Strength Index (RSI) (on Price)
  INDI_RVI,                  // Relative Vigor Index
  INDI_SAR,                  // Parabolic SAR
  INDI_SPECIAL_MATH,         // Math operations over given indicator.
  INDI_STDDEV,               // Standard Deviation
  INDI_STDDEV_ON_MA_SMA,     // Standard Deviation on Moving Average in SMA mode
  INDI_STDDEV_ON_PRICE,      // Standard Deviation (on Price)
  INDI_STDDEV_SMA_ON_PRICE,  // Standard Deviation in SMA mode (on Price)
  INDI_STOCHASTIC,           // Stochastic Oscillator
  INDI_SVE_BB,               // SVE Bollinger Bands
  INDI_TEMA,                 // Triple Exponential Moving Average
  INDI_TICK,                 // Tick
  INDI_TMA_TRUE,             // Triangular Moving Average True
  INDI_TRIX,                 // Triple Exponential Moving Averages Oscillator
  INDI_ULTIMATE_OSCILLATOR,  // Ultimate Oscillator
  INDI_VIDYA,                // Variable Index Dynamic Average
  INDI_VOLUMES,              // Volumes
  INDI_VROC,                 // Volume Rate of Change
  INDI_WILLIAMS_AD,          // Larry Williams' Accumulation/Distribution
  INDI_WPR,                  // Williams' Percent Range
  INDI_ZIGZAG,               // ZigZag
  INDI_ZIGZAG_COLOR,         // ZigZag Color
  FINAL_INDICATOR_TYPE_ENTRY
};

/* Defines type of source data for indicator. */
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
  IDATA_RANGE_ARROW,    // Value is non-zero on signal.
  IDATA_RANGE_BINARY,   // E.g. 0 or 1.
  IDATA_RANGE_BITWISE,  // Bitwise
  IDATA_RANGE_MIXED,
  IDATA_RANGE_PRICE,  // Values represent price.
  IDATA_RANGE_RANGE,  // E.g. 0 to 100.
  IDATA_RANGE_UNKNOWN
};

// Indicator line identifiers used in ADX and ADXW indicators.
enum ENUM_INDI_ADX_LINE {
#ifdef __MQL4__
  LINE_MAIN_ADX = MODE_MAIN,    // Base indicator line.
  LINE_PLUSDI = MODE_PLUSDI,    // +DI indicator line.
  LINE_MINUSDI = MODE_MINUSDI,  // -DI indicator line.
#else
  LINE_MAIN_ADX = MAIN_LINE,    // Base indicator line.
  LINE_PLUSDI = PLUSDI_LINE,    // +DI indicator line.
  LINE_MINUSDI = MINUSDI_LINE,  // -DI indicator line.
#endif
  FINAL_INDI_ADX_LINE_ENTRY,
};

/* Define indicator index. */
enum ENUM_INDICATOR_INDEX {
  CURR = 0,
  PREV = 1,
  PPREV = 2,
  FINAL_ENUM_INDICATOR_INDEX = 3  // Should be the last one. Used to calculate the number of enum items.
};

/* Indicator line identifiers used in Envelopes and Fractals indicators. */
enum ENUM_LO_UP_LINE {
#ifdef __MQL4__
  LINE_UPPER = MODE_UPPER,  // Upper line.
  LINE_LOWER = MODE_LOWER,  // Bottom line.
#else
  LINE_UPPER = UPPER_LINE,      // Upper line.
  LINE_LOWER = LOWER_LINE,      // Bottom line.
#endif
  FINAL_LO_UP_LINE_ENTRY,
};

/**
 * Indicator line identifiers used in MACD, RVI and Stochastic indicators.
 *
 * @see:
 * - https://docs.mql4.com/constants/indicatorconstants/lines
 * - https://www.mql5.com/en/docs/constants/indicatorconstants/lines
 */
enum ENUM_SIGNAL_LINE {
#ifdef __MQL4__
  LINE_MAIN = MODE_MAIN,      // Main line.
  LINE_SIGNAL = MODE_SIGNAL,  // Signal line.
#else
  LINE_MAIN = MAIN_LINE,        // Main line.
  LINE_SIGNAL = SIGNAL_LINE,    // Signal line.
#endif
  FINAL_SIGNAL_LINE_ENTRY,
};

#ifdef __MQL4__
/**
 * The volume type is used in calculations.
 *
 * Notes:
 * - For MT4, we define it for backward compatibility.
 *
 * @see:
 * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
 */
enum ENUM_APPLIED_VOLUME { VOLUME_TICK = 0, VOLUME_REAL = 1 };
#endif

/* Indicator entry flags. */
enum INDICATOR_ENTRY_FLAGS {
  INDI_ENTRY_FLAG_NONE = 0 << 0,
  INDI_ENTRY_FLAG_IS_BITWISE = 1 << 0,
  INDI_ENTRY_FLAG_IS_DOUBLED = 1 << 1,  // Type is doubled in size (e.g. double or long).
  INDI_ENTRY_FLAG_IS_EXPIRED = 1 << 2,
  INDI_ENTRY_FLAG_IS_REAL = 1 << 3,  // Type is real (float or double).
  INDI_ENTRY_FLAG_IS_PRICE = 1 << 4,
  INDI_ENTRY_FLAG_IS_UNSIGNED = 1 << 5,  // Type is unsigned (uint or ulong).
  INDI_ENTRY_FLAG_IS_VALID = 1 << 6,
  INDI_ENTRY_FLAG_INSUFFICIENT_DATA = 1 << 7,  // Entry has missing value for that shift and probably won't ever have.
};
