//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Includes Condition's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef CONDITION_ENUM_H
#define CONDITION_ENUM_H

/* Defines class' enums */

#ifndef MARKET_EVENT_ENUM
#define MARKET_EVENT_ENUM
/* Define market event conditions. */
enum ENUM_MARKET_EVENT {
  C_EVENT_NONE = 0,            // None
  C_AC_BUY_SELL = 1,           // AC on buy/sell
  C_AD_BUY_SELL = 2,           // AD on buy/sell
  C_ADX_BUY_SELL = 3,          // ADX on buy/sell
  C_ALLIGATOR_BUY_SELL = 4,    // Alligator on buy/sell
  C_ATR_BUY_SELL = 5,          // ATR on buy/sell
  C_AWESOME_BUY_SELL = 6,      // Awesome on buy/sell
  C_BANDS_BUY_SELL = 7,        // Bands on buy/sell
  C_BEARSPOWER_BUY_SELL = 8,   // BearsPower on buy/sell
  C_BULLSPOWER_BUY_SELL = 40,  // BullsPower on buy/sell
  C_BWMFI_BUY_SELL = 10,       // BWMFI on buy/sell
  C_CCI_BUY_SELL = 11,         // CCI on buy/sell
  C_DEMARKER_BUY_SELL = 12,    // DeMarker on buy/sell
  C_ENVELOPES_BUY_SELL = 13,   // Envelopes on buy/sell
  C_FORCE_BUY_SELL = 14,       // Force on buy/sell
  C_FRACTALS_BUY_SELL = 15,    // Fractals on buy/sell
  C_GATOR_BUY_SELL = 16,       // Gator on buy/sell
  C_ICHIMOKU_BUY_SELL = 17,    // Ichimoku on buy/sell
  C_MA_BUY_SELL = 18,          // MA on buy/sell
  C_MACD_BUY_SELL = 19,        // MACD on buy/sell
  C_MFI_BUY_SELL = 20,         // MFI on buy/sell
  C_MOMENTUM_BUY_SELL = 21,    // Momentum on buy/sell
  C_OBV_BUY_SELL = 22,         // OBV on buy/sell
  C_OSMA_BUY_SELL = 23,        // OSMA on buy/sell
  C_RSI_BUY_SELL = 24,         // RSI on buy/sell
  C_RVI_BUY_SELL = 25,         // RVI on buy/sell
  C_SAR_BUY_SELL = 26,         // SAR on buy/sell
  C_STDDEV_BUY_SELL = 27,      // StdDev on buy/sell
  C_STOCHASTIC_BUY_SELL = 28,  // Stochastic on buy/sell
  C_WPR_BUY_SELL = 29,         // WPR on buy/sell
  C_ZIGZAG_BUY_SELL = 30,      // ZigZag on buy/sell
  C_MA_FAST_SLOW_OPP = 31,     // MA Fast&Slow opposite
  C_MA_FAST_MED_OPP = 32,      // MA Fast&Med opposite
  C_MA_MED_SLOW_OPP = 33,      // MA Med&Slow opposite
#ifdef __advanced__
  C_CUSTOM1_BUY_SELL = 34,     // Custom 1 on buy/sell
  C_CUSTOM2_BUY_SELL = 35,     // Custom 2 on buy/sell
  C_CUSTOM3_BUY_SELL = 36,     // Custom 3 on buy/sell
  C_CUSTOM4_MARKET_COND = 37,  // Custom 4 market condition
  C_CUSTOM5_MARKET_COND = 38,  // Custom 5 market condition
  C_CUSTOM6_MARKET_COND = 39,  // Custom 6 market condition
#endif
};
#endif

/* Defines condition entry flags. */
enum ENUM_CONDITION_ENTRY_FLAGS {
  COND_ENTRY_FLAG_NONE = 0,
  COND_ENTRY_FLAG_IS_ACTIVE = 1,
  COND_ENTRY_FLAG_IS_EXPIRED = 2,
  COND_ENTRY_FLAG_IS_INVALID = 4,
  COND_ENTRY_FLAG_IS_READY = 8
};

