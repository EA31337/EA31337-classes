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
  BAR_TYPE_HAS_LONG_SHADOW_LW = 1 << 3,  // Has long lower shadow
  BAR_TYPE_HAS_LONG_SHADOW_UP = 1 << 4,  // Has long upper shadow
  BAR_TYPE_HAS_WICK_BEAR = 1 << 5,       // Has lower shadow
  BAR_TYPE_HAS_WICK_BULL = 1 << 6,       // Has upper shadow
  BAR_TYPE_IS_DOJI_DRAGON = 1 << 7,      // Has doji dragonfly pattern (upper)
  BAR_TYPE_IS_DOJI_GRAVE = 1 << 8,       // Has doji gravestone pattern (lower)
  BAR_TYPE_IS_HAMMER_BEAR = 1 << 9,      // Has a lower hammer pattern
  BAR_TYPE_IS_HAMMER_BULL = 1 << 10,     // Has a upper hammer pattern
  BAR_TYPE_IS_HANGMAN = 1 << 11,         // Has a hanging man pattern
  BAR_TYPE_IS_SPINNINGTOP = 1 << 12,     // Has a spinning top pattern
  BAR_TYPE_IS_SSTAR = 1 << 13,           // Has a shooting star pattern
  BAR_TYPE_BODY_ABOVE_MID = 1 << 14,     // Body is above center
  BAR_TYPE_BODY_BELOW_MID = 1 << 15,     // Body is below center
  BAR_TYPE_BODY_GT_WICK = 1 << 16,       // Body is higher than each wick
  BAR_TYPE_BODY_GT_WICKS = 1 << 17,      // Body is higher than sum of wicks
  // Special (rely on the existing patterns).
  BAR_TYPE_IS_MARUBOZU = (~BAR_TYPE_HAS_WICK_BEAR | ~BAR_TYPE_HAS_WICK_BULL),  // Full body with no wicks
  BAR_TYPE_IS_SHAVEN_DOWN = (BAR_TYPE_BEAR & BAR_TYPE_HAS_WICK_BULL & ~BAR_TYPE_HAS_WICK_BEAR),
  BAR_TYPE_IS_SHAVEN_UP = (BAR_TYPE_BULL & BAR_TYPE_HAS_WICK_BEAR & ~BAR_TYPE_HAS_WICK_BULL),
  // Other features (rely on other bars).
  BAR_TYPE_CANDLE_GT_1PC = 1 << 18,   // Candle size is greater than 1% of the price
  BAR_TYPE_CANDLE_GT_AVG = 1 << 19,   // Candle size is greater than a daily average
  BAR_TYPE_CANDLE_IS_MAX = 1 << 20,   // Candle size is reported as the largest of a day
  BAR_TYPE_CANDLE_IS_PEAK = 1 << 21,  // Candle size is reported at the peak price of a day
  BAR_TYPE_SPIKE_GT_AVG = 1 << 22,    // Spike/wick is greater than a daily average
  BAR_TYPE_SPIKE_IS_MAX = 1 << 23,    // Spike/wick is reported as the largest of a day
  BAR_TYPE_SPIKE_IS_PEAK = 1 << 24,   // Spike/wick is reported at the peak price of a day
  // Used to calculate the number of enum items.
  FINAL_ENUM_BAR_PATTERN_INDEX
};
