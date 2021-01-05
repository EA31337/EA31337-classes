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
 * Includes Strategy's enums.
 */

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

// Strategy actions.
enum ENUM_STRATEGY_ACTION {
  STRAT_ACTION_DISABLE = 0,  // Disables Strategy.
  STRAT_ACTION_ENABLE,       // Enables Strategy.
  STRAT_ACTION_SUSPEND,      // Suspend Strategy.
  STRAT_ACTION_UNSUSPEND,    // Unsuspend Strategy.
  FINAL_STRATEGY_ACTION_ENTRY
};

// Strategy conditions.
enum ENUM_STRATEGY_CONDITION {
  STRAT_COND_IS_ENABLED = 1,  // Strategy is enabled.
  STRAT_COND_IS_SUSPENDED,    // Strategy is suspended.
  STRAT_COND_IS_TREND,        // Strategy is in trend.
  STRAT_COND_SIGNALOPEN,      // On strategy's signal to open.
  FINAL_STRATEGY_CONDITION_ENTRY
};

// Defines EA input data types.
enum ENUM_STRATEGY_SIGNAL_FLAGS {
  STRAT_SIGNAL_NONE = 0 << 0,
  STRAT_SIGNAL_BUY_CLOSE = 1 << 0,    // Close signal for buy
  STRAT_SIGNAL_BUY_CLOSED = 1 << 1,   // Buy position closed
  STRAT_SIGNAL_BUY_OPEN = 1 << 2,     // Open signal for buy
  STRAT_SIGNAL_BUY_OPENED = 1 << 3,   // Buy position opened
  STRAT_SIGNAL_BUY_PASS = 1 << 4,     // Open signal for buy passed by filter
  STRAT_SIGNAL_SELL_CLOSE = 1 << 5,   // Sell signal for sell
  STRAT_SIGNAL_SELL_CLOSED = 1 << 6,  // Sell position closed
  STRAT_SIGNAL_SELL_OPEN = 1 << 7,    // Open signal for sell
  STRAT_SIGNAL_SELL_OPENED = 1 << 8,  // Sell position opened
  STRAT_SIGNAL_SELL_PASS = 1 << 9,    // Open signal for sell passed by filter
  FINAL_ENUM_STRATEGY_SIGNAL_FLAGS
};

enum ENUM_STRATEGY_STATS_PERIOD {
  EA_STATS_DAILY,
  EA_STATS_WEEKLY,
  EA_STATS_MONTHLY,
  EA_STATS_TOTAL,
  FINAL_ENUM_STRATEGY_STATS_PERIOD
};
