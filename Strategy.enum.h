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
 * Includes Strategy's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/* Enumeration for strategy bitwise open methods. */
enum ENUM_OPEN_METHOD {
  OPEN_METHOD1 = 1,      // Method #1.
  OPEN_METHOD2 = 2,      // Method #2.
  OPEN_METHOD3 = 4,      // Method #3.
  OPEN_METHOD4 = 8,      // Method #4.
  OPEN_METHOD5 = 16,     // Method #5.
  OPEN_METHOD6 = 32,     // Method #6.
  OPEN_METHOD7 = 64,     // Method #7.
  OPEN_METHOD8 = 128,    // Method #8.
  OPEN_METHOD9 = 256,    // Method #9.
  OPEN_METHOD10 = 512,   // Method #10.
  OPEN_METHOD11 = 1024,  // Method #11.
  OPEN_METHOD12 = 2048   // Method #12.
};

/* Enumeration for strategy actions. */
enum ENUM_STRATEGY_ACTION {
  STRAT_ACTION_DISABLE = 0,  // Disables strategy.
  STRAT_ACTION_ENABLE,       // Enables strategy.
  STRAT_ACTION_SUSPEND,      // Suspend Strategy.
  STRAT_ACTION_TRADE_EXE,    // Execute trade action.
  STRAT_ACTION_UNSUSPEND,    // Unsuspend Strategy.
  FINAL_STRATEGY_ACTION_ENTRY
};

/* Enumeration for strategy conditions. */
enum ENUM_STRATEGY_CONDITION {
  STRAT_COND_IS_ENABLED = 1,  // Strategy is enabled.
  STRAT_COND_IS_SUSPENDED,    // Strategy is suspended.
  STRAT_COND_IS_TREND,        // Strategy is in trend.
  STRAT_COND_SIGNALOPEN,      // On strategy's signal to open.
  STRAT_COND_TRADE_COND,      // On strategy's trade condition (args).
  FINAL_STRATEGY_CONDITION_ENTRY
};

// Defines enumeration for strategy parameters.
enum ENUM_STRATEGY_PARAM {
  STRAT_PARAM_LS,          // Lot size
  STRAT_PARAM_LSF,         // Lot size factor
  STRAT_PARAM_MAX_RISK,    // Max risk
  STRAT_PARAM_MAX_SPREAD,  // Max spread
  STRAT_PARAM_OCT,         // Order close time
  STRAT_PARAM_PPL,         // Signal profit level
  STRAT_PARAM_PPM,         // Signal profit method
  STRAT_PARAM_PSL,         // Price stop level
  STRAT_PARAM_PSM,         // Price stop method
  STRAT_PARAM_SCL,         // Signal close level
  STRAT_PARAM_SCM,         // Signal close method
  STRAT_PARAM_SHIFT,       // Shift
  STRAT_PARAM_SOB,         // Signal open boost method
  STRAT_PARAM_SOF,         // Signal open filter
  STRAT_PARAM_SOL,         // Signal open level
  STRAT_PARAM_SOM,         // Signal open method
  STRAT_PARAM_TFM,         // Tick filter method
  STRAT_PARAM_WEIGHT,      // Weight
  FINAL_ENUM_STRATEGY_PARAM
};

/* Enumeration for strategy signal types. */
enum ENUM_STRATEGY_SIGNAL_TYPE {
  STRAT_SIGNAL_SELL = -1,    // Signal to sell.
  STRAT_SIGNAL_NEUTRAL = 0,  // Neutral signal.
  STRAT_SIGNAL_BUY = 1,      // Signal to buy.
};

/* Enumeration for strategy bitwise signal flags. */
enum ENUM_STRATEGY_SIGNAL_FLAG {
  STRAT_SIGNAL_NONE = 0 << 0,
  STRAT_SIGNAL_BUY_CLOSE = 1 << 0,   // Close signal for buy
  STRAT_SIGNAL_BUY_OPEN = 1 << 1,    // Open signal for buy
  STRAT_SIGNAL_BUY_PASS = 1 << 2,    // Open signal for buy passed by filter
  STRAT_SIGNAL_SELL_CLOSE = 1 << 3,  // Close signal for sell
  STRAT_SIGNAL_SELL_OPEN = 1 << 4,   // Open signal for sell
  STRAT_SIGNAL_SELL_PASS = 1 << 5,   // Open signal for sell passed by filter
  FINAL_ENUM_STRATEGY_SIGNAL_FLAG
};

/* Enumeration for strategy periodical statistics. */
enum ENUM_STRATEGY_STATS_PERIOD {
  EA_STATS_DAILY,
  EA_STATS_WEEKLY,
  EA_STATS_MONTHLY,
  EA_STATS_TOTAL,
  FINAL_ENUM_STRATEGY_STATS_PERIOD
};
