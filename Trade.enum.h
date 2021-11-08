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
 * Includes Trade's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Trade actions.
enum ENUM_TRADE_ACTION {
  TRADE_ACTION_CALC_LOT_SIZE = 1,            // Recalculate lot size
  TRADE_ACTION_ORDER_CLOSE_LEAST_LOSS,       // Close order with least loss
  TRADE_ACTION_ORDER_CLOSE_LEAST_PROFIT,     // Close order with least profit
  TRADE_ACTION_ORDER_CLOSE_MOST_LOSS,        // Close order with most loss
  TRADE_ACTION_ORDER_CLOSE_MOST_PROFIT,      // Close order with most profit
  TRADE_ACTION_ORDER_OPEN,                   // Open order
  TRADE_ACTION_ORDERS_CLOSE_ALL,             // Close open sell orders
  TRADE_ACTION_ORDERS_CLOSE_BY_TYPE,         // Close open orders by type (args)
  TRADE_ACTION_ORDERS_CLOSE_IN_PROFIT,       // Close open orders in profit
  TRADE_ACTION_ORDERS_CLOSE_IN_TREND,        // Close open orders in trend
  TRADE_ACTION_ORDERS_CLOSE_IN_TREND_NOT,    // Close open orders NOT in trend
  TRADE_ACTION_ORDERS_CLOSE_SIDE_IN_LOSS,    // Close orders in loss side
  TRADE_ACTION_ORDERS_CLOSE_SIDE_IN_PROFIT,  // Close orders in profit side
  // TRADE_ACTION_ORDERS_REMOVE_ALL_PENDING,
  TRADE_ACTION_ORDERS_LIMIT_SET,  // Set orders per period limit
  TRADE_ACTION_STATE_ADD,         // Add trade specific state (1 arg)
  FINAL_ENUM_TRADE_ACTION_ENTRY
};

// Trade conditions.
enum ENUM_TRADE_CONDITION {
  TRADE_COND_ACCOUNT = 1,            // Account condition (1 arg)
  TRADE_COND_ALLOWED_NOT,            // When trade is not allowed
  TRADE_COND_HAS_STATE,              // Trade as specific state (1 arg)
  TRADE_COND_IS_ORDER_LIMIT,         // Trade has reached order limits
  TRADE_COND_IS_PEAK,                // Market is at peak level
  TRADE_COND_IS_PIVOT,               // Market is in pivot levels
  TRADE_COND_ORDERS_PROFIT_GT_01PC,  // Equity > 1%
  TRADE_COND_ORDERS_PROFIT_LT_01PC,  // Equity < 1%
  TRADE_COND_ORDERS_PROFIT_GT_02PC,  // Equity > 2%
  TRADE_COND_ORDERS_PROFIT_LT_02PC,  // Equity < 2%
  TRADE_COND_ORDERS_PROFIT_GT_05PC,  // Equity > 5%
  TRADE_COND_ORDERS_PROFIT_LT_05PC,  // Equity < 5%
  TRADE_COND_ORDERS_PROFIT_GT_10PC,  // Equity > 10%
  TRADE_COND_ORDERS_PROFIT_LT_10PC,  // Equity < 10%
  // TRADE_ORDER_CONDS_IN_TREND       = 2, // Open orders with trend
  // TRADE_ORDER_CONDS_IN_TREND_NOT   = 3, // Open orders against trend
  FINAL_ENUM_TRADE_CONDITION_ENTRY = 4
};

// Defines enumeration for trade parameters.
enum ENUM_TRADE_PARAM {
  TRADE_PARAM_BARS_MIN = 0,   // Bars minimum
  TRADE_PARAM_LOT_SIZE,       // Lot size
  TRADE_PARAM_MAGIC_NO,       // Magic number
  TRADE_PARAM_ORDER_COMMENT,  // Order comment
  TRADE_PARAM_RISK_MARGIN,    // Risk margin
  TRADE_PARAM_SLIPPAGE,       // Slippage
  FINAL_ENUM_TRADE_PARAM
};

// Defines enumeration for stat periods.
enum ENUM_TRADE_STAT_PERIOD {
  TRADE_STAT_ALL = 0,        // Stats for all periods
  TRADE_STAT_PER_HOUR = 1,   // Stats per hour
  TRADE_STAT_PER_DAY = 2,    // Stats per day
  TRADE_STAT_PER_WEEK = 3,   // Stats per week
  TRADE_STAT_PER_MONTH = 4,  // Stats per month
  TRADE_STAT_PER_YEAR = 5,   // Stats per year
  FINAL_ENUM_TRADE_STAT_PERIOD
};

