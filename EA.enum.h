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
 * Includes EA's enums.
 */

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
  EA_DATA_EXPORT_NONE = 0 << 0,
  EA_DATA_EXPORT_CSV = 1 << 0,        // Export into CSV file.
  EA_DATA_EXPORT_DB = 1 << 1,         // Export into database table.
  EA_DATA_EXPORT_JSON = 1 << 2,       // Export into JSON file.
  EA_DATA_EXPORT_ALL = (1 << 3) - 1,  // Export in all formats.
};

// Defines enumeration for EA parameters.
enum ENUM_EA_PARAM {
  EA_PARAM_NONE = 0,           // None
  EA_PARAM_AUTHOR,             // Author
  EA_PARAM_CHART_INFO_FREQ,    // Chart info frequency
  EA_PARAM_DATA_EXPORT,        // Format to export the data.
  EA_PARAM_DATA_STORE,         // Type of data to store.
  EA_PARAM_DESC,               // Description
  EA_PARAM_LOG_LEVEL,          // Log level
  EA_PARAM_NAME,               // Name
  EA_PARAM_RISK_MARGIN_MAX,    // Maximum margin to risk
  EA_PARAM_SYMBOL,             // Symbol
  EA_PARAM_TASK_ENTRY,         // Task entry
  EA_PARAM_VER,                // Version
  FINAL_ENUM_EA_PARAM
};

/* Defines EA state flags. */
enum ENUM_EA_PARAM_FLAGS {
  EA_PARAM_FLAG_NONE = 0 << 0,           // None flags.
  EA_PARAM_FLAG_LOTSIZE_AUTO  = 1 << 0,  // Auto calculate lot size.
  EA_PARAM_FLAG_REPORT_EXPORT = 1 << 1,  // Export report on exit.
  EA_PARAM_FLAG_REPORT_PRINT = 1 << 2,   // Print report on exit.
};

/* Defines EA state flags. */
enum ENUM_EA_STATE_FLAGS {
  EA_STATE_FLAG_NONE = 0 << 0,           // None flags.
  EA_STATE_FLAG_ACTIVE = 1 << 0,         // Is active (can trade).
  EA_STATE_FLAG_CONNECTED = 1 << 1,      // Indicates connectedness to a trade server.
  EA_STATE_FLAG_ENABLED = 1 << 2,        // Is enabled.
  EA_STATE_FLAG_LIBS_ALLOWED = 1 << 3,   // Indicates the permission to use external libraries (such as DLL).
  EA_STATE_FLAG_ON_INIT = 1 << 4,        // Indicates EA is during initializing procedure (constructor).
  EA_STATE_FLAG_ON_QUIT = 1 << 5,        // Indicates EA is during exiting procedure (deconstructor).
  EA_STATE_FLAG_OPTIMIZATION = 1 << 6,   // Indicates EA runs in optimization mode.
  EA_STATE_FLAG_TESTING = 1 << 7,        // Indicates EA runs in testing mode.
  EA_STATE_FLAG_TRADE_ALLOWED = 1 << 8,  // Indicates the permission to trade on the chart.
  EA_STATE_FLAG_VISUAL_MODE = 1 << 9,    // Indicates EA runs in visual testing mode.
};
