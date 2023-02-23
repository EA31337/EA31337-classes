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
  virtual void OnTick(ItemsHistory<TickTAB<TV>, ItemsHistoryTickProvider<TV>>* _history, long _time_ms, float _ask,
                      float _bid) {
    TickTAB<TV> _tick(_time_ms, _ask, _bid);
    _history PTR_DEREF Append(_tick);
  }

  /**
   * Retrieves given number of items starting from the given microseconds or index (inclusive). "_dir" identifies if we
   * want previous or next items from selected starting point.
   */
  void GetItems(ItemsHistory<TickTAB<TV>, ItemsHistoryTickProvider<TV>>* _history, long _from_time_ms,
                ENUM_ITEMS_HISTORY_DIRECTION _dir, int _num_items, ARRAY_REF(TickTAB<TV>, _out_arr)) {
    // Method is called if there is a missing item (tick) in the history. We need to regenerate it.
    indi PTR_DEREF FetchHistoryByStartTimeAndCount(_from_time_ms, _dir, _num_items, _out_arr);
  }

  /**
   * Returns information about item provider.
   */
  string ToString() override { return "IndicatorTick tick provider on " + indi PTR_DEREF GetFullName(); }
};

#endif  // INDICATOR_TICK_PROVIDER_H
