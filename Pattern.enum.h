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
 * Includes Pattern's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/* Enumeration for 1-candle patterns. */
enum ENUM_PATTERN_1CANDLE {
  // Single candlestick (bar) patterns.
  PATTERN_1CANDLE_NONE = 0 << 0,                // None/Neutral (Doji)
  PATTERN_1CANDLE_BEAR = 1 << 0,                // Bearish
  PATTERN_1CANDLE_BULL = 1 << 1,                // Bullish
  PATTERN_1CANDLE_BODY_GT_MED = 1 << 2,         // Body is above the median price
  PATTERN_1CANDLE_BODY_GT_PP = 1 << 3,          // Body is above the pivot price (HLC/3)
  PATTERN_1CANDLE_BODY_GT_PP_DM = 1 << 4,       // Body is above the Tom DeMark pivot price
  PATTERN_1CANDLE_BODY_GT_PP_OPEN = 1 << 5,     // Body is above the pivot price (OHLC/4)
  PATTERN_1CANDLE_BODY_GT_WEIGHTED = 1 << 6,    // Body is above the weighted price (OH2C/4)
  PATTERN_1CANDLE_BODY_GT_WICKS = 1 << 7,       // Body is greater than sum of wicks
  PATTERN_1CANDLE_CHANGE_GT_01PC = 1 << 8,      // Price change is greater than 0.1% of the price change
  PATTERN_1CANDLE_CHANGE_GT_02PC = 1 << 9,      // Price change is greater than 0.2% of the price change
  PATTERN_1CANDLE_CLOSE_GT_MED = 1 << 10,       // Close price is above the median price
  PATTERN_1CANDLE_CLOSE_GT_PP = 1 << 11,        // Close price is above the pivot price (HLC/3)
  PATTERN_1CANDLE_CLOSE_GT_PP_DM = 1 << 12,     // Close price is above the Tom DeMark pivot price
  PATTERN_1CANDLE_CLOSE_GT_PP_OPEN = 1 << 13,   // Close price is above the pivot price (OHLC/4)
  PATTERN_1CANDLE_CLOSE_GT_WEIGHTED = 1 << 14,  // Close price is above the weighted price (OH2C/4)
  PATTERN_1CANDLE_CLOSE_LT_PP = 1 << 15,        // Close price is lower the pivot price (HLC/3)
  PATTERN_1CANDLE_CLOSE_LT_PP_DM = 1 << 16,     // Close price is lower the Tom DeMark pivot price
  PATTERN_1CANDLE_CLOSE_LT_PP_OPEN = 1 << 17,   // Close price is lower the pivot price (OHLC/4)
  PATTERN_1CANDLE_CLOSE_LT_WEIGHTED = 1 << 18,  // Close price is lower the weighted price (OH2C/4)
  PATTERN_1CANDLE_HAS_WICK_LW = 1 << 19,        // Has lower shadow
  PATTERN_1CANDLE_HAS_WICK_UP = 1 << 20,        // Has upper shadow
  PATTERN_1CANDLE_IS_DOJI_DRAGON = 1 << 21,     // Has doji dragonfly pattern (upper)
  PATTERN_1CANDLE_IS_DOJI_GRAVE = 1 << 22,      // Has doji gravestone pattern (lower)
  PATTERN_1CANDLE_IS_HAMMER_INV = 1 << 23,      // Has an inverted hammer (also a shooting star) pattern
  PATTERN_1CANDLE_IS_HAMMER_UP = 1 << 24,       // Has an upper hammer pattern
  PATTERN_1CANDLE_IS_HANGMAN = 1 << 25,         // Has a hanging man pattern
  PATTERN_1CANDLE_IS_LONG_SHADOW_LW = 1 << 26,  // Has long lower shadow pattern
  PATTERN_1CANDLE_IS_LONG_SHADOW_UP = 1 << 27,  // Has long upper shadow pattern
  PATTERN_1CANDLE_IS_MARUBOZU = 1 << 28,        // Has body with no or small wicks
  PATTERN_1CANDLE_IS_SHAVEN_LW = 1 << 29,       // Has a shaven bottom (lower) pattern
  PATTERN_1CANDLE_IS_SHAVEN_UP = 1 << 30,       // Has a shaven head (upper) pattern
  PATTERN_1CANDLE_IS_SPINNINGTOP = 1 << 31,     // Has a spinning top pattern
  // Candle features (rely on other bars).
  // PATTERN_1CANDLE_CANDLE_GT_AVG = 1 << 30,      // Candle size is greater
  // than a daily average
  // PATTERN_1CANDLE_CANDLE_IS_MAX = 1 << 31,      // Candle size is reported as
  // the largest of a day
  // PATTERN_1CANDLE_CANDLE_IS_PEAK = 1 << 32,     // Candle size is reported at
  // the peak price of a day
  // Relations to previous candle (rely on previous bar).
  // PATTERN_1CANDLE_NEW_CLOSE_HIGH = 1 << 33,     // Current bar's close price
  // is higher.
  // PATTERN_1CANDLE_NEW_OPEN_HIGH = 1 << 34,      // Current bar's open price
  // is higher.
  // PATTERN_1CANDLE_NEW_TYPICAL_HIGH = 1 << 35,   // Current bar's typical
  // price is higher.
  // PATTERN_1CANDLE_NEW_PEAK = 1 << 36,           // Current bar reached a peak
  // price.
  // Candle spike features (rely on other bars).
  // PATTERN_1CANDLE_SPIKE_GT_AVG = 1 << 37,       // Spike/wick is greater than
  // a daily average
  // PATTERN_1CANDLE_SPIKE_IS_MAX = 1 << 38,       // Spike/wick is reported as
  // the large one
  // PATTERN_1CANDLE_SPIKE_IS_PEAK = 1 << 39,      // Spike/wick is reported at
  // the peak price
  // Used to calculate the number of enum items.
  FINAL_ENUM_PATTERN_1CANDLE = INT_MAX
};

