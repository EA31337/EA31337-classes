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

/* Define type of */
enum ENUM_INDICATOR_TYPE {
  INDI_NONE = 0,                        // (None)
  INDI_AC,                              // Accelerator Oscillator
  INDI_AD,                              // Accumulation/Distribution
  INDI_ADX,                             // Average Directional Index
  INDI_ADXW,                            // ADX by Welles Wilder
  INDI_ALLIGATOR,                       // Alligator
  INDI_AMA,                             // Adaptive Moving Average
  INDI_APPLIED_PRICE,                   // Applied Price over OHLC Indicator
  INDI_AO,                              // Awesome Oscillator
  INDI_ASI,                             // Accumulation Swing Index
  INDI_ATR,                             // Average True Range
  INDI_BANDS,                           // Bollinger Bands
  INDI_BANDS_ON_PRICE,                  // Bollinger Bands (on Price)
  INDI_BEARS,                           // Bears Power
  INDI_BULLS,                           // Bulls Power
  INDI_BWMFI,                           // Market Facilitation Index
  INDI_BWZT,                            // Bill Williams' Zone Trade
  INDI_CANDLE,                          // Candle Pattern Detector
  INDI_CCI,                             // Commodity Channel Index
  INDI_CCI_ON_PRICE,                    // Commodity Channel Index (CCI) (on Price)
  INDI_CHAIKIN,                         // Chaikin Oscillator
  INDI_CHAIKIN_V,                       // Chaikin Volatility
  INDI_COLOR_BARS,                      // Color Bars
  INDI_COLOR_CANDLES_DAILY,             // Color Candles Daily
  INDI_COLOR_LINE,                      // Color Line
  INDI_CUSTOM,                          // Custom indicator
  INDI_CUSTOM_MOVING_AVG,               // Custom Moving Average
  INDI_DEMA,                            // Double Exponential Moving Average
  INDI_DEMARKER,                        // DeMarker
  INDI_DEMO,                            // Demo/Dummy Indicator
  INDI_DETRENDED_PRICE,                 // Detrended Price Oscillator
  INDI_DRAWER,                          // Drawer (Socket-based) Indicator
  INDI_ENVELOPES,                       // Envelopes
  INDI_ENVELOPES_ON_PRICE,              // Evelopes (on Price)
  INDI_FORCE,                           // Force Index
  INDI_FRACTALS,                        // Fractals
  INDI_FRAMA,                           // Fractal Adaptive Moving Average
  INDI_GATOR,                           // Gator Oscillator
  INDI_HEIKENASHI,                      // Heiken Ashi
  INDI_ICHIMOKU,                        // Ichimoku Kinko Hyo
  INDI_KILLZONES,                       // Killzones
  INDI_MA,                              // Moving Average
  INDI_MACD,                            // MACD
  INDI_MA_ON_PRICE,                     // Moving Average (on Price).
  INDI_MARKET_FI,                       // Market Facilitation Index
  INDI_MASS_INDEX,                      // Mass Index
  INDI_MFI,                             // Money Flow Index
  INDI_MOMENTUM,                        // Momentum
  INDI_MOMENTUM_ON_PRICE,               // Momentum (on Price)
  INDI_OBV,                             // On Balance Volume
  INDI_OHLC,                            // OHLC (Open-High-Low-Close)
  INDI_OSMA,                            // OsMA
  INDI_PATTERN,                         // Pattern Detector
  INDI_PIVOT,                           // Pivot Detector
  INDI_PRICE,                           // Price
  INDI_PRICE_CHANNEL,                   // Price Channel
  INDI_PRICE_FEEDER,                    // Indicator which returns prices from custom array
  INDI_PRICE_VOLUME_TREND,              // Price and Volume Trend
  INDI_RATE_OF_CHANGE,                  // Rate of Change
  INDI_RS,                              // Indi_Math-based RSI
  INDI_RSI,                             // Relative Strength Index
  INDI_RSI_ON_PRICE,                    // Relative Strength Index (RSI) (on Price)
  INDI_RVI,                             // Relative Vigor Index
  INDI_SAR,                             // Parabolic SAR
  INDI_SPECIAL_MATH,                    // Math operations over given
  INDI_STDDEV,                          // Standard Deviation
  INDI_STDDEV_ON_MA_SMA,                // Standard Deviation on Moving Average in SMA mode
  INDI_STDDEV_ON_PRICE,                 // Standard Deviation (on Price)
  INDI_STDDEV_SMA_ON_PRICE,             // Standard Deviation in SMA mode (on Price)
  INDI_STOCHASTIC,                      // Stochastic Oscillator
  INDI_SVE_BB,                          // SVE Bollinger Bands
  INDI_TEMA,                            // Triple Exponential Moving Average
  INDI_TF,                              // Timeframe
  INDI_TICK,                            // Tick
  INDI_TMA_TRUE,                        // Triangular Moving Average True
  INDI_TRIX,                            // Triple Exponential Moving Averages Oscillator
  INDI_ULTIMATE_OSCILLATOR,             // Ultimate Oscillator
  INDI_ULTIMATE_OSCILLATOR_ATR_FAST,    // Ultimate Oscillator's ATR, Fast
  INDI_ULTIMATE_OSCILLATOR_ATR_MIDDLE,  // Ultimate Oscillator's ATR, Middle
  INDI_ULTIMATE_OSCILLATOR_ATR_SLOW,    // Ultimate Oscillator's ATR, Slow
  INDI_VIDYA,                           // Variable Index Dynamic Average
  INDI_VOLUMES,                         // Volumes
  INDI_VROC,                            // Volume Rate of Change
  INDI_WILLIAMS_AD,                     // Larry Williams' Accumulation/Distribution
  INDI_WPR,                             // Williams' Percent Range
  INDI_ZIGZAG,                          // ZigZag
  INDI_ZIGZAG_COLOR,                    // ZigZag Color
  FINAL_INDICATOR_TYPE_ENTRY
};

