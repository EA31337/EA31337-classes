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
 * Includes Task's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/* Structure for task actions for Action class. */
enum ENUM_TASK_ACTION {
  TASK_ACTION_NONE = 0,  // Does nothing.
  TASK_ACTION_PROCESS,   // Process tasks.
  FINAL_TASK_ACTION_ENTRY
};

/* Structure for task conditions for Action class. */
enum ENUM_TASK_CONDITION {
  TASK_COND_NONE = 0,     // Empty condition.
  TASK_COND_IS_ACTIVE,    // Is active.
  TASK_COND_IS_DONE,      // Is done.
  TASK_COND_IS_FAILED,    // Is failed.
  TASK_COND_IS_FINISHED,  // Is finished.
  TASK_COND_IS_INVALID,   // Is invalid.
  FINAL_TASK_CONDITION_ENTRY
};

/* Structure for task entry flags. */
enum ENUM_TASK_ENTRY_FLAGS {
  TASK_ENTRY_FLAG_NONE = 0,
  TASK_ENTRY_FLAG_IS_ACTIVE = 1,
  TASK_ENTRY_FLAG_IS_DONE = 2,
  TASK_ENTRY_FLAG_IS_EXPIRED = 4,
  TASK_ENTRY_FLAG_IS_FAILED = 8,
  TASK_ENTRY_FLAG_IS_INVALID = 16
};