/* Enumeration for 2-candle patterns. */
enum ENUM_PATTERN_2CANDLE {
  PATTERN_2CANDLE_NONE = 0 << 0,                   // None.
  PATTERN_2CANDLE_BEARS = 1 << 0,                  // Two bear candles.
  PATTERN_2CANDLE_BODY_GT_BODY = 1 << 1,           // Body size is greater than the previous one.
  PATTERN_2CANDLE_BULLS = 1 << 2,                  // Two bulls candles.
  PATTERN_2CANDLE_CLOSE_GT_CLOSE = 1 << 3,         // Close is greater than the previous one.
  PATTERN_2CANDLE_CLOSE_GT_HIGH = 1 << 4,          // Close is greater than previous high.
  PATTERN_2CANDLE_CLOSE_LT_LOW = 1 << 5,           // Close is lower than previous low.
  PATTERN_2CANDLE_HIGH_GT_HIGH = 1 << 6,           // High is greater than the previous one.
  PATTERN_2CANDLE_HIGH_GT_HOC = 1 << 7,            // High is greater than the previous higher price (open or close).
  PATTERN_2CANDLE_HOC_GT_HIGH = 1 << 8,            // Higher price (open or close) is greater than the previous high.
  PATTERN_2CANDLE_HOC_GT_HOC = 1 << 9,             // Higher price (open or close) is greater than the previous one.
  PATTERN_2CANDLE_LOC_LT_LOC = 1 << 10,            // Lower price (open or close) is lower than the previous one.
  PATTERN_2CANDLE_LOC_LT_LOW = 1 << 11,            // Lower price (open or close) is lower than the previous low.
  PATTERN_2CANDLE_LOW_LT_LOC = 1 << 12,            // Low is lower than the previous lower price (open or close).
  PATTERN_2CANDLE_LOW_LT_LOW = 1 << 13,            // Low is lower than the previous one.
  PATTERN_2CANDLE_OPEN_GT_OPEN = 1 << 14,          // Open is greater than the previous one.
  PATTERN_2CANDLE_PP_GT_PP = 1 << 15,              // Pivot price is greater than the previous one (HLC/3).
  PATTERN_2CANDLE_PP_GT_PP_OPEN = 1 << 16,         // Pivot price open is greater than the previous one (OHLC/4).
  PATTERN_2CANDLE_RANGE_DBL_RANGE = 1 << 17,       // Range size doubled from the previous one.
  PATTERN_2CANDLE_RANGE_GT_RANGE = 1 << 18,        // Range is greater than the previous one.
  PATTERN_2CANDLE_TIME_GAP_DAY = 1 << 19,          // Bars have over 24h gap.
  PATTERN_2CANDLE_WEIGHTED_GT_WEIGHTED = 1 << 20,  // Weighted price is greater than the previous one (OH2C/4).
  PATTERN_2CANDLE_WICKS_DBL_WICKS = 1 << 21,       // Size of wicks doubled from the previous onces.
  PATTERN_2CANDLE_WICKS_GT_WICKS = 1 << 22,        // Size of wicks is greater than the previous onces.
  // ---
  PATTERN_2CANDLE_BODY_IN_BODY = 1 << 23,
  PATTERN_2CANDLE_BODY_OUT_BODY = 1 << 24,
  PATTERN_2CANDLE_RANGE_IN_RANGE = 1 << 25,
  PATTERN_2CANDLE_RANGE_OUT_RANGE = 1 << 26,
  // Patterns based on the existing patterns.
  // PATTERN_2CANDLE_BODY_IN_BODY = ~PATTERN_2CANDLE_HOC_GT_HOC | ~PATTERN_2CANDLE_LOC_LT_LOC,
  // PATTERN_2CANDLE_BODY_OUT_BODY = PATTERN_2CANDLE_HOC_GT_HOC | PATTERN_2CANDLE_LOC_LT_LOC,
  // PATTERN_2CANDLE_RANGE_IN_RANGE = ~PATTERN_2CANDLE_HIGH_GT_HIGH | ~PATTERN_2CANDLE_LOW_LT_LOW,
  // PATTERN_2CANDLE_RANGE_OUT_RANGE = PATTERN_2CANDLE_HIGH_GT_HIGH | PATTERN_2CANDLE_LOW_LT_LOW,
  // PATTERN_2CANDLE_RANGE_IN_BODY = 1 << ??,   // Range is inside body of the previous candle.
  // PATTERN_2CANDLE_RANGE_OUT_RANGE = 1 << ??, // Range is outside of range of the previous candle.
  // Bearish engulfing pattern.
  // A lot of momentum in favor of price falling.
  PATTERN_2CANDLE_BEAR_ENGULFING = ~PATTERN_2CANDLE_BEARS | ~PATTERN_2CANDLE_BULLS | ~PATTERN_2CANDLE_CLOSE_GT_CLOSE |
                                   PATTERN_2CANDLE_BODY_OUT_BODY | PATTERN_2CANDLE_RANGE_OUT_RANGE |
                                   PATTERN_2CANDLE_HOC_GT_HOC | PATTERN_2CANDLE_LOC_LT_LOC,
  // Bullish engulfing pattern.
  // A lot of momentum in favor of price rising.
  PATTERN_2CANDLE_BULL_ENGULFING = ~PATTERN_2CANDLE_BEARS | ~PATTERN_2CANDLE_BULLS | PATTERN_2CANDLE_CLOSE_GT_CLOSE |
                                   PATTERN_2CANDLE_BODY_OUT_BODY | PATTERN_2CANDLE_RANGE_OUT_RANGE |
                                   PATTERN_2CANDLE_HOC_GT_HOC | PATTERN_2CANDLE_LOC_LT_LOC,

