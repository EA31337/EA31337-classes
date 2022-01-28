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
 * Includes EA's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/* Defines EA input data types. */
enum ENUM_EA_DATA_STORE_TYPE {
  EA_DATA_STORE_NONE = 0 << 0,
  EA_DATA_STORE_CHART = 1 << 0,      // Chart data (OHCL).
  EA_DATA_STORE_INDICATOR = 1 << 1,  // Indicator data.
  EA_DATA_STORE_STRATEGY = 1 << 2,   // Strategy data.
  EA_DATA_STORE_SYMBOL = 1 << 3,     // Symbol data (tick).
  EA_DATA_STORE_TRADE = 1 << 4,      // Trade data.
  EA_DATA_STORE_ALL = (1 << 5) - 1,  // All data to store.
};

/* Defines EA data export methods. */
enum ENUM_EA_DATA_EXPORT_METHOD {
  EA_DATA_EXPORT_NONE = 0 << 0,       // (None)
  EA_DATA_EXPORT_CSV = 1 << 0,        // CSV file
  EA_DATA_EXPORT_DB = 1 << 1,         // Database (SQLite)
  EA_DATA_EXPORT_JSON = 1 << 2,       // JSON file
  EA_DATA_EXPORT_ALL = (1 << 3) - 1,  // All
};

/* Defines EA state flags. */
enum ENUM_EA_PARAM_FLAGS {
  EA_PARAM_FLAG_NONE = 0 << 0,           // None flags.
  EA_PARAM_FLAG_LOTSIZE_AUTO = 1 << 0,   // Auto calculate lot size.
  EA_PARAM_FLAG_REPORT_EXPORT = 1 << 1,  // Export report on exit.
  EA_PARAM_FLAG_REPORT_PRINT = 1 << 2,   // Print report on exit.
};