/* Defines condition statements (operators). */
enum ENUM_CONDITION_STATEMENT {
  COND_AND = 1,  // Use AND statement.
  COND_OR,       // Use OR statement.
  COND_SEQ,      // Use sequential checks.
  FINAL_ENUM_COND_STATEMENT
};

/* Defines condition types. */
enum ENUM_CONDITION_TYPE {
  COND_TYPE_ACCOUNT = 1,  // Account condition.
  COND_TYPE_ACTION,       // Action condition.
  COND_TYPE_CHART,        // Chart condition.
  COND_TYPE_DATETIME,     // Datetime condition.
  COND_TYPE_EA,           // EA condition.
  COND_TYPE_INDICATOR,    // Indicator condition.
  COND_TYPE_MARKET,       // Market condition.
  COND_TYPE_MATH,         // Math condition.
  COND_TYPE_ORDER,        // Order condition.
  COND_TYPE_STRATEGY,     // Strategy condition.
  COND_TYPE_TASK,         // Task condition.
  COND_TYPE_TERMINAL,     // Terminal condition.
  COND_TYPE_TRADE,        // Trade condition.
  FINAL_CONDITION_TYPE_ENTRY
};

/* Defines class' condition enums */

/* Account conditions. */
enum ENUM_ACCOUNT_CONDITION {
  ACCOUNT_COND_NONE = 0,  // Empty condition.
  /* @todo
  ACCOUNT_COND_BALM_GT_YEARLY, // Current month's balance highest of the year
  ACCOUNT_COND_BALM_LT_YEARLY, // Current month's balance lowest of the year
  ACCOUNT_COND_BALT_GT_WEEKLY, // Today's balance highest of the week
  ACCOUNT_COND_BALT_IN_LOSS, // Today's balance in loss
  ACCOUNT_COND_BALT_IN_PROFIT, // Today's balance in profit
  ACCOUNT_COND_BALT_LT_WEEKLY, // Today's balance lowest of the week
  ACCOUNT_COND_BALW_GT_MONTHLY, // Current week's balance highest of the month
  ACCOUNT_COND_BALW_LT_MONTHLY, // Current week's balance lowest of the month
  ACCOUNT_COND_BALY_IN_LOSS, // Previous day in loss
  ACCOUNT_COND_BALY_IN_PROFIT, // Previous day in profit
  */
  ACCOUNT_COND_BAL_IN_LOSS,       // Total balance in loss
  ACCOUNT_COND_BAL_IN_PROFIT,     // Total balance in profit
  ACCOUNT_COND_EQUITY_01PC_HIGH,  // Equity 1% high
  ACCOUNT_COND_EQUITY_01PC_LOW,   // Equity 1% low
  ACCOUNT_COND_EQUITY_02PC_HIGH,  // Equity 2% high
  ACCOUNT_COND_EQUITY_02PC_LOW,   // Equity 2% low
  ACCOUNT_COND_EQUITY_05PC_HIGH,  // Equity 5% high
  ACCOUNT_COND_EQUITY_05PC_LOW,   // Equity 5% low
  ACCOUNT_COND_EQUITY_10PC_HIGH,  // Equity 10% high
  ACCOUNT_COND_EQUITY_10PC_LOW,   // Equity 10% low
  ACCOUNT_COND_EQUITY_20PC_HIGH,  // Equity 20% high
  ACCOUNT_COND_EQUITY_20PC_LOW,   // Equity 20% low
  ACCOUNT_COND_EQUITY_IN_LOSS,    // Equity in loss
  ACCOUNT_COND_EQUITY_IN_PROFIT,  // Equity in profit
  /* @todo
  ACCOUNT_COND_MARGIN_CALL_10PC, // Margin call (10% margin left)
  ACCOUNT_COND_MARGIN_CALL_20PC, // Margin call (20% margin left)
  */
  ACCOUNT_COND_MARGIN_FREE_IN_PC,  // Margin used in % (args)
  ACCOUNT_COND_MARGIN_USED_10PC,   // Margin used in 10%
  ACCOUNT_COND_MARGIN_USED_20PC,   // Margin used in 20%
  ACCOUNT_COND_MARGIN_USED_50PC,   // Margin used in 50%
  ACCOUNT_COND_MARGIN_USED_80PC,   // Margin used in 80%
  ACCOUNT_COND_MARGIN_USED_99PC,   // Margin used in 99%
  ACCOUNT_COND_MARGIN_USED_IN_PC,  // Margin used in % (args)
  FINAL_ACCOUNT_CONDITION_ENTRY
};