  // Body is inside of the previous candle's range.
  PATTERN_2CANDLE_BODY_IN_RANGE = 1 << 27,
  // PATTERN_2CANDLE_BODY_IN_RANGE = ~PATTERN_2CANDLE_HOC_GT_HIGH | ~PATTERN_2CANDLE_LOC_LT_LOW,

  // Body is outside of the previous candle's range (partial Bullish engulfing).
  PATTERN_2CANDLE_BODY_OUT_RANGE = 1 << 28,
  // PATTERN_2CANDLE_BODY_OUT_RANGE = PATTERN_2CANDLE_HOC_GT_HIGH | PATTERN_2CANDLE_LOC_LT_LOW,

  // Range is inside of the previous candle's body (partial Harami pattern).
  PATTERN_2CANDLE_RANGE_IN_BODY = 1 << 29,
  // PATTERN_2CANDLE_RANGE_IN_BODY = ~PATTERN_2CANDLE_HIGH_GT_HOC | ~PATTERN_2CANDLE_LOW_LT_LOC,

  // Range is outside of the previous candle's body (partial Harami pattern).
  PATTERN_2CANDLE_RANGE_OUT_BODY = 1 << 30,
  // PATTERN_2CANDLE_RANGE_OUT_BODY = PATTERN_2CANDLE_HIGH_GT_HOC | PATTERN_2CANDLE_LOW_LT_LOC,

