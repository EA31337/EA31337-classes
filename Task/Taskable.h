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
 * Defines Taskable class.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef TASKABLE_H
#define TASKABLE_H

// Includes.
#include "TaskAction.h"
#include "TaskCondition.h"

/**
 * Taskable class.
 */
class Taskable {
 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  Taskable() {}

  /* Main methods */

  /**
   * Checks a condition.
   */
  virtual bool Check(const TaskConditionEntry &_entry) = NULL;

  /**
   * Runs an action.
   */
  virtual bool Run(const TaskActionEntry &_entry) = NULL;
};

#endif  // TASKABLE_H