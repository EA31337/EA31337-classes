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

// Ignore processing of this file if already included.
#ifndef ITEMS_HISTORY_H
#define ITEMS_HISTORY_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

#include "../DictStruct.mqh"
#include "../Refs.mqh"

/**
 * Direction used by ItemsHistoryItemProvider's methods.
 */
enum ENUM_ITEMS_HISTORY_DIRECTION { ITEMS_HISTORY_DIRECTION_FORWARD, ITEMS_HISTORY_DIRECTION_BACKWARD };

/**
 * Generates/regenerates history for ItemsHistory class. Should be subclassed.
 */
template <typename IV>
class ItemsHistoryItemProvider : public Dynamic {
  /**
   * Retrieves given number of items starting from the given microseconds (inclusive). "_dir" identifies if we want
   * previous or next items from mentioned date and time.
   */
  virtual void GetItems(long _from_ms, ENUM_ITEMS_HISTORY_DIRECTION _dir, int _num_items, ARRAY_REF(IV, _out_arr)) {
    Print(
        "Error: Retrieving items from a given date and time is not supported by this historic items provides. Please "
        "use GetItems(int _from_index) version!");
    DebugBreak();
  }

  /**
   * Retrieves given number of items starting from the given index (inclusive). "_dir" identifies if we want previous or
   * next items from mentioned index.
   */
  virtual void GetItems(int _from_index, ENUM_ITEMS_HISTORY_DIRECTION _dir, int _num_items, ARRAY_REF(IV, _out_arr)) {
    Print(
        "Error: Retrieving items from a given index is not supported by this historic items provides. Please use "
        "GetItems(long _from_ms) version!");
    DebugBreak();
  }

  /**
   * Helper method to retrieve items up to item with "_to_ms" date and time.
   */
  void GetItems(datetime _from_ms, datetime _to_ms, ARRAY_REF(IV, _out_arr)) {
    // @todo.
  }
};

/**
 * A continuous history of items. Appending new item may remove the
 * oldest one and vice versa. We can't remove iems in-between the history.
 *
 * Indices in history's dict are incremented when adding new items, so
 * first item will have index 0, second one will have index 1.
 *
 * When items are prepended, there could be a situation where the most
 * recent items dissapeared and must be regenerated.
 */
template <typename IV, typename PT>
class ItemsHistory {
  // Provides items from bound provider.
  Ref<PT> item_provider;

  // Holds items per its index. "shift" property indicates how indices
  // are shifted from their index.
  DictStruct<int, IV> history;

  // Maximum number of entries in history dict.
  unsigned int history_max_size;

  // How indices are shifted from their stored index. Shift is incremented
  // after each appended item.
  int current_index;

  // Index of the first valid iem. Items between range
  // shift <-> first_valid_shift must be regenerated in order to access
  // them. Note that we can't regenerate item only from the given shift.
  // We have to regenerate all between given shift <- first_valid_shift.
  int first_valid_index;

  // Index of the last valid item. items between range
  // last_valid_shift <-> shift must be regenerated in order to access
  // them. Note that we can't regenerate item only from the given shift.
  // We have to regenerate all between last_valid_shift -> given shift.
  int last_valid_index;

  /// Maximum number of items that occupied the history.
  unsigned int peak_size;

 public:
  /**
   * Constructor
   */
  ItemsHistory(PT* _item_provider)
      : item_provider(_item_provider), current_index(0), first_valid_index(0), last_valid_index(0), peak_size(0) {}

  /**
   * Returns item provider.
   */
  PT* GetProvider() { return item_provider.Ptr(); }

  /**
   * Gets time in milliseconds of the last(oldest) item's time in current history time or 0.
   */
  /*
  long GetLastValidTimeInCache() {
    return history.GetByKey(last_valid_index).GetTime();
  }
  */

  /**
   * Returns maximum number of items that occupied the history. Could be used e.g., to determine how many bars could be
   * retrieved from history and past the history.
   */
  unsigned int PeakSize() { return peak_size; }

  /**
   * Will regenerate items from item provider. "_dir" indicates if we have to prepend or append items.
   */
  void RegenerateHistory(int _from_index, int _to_index, ENUM_ITEMS_HISTORY_DIRECTION _dir) {}

  /**
   * Appends item to the history and increments history shift, so current item will be the added one.
   *
   * If shift is lower than last_valid_shift then we need to regenerate history between last_valid_shift and shift.
   */
  void Append(IV& _item, bool _allow_regenerate = true) {
    if (history_max_size != 0 && history.Size() >= history_max_size) {
      // We need to remove first item from the history (the oldest one).
      history.Unset(first_valid_index++);
    }

    if (_allow_regenerate) {
      // May call Append() multiple times with regenerated items.
      RegenerateHistory(last_valid_index, current_index, ITEMS_HISTORY_DIRECTION_BACKWARD);
    }

    // Adding item in the future of all the history and making it the current one.
    history.Set(++current_index, _item);

    ++last_valid_index;

    peak_size = MathMax(peak_size, history.Size());
  }

  /**
   * Prepends item to the history.
   *
   * If shift is lower than last_valid_shift then we need to regenerate history between last_valid_shift and shift.
   */
  void Prepend(IV& _item, bool _allow_regenerate = true) {
    if (history_max_size != 0 && history.Size() >= history_max_size) {
      // We need to remove first item from the history (the oldest one).
      history.Unset(first_valid_index++);
    }

    if (_allow_regenerate) {
      // May call Prepend() multiple times with regenerated items.
      RegenerateHistory(first_valid_index, current_index, ITEMS_HISTORY_DIRECTION_FORWARD);
    }

    // Adding iem at the beginning of all the history and expanding history by one item in the past.
    history.Set(first_valid_index--, _item);

    peak_size = MathMax(peak_size, history.Size());
  }

  /**
   * Returns item time in milliseconds for the given shift.
   */
  long GetItemTimeByShiftMsc(int _shift) {
    if (!EnsureShiftExists(_shift)) {
      // There won't be item at given shift.
      return (datetime)0;
    }

    return GetItemByShift(_shift).GetTimeMs();
  }

  /**
   * Returns bar date and time for the given shift.
   */
  datetime GetItemTimeByShift(int _shift) { return (datetime)(GetItemTimeByShiftMsc(_shift) / 1000); }

  /**
   * Ensures
   */
  bool EnsureShiftExists(int _shift) {
    int _index = GetShiftIndex(_shift);
    if (_index < first_valid_index) {
      RegenerateHistory(_index, first_valid_index - 1, ITEMS_HISTORY_DIRECTION_BACKWARD);
    } else if (_index > last_valid_index) {
      RegenerateHistory(last_valid_index + 1, _index, ITEMS_HISTORY_DIRECTION_FORWARD);
    }
    return history.Size() > 0;
  }

  /**
   * Returns history index from the given shift.
   */
  int GetShiftIndex(int _shift) { return current_index - _shift; }

  /**
   * Returns item at given shift. Shift must! exists.
   */
  IV GetItemByShift(int _shift) {
    int _index = GetShiftIndex(_shift);
    if (_index < first_valid_index || _index > last_valid_index) {
      Print("Error! Given shift is outside the range of valid items!");
      DebugBreak();
      IV _default;
      return _default;
    }
    return history.GetByKey(_index);
  }
};

#endif
