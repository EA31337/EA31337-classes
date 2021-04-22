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
 * Includes Terminal's enums.
 */

// Terminal actions.
enum ENUM_TERMINAL_ACTION { TERMINAL_ACTION_CRASH, FINAL_ENUM_TERMINAL_ACTION };

// Terminal conditions.
enum ENUM_TERMINAL_CONDITION { TERMINAL_COND_IS_CONNECTED, FINAL_ENUM_TERMINAL_CONDITION_ENTRY };

#ifndef __MQL__
/**
 * Enumeration for the return codes.
 * @docs
 * https://www.mql5.com/en/docs/basis/function/events
 */
enum ENUM_INIT_RETCODE {
  INIT_SUCCEEDED = 0,         // Successful initialization.
  INIT_FAILED = 1,            // Initialization failed.
  INIT_PARAMETERS_INCORRECT,  // Incorrect set of input parameters.
  INIT_AGENT_NOT_SUITABLE,    // The agent is not suitable for testing.
};
#endif