/* Action conditions. */
enum ENUM_ACTION_CONDITION {
  ACTION_COND_NONE = 0,     // Empty condition.
  ACTION_COND_IS_ACTIVE,    // Is active.
  ACTION_COND_IS_DONE,      // Is done.
  ACTION_COND_IS_FAILED,    // Is failed.
  ACTION_COND_IS_FINISHED,  // Is finished.
  ACTION_COND_IS_INVALID,   // Is invalid.
  FINAL_ACTION_CONDITION_ENTRY
};

/* Chart conditions. */
enum ENUM_CHART_CONDITION {
  CHART_COND_ASK_BAR_PEAK = 1,          // Ask price on current bar's peak
  CHART_COND_ASK_GT_BAR_HIGH = 2,       // Ask price > bar's high price
  CHART_COND_ASK_GT_BAR_LOW = 3,        // Ask price > bar's low price
  CHART_COND_ASK_LT_BAR_HIGH = 4,       // Ask price < bar's high price
  CHART_COND_ASK_LT_BAR_LOW = 5,        // Ask price < bar's low price
  CHART_COND_BAR_CLOSE_GT_PP_PP = 6,    // Current bar's close price > Pivot point (main line)
  CHART_COND_BAR_CLOSE_GT_PP_R1 = 7,    // Current bar's close price > Pivot point (R1)
  CHART_COND_BAR_CLOSE_GT_PP_R2 = 8,    // Current bar's close price > Pivot point (R2)
  CHART_COND_BAR_CLOSE_GT_PP_R3 = 9,    // Current bar's close price > Pivot point (R3)
  CHART_COND_BAR_CLOSE_GT_PP_R4 = 10,   // Current bar's close price > Pivot point (R4)
  CHART_COND_BAR_CLOSE_GT_PP_S1 = 11,   // Current bar's close price > Pivot point (S1)
  CHART_COND_BAR_CLOSE_GT_PP_S2 = 12,   // Current bar's close price > Pivot point (S2)
  CHART_COND_BAR_CLOSE_GT_PP_S3 = 13,   // Current bar's close price > Pivot point (S3)
  CHART_COND_BAR_CLOSE_GT_PP_S4 = 14,   // Current bar's close price > Pivot point (S4)
  CHART_COND_BAR_CLOSE_LT_PP_PP = 15,   // Current bar's close price < Pivot point (main line)
  CHART_COND_BAR_CLOSE_LT_PP_R1 = 16,   // Current bar's close price < Pivot point (R1)
  CHART_COND_BAR_CLOSE_LT_PP_R2 = 17,   // Current bar's close price < Pivot point (R2)
  CHART_COND_BAR_CLOSE_LT_PP_R3 = 18,   // Current bar's close price < Pivot point (R3)
  CHART_COND_BAR_CLOSE_LT_PP_R4 = 19,   // Current bar's close price < Pivot point (R4)
  CHART_COND_BAR_CLOSE_LT_PP_S1 = 20,   // Current bar's close price < Pivot point (S1)
  CHART_COND_BAR_CLOSE_LT_PP_S2 = 21,   // Current bar's close price < Pivot point (S2)
  CHART_COND_BAR_CLOSE_LT_PP_S3 = 22,   // Current bar's close price < Pivot point (S3)
  CHART_COND_BAR_CLOSE_LT_PP_S4 = 23,   // Current bar's close price < Pivot point (S4)
  CHART_COND_BAR_HIGHEST_CURR_20 = 24,  // Is current bar has highest price out of 20 bars
  CHART_COND_BAR_HIGHEST_CURR_50 = 25,  // Is current bar has highest price out of 50 bars
  CHART_COND_BAR_HIGHEST_PREV_20 = 26,  // Is previous bar has highest price out of 20 bars
  CHART_COND_BAR_HIGHEST_PREV_50 = 27,  // Is previous bar has highest price out of 50 bars
  CHART_COND_BAR_HIGH_GT_OPEN = 28,     // Current bar's high price > current open
  CHART_COND_BAR_HIGH_LT_OPEN = 29,     // Current bar's high price < current open
  CHART_COND_BAR_INDEX_EQ_ARG,          // Current bar's index equals argument value
  CHART_COND_BAR_INDEX_GT_ARG,          // Current bar's index greater than argument value
  CHART_COND_BAR_INDEX_LT_ARG,          // Current bar's index lower than argument value
  CHART_COND_BAR_LOWEST_CURR_20,        // Is current bar has lowest price out of 20 bars
  CHART_COND_BAR_LOWEST_CURR_50,        // Is current bar has lowest price out of 50 bars
  CHART_COND_BAR_LOWEST_PREV_20,        // Is previous bar has lowest price out of 20 bars
  CHART_COND_BAR_LOWEST_PREV_50,        // Is previous bar has lowest price out of 50 bars
  CHART_COND_BAR_LOW_GT_OPEN,           // Current bar's low price > current open
  CHART_COND_BAR_LOW_LT_OPEN,           // Current bar's low price < current open
  CHART_COND_BAR_NEW,                   // On new bar
  /* @fixme
  CHART_COND_BAR_NEW_DAY           = 37, // On new daily bar
  CHART_COND_BAR_NEW_HOUR          = 38, // On new hourly bar
  CHART_COND_BAR_NEW_MONTH         = 49, // On new monthly bar
  CHART_COND_BAR_NEW_WEEK          = 50, // On new weekly bar
  CHART_COND_BAR_NEW_YEAR          = 51, // On new yearly bar
  */
  FINAL_ENUM_CHART_CONDITION_ENTRY
};

