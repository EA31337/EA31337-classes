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
 * Includes Chart's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

#ifndef __MQL__
// Defines enumeration for price price base calculations.
// Define: In MQL4 enum values starts from 0, where in MQL5 from 1.
// https://www.mql5.com/en/docs/constants/indicatorconstants/prices
// https://docs.mql4.com/constants/indicatorconstants/prices
enum ENUM_APPLIED_PRICE {
  PRICE_CLOSE = 0,  // Close price
  PRICE_OPEN,       // Open price
  PRICE_HIGH,       // The maximum price for the period
  PRICE_LOW,        // The minimum price for the period
  PRICE_MEDIAN,     // Median price (H+L)/2
  PRICE_TYPICAL,    // Typical price, (H+L+C)/3
  PRICE_WEIGHTED,   // Weighted close price (H+L+C+C)/4
};
#endif

// Defines enumeration for chart parameters.
enum ENUM_CHART_PARAM {
  CHART_PARAM_NONE = 0,  // None
  CHART_PARAM_ID,        // Chart ID
  CHART_PARAM_SYMBOL,    // Symbol
  CHART_PARAM_TF,        // Timeframe
  CHART_PARAM_TFI,       // Timeframe index
  FINAL_ENUM_CHART_PARAM
};

/**
 * Define type of periods.
 *
 * @see: https://docs.mql4.com/constants/chartconstants/enum_timeframes
 */
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

#ifndef __MQLBUILD__
/**
 * Defines chart timeframes.
 *
 * @see:
 * - https://docs.mql4.com/constants/chartconstants/enum_timeframes
 * - https://www.mql5.com/en/docs/constants/chartconstants/enum_timeframes
 */
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
};

#endif

// Define type of periods.
// @see: https://docs.mql4.com/constants/chartconstants/enum_timeframes
#define TFS 21
const ENUM_TIMEFRAMES TIMEFRAMES_LIST[TFS] = {PERIOD_M1,  PERIOD_M2,  PERIOD_M3,  PERIOD_M4,  PERIOD_M5,  PERIOD_M6,
                                              PERIOD_M10, PERIOD_M12, PERIOD_M15, PERIOD_M20, PERIOD_M30, PERIOD_H1,
                                              PERIOD_H2,  PERIOD_H3,  PERIOD_H4,  PERIOD_H6,  PERIOD_H8,  PERIOD_H12,
                                              PERIOD_D1,  PERIOD_W1,  PERIOD_MN1};
