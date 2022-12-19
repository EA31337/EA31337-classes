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
#ifndef INDICATOR_CANDLE_PROVIDER_H
#define INDICATOR_CANDLE_PROVIDER_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Candle.struct.h"
#include "../Storage/ItemsHistory.h"

/**
 * Regenerates candles and updates exising candles from new ticks. Subclasses by IndicatorTf, IndicatorRenko.
 */
template <typename TV>
class ItemsHistoryCandleProvider : public ItemsHistoryItemProvider<CandleOCTOHLC<TV>> {
 public:
  /**
   * Constructor.
   */
  ItemsHistoryCandleProvider() {}

  /**
   * Called when new tick was emitted from IndicatorTick-based source.
   */
  virtual void OnTick(ItemsHistory<CandleOCTOHLC<TV>, ItemsHistoryItemProvider<CandleOCTOHLC<TV>>>* _history,
                      long _time_ms, float _ask, float _bid) {
    // Should be overrided.
  }

  /**
   * Retrieves given number of items starting from the given microseconds or index (inclusive). "_dir" identifies if we
   * want previous or next items from selected starting point.
   */
  void GetItems(ItemsHistory<CandleOCTOHLC<TV>, ItemsHistoryCandleProvider<TV>>* _history, long _from_time_ms,
                ENUM_ITEMS_HISTORY_DIRECTION _dir, int _num_items, ARRAY_REF(CandleOCTOHLC<TV>, _out_arr)) {
    // Method is called if there is a missing item (candle) in the history. We need to regenerate it.
    Print("Error: Retrieving items by this item provider is not implemented!");
    DebugBreak();
  }
};

#endif