  // Harami pattern.
  // Neutral pattern where price is being pushed into a tighter range.
  PATTERN_2CANDLE_HARAMI = 1 << 31,
  // PATTERN_2CANDLE_HARAMI = PATTERN_2CANDLE_BODY_IN_BODY | PATTERN_2CANDLE_RANGE_IN_BODY | ~PATTERN_2CANDLE_HOC_GT_HOC
  // | ~PATTERN_2CANDLE_LOC_LT_LOC,

  // Dark cloud cover.
  // Price acted like it was continuing upwards, but then reversed.
  PATTERN_2CANDLE_DARK_CLOUD_COVER = ~PATTERN_2CANDLE_BEARS | ~PATTERN_2CANDLE_BULLS | ~PATTERN_2CANDLE_CLOSE_GT_CLOSE |
                                     PATTERN_2CANDLE_HIGH_GT_HIGH | ~PATTERN_2CANDLE_LOW_LT_LOW |
                                     PATTERN_2CANDLE_HOC_GT_HOC | ~PATTERN_2CANDLE_LOC_LT_LOC,
  // Rising sun.
  // Price looked like it was going to continue down, then moved up.
  PATTERN_2CANDLE_RISING_SUN = ~PATTERN_2CANDLE_BEARS | ~PATTERN_2CANDLE_BULLS | ~PATTERN_2CANDLE_CLOSE_GT_CLOSE |
                               PATTERN_2CANDLE_HIGH_GT_HIGH | ~PATTERN_2CANDLE_LOW_LT_LOW | PATTERN_2CANDLE_HOC_GT_HOC |
                               ~PATTERN_2CANDLE_LOC_LT_LOC,
  // @todo
  FINAL_ENUM_PATTERN_2CANDLE = INT_MAX
};

