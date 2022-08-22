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
 * DictSlotsRef struct.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Array.mqh"
#include "Dict.enum.h"
#include "DictSlot.mqh"
#include "Std.h"
#include "Util.h"

// Forward class declaration.
template <typename K, typename V>
class DictSlot;

template <typename K, typename V>
struct DictSlotsRef {
  ARRAY(DictSlot<K _COMMA V>, DictSlots);

  // Incremental index for dict operating in list mode.
  int _list_index;

  int _num_used;

  int _num_conflicts;

  float _avg_conflicts;

  DictSlotsRef() {
    _list_index = 0;
    _num_used = 0;
    _num_conflicts = 0;
    _avg_conflicts = 0;
  }

  void operator=(DictSlotsRef& r) {
    Util::ArrayCopy(DictSlots, r.DictSlots);
    _list_index = r._list_index;
    _num_used = r._num_used;
    _num_conflicts = r._num_conflicts;
    _avg_conflicts = r._avg_conflicts;
  }

  /**
   * Adds given number of conflicts for an insert action, so we can store average number of conflicts.
   */
  void AddConflicts(int num) {
    if (num != 0) {
      _avg_conflicts += (float)num / (float)++_num_conflicts;
    }
  }

  /**
   * Checks whethere there is no performance problems with slots.
   */
  bool IsPerformant() { return _avg_conflicts < DICT_PERFORMANCE_PROBLEM_AVG_CONFLICTS; }
};
