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
   * Called when new tick was emitted from IndicatorTick-based source.
   */
  virtual void OnTick(long _timestamp_ms, float _ask, float _bid) {
    // Should be overrided.
  }
};

#endif
