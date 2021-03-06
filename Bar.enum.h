//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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

/* Defines types of candlestick (bar) patterns. */
enum ENUM_BAR_PATTERN {
  // Single candlestick (bar) patterns.
  BAR_TYPE_NONE = 0 << 0,                // None/Neutral (Doji)
  BAR_TYPE_BEAR = 1 << 0,                // Bearish
  BAR_TYPE_BULL = 1 << 1,                // Bullish
  BAR_TYPE_BODY_GT_MED = 1 << 2,         // Body is above the median price
  BAR_TYPE_BODY_GT_PP = 1 << 3,          // Body is above the pivot price (HLC/3)
  BAR_TYPE_BODY_GT_PP_DM = 1 << 4,       // Body is above the Tom DeMark pivot price
  BAR_TYPE_BODY_GT_PP_OPEN = 1 << 5,     // Body is above the pivot price (OHLC/4)
  BAR_TYPE_BODY_GT_WEIGHTED = 1 << 6,    // Body is above the weighted price (OH2C/4)
  BAR_TYPE_BODY_GT_WICKS = 1 << 7,       // Body is greater than sum of wicks
  BAR_TYPE_CHANGE_GT_02PC = 1 << 8,      // Price change is greater than 0.2% of the price change
  BAR_TYPE_CHANGE_GT_05PC = 1 << 9,      // Price change is greater than 0.5% of the price change
  BAR_TYPE_CLOSE_GT_MED = 1 << 10,       // Close price is above the median price
  BAR_TYPE_CLOSE_GT_PP = 1 << 11,        // Close price is above the pivot price (HLC/3)
  BAR_TYPE_CLOSE_GT_PP_DM = 1 << 12,     // Close price is above the Tom DeMark pivot price
  BAR_TYPE_CLOSE_GT_PP_OPEN = 1 << 13,   // Close price is above the pivot price (OHLC/4)
  BAR_TYPE_CLOSE_GT_WEIGHTED = 1 << 14,  // Close price is above the weighted price (OH2C/4)
  BAR_TYPE_CLOSE_LT_PP = 1 << 15,        // Close price is lower the pivot price (HLC/3)
  BAR_TYPE_CLOSE_LT_PP_DM = 1 << 16,     // Close price is lower the Tom DeMark pivot price
  BAR_TYPE_CLOSE_LT_PP_OPEN = 1 << 17,   // Close price is lower the pivot price (OHLC/4)
  BAR_TYPE_CLOSE_LT_WEIGHTED = 1 << 18,  // Close price is lower the weighted price (OH2C/4)
  BAR_TYPE_HAS_WICK_LW = 1 << 19,        // Has lower shadow
  BAR_TYPE_HAS_WICK_UP = 1 << 20,        // Has upper shadow
  BAR_TYPE_IS_DOJI_DRAGON = 1 << 21,     // Has doji dragonfly pattern (upper)
  BAR_TYPE_IS_DOJI_GRAVE = 1 << 22,      // Has doji gravestone pattern (lower)
  BAR_TYPE_IS_HAMMER_INV = 1 << 23,      // Has an inverted hammer (also a shooting star) pattern
  BAR_TYPE_IS_HAMMER_UP = 1 << 24,       // Has an upper hammer pattern
  BAR_TYPE_IS_HANGMAN = 1 << 25,         // Has a hanging man pattern
  BAR_TYPE_IS_LONG_SHADOW_LW = 1 << 26,  // Has long lower shadow pattern
  BAR_TYPE_IS_LONG_SHADOW_UP = 1 << 27,  // Has long upper shadow pattern
  BAR_TYPE_IS_MARUBOZU = 1 << 28,        // Has body with no or small wicks
  BAR_TYPE_IS_SHAVEN_LW = 1 << 29,       // Has a shaven bottom (lower) pattern
  BAR_TYPE_IS_SHAVEN_UP = 1 << 30,       // Has a shaven head (upper) pattern
  BAR_TYPE_IS_SPINNINGTOP = 1 << 31,     // Has a spinning top pattern
  // Candle features (rely on other bars).
  // BAR_TYPE_CANDLE_GT_AVG = 1 << 30,      // Candle size is greater than a daily average
  // BAR_TYPE_CANDLE_IS_MAX = 1 << 31,      // Candle size is reported as the largest of a day
  // BAR_TYPE_CANDLE_IS_PEAK = 1 << 32,     // Candle size is reported at the peak price of a day
  // Relations to previous candle (rely on previous bar).
  // BAR_TYPE_NEW_CLOSE_HIGH = 1 << 33,     // Current bar's close price is higher.
  // BAR_TYPE_NEW_OPEN_HIGH = 1 << 34,      // Current bar's open price is higher.
  // BAR_TYPE_NEW_TYPICAL_HIGH = 1 << 35,   // Current bar's typical price is higher.
  // BAR_TYPE_NEW_PEAK = 1 << 36,           // Current bar reached a peak price.
  // Candle spike features (rely on other bars).
  // BAR_TYPE_SPIKE_GT_AVG = 1 << 37,       // Spike/wick is greater than a daily average
  // BAR_TYPE_SPIKE_IS_MAX = 1 << 38,       // Spike/wick is reported as the large one
  // BAR_TYPE_SPIKE_IS_PEAK = 1 << 39,      // Spike/wick is reported at the peak price
  // Used to calculate the number of enum items.
  FINAL_ENUM_BAR_PATTERN_INDEX = INT_MAX
};

/* Pivot Point calculation method. */
enum ENUM_PP_TYPE {
  PP_CAMARILLA = 1,   // A set of eight levels which resemble support and resistance values
  PP_CLASSIC = 2,     // Classic pivot point
  PP_FIBONACCI = 3,   // Fibonacci pivot point
  PP_FLOOR = 4,       // Most basic and popular type of pivots used in Forex trading technical analysis
  PP_TOM_DEMARK = 5,  // Tom DeMark's pivot point (predicted lows and highs of the period)
  PP_WOODIE = 6,      // Woodie's pivot point are giving more weight to the Close price of the previous period
  FINAL_ENUM_PP_TYPE_ENTRY
};
