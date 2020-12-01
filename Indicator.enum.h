//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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

// Indicator actions.
enum ENUM_INDICATOR_ACTION {
  INDI_ACTION_CLEAR_CACHE,  // Clear cache.
  FINAL_INDICATOR_ACTION_ENTRY
};

// Define type of indicators.
enum ENUM_INDICATOR_TYPE {
  INDI_NONE = 0,             // (None)
  INDI_AC,                   // Accelerator Oscillator
  INDI_AD,                   // Accumulation/Distribution
  INDI_ADX,                  // Average Directional Index
  INDI_ADXW,                 // ADX by Welles Wilder
  INDI_ALLIGATOR,            // Alligator
  INDI_AMA,                  // Adaptive Moving Average
  INDI_AO,                   // Awesome Oscillator
  INDI_ATR,                  // Average True Range
  INDI_BANDS,                // Bollinger Bands
  INDI_BANDS_ON_PRICE,       // Bollinger Bands (on Price)
  INDI_BEARS,                // Bears Power
  INDI_BULLS,                // Bulls Power
  INDI_BWMFI,                // Market Facilitation Index
  INDI_CCI,                  // Commodity Channel Index
  INDI_CCI_ON_PRICE,         // Commodity Channel Index (CCI) (on Price)
  INDI_CHAIKIN,              // Chaikin Oscillator
  INDI_CUSTOM,               // Custom indicator
  INDI_DEMA,                 // Double Exponential Moving Average
  INDI_DEMARKER,             // DeMarker
  INDI_DEMO,                 // Demo/Dummy Indicator
  INDI_ENVELOPES,            // Envelopes
  INDI_ENVELOPES_ON_PRICE,   // Evelopes (on Price)
  INDI_FORCE,                // Force Index
  INDI_FRACTALS,             // Fractals
  INDI_FRAMA,                // Fractal Adaptive Moving Average
  INDI_GATOR,                // Gator Oscillator
  INDI_HEIKENASHI,           // Heiken Ashi
  INDI_ICHIMOKU,             // Ichimoku Kinko Hyo
  INDI_MA,                   // Moving Average
  INDI_MACD,                 // MACD
  INDI_MA_ON_PRICE,          // Moving Average (on Price).
  INDI_MFI,                  // Money Flow Index
  INDI_MOMENTUM,             // Momentum
  INDI_MOMENTUM_ON_PRICE,    // Momentum (on Price)
  INDI_OBV,                  // On Balance Volume
  INDI_OSMA,                 // OsMA
  INDI_PRICE,                // Price Indicator
  INDI_PRICE_FEEDER,         // Indicator which returns prices from custom array
  INDI_RSI,                  // Relative Strength Index
  INDI_RSI_ON_PRICE,         // Relative Strength Index (RSI) (on Price)
  INDI_RVI,                  // Relative Vigor Index
  INDI_SAR,                  // Parabolic SAR
  INDI_STDDEV,               // Standard Deviation
  INDI_STDDEV_ON_MA_SMA,     // Standard Deviation on Moving Average in SMA mode
  INDI_STDDEV_ON_PRICE,      // Standard Deviation (on Price)
  INDI_STDDEV_SMA_ON_PRICE,  // Standard Deviation in SMA mode (on Price)
  INDI_STOCHASTIC,           // Stochastic Oscillator
  INDI_TEMA,                 // Triple Exponential Moving Average
  INDI_TRIX,                 // Triple Exponential Moving Averages Oscillator
  INDI_VIDYA,                // Variable Index Dynamic Average
  INDI_VOLUMES,              // Volumes
  INDI_WPR,                  // Williams' Percent Range
  INDI_ZIGZAG,               // ZigZag
  FINAL_INDICATOR_TYPE_ENTRY
};

// Defines type of source data for indicator.
enum ENUM_IDATA_SOURCE_TYPE {
  IDATA_BUILTIN,   // Use builtin function.
  IDATA_ICUSTOM,   // Use custom indicator file (iCustom).
  IDATA_INDICATOR  // Use indicator class as source of data with custom calculation.
};

// Defines range value data type for indicator storage.
enum ENUM_IDATA_VALUE_RANGE {
  IDATA_RANGE_ARROW,   // Value is non-zero on signal.
  IDATA_RANGE_BINARY,  // E.g. 0 or 1.
  IDATA_RANGE_FIXED,   // E.g. 0 to 100.
  IDATA_RANGE_MIXED,
  IDATA_RANGE_PRICE,  // Values represent price.
  IDATA_RANGE_UNKNOWN
};

// Defines type of value for indicator storage.
enum ENUM_IDATA_VALUE_TYPE { TNONE, TDBL1, TDBL2, TDBL3, TDBL4, TDBL5, TINT1, TINT2, TINT3, TINT4, TINT5 };

// Define indicator index.
enum ENUM_INDICATOR_INDEX {
  CURR = 0,
  PREV = 1,
  PPREV = 2,
  FINAL_ENUM_INDICATOR_INDEX = 3  // Should be the last one. Used to calculate the number of enum items.
};

// Indicator line identifiers used in Envelopes and Fractals indicators.
enum ENUM_LO_UP_LINE {
#ifdef __MQL4__
  LINE_UPPER = MODE_UPPER,  // Upper line.
  LINE_LOWER = MODE_LOWER,  // Bottom line.
#else
  LINE_UPPER = UPPER_LINE,  // Upper line.
  LINE_LOWER = LOWER_LINE,  // Bottom line.
#endif
  FINAL_LO_UP_LINE_ENTRY,
};

// Indicator line identifiers used in MACD, RVI and Stochastic indicators.
enum ENUM_SIGNAL_LINE {
#ifdef __MQL4__
  // @see: https://docs.mql4.com/constants/indicatorconstants/lines
  LINE_MAIN = MODE_MAIN,      // Main line.
  LINE_SIGNAL = MODE_SIGNAL,  // Signal line.
#else
  // @see: https://www.mql5.com/en/docs/constants/indicatorconstants/lines
  LINE_MAIN = MAIN_LINE,      // Main line.
  LINE_SIGNAL = SIGNAL_LINE,  // Signal line.
#endif
  FINAL_SIGNAL_LINE_ENTRY,
};

#ifdef __MQL4__
// The volume type is used in calculations.
// For MT4, we define it for backward compatibility.
// @docs: https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
enum ENUM_APPLIED_VOLUME { VOLUME_TICK = 0, VOLUME_REAL = 1 };
#endif

// Indicator entry flags.
enum INDICATOR_ENTRY_FLAGS {
  INDI_ENTRY_FLAG_NONE = 0,
  INDI_ENTRY_FLAG_IS_VALID = 1,
  INDI_ENTRY_FLAG_RESERVED1 = 2,
  INDI_ENTRY_FLAG_RESERVED2 = 4,
  INDI_ENTRY_FLAG_RESERVED3 = 8
};
