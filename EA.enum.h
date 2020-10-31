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
 * Includes EA's enums.
 */

// Defines EA input data types.
enum ENUM_EA_DATA_TYPE {
  EA_DATA_NONE = 0 << 0,
  EA_DATA_CHART = 1 << 0,                 // Chart data (OHCL).
  EA_DATA_INDICATOR = 1 << 1,             // Indicator data.
  EA_DATA_STRATEGY = 1 << 2,              // Strategy data.
  EA_DATA_SYMBOL = 1 << 3,                // Symbol data (tick).
  EA_DATA_TRADE = 1 << 4,                 // Trade data.
  EA_DATA_ALL = EA_DATA_CHART | EA_DATA_INDICATOR | EA_DATA_STRATEGY | EA_DATA_SYMBOL | EA_DATA_TRADE,
};

// Defines EA state flags.
enum ENUM_EA_STATE_FLAGS {
  EA_STATE_FLAG_NONE = 0 << 0,            // None flags.
  EA_STATE_FLAG_ACTIVE = 1 << 0,          // Is active (can trade).
  EA_STATE_FLAG_CONNECTED = 1 << 1,       // Indicates connectedness to a trade server.
  EA_STATE_FLAG_ENABLED = 1 << 2,         // Is enabled.
  EA_STATE_FLAG_LIBS_ALLOWED = 1 << 3,    // Indicates the permission to use external libraries (such as DLL).
  EA_STATE_FLAG_ON_INIT = 1 << 4,         // Indicates EA is during initializing procedure (constructor).
  EA_STATE_FLAG_ON_QUIT = 1 << 5,         // Indicates EA is during exiting procedure (deconstructor).
  EA_STATE_FLAG_OPTIMIZATION = 1 << 6,    // Indicates EA runs in optimization mode.
  EA_STATE_FLAG_TESTING = 1 << 7,         // Indicates EA runs in testing mode.
  EA_STATE_FLAG_TESTING_VISUAL = 1 << 8,  // Indicates EA runs in visual testing mode.
  EA_STATE_FLAG_TRADE_ALLOWED = 1 << 9,   // Indicates the permission to trade on the chart.
};