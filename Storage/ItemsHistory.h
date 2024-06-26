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
 * Forward declaration.
 */
template <typename IV, typename PT>
class ItemsHistory;

/**
 * Generates/regenerates history for ItemsHistory class. Should be subclassed.
 */
template <typename IV>
class ItemsHistoryItemProvider : public Dynamic {
 public:
  /**
   * Constructor.
   */
  ItemsHistoryItemProvider() {}

  /**
   * Retrieves given number of items starting from the given microseconds or index (inclusive). "_dir" identifies if we
   * want previous or next items from selected starting point. Should return false if retrieving items by this method
   * is not available.
   */
  bool GetItems(ItemsHistory<IV, ItemsHistoryItemProvider<IV>>* _history, long _from_time_ms,
                ENUM_ITEMS_HISTORY_DIRECTION _dir, int _num_items, ARRAY_REF(IV, _out_arr)) {
    return false;
  }

  /**
   * Retrieves items between given indices (both indices inclusive). Should return false if retrieving items by this
   * method is not available.
   */
  bool GetItems(ItemsHistory<IV, ItemsHistoryItemProvider<IV>>* _history, int _start_index, int _end_index,
                ARRAY_REF(IV, _out_arr)) {
    return false;
  }

  /**
   * Time of the first possible item/candle/tick.
   */
  virtual long GetInitialTimeMs() {
    // Item's provider does not implement GetInitialTimeMs(), but it should. We'll use current time for the time of the
    // first item.
    return (long)TimeCurrent() * 1000;
  }

  /**
   * Returns information about item provider.
   */
  virtual string ToString() { return "Abstract items history item provider."; }
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

  // Index of the most old item in the history ever added.
  int first_valid_index_ever;

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
  ItemsHistory(unsigned int _history_max_size = 0)
      : history_max_size(_history_max_size),
        current_index(0),
        first_valid_index(0),
        first_valid_index_ever(0),
        last_valid_index(0),
        peak_size(0) {}

  /**
   * Returns item provider.
   */
  PT* GetItemProvider() { return item_provider.Ptr(); }

  /**
   * Sets item provider.
   */
  void SetItemProvider(PT* _item_provider) { item_provider = _item_provider; }

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
  unsigned int GetPeakSize() { return peak_size; }

  /**
   * Increments maximum size of historic items.
   */
  void ReserveAdditionalHistoryMaxSize(unsigned int size) { history_max_size += size; }

  /**
   * Changes maximum size of historic items.
   */
  void SetHistoryMaxSize(unsigned int size) { history_max_size += size; }

  /**
   * Will regenerate items from item provider. "_dir" indicates if we have to prepend or append items.
   */
  void RegenerateHistory(int _from_index, int _to_index, ENUM_ITEMS_HISTORY_DIRECTION _dir) {
#ifdef __debug_items_history__
    Print("RegenerateHistory(", _from_index, ", ", _to_index, ", ", EnumToString(_dir), "), ", GetInfo());
#endif

    int _item_count = _to_index - _from_index + 1;

    // Static buffer for items generated by the item provider.
    static ARRAY(IV, _items);
    ArrayResize(_items, 0);

    // Currently we only support getting items via start -> end indices.

    item_provider REF_DEREF GetItems(THIS_PTR, _from_index, _to_index, _items);

    if (ArraySize(_items) != _item_count) {
#ifdef __debug_items_history__
      Print("RegenerateHistory: Notice: Requested ", _item_count, " historic items, got ", ArraySize(_items),
            ". from index = ", _from_index, ", to index = ", _to_index, ", dir = ", EnumToString(_dir), " (", GetInfo(),
            ")");
#endif
    }

    int i;

    if (_dir == ITEMS_HISTORY_DIRECTION_FORWARD) {
      for (i = 0; i < _item_count; ++i) {
        Append(_items[i], false);
      }
    } else if (_dir == ITEMS_HISTORY_DIRECTION_BACKWARD) {
      // Our _items array contain most recent items at the start, so we have to iterate from the end in order to prepend
      // items.
      if (peak_size <= 1) {
        // It's the first time we're trying to retrieve historic items. We need to make sure all history will fit in the
        // buffer. Note that we use <= 1, because Tick indicator could already have appeneded first candle.
        history_max_size = MathMax(history_max_size, history.Size() + _item_count);
      }
      for (i = 0; i < _item_count; ++i) {
        Prepend(_items[i], false);
      }
    }

    /*

        int _item_count = _to_index - _from_index + 1;
        long _from_time_ms;
        IV _item;

        // Calculating time to be passed to GetItems().
        if (_dir == ITEMS_HISTORY_DIRECTION_FORWARD) {
          if (history.Size() == 0) {
    #ifdef __debug_items_history__
            Print("RegenerateHistory: Getting initial time from item provider");
    #endif

            // Time from we'll be getting items will be the time of the first possible item/candle/tick.
            _from_time_ms = item_provider REF_DEREF GetInitialTimeMs();
          } else {
    #ifdef __debug_items_history__
            Print("RegenerateHistory: Getting last valid item at index ", last_valid_index);
    #endif

            // Time will be the time of last valid item + item's length + 1ms.
            // Note that ticks have length of 0ms, so next tick could be at least 1ms after the previous tick.
            _item = GetItemByIndex(last_valid_index);
            _from_time_ms = _item.GetTimeMs() + _item.GetLengthMs() + 1;
          }

          long _current_time_ms = TimeCurrent() * 1000;

          if (_from_time_ms > (long)TimeCurrent() * 1000) {
            // There won't be items in the future.
            return;
          }
        } else if (_dir == ITEMS_HISTORY_DIRECTION_BACKWARD) {
          if (history.Size() == 0) {
            // Time from we'll be getting items will be the time of the first possible item/candle/tick - 1ms.
            _from_time_ms = item_provider REF_DEREF GetInitialTimeMs() - 1;
          } else {
    #ifdef __debug_items_history__
            Print("RegenerateHistory: Getting first valid item at index ", first_valid_index);
    #endif

            // Time will be the time of the first valid item - 1ms.
            _item = GetItemByIndex(first_valid_index);
            _from_time_ms = _item.GetTimeMs() - 1;
          }
        } else {
          Print("Error: We shouldn't be here!");
          DebugBreak();
          return;
        }

        item_provider REF_DEREF GetItems(THIS_PTR, _from_time_ms, _dir, _item_count, _items);

        if (ArraySize(_items) != _item_count) {
    // There's really no problem if number of generated items are less than
    // requested.
    // @todo However, if there's too many calls for RegenerateHistory then we
    // need to find a way to make it exit earlier.
    #ifdef __debug_items_history__
          Print("RegenerateHistory: Notice: Requested ", _item_count, " historic items, got ", ArraySize(_items),
                ". from index = ", _from_index, ", to index = ", _to_index, ", dir = ", EnumToString(_dir), " (",
    GetInfo(),
                ")");
    #endif
          return;
        }

        */
  }