/* EA conditions. */
enum ENUM_EA_CONDITION {
  EA_COND_IS_ACTIVE = 1,     // When EA is active (can trade).
  EA_COND_IS_ENABLED,        // When EA is enabled.
  EA_COND_IS_NOT_CONNECTED,  // When terminal is not connected.
  EA_COND_ON_INIT,           // On EA init.
  EA_COND_ON_NEW_MINUTE,     // On new minute.
  EA_COND_ON_NEW_HOUR,       // On new hour.
  EA_COND_ON_NEW_DAY,        // On new day.
  EA_COND_ON_NEW_WEEK,       // On new week.
  EA_COND_ON_NEW_MONTH,      // On new month.
  EA_COND_ON_NEW_YEAR,       // On new year.
  EA_COND_ON_QUIT,           // On EA quit.
  FINAL_EA_CONDITION_ENTRY
};

/* Indicator conditions. */
enum ENUM_INDICATOR_CONDITION {
  INDI_COND_ENTRY_IS_MAX = 1,  // Indicator entry value is maximum.
  INDI_COND_ENTRY_IS_MIN = 2,  // Indicator entry value is minimum.
  INDI_COND_ENTRY_GT_AVG = 3,  // Indicator entry value is greater than average.
  INDI_COND_ENTRY_GT_MED = 4,  // Indicator entry value is greater than median.
  INDI_COND_ENTRY_LT_AVG = 5,  // Indicator entry value is lesser than average.
  INDI_COND_ENTRY_LT_MED = 6,  // Indicator entry value is lesser than median.
  FINAL_INDICATOR_CONDITION_ENTRY = 7
};

/* Market conditions. */
enum ENUM_MARKET_CONDITION {
  MARKET_COND_IN_PEAK_HOURS = 1,  // Market in peak hours (8-16)
  MARKET_COND_SPREAD_LE_10 = 2,   // Spread <= 10pts
  MARKET_COND_SPREAD_GT_10 = 3,   // Spread > 10pts
  MARKET_COND_SPREAD_GT_20 = 4,   // Spread > 20pts
  FINAL_ENUM_MARKET_CONDITION_ENTRY = 5
};

#endif
