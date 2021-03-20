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
  PATTERN_2CANDLE_RANGE_IN_BODY = 1 << 19,         // Range is inside body of the previous candle.
  PATTERN_2CANDLE_RANGE_OUT_RANGE = 1 << 20,       // Range is outside of range of the previous candle.
  PATTERN_2CANDLE_WEIGHTED_GT_WEIGHTED = 1 << 21,  // Weighted price is greater than the previous one (OH2C/4).
  PATTERN_2CANDLE_WICKS_DBL_WICKS = 1 << 22,       // Size of wicks doubled from the previous onces.
  PATTERN_2CANDLE_WICKS_GT_WICKS = 1 << 23,        // Size of wicks is greater than the previous onces.
  // Patterns based on the existing patterns.
  PATTERN_2CANDLE_BODY_IN_BODY = ~PATTERN_2CANDLE_HOC_GT_HOC | ~PATTERN_2CANDLE_LOC_LT_LOC,
  PATTERN_2CANDLE_BODY_OUT_BODY = PATTERN_2CANDLE_HOC_GT_HOC | PATTERN_2CANDLE_LOC_LT_LOC,
  PATTERN_2CANDLE_RANGE_IN_RANGE = ~PATTERN_2CANDLE_HIGH_GT_HIGH | ~PATTERN_2CANDLE_LOW_LT_LOW,
  PATTERN_2CANDLE_RANGE_OUT_RANGE = PATTERN_2CANDLE_HIGH_GT_HIGH | PATTERN_2CANDLE_LOW_LT_LOW,
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
  PATTERN_2CANDLE_BODY_IN_RANGE = ~PATTERN_2CANDLE_HOC_GT_HIGH | ~PATTERN_2CANDLE_LOC_LT_LOW,
  // Body is outside of the previous candle's range (partial Bullish engulfing).
  PATTERN_2CANDLE_BODY_OUT_RANGE = PATTERN_2CANDLE_HOC_GT_HIGH | PATTERN_2CANDLE_LOC_LT_LOW,
  // Range is inside of the previous candle's body (partial Harami pattern).
  PATTERN_2CANDLE_RANGE_IN_BODY = ~PATTERN_2CANDLE_HIGH_GT_HOC | ~PATTERN_2CANDLE_LOW_LT_LOC,
  // Range is outside of the previous candle's body (partial Harami pattern).
  PATTERN_2CANDLE_RANGE_OUT_BODY = ~PATTERN_2CANDLE_HIGH_GT_HOC | ~PATTERN_2CANDLE_LOW_LT_LOC,
  // Harami pattern.
  // Neutral pattern where price is being pushed into a tighter range.
  PATTERN_2CANDLE_HARAMI = PATTERN_2CANDLE_BODY_IN_BODY | PATTERN_2CANDLE_RANGE_IN_BODY | ~PATTERN_2CANDLE_HOC_GT_HOC |
                           ~PATTERN_2CANDLE_LOC_LT_LOC,
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
  PATTERN_4CANDLE_NONE = 0 << 0,  // None
  FINAL_ENUM_PATTERN_4CANDLE = INT_MAX
};

/* Enumeration for 5-candle patterns. */
enum ENUM_PATTERN_5CANDLE {
  PATTERN_5CANDLE_NONE = 0 << 0,  // None
  FINAL_ENUM_PATTERN_5CANDLE = INT_MAX
};

/* Enumeration for 6-candle patterns. */
enum ENUM_PATTERN_6CANDLE {
  PATTERN_6CANDLE_NONE = 0 << 0,  // None
  FINAL_ENUM_PATTERN_6CANDLE = INT_MAX
};

/* Enumeration for 7-candle patterns. */
enum ENUM_PATTERN_7CANDLE {
  PATTERN_7CANDLE_NONE = 0 << 0,  // None
  FINAL_ENUM_PATTERN_7CANDLE = INT_MAX
};
