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
 * Includes Bar's enums.
 */

// Defines types of candlestick (bar) patterns.
enum ENUM_BAR_PATTERN {
  // Single candlestick (bar) patterns.
  BAR_TYPE_NONE = 0 << 0,                // None/Neutral (Doji)
  BAR_TYPE_BEAR = 1 << 1,                // Bearish
  BAR_TYPE_BULL = 1 << 2,                // Bullish
  BAR_TYPE_HAS_WICK_LW = 1 << 3,         // Has lower shadow
  BAR_TYPE_HAS_WICK_UP = 1 << 4,         // Has upper shadow
  BAR_TYPE_IS_DOJI_DRAGON = 1 << 5,      // Has doji dragonfly pattern (upper)
  BAR_TYPE_IS_DOJI_GRAVE = 1 << 6,       // Has doji gravestone pattern (lower)
  BAR_TYPE_IS_HAMMER_INV = 1 << 7,       // Has an inverted hammer (also a shooting star) pattern
  BAR_TYPE_IS_HAMMER_UP = 1 << 8,        // Has an upper hammer pattern
  BAR_TYPE_IS_HANGMAN = 1 << 9,          // Has a hanging man pattern
  BAR_TYPE_IS_LONG_SHADOW_LW = 1 << 10,  // Has long lower shadow pattern
  BAR_TYPE_IS_LONG_SHADOW_UP = 1 << 11,  // Has long upper shadow pattern
  BAR_TYPE_IS_MARUBOZU = 1 << 12,        // Has body with no or small wicks
  BAR_TYPE_IS_SHAVEN_LW = 1 << 13,       // Has a shaven bottom (lower) pattern
  BAR_TYPE_IS_SHAVEN_UP = 1 << 14,       // Has a shaven head (upper) pattern
  BAR_TYPE_IS_SPINNINGTOP = 1 << 15,     // Has a spinning top pattern
  BAR_TYPE_BODY_GT_MED = 1 << 16,        // Body is above the median price
  BAR_TYPE_BODY_GT_WICK = 1 << 17,       // Body is higher than each wick
  BAR_TYPE_BODY_GT_WICKS = 1 << 18,      // Body is higher than sum of wicks
  BAR_TYPE_BODY_LT_MED = 1 << 19,        // Body is below the median price
  // Other features (rely on other bars).
  BAR_TYPE_CANDLE_GT_1PC = 1 << 20,   // Candle size is greater than 1% of the price
  BAR_TYPE_CANDLE_GT_AVG = 1 << 21,   // Candle size is greater than a daily average
  BAR_TYPE_CANDLE_IS_MAX = 1 << 22,   // Candle size is reported as the largest of a day
  BAR_TYPE_CANDLE_IS_PEAK = 1 << 23,  // Candle size is reported at the peak price of a day
  BAR_TYPE_SPIKE_GT_AVG = 1 << 24,    // Spike/wick is greater than a daily average
  BAR_TYPE_SPIKE_IS_MAX = 1 << 25,    // Spike/wick is reported as the largest of a day
  BAR_TYPE_SPIKE_IS_PEAK = 1 << 26,   // Spike/wick is reported at the peak price of a day
  // Used to calculate the number of enum items.
  FINAL_ENUM_BAR_PATTERN_INDEX
};

// Pivot Point calculation method.
enum ENUM_PP_TYPE {
  PP_CAMARILLA = 1,   // A set of eight levels which resemble support and resistance values
  PP_CLASSIC = 2,     // Classic pivot point
  PP_FIBONACCI = 3,   // Fibonacci pivot point
  PP_FLOOR = 4,       // Most basic and popular type of pivots used in Forex trading technical analysis
  PP_TOM_DEMARK = 5,  // Tom DeMark's pivot point (predicted lows and highs of the period)
  PP_WOODIE = 6,      // Woodie's pivot point are giving more weight to the Close price of the previous period
  FINAL_ENUM_PP_TYPE_ENTRY
};
