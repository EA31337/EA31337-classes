//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

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
 * Enumeration for the current account double values.
 *
 * Used for function AccountInfoDouble().
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/accountinformation
 */
enum ENUM_ACCOUNT_INFO_DOUBLE {
  ACCOUNT_ASSETS,              // The current assets of an account (double).
  ACCOUNT_BALANCE,             // Account balance in the deposit currency (double).
  ACCOUNT_COMMISSION_BLOCKED,  // The current blocked commission amount on an account (double).
  ACCOUNT_CREDIT,              // Account credit in the deposit currency (double).
  ACCOUNT_EQUITY,              // Account equity in the deposit currency (double).
  ACCOUNT_LIABILITIES,         // The current liabilities on an account (double).
  ACCOUNT_MARGIN,              // Account margin used in the deposit currency (double).
  ACCOUNT_MARGIN_FREE,         // Free margin of an account in the deposit currency (double).
  ACCOUNT_MARGIN_INITIAL,      // Initial margin reserved on an account to cover all pending orders (double).
  ACCOUNT_MARGIN_LEVEL,        // Account margin level in percents (double).
  ACCOUNT_MARGIN_MAINTENANCE,  // Maintenance margin reserved to cover minimum amount of open positions (double).
  ACCOUNT_MARGIN_SO_CALL,      // Margin call level (double). Depends on ACCOUNT_MARGIN_SO_MODE.
  ACCOUNT_MARGIN_SO_SO,        // Margin stop out level (double). Depends on ACCOUNT_MARGIN_SO_MODE.
  ACCOUNT_PROFIT,              // Current profit of an account in the deposit currency (double).
};

/**
 * Enumeration for the current account integer values.
 *
 * Used for function AccountInfoInteger().
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/accountinformation
 */
enum ENUM_ACCOUNT_INFO_INTEGER {
  ACCOUNT_CURRENCY_DIGITS,  // The number of decimal places in the account currency (int).
  ACCOUNT_FIFO_CLOSE,       // Whether positions can only be closed by FIFO rule (bool).
  ACCOUNT_LEVERAGE,         // Account leverage (long).
  ACCOUNT_LIMIT_ORDERS,     // Maximum allowed number of active pending orders (int).
  ACCOUNT_LOGIN,            // Account number (long).
  ACCOUNT_MARGIN_MODE,      // Margin calculation mode (ENUM_ACCOUNT_MARGIN_MODE).
  ACCOUNT_MARGIN_SO_MODE,   // Mode for setting the minimal allowed margin (ENUM_ACCOUNT_STOPOUT_MODE).
  ACCOUNT_TRADE_ALLOWED,    // Allowed trade for the current account (bool).
  ACCOUNT_TRADE_EXPERT,     // Allowed trade for an Expert Advisor (bool).
  ACCOUNT_TRADE_MODE,       // Account trade mode (ENUM_ACCOUNT_TRADE_MODE).
};

/**
 * Enumeration for the current account string values.
 *
 * Used for function AccountInfoString().
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/accountinformation
 */
enum ENUM_ACCOUNT_INFO_STRING {
  ACCOUNT_COMPANY,   // Name of a company that serves the account (string).
  ACCOUNT_CURRENCY,  // Account currency (string).
  ACCOUNT_NAME,      // Client name (string).
  ACCOUNT_SERVER     // Trade server name (string).
};

/**
 * Enumeration for the margin modes.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/accountinformation
 */
enum ENUM_ACCOUNT_MARGIN_MODE {
  ACCOUNT_MARGIN_MODE_EXCHANGE,        // Margin is calculated based on the discounts.
  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING,  // Used for the exchange markets where individual positions are possible.
  ACCOUNT_MARGIN_MODE_RETAIL_NETTING,  // Used for the OTC markets to interpret positions in the "netting" mode.
};

/**
 * Enumeration for the types of accounts on a trade server.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/accountinformation
 */
enum ENUM_ACCOUNT_TRADE_MODE {
  ACCOUNT_TRADE_MODE_DEMO,     // Demo account.
  ACCOUNT_TRADE_MODE_CONTEST,  // Contest account.
  ACCOUNT_TRADE_MODE_REAL,     // Real account.
};

/**
 * Enumeration for the Stop Out modes.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/accountinformation
 */
enum ENUM_ACCOUNT_STOPOUT_MODE {
  ACCOUNT_STOPOUT_MODE_PERCENT,  // Account stop out mode in percents.
  ACCOUNT_STOPOUT_MODE_MONEY,    // Account stop out mode in money.
};
#endif
