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
 * Includes Account's enums.
 */

/* Account type of values for statistics. */
enum ENUM_ACC_STAT_VALUE {
  ACC_BALANCE = 0,
  ACC_CREDIT = 1,
  ACC_EQUITY = 2,
  ACC_PROFIT = 3,
  ACC_MARGIN_USED = 4,
  ACC_MARGIN_FREE = 5,
  FINAL_ENUM_ACC_STAT_VALUE = 6
};

/* Account type of periods for statistics. */
enum ENUM_ACC_STAT_PERIOD { ACC_DAILY = 0, ACC_WEEKLY = 1, ACC_MONTHLY = 2, FINAL_ENUM_ACC_STAT_PERIOD = 3 };

/* Account type of calculation for statistics. */
enum ENUM_ACC_STAT_TYPE { ACC_VALUE_MIN = 0, ACC_VALUE_MAX = 1, ACC_VALUE_AVG = 2, FINAL_ENUM_ACC_STAT_TYPE = 3 };

/* Account type of index for statistics. */
enum ENUM_ACC_STAT_INDEX { ACC_VALUE_CURR = 0, ACC_VALUE_PREV = 1, FINAL_ENUM_ACC_STAT_INDEX = 2 };

#ifndef __MQL__
/**
 * Enumeration for the current account integer values.
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/accountinformation
 */
enum ENUM_ACCOUNT_INFO_INTEGER {
  ACCOUNT_LOGIN,            // Account number (long).
  ACCOUNT_TRADE_MODE,       // Account trade mode (ENUM_ACCOUNT_TRADE_MODE).
  ACCOUNT_LEVERAGE,         // Account leverage (long).
  ACCOUNT_LIMIT_ORDERS,     // Maximum allowed number of active pending orders (int).
  ACCOUNT_MARGIN_SO_MODE,   // Mode for setting the minimal allowed margin (ENUM_ACCOUNT_STOPOUT_MODE).
  ACCOUNT_TRADE_ALLOWED,    // Allowed trade for the current account (bool).
  ACCOUNT_TRADE_EXPERT,     // Allowed trade for an Expert Advisor (bool).
  ACCOUNT_MARGIN_MODE,      // Margin calculation mode (ENUM_ACCOUNT_MARGIN_MODE).
  ACCOUNT_CURRENCY_DIGITS,  // The number of decimal places in the account currency (int).
  ACCOUNT_FIFO_CLOSE,       // An indication showing that positions can only be closed by FIFO rule (bool).
};
#endif
