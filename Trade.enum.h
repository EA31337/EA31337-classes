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
 * Includes Trade's enums.
 */

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
  TRADE_COND_IS_PEAK,          // When market is at peak level
  TRADE_COND_IS_PIVOT,         // When market is in pivot levels
  // TRADE_ORDER_CONDS_IN_TREND       = 2, // Open orders with trend
  // TRADE_ORDER_CONDS_IN_TREND_NOT   = 3, // Open orders against trend
  FINAL_ENUM_TRADE_CONDITION_ENTRY = 4
};