/* Enumeration for 3-candle patterns. */
enum ENUM_PATTERN_3CANDLE {
  PATTERN_3CANDLE_NONE = 0 << 0,              // None
  PATTERN_3CANDLE_BEARS = 1 << 0,             // Three bear candles.
  PATTERN_3CANDLE_BODY0_DBL_SUM = 1 << 1,     // Body size is greater than doubled sum of others.
  PATTERN_3CANDLE_BODY0_GT_SUM = 1 << 2,      // Body size is greater than sum of others.
  PATTERN_3CANDLE_BODY_DEC = 1 << 3,          // Body size decreases.
  PATTERN_3CANDLE_BODY_INC = 1 << 4,          // Body size increases.
  PATTERN_3CANDLE_BULLS = 1 << 5,             // Three bull candles.
  PATTERN_3CANDLE_CLOSE_DEC = 1 << 6,         // Close price decreases.
  PATTERN_3CANDLE_CLOSE_INC = 1 << 7,         // Close price increases.
  PATTERN_3CANDLE_HIGH0_LT_LOW2 = 1 << 8,     // High price lower than low price of 2 bars before.
  PATTERN_3CANDLE_HIGH1_LT_PP = 1 << 9,       // High price of the middle bar is lower than pivot price.
  PATTERN_3CANDLE_HIGH_DEC = 1 << 10,         // High price decreases.
  PATTERN_3CANDLE_HIGH_INC = 1 << 11,         // High price increases.
  PATTERN_3CANDLE_LOW0_GT_HIGH2 = 1 << 12,    // Low price is greater than high price of 2 bars before.
  PATTERN_3CANDLE_LOW1_GT_PP = 1 << 13,       // Low price of the middle bar is greater than pivot price.
  PATTERN_3CANDLE_LOW_DEC = 1 << 14,          // Low price decreases.
  PATTERN_3CANDLE_LOW_INC = 1 << 15,          // Low price increases.
  PATTERN_3CANDLE_OPEN0_GT_HIGH2 = 1 << 16,   // Open price is greater than high price of 2 bars before.
  PATTERN_3CANDLE_OPEN0_LT_LOW2 = 1 << 17,    // Open price is lower than low price of 2 bars before.
  PATTERN_3CANDLE_OPEN_DEC = 1 << 18,         // Open price decreases.
  PATTERN_3CANDLE_OPEN_INC = 1 << 19,         // Open price increases.
  PATTERN_3CANDLE_PEAK = 1 << 20,             // High or low price at peak.
  PATTERN_3CANDLE_PP_DEC = 1 << 21,           // Pivot point decreases.
  PATTERN_3CANDLE_PP_INC = 1 << 22,           // Pivot point increases.
  PATTERN_3CANDLE_RANGE0_GT_SUM = 1 << 23,    // Range size is greater than sum of others.
  PATTERN_3CANDLE_RANGE1_GT_SUM = 1 << 24,    // Range size of middle candle is greater than sum of others.
  PATTERN_3CANDLE_RANGE_DEC = 1 << 25,        // Range size decreases.
  PATTERN_3CANDLE_RANGE_INC = 1 << 26,        // Range size increases.
  PATTERN_3CANDLE_WICKS0_DBL_SUM = 1 << 27,   // Size of wicks are greater than doubled sum of others.
  PATTERN_3CANDLE_WICKS0_GT_BODY = 1 << 28,   // Size of wicks are greater than sum of bodies.
  PATTERN_3CANDLE_WICKS0_GT_SUM = 1 << 29,    // Size of wicks are greater than sum of others.
  PATTERN_3CANDLE_WICKS1_DBL_BODY = 1 << 30,  // Size of middle wicks are greater than doubled sum of bodies.
  PATTERN_3CANDLE_WICKS1_GT_BODY = 1 << 31,   // Size of middle wicks are greater than sum of bodies.
  FINAL_ENUM_PATTERN_3CANDLE = INT_MAX
};

