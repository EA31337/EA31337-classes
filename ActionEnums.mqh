//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
 * Enums used by ActionEntry's struct.
 */

// Prevents processing this includes file for the second time.
#ifndef ACTION_ENUMS_MQH
#define ACTION_ENUMS_MQH

// EA actions.
enum ENUM_EA_ACTION {
  EA_ACTION_DISABLE = 0,  // Disables EA.
  EA_ACTION_ENABLE,       // Enables EA.
  EA_ACTION_TASKS_CLEAN,  // Clean tasks.
  FINAL_EA_ACTION_ENTRY
};

// EA conditions.
enum ENUM_EA_CONDITION {
  EA_COND_IS_ACTIVE = 1,   // When EA is active (can trade).
  EA_COND_IS_ENABLED = 2,  // When EA is enabled.
  FINAL_EA_CONDITION_ENTRY
};

// Order conditions.
enum ENUM_ORDER_CONDITION {
  ORDER_COND_NONE = 0,         // Empty condition.
  ORDER_COND_IN_LOSS,          // When order in loss
  ORDER_COND_IN_PROFIT,        // When order in profit
  ORDER_COND_IS_CLOSED,        // When order is closed
  ORDER_COND_IS_OPEN,          // When order is open
  ORDER_COND_LIFETIME_GT_ARG,  // Order lifetime greater than argument value.
  ORDER_COND_LIFETIME_LT_ARG,  // Order lifetime lesser than argument value.
  ORDER_COND_PROP_EQ_ARG,      // Order property equals argument value.
  ORDER_COND_PROP_GT_ARG,      // Order property greater than argument value.
  ORDER_COND_PROP_LT_ARG,      // Order property lesser than argument value.
  FINAL_ORDER_CONDITION_ENTRY
};

// Order actions.
enum ENUM_ORDER_ACTION {
  ORDER_ACTION_CLOSE = 1,  // Close the order.
  ORDER_ACTION_OPEN,       // Open the order.
  FINAL_ORDER_ACTION_ENTRY
};

// EA actions.
enum ENUM_STRATEGY_ACTION {
  STRAT_ACTION_DISABLE = 0,  // Disables Strategy.
  STRAT_ACTION_ENABLE,       // Enables Strategy.
  STRAT_ACTION_SUSPEND,      // Suspend Strategy.
  STRAT_ACTION_UNSUSPEND,    // Unsuspend Strategy.
  FINAL_STRATEGY_ACTION_ENTRY
};

// EA conditions.
enum ENUM_STRATEGY_CONDITION {
  STRAT_COND_IS_ENABLED = 1,  // When Strategy is enabled.
  STRAT_COND_IS_SUSPENDED,    // When Strategy is suspended.
  FINAL_STRATEGY_CONDITION_ENTRY
};

// Trade actions.
enum ENUM_TRADE_ACTION {
  TRADE_ACTION_ORDERS_CLOSE_ALL = 1,           // Close open sell orders
  TRADE_ACTION_ORDERS_CLOSE_IN_TREND = 2,      // Close open orders in trend
  TRADE_ACTION_ORDERS_CLOSE_IN_TREND_NOT = 3,  // Close open orders NOT in trend
  TRADE_ACTION_ORDERS_CLOSE_TYPE_BUY = 4,      // Close open buy orders
  TRADE_ACTION_ORDERS_CLOSE_TYPE_SELL = 5,     // Close open sell orders
  // TRADE_ACTION_ORDERS_REMOVE_ALL_PENDING,
  FINAL_ENUM_TRADE_ACTION_ENTRY = 6
};
// Trade conditions.
enum ENUM_TRADE_CONDITION {
  TRADE_COND_ALLOWED_NOT = 1,  // When trade is not allowed
  // TRADE_ORDER_CONDS_IN_TREND       = 2, // Open orders with trend
  // TRADE_ORDER_CONDS_IN_TREND_NOT   = 3, // Open orders against trend
  FINAL_ENUM_TRADE_CONDITION_ENTRY = 4
};

#endif
