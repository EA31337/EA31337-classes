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
 * Includes Chart's enums.
 */

// Define type of periods.
// @see: https://docs.mql4.com/constants/chartconstants/enum_timeframes
enum ENUM_TIMEFRAMES_INDEX {
  M1 = 0,    // 1 minute
  M2 = 1,    // 2 minutes (non-standard)
  M3 = 2,    // 3 minutes (non-standard)
  M4 = 3,    // 4 minutes (non-standard)
  M5 = 4,    // 5 minutes
  M6 = 5,    // 6 minutes (non-standard)
  M10 = 6,   // 10 minutes (non-standard)
  M12 = 7,   // 12 minutes (non-standard)
  M15 = 8,   // 15 minutes
  M20 = 9,   // 20 minutes (non-standard)
  M30 = 10,  // 30 minutes
  H1 = 11,   // 1 hour
  H2 = 12,   // 2 hours (non-standard)
  H3 = 13,   // 3 hours (non-standard)
  H4 = 14,   // 4 hours
  H6 = 15,   // 6 hours (non-standard)
  H8 = 16,   // 8 hours (non-standard)
  H12 = 17,  // 12 hours (non-standard)
  D1 = 18,   // Daily
  W1 = 19,   // Weekly
  MN1 = 20,  // Monthly
  // This item should be the last one.
  // Used to calculate the number of enum items.
  FINAL_ENUM_TIMEFRAMES_INDEX = 21
};

// Define type of periods using bitwise operators.
enum ENUM_TIMEFRAMES_BITS {
  M1B = 1 << 0,   //   =1: 1 minute
  M5B = 1 << 1,   //   =2: 5 minutes
  M15B = 1 << 2,  //   =4: 15 minutes
  M30B = 1 << 3,  //   =8: 30 minutes
  H1B = 1 << 4,   //  =16: 1 hour
  H4B = 1 << 5,   //  =32: 4 hours
  H8B = 1 << 6,   //  =64: 8 hours
  D1B = 1 << 7,   // =128: Daily
  W1B = 1 << 8,   // =256: Weekly
  MN1B = 1 << 9,  // =512: Monthly
};

#ifndef __MQLBUILD__
// Defines chart timeframes
// @docs
// - https://docs.mql4.com/constants/chartconstants/enum_timeframes
// - https://www.mql5.com/en/docs/constants/chartconstants/enum_timeframes
enum ENUM_TIMEFRAMES {
  PERIOD_CURRENT = 0,  // Current timeframe.
  PERIOD_M1 = 1,       // 1 minute.
  PERIOD_M2 = 2,       // 2 minutes.
  PERIOD_M3 = 3,       // 3 minutes.
  PERIOD_M4 = 4,       // 4 minutes.
  PERIOD_M5 = 5,       // 5 minutes.
  PERIOD_M6 = 6,       // 6 minutes.
  PERIOD_M10 = 10,     // 10 minutes.
  PERIOD_M12 = 12,     // 12 minutes.
  PERIOD_M15 = 15,     // 15 minutes.
  PERIOD_M20 = 20,     // 20 minutes.
  PERIOD_M30 = 30,     // 30 minutes.
  PERIOD_H1 = 60,      // 1 hour.
  PERIOD_H2 = 120,     // 2 hours.
  PERIOD_H3 = 180,     // 3 hours.
  PERIOD_H4 = 240,     // 4 hours.
  PERIOD_H6 = 360,     // 6 hours.
  PERIOD_H8 = 480,     // 8 hours.
  PERIOD_H12 = 720,    // 12 hours.
  PERIOD_D1 = 1440,    // 1 day.
  PERIOD_W1 = 10080,   // 1 week.
  PERIOD_MN1 = 43200   // 1 month.
}
#endif

// Pivot Point calculation method.
enum ENUM_PP_TYPE {
  PP_CAMARILLA = 1,   // A set of eight levels which resemble support and resistance values.
  PP_CLASSIC = 2,     // Classic pivot point
  PP_FIBONACCI = 3,   // Fibonacci pivot point
  PP_FLOOR = 4,       // Most basic and popular type of pivots used in Forex trading technical analysis.
  PP_TOM_DEMARK = 5,  // Tom DeMark's pivot point (predicted lows and highs of the period).
  PP_WOODIE = 6,      // Woodie's pivot point are giving more weight to the Close price of the previous period.
  FINAL_ENUM_PP_TYPE_ENTRY
};
