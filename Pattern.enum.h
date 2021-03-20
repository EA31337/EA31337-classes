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
  PATTERN_2CANDLE_NONE = 0 << 0,                   // None
  PATTERN_2CANDLE_BODY_GT_BODY = 1 << 0,           // Body size greater than the previous one.
  PATTERN_2CANDLE_CLOSE_GT_CLOSE = 1 << 1,         // Close greater than the previous one.
  PATTERN_2CANDLE_CLOSE_GT_HIGH = 1 << 2,          // Close greater than previous high.
  PATTERN_2CANDLE_CLOSE_LT_LOW = 1 << 3,           // Close lower than previous low.
  PATTERN_2CANDLE_HIGH_GT_HIGH = 1 << 4,           // High greater than the previous one.
  PATTERN_2CANDLE_LOW_GT_LOW = 1 << 5,             // Low greater than the previous one.
  PATTERN_2CANDLE_OPEN_GT_OPEN = 1 << 6,           // Open greater than the previous one.
  PATTERN_2CANDLE_PP_GT_PP = 1 << 7,               // Pivot price greater than the previous one (HLC/3).
  PATTERN_2CANDLE_PP_GT_PP_OPEN = 1 << 8,          // Pivot price open is greater than the previous one (OHLC/4).
  PATTERN_2CANDLE_RANGE_DBL_RANGE = 1 << 9,        // Range size doubled from the previous one.
  PATTERN_2CANDLE_RANGE_GT_RANGE = 1 << 10,        // Range greater than the previous one.
  PATTERN_2CANDLE_WEIGHTED_GT_WEIGHTED = 1 << 11,  // Weighted price is greater than the previous one (OH2C/4).
  PATTERN_2CANDLE_WICKS_DBL_WICKS = 1 << 12,       // Wicks size double from the previous onces.
  PATTERN_2CANDLE_WICKS_GT_WICKS = 1 << 13,        // Wicks size greater than the previous onces.
  FINAL_ENUM_PATTERN_2CANDLE = INT_MAX
};

/* Enumeration for 3-candle patterns. */
enum ENUM_PATTERN_3CANDLE {
  PATTERN_3CANDLE_NONE = 0 << 0,  // None
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