// Indicator line identifiers used in ADX and ADXW
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

/* Indicator line identifiers used in Envelopes and Fractals */
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
 * Indicator line identifiers used in MACD, RVI and Stochastic
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

// Indicator flags.
enum ENUM_INDI_FLAGS {
  INDI_FLAG_INDEXABLE_BY_SHIFT,                // Indicator supports indexation by shift.
  INDI_FLAG_INDEXABLE_BY_TIMESTAMP,            // Indicator supports indexation by shift.
  INDI_FLAG_SOURCE_REQ_INDEXABLE_BY_SHIFT,     // Source indicator must be indexable by shift.
  INDI_FLAG_SOURCE_REQ_INDEXABLE_BY_TIMESTAMP  // Source indicator must be indexable by timestamp.
};

// Flags indicating which data sources are required to be provided in order indicator to work.
enum ENUM_INDI_SUITABLE_DS_TYPE {
  INDI_SUITABLE_DS_TYPE_EXPECT_NONE = 1 << 0,
  INDI_SUITABLE_DS_TYPE_TICK = 1 << 1,    // Indicator requires Tick-based data source in the hierarchy.
  INDI_SUITABLE_DS_TYPE_CANDLE = 1 << 2,  // Indicator requires Candle-based data source in the hierarchy.
  INDI_SUITABLE_DS_TYPE_CUSTOM = 1 << 3,  // Indicator requires parent data source to have custom set of buffers/modes.
  INDI_SUITABLE_DS_TYPE_AP =
      1 << 4,  // Indicator requires single, targetted (by applied price) buffer from data source in the hierarchy.
  INDI_SUITABLE_DS_TYPE_AV =
      1 << 5,  // Indicator requires single, targetted (by applied volume) buffer from data source in the hierarchy.
  INDI_SUITABLE_DS_TYPE_BASE_ONLY = 1 << 6,   // Required data source must be directly connected to this data source.
  INDI_SUITABLE_DS_TYPE_EXPECT_ANY = 1 << 7,  // Requires data source of any kind.
};

// Type of data source mode. Required to determine what "mode" means for the user.
enum ENUM_INDI_DS_MODE_KIND {
  INDI_DS_MODE_KIND_INDEX,    // Mode is a buffer index.
  INDI_DS_MODE_KIND_VS_TYPE,  // Mode is a value from ENUM_INDI_VS_TYPE enumeration, e.g., ENUM_INDI_VS_PRICE_OPEN.
  INDI_DS_MODE_KIND_AP,  // Mode is a value from ENUM_APPLIED_PRICE enumeration. It is used to retrieve value storage
                         // based on ENUM_INDI_VS_TYPE enumeration, e.g., PRICE_OPEN becomes ENUM_INDI_VS_PRICE_OPEN.
};