/* Enumeration for 4-candle patterns. */
enum ENUM_PATTERN_4CANDLE {
  PATTERN_4CANDLE_NONE = 0 << 0,            // None
  PATTERN_4CANDLE_BEARS = 1 << 0,           // Four bear candles.
  PATTERN_4CANDLE_BEAR_CONT = 1 << 1,       // Bearish trend continuation (DUUP).
  PATTERN_4CANDLE_BEAR_REV = 1 << 2,        // Bearish trend reversal (UUDD).
  PATTERN_4CANDLE_BEBU_MIXED = 1 << 3,      // Bears and bulls mixed (not in a row).
  PATTERN_4CANDLE_BODY0_GT_SUM = 1 << 4,    // Body size is greater than sum of others.
  PATTERN_4CANDLE_BODY_DEC = 1 << 5,        // Body size decreases.
  PATTERN_4CANDLE_BODY_INC = 1 << 6,        // Body size increases.
  PATTERN_4CANDLE_BULLS = 1 << 7,           // Four bull candles.
  PATTERN_4CANDLE_BULL_CONT = 1 << 8,       // Bull trend continuation (UDDU).
  PATTERN_4CANDLE_BULL_REV = 1 << 9,        // Bullish trend reversal (DDUU).
  PATTERN_4CANDLE_CLOSE_DEC = 1 << 10,      // Close price decreases.
  PATTERN_4CANDLE_CLOSE_INC = 1 << 11,      // Close price increases.
  PATTERN_4CANDLE_HIGH_DEC = 1 << 12,       // High price decreases.
  PATTERN_4CANDLE_HIGH_INC = 1 << 13,       // High price increases.
  PATTERN_4CANDLE_INV_HAMMER = 1 << 14,     // Inverted hammer (DD^UU).
  PATTERN_4CANDLE_LOW_DEC = 1 << 15,        // Low price decreases.
  PATTERN_4CANDLE_LOW_INC = 1 << 16,        // Low price increases.
  PATTERN_4CANDLE_OPEN_DEC = 1 << 17,       // Open price decreases.
  PATTERN_4CANDLE_OPEN_INC = 1 << 18,       // Open price increases.
  PATTERN_4CANDLE_PEAK = 1 << 19,           // High or low price at peak.
  PATTERN_4CANDLE_PP_DEC = 1 << 20,         // Pivot point decreases.
  PATTERN_4CANDLE_PP_INC = 1 << 21,         // Pivot point increases.
  PATTERN_4CANDLE_RANGE0_GT_SUM = 1 << 22,  // Range size is greater than sum of others.
  PATTERN_4CANDLE_RANGE_DEC = 1 << 23,      // Range size decreases.
  PATTERN_4CANDLE_RANGE_INC = 1 << 24,      // Range size increases.
  PATTERN_4CANDLE_SHOOT_STAR = 1 << 25,     // Shooting star (UU^DD).
  PATTERN_4CANDLE_TIME_GAPS = 1 << 26,      // Bar time is not consistent (has time gaps).
  PATTERN_4CANDLE_WICKS0_GT_SUM = 1 << 27,  // Size of wicks are greater than sum of others.
  PATTERN_4CANDLE_WICKS_DEC = 1 << 28,      // Size of wicks increases.
  PATTERN_4CANDLE_WICKS_GT_BODY = 1 << 29,  // Sum of wicks are greater than sum of bodies.
  PATTERN_4CANDLE_WICKS_INC = 1 << 30,      // Size of wicks increases.
  PATTERN_4CANDLE_WICKS_UPPER = 1 << 31,    // Sum of upper wicks are greater than lower.
  FINAL_ENUM_PATTERN_4CANDLE = INT_MAX
};

