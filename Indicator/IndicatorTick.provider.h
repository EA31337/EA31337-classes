//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
#ifndef INDICATOR_TICK_PROVIDER_H
#define INDICATOR_TICK_PROVIDER_H

#ifndef __MQL__
  // Allows the preprocessor to include a header file when it is needed.
  #pragma once
#endif

// Includes.
#include "../Storage/ItemsHistory.h"

/**
 * Regenerates candles and updates existing candles from new ticks. Derived by IndicatorTf, IndicatorRenko.
 */
template <typename TV>
class ItemsHistoryTickProvider : public ItemsHistoryItemProvider<TickTAB<TV>> {
  // Pointer to IndicatorTick. Used to fetch ask/bid prices.
  IndicatorData* indi;

 public:
  /**
   * Constructor.
   */
  ItemsHistoryTickProvider(IndicatorData* _indi_tick) : indi(_indi_tick) {}

  /**
   * Called when new tick was emitted from IndicatorTick-based source.
   */
  virtual void OnTick(ItemsHistory<TickTAB<TV>, ItemsHistoryTickProvider<TV>>* _history, int64 _time_ms, float _ask,
                      float _bid) {
    TickTAB<TV> _tick(_time_ms, _ask, _bid);
    _history PTR_DEREF Append(_tick);
  }

  /**
   * Retrieves given number of items starting from the given microseconds or index (inclusive). "_dir" identifies if we
   * want previous or next items from selected starting point. Should return false if retrieving items by this method
   * is not available.
   */
  bool GetItems(ItemsHistory<TickTAB<TV>, ItemsHistoryTickProvider<TV>>* _history, int64 _from_time_ms,
                ENUM_ITEMS_HISTORY_DIRECTION _dir, int _num_items, ARRAY_REF(TickTAB<TV>, _out_arr)) {
    return false;
  }

  /**
   * Retrieves items between given indices (both indices inclusive). Should return false if retrieving items by this
   * method is not available.
   */
  bool GetItems(ItemsHistory<TickTAB<TV>, ItemsHistoryTickProvider<TV>>* _history, int _start_index, int _end_index,
                ARRAY_REF(TickTAB<TV>, _out_arr)) {
    return false;
  }

  /**
   * Returns information about item provider.
   */
  string const ToString() override { return "IndicatorTick tick provider on " + indi PTR_DEREF GetFullName(); }
};

#endif  // INDICATOR_TICK_PROVIDER_H
