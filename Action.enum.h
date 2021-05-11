//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * Includes Action's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef ACTION_ENUM_H
#define ACTION_ENUM_H

/* Defines action entry flags. */
enum ENUM_ACTION_ENTRY_FLAGS {
  ACTION_ENTRY_FLAG_NONE = 0,
  ACTION_ENTRY_FLAG_IS_ACTIVE = 1,
  ACTION_ENTRY_FLAG_IS_DONE = 2,
  ACTION_ENTRY_FLAG_IS_FAILED = 4,
  ACTION_ENTRY_FLAG_IS_INVALID = 8
};

/* Defines action types. */
enum ENUM_ACTION_TYPE {
  ACTION_TYPE_NONE = 0,   // None.
  ACTION_TYPE_ACTION,     // Action of action.
  ACTION_TYPE_EA,         // EA action.
  ACTION_TYPE_INDICATOR,  // Order action.
  ACTION_TYPE_ORDER,      // Order action.
  ACTION_TYPE_STRATEGY,   // Strategy action.
  ACTION_TYPE_TASK,       // Task action.
  ACTION_TYPE_TRADE,      // Trade action.
  ACTION_TYPE_TERMINAL,   // Terminal action.
  FINAL_ACTION_TYPE_ENTRY
};

/* Defines action types for Action class. */
enum ENUM_ACTION_ACTION {
  ACTION_ACTION_NONE = 0,          // Does nothing.
  ACTION_ACTION_DISABLE,           // Disables action.
  ACTION_ACTION_EXECUTE,           // Executes action.
  ACTION_ACTION_MARK_AS_DONE,      // Marks as done.
  ACTION_ACTION_MARK_AS_INVALID,   // Marks as invalid.
  ACTION_ACTION_MARK_AS_FAILED,    // Marks as failed.
  ACTION_ACTION_MARK_AS_FINISHED,  // Marks as finished.
  FINAL_ACTION_ACTION_ENTRY
};

/* EA actions. */
enum ENUM_EA_ACTION {
  EA_ACTION_DISABLE = 0,        // Disables EA.
  EA_ACTION_ENABLE,             // Enables EA.
  EA_ACTION_EXPORT_DATA,        // Trigger export data.
  EA_ACTION_STRATS_EXE_ACTION,  // Executes strategy's set action for all.
  EA_ACTION_TASKS_CLEAN,        // Clean tasks.
  FINAL_EA_ACTION_ENTRY
};

#endif  // End: ACTION_ENUM_H