  string GetInfo() {
    string _out;
    _out += "first_valid_index_ever = " + IntegerToString(first_valid_index_ever) + ", ";
    _out += "first_valid_index = " + IntegerToString(first_valid_index) + ", ";
    _out += "current_index = " + IntegerToString(current_index) + ", ";
    _out += "history_size = " + IntegerToString(history.Size());
    return _out;
  }

  /**
   * Appends item to the history and increments history shift, so current item will be the added one.
   *
   * If shift is lower than last_valid_shift then we need to regenerate history between last_valid_shift and shift.
   */
  void Append(IV& _item, bool _allow_regenerate = true) {
    if (peak_size > 0) {
      // There was at least one prepended/appended item, so indices relates to existing items.
      if (history_max_size != 0 && history.Size() >= history_max_size) {
        // We need to remove first item from the history (the oldest one).
        // Print("Removing item #", first_valid_index, " from the history.");
        history.Unset(first_valid_index++);
      }

      if (_allow_regenerate && last_valid_index < current_index) {
#ifdef __debug_items_history__
        Print("Append: Missing history between index ", last_valid_index, " and ", current_index,
              ". We will try to regenerate it.");
#endif
        // May call Append() multiple times with regenerated items.
        RegenerateHistory(last_valid_index, current_index, ITEMS_HISTORY_DIRECTION_BACKWARD);

        // @todo Check if history was fully regenerated.
      }

      // Incrementing current index and setting last valid index to the same value.
      last_valid_index = ++current_index;
    }

    // Adding item to the newly set index or index 0.
    history.Set(current_index, _item);  // if peak_size == 0 then current_index = 0.

    peak_size = MathMax(peak_size, history.Size());
  }

  /**
   * Prepends item to the history.
   *
   * If shift is lower than last_valid_shift then we need to regenerate history between last_valid_shift and shift.
   */
  void Prepend(IV& _item, bool _allow_regenerate = true) {
    if (peak_size > 0) {
      // There was at least one prepended/appended item, so indices relates to existing items.
      if (history_max_size != 0 && history.Size() >= history_max_size) {
        // We need to remove last item from the history (the newest one).
        // Print("Removing item #", last_valid_index, " from the history.");
        history.Unset(last_valid_index--);
      }

      if (_allow_regenerate && first_valid_index_ever < current_index) {
#ifdef __debug_items_history__
        Print("Prepend: Missing history between index ", first_valid_index, " and ", current_index,
              ". We will try to regenerate it.");
#endif

        // May call Prepend() multiple times with regenerated items.
        RegenerateHistory(first_valid_index, current_index, ITEMS_HISTORY_DIRECTION_FORWARD);

        // @todo Check if history was fully regenerated.
      }

      // last_valid_index stays on its own, because it is not a first item to be added to the history.
      --first_valid_index;
    } else {
      // It is a first item to be prepended. last_valid_index will be now
      // negative. That means we don't have information about item at
      // index/shift 0. In order to retrieve item at index/shift 0 the history
      // must be regenerated from last_valid_index (not inclusive) to index 0.
      // Effectively, we would just need to regenerate item at index 0.
      // current_index will stay at index 0.
      last_valid_index = --first_valid_index;  // last_valid_index = -1.
    }

    // Adding item to the newly set index.
    history.Set(first_valid_index, _item);

    // Saving index of the most old item in the history ever added.
    first_valid_index_ever = MathMin(first_valid_index_ever, first_valid_index);

    peak_size = MathMax(peak_size, history.Size());
  }