/* Enumeration for 5-candle patterns. */
enum ENUM_PATTERN_5CANDLE {
  PATTERN_5CANDLE_NONE = 0 << 0,               // None
  PATTERN_5CANDLE_BODY0_DIFF_PEAK = 1 << 0,    // Diff of the last two bodies is at a peak.
  PATTERN_5CANDLE_BODY0_GT_SUM = 1 << 1,       // Body size is greater than sum of others.
  PATTERN_5CANDLE_CLOSE0_DIFF_PEAK = 1 << 2,   // Diff of the last two closes is at a peak.
  PATTERN_5CANDLE_CLOSE0_PEAK = 1 << 3,        // Latest close is at a peak.
  PATTERN_5CANDLE_CLOSE2_PEAK = 1 << 4,        // Middle close is at a peak.
  PATTERN_5CANDLE_HIGH0_DIFF_PEAK = 1 << 5,    // Diff of the last two highs is at a peak.
  PATTERN_5CANDLE_HIGH0_PEAK = 1 << 6,         // Latest high is at a peak.
  PATTERN_5CANDLE_HIGH2_PEAK = 1 << 7,         // Middle high is at a peak.
  PATTERN_5CANDLE_HORN_BOTTOMS = 1 << 8,       // Double bottom (1 & 3).
  PATTERN_5CANDLE_HORN_TOPS = 1 << 9,          // Double top (1 & 3).
  PATTERN_5CANDLE_LINE_STRIKE = 1 << 10,       // 4 bulls or bears, and line strike opposite.
  PATTERN_5CANDLE_LOW0_DIFF_PEAK = 1 << 11,    // Diff of the last two lows is at a peak.
  PATTERN_5CANDLE_LOW0_PEAK = 1 << 12,         // Latest low is at a peak.
  PATTERN_5CANDLE_LOW2_PEAK = 1 << 13,         // Middle low is at a peak.
  PATTERN_5CANDLE_MAT_HOLD = 1 << 14,          // Mat hold (bear/bull continuation pattern).
  PATTERN_5CANDLE_OPEN0_DIFF_PEAK = 1 << 15,   // Diff of the last two opens is at a peak.
  PATTERN_5CANDLE_OPEN0_PEAK = 1 << 16,        // Latest open is at a peak.
  PATTERN_5CANDLE_OPEN2_PEAK = 1 << 17,        // Middle open is at a peak.
  PATTERN_5CANDLE_OPEN4_PEAK = 1 << 18,        // Last open is at a peak.
  PATTERN_5CANDLE_PP0_DIFF_PEAK = 1 << 19,     // Diff of the last two pivots is at a peak.
  PATTERN_5CANDLE_PP0_PEAK = 1 << 20,          // Latest pivot is at a peak.
  PATTERN_5CANDLE_PP2_PEAK = 1 << 21,          // Middle pivot is at a peak.
  PATTERN_5CANDLE_PP_DEC = 1 << 22,            // Pivot point decreases.
  PATTERN_5CANDLE_PP_DEC_INC = 1 << 23,        // Pivot point decreases then increases.
  PATTERN_5CANDLE_PP_INC = 1 << 24,            // Pivot point increases.
  PATTERN_5CANDLE_PP_INC_DEC = 1 << 25,        // Pivot point increases then decreases.
  PATTERN_5CANDLE_RANGE0_DIFF_PEAK = 1 << 26,  // Diff of the last two ranges is at a peak.
  PATTERN_5CANDLE_RANGE0_GT_SUM = 1 << 27,     // Range size is greater than sum of others.
  PATTERN_5CANDLE_REVERSAL = 1 << 28,          // Reversal pattern.
  PATTERN_5CANDLE_WICKS0_DIFF_PEAK = 1 << 29,  // Diff of the last two ranges is at a peak.
  PATTERN_5CANDLE_WICKS0_PEAK = 1 << 30,       // Latest wick sizes are at a peak.
  PATTERN_5CANDLE_WICKS2_PEAK = 1 << 31,       // Middle wick sizes are at a peak.
  FINAL_ENUM_PATTERN_5CANDLE = INT_MAX
};

/* Enumeration for 6-candle patterns. */
enum ENUM_PATTERN_6CANDLE {
  PATTERN_6CANDLE_NONE = 0 << 0,             // None
  PATTERN_6CANDLE_ISLAND_REVERSAL = 1 << 0,  // Island reversal (top or bottom).
  PATTERN_6CANDLE_REVERSAL = 1 << 1,         // Three same candles, then 3 opposite.
  FINAL_ENUM_PATTERN_6CANDLE = INT_MAX
};

/* Enumeration for 7-candle patterns. */
enum ENUM_PATTERN_7CANDLE {
  PATTERN_7CANDLE_NONE = 0 << 0,  // None
  FINAL_ENUM_PATTERN_7CANDLE = INT_MAX
};

/* Enumeration for 8-candle patterns. */
enum ENUM_PATTERN_8CANDLE {
  PATTERN_8CANDLE_NONE = 0 << 0,  // None
  FINAL_ENUM_PATTERN_8CANDLE = INT_MAX
};

/* Enumeration for 9-candle patterns. */
enum ENUM_PATTERN_9CANDLE {
  PATTERN_9CANDLE_NONE = 0 << 0,  // None
  FINAL_ENUM_PATTERN_9CANDLE = INT_MAX
};

/* Enumeration for 10-candle patterns. */
enum ENUM_PATTERN_10CANDLE {
  PATTERN_10CANDLE_NONE = 0 << 0,  // None
  FINAL_ENUM_PATTERN_10CANDLE = INT_MAX
};