// Defines enumeration for stat types.
enum ENUM_TRADE_STAT_TYPE {
  TRADE_STAT_ORDERS_CLOSED = 0,             // Orders closed
  TRADE_STAT_ORDERS_CLOSED_WINS = 1,        // Orders closed wins
  TRADE_STAT_ORDERS_ERRORS = 2,             // Orders with errors
  TRADE_STAT_ORDERS_OPENED = 3,             // Orders opened
  TRADE_STAT_ORDERS_PENDING_DELETED = 4,    // Pending orders deleted
  TRADE_STAT_ORDERS_PENDING_OPENED = 5,     // Pending orders opened
  TRADE_STAT_ORDERS_PENDING_TRIGGERED = 6,  // Pending orders triggered
  FINAL_ENUM_TRADE_STAT_TYPE
};

// Trade state.
enum ENUM_TRADE_STATE {
  TRADE_STATE_NONE = 0 << 0,                      // None
  TRADE_STATE_BARS_NOT_ENOUGH = 1 << 0,           // Not enough bars to trade
  TRADE_STATE_HEDGE_NOT_ALLOWED = 1 << 1,         // Hedging not allowed by broker
  TRADE_STATE_MARGIN_MAX_HARD = 1 << 2,           // Hard limit of trade margin reached
  TRADE_STATE_MARGIN_MAX_SOFT = 1 << 3,           // Soft limit of trade margin reached
  TRADE_STATE_MARKET_CLOSED = 1 << 4,             // Trade market closed
  TRADE_STATE_MONEY_NOT_ENOUGH = 1 << 5,          // Not enough money to trade
  TRADE_STATE_ORDERS_ACTIVE = 1 << 6,             // There are active orders
  TRADE_STATE_ORDERS_MAX_HARD = 1 << 7,           // Soft limit of maximum orders reached
  TRADE_STATE_ORDERS_MAX_SOFT = 1 << 8,           // Hard limit of maximum orders reached
  TRADE_STATE_PERIOD_LIMIT_REACHED = 1 << 9,      // Per period limit reached
  TRADE_STATE_SPREAD_TOO_HIGH = 1 << 10,          // Spread too high
  TRADE_STATE_TRADE_NOT_ALLOWED = 1 << 11,        // Trade not allowed
  TRADE_STATE_TRADE_NOT_POSSIBLE = 1 << 12,       // Trade not possible
  TRADE_STATE_TRADE_TERMINAL_BUSY = 1 << 13,      // Terminal context busy
  TRADE_STATE_TRADE_TERMINAL_OFFLINE = 1 << 14,   // Terminal offline
  TRADE_STATE_TRADE_TERMINAL_SHUTDOWN = 1 << 15,  // Terminal is shutting down
  // Pre-defined trade state enumerations.
  TRADE_STATE_TRADE_CANNOT = TRADE_STATE_MARGIN_MAX_HARD | TRADE_STATE_ORDERS_MAX_HARD | TRADE_STATE_MARKET_CLOSED |
                             TRADE_STATE_MONEY_NOT_ENOUGH | TRADE_STATE_TRADE_NOT_ALLOWED |
                             TRADE_STATE_TRADE_NOT_POSSIBLE | TRADE_STATE_TRADE_TERMINAL_BUSY |
                             TRADE_STATE_TRADE_TERMINAL_OFFLINE | TRADE_STATE_TRADE_TERMINAL_SHUTDOWN,
  TRADE_STATE_TRADE_SHOULDNT = TRADE_STATE_BARS_NOT_ENOUGH | TRADE_STATE_MARGIN_MAX_SOFT | TRADE_STATE_ORDERS_MAX_SOFT |
                               TRADE_STATE_PERIOD_LIMIT_REACHED | TRADE_STATE_SPREAD_TOO_HIGH,
  TRADE_STATE_TRADE_WONT = TRADE_STATE_TRADE_CANNOT | TRADE_STATE_TRADE_SHOULDNT,
  TRADE_STATE_TRADE_CAN = ~TRADE_STATE_TRADE_CANNOT,
  FINAL_ENUM_TRADE_STATE,
};