  /**
   * Updates item in the history. History must contain item with the given index!
   */
  void Update(IV& _item, int _index) {
    if (!history.KeyExists(_index)) {
      Print("Error: You may only update existing items! History doesn't contain item with index ", _index, ".");
      DebugBreak();
    }
    history.Set(_index, _item);
  }

  /**
   * Ensures that the given shift exists. Tries to regenerate the history if it does not.
   */
  bool EnsureShiftExists(int _shift) {
    if (history.Size() == 0) {
      // return false;
    }

#ifdef __debug_items_history__
      // Print("EnsureShiftExists(", _shift, ")");
#endif

    int _index = GetShiftIndex(_shift);
    if (_index < first_valid_index) {
      RegenerateHistory(_index, first_valid_index - 1, ITEMS_HISTORY_DIRECTION_BACKWARD);
    } else if (_index > last_valid_index) {
      RegenerateHistory(last_valid_index + 1, _index, ITEMS_HISTORY_DIRECTION_FORWARD);
    }

    return history.KeyExists(_index);
  }

  /**
   * Returns item at given index. Index must exist!
   */
  IV GetItemByIndex(int _index, bool _try_regenerate = true) {
    IV _item;

#ifdef __debug_items_history__
    Print("GetItemByIndex(", _index, ", try_regenerate = ", _try_regenerate, ")");
#endif

    if (!TryGetItemByIndex(_index, _item, _try_regenerate)) {
      Print("Error: Given index ", _index,
            " is outside the range of valid items! Errored: ", item_provider REF_DEREF ToString());
      DebugBreak();
    }
    return _item;
  }

  /**
   * Tries to get item at given index.
   */
  bool TryGetItemByIndex(int _index, IV& _out_item, bool _try_regenerate = true) {
    if (history.Size() == 0 || _index < first_valid_index || _index > last_valid_index) {
      if (!_try_regenerate) {
        // Print("Notice: Missing history. Tried to get item at index ", _index);
        return false;
      }

#ifdef __debug_items_history__
      Print("TryGetItemByIndex(", _index, ", try_regenerate = ", _try_regenerate, ")");
#endif

      // Whether we need to prepend old items or append new ones.
      ENUM_ITEMS_HISTORY_DIRECTION _dir =
          _index < first_valid_index ? ITEMS_HISTORY_DIRECTION_BACKWARD : ITEMS_HISTORY_DIRECTION_FORWARD;
      RegenerateHistory(_index < first_valid_index ? _index : (last_valid_index - 1),
                        _index < first_valid_index ? (first_valid_index - 1) : _index, _dir);
      // Trying to get item again, but without regeneration at this time.
      return TryGetItemByIndex(_index, _out_item, false);
    }
    _out_item = history.GetByKey(_index);
    return true;
  }

  /**
   * Returns index of the current item. 0 if there were no items added or there
   * is a single item.
   */
  int GetCurrentIndex() { return current_index; }

  /**
   * Returns history index from the given shift.
   */
  int GetShiftIndex(int _shift) { return current_index - _shift; }

  /**
   * Returns item at given shift. Shift must exist!
   */
  IV GetItemByShift(int _shift, bool _try_regenerate = true) {
    return GetItemByIndex(GetShiftIndex(_shift), _try_regenerate);
  }

  /**
   * Tries to get item at given shift.
   */
  bool TryGetItemByShift(int _shift, IV& _out_item, bool _try_regenerate = true) {
    return TryGetItemByIndex(GetShiftIndex(_shift), _out_item, _try_regenerate);
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
  datetime GetItemTimeByShift(int _shift) {
#ifdef __debug_items_history__
    Print("GetItemTimeByShift(", _shift, "), ", GetInfo());
#endif

    if (!EnsureShiftExists(_shift)) {
      // There won't be item at given shift.
      return (datetime)0;
    }

    datetime _dt = (datetime)(GetItemTimeByShiftMsc(_shift) / 1000);

#ifdef __debug_items_history__
    Print("GetItemTimeByShift(", _shift, "), ", GetInfo(), " = ", _dt);
#endif

    return _dt;
  }

  /**
   * Removes recently added item.
   */
  bool RemoveRecentItem() {
    history.Unset(last_valid_index);

    // Going back to previous item.
    current_index = --last_valid_index;

    // Peak size is less by one item.
    --peak_size;

    return history.Size() > 0;
  }

  /**
   * Removes recently added items.
   */
  void RemoveRecentItems(int _num_to_remove = INT_MAX) {
    while (_num_to_remove-- > 0 && RemoveRecentItem()) {
      // Removing item one by one ^^.
    }
  }
};

#endif
