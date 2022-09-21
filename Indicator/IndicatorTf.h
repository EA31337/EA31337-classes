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
#ifndef INDICATOR_TF_H
#define INDICATOR_TF_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Chart.struct.tf.h"
#include "IndicatorCandle.h"
#include "IndicatorTf.struct.h"

/**
 * Candle grouping and regeneration for time-frame based candles.
 */
template <typename TV>
class ItemsHistoryTfCandleProvider : public ItemsHistoryCandleProvider<TV> {
  // Seconds per candle.
  int spc;

 public:
  /**
   * Constructor.
   */
  ItemsHistoryTfCandleProvider(int _spc) : spc(_spc) {}

  /**
   * Called when new tick was emitted from IndicatorTick-based source.
   */
  virtual void OnTick(ItemsHistory<CandleOCTOHLC<TV>, ItemsHistoryTfCandleProvider<TV>>* _history, long _time_ms,
                      float _ask, float _bid) {
    Print("IndicatorTf's history: New tick: ", TimeToString(_time_ms / 1000, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
          ", ", _ask, ", ", _bid);

    // We know that tick's timestamp will be ahead of the last tick and thus
    // inside or ahead of the last created candle. In order to retrieve last
    // valid candle, we need to use ItemsHistory::GetItemByShift(0) to check if
    // we have to update last or create/append new candle.
    CandleOCTOHLC<TV> _candle;

    // Will regenerate candles up to the last added candle ever. We have to
    // call it, because some of the previous actions may have removed some of
    // the recent candles. Note that OnTick() advances its _time_ms in
    // ascending order, so all we need to most recent history.
    //
    // Note that EnsureShiftExists() may return false when there never been any
    // candle added.
    _history PTR_DEREF EnsureShiftExists(0);

    if (_history PTR_DEREF TryGetItemByShift(0, _candle) && _candle.ContainsTimeMs(_time_ms)) {
      // Time given fits in the last added candle's time-frame, updating the candle with given price.
      _candle.Update(_time_ms, _bid);

      // Storing candle in the history.
      _history PTR_DEREF Update(_candle, _history PTR_DEREF GetShiftIndex(0));
    } else {
      // Either there is no candle at shift 0 or given time doesn't fit in the #0 candle's time-frame.
      _candle.Init(GetCandleTimeFromTimeMs(_time_ms, spc), spc, _time_ms, _bid);

      // Adding candle as the most recent item in the history. It will now become the candle at shift 0.
      _history PTR_DEREF Append(_candle);
    }
  }

  /**
   * Returns start time of the candle (the place it's on the chart) for the given tick's time in milliseconds.
   */
  int GetCandleTimeFromTimeMs(long _time_ms, int _length_in_secs) {
    return (int)((_time_ms - _time_ms % (_length_in_secs * 1000)) / 1000);
  }

  /**
   * Retrieves given number of items starting from the given microseconds or index (inclusive). "_dir" identifies if we
   * want previous or next items from selected starting point.
   */
  void GetItems(ItemsHistory<CandleOCTOHLC<TV>, ItemsHistoryTfCandleProvider<TV>>* _history, long _from,
                ENUM_ITEMS_HISTORY_SELECTOR _sel, ENUM_ITEMS_HISTORY_DIRECTION _dir, int _num_items,
                ARRAY_REF(CandleOCTOHLC<TV>, _out_arr)) {
    // Method is called if there is a missing item (candle) in the history. We need to regenerate it.
    if (_sel == ITEMS_HISTORY_SELECTOR_INDEX) {
      DebugBreak();
    } else if (_sel == ITEMS_HISTORY_SELECTOR_TIME_MS) {
      Print("Error: Candles are indexed by their index (integer) and thus we can't work with time indices!");
      DebugBreak();
    }
  }
};

/**
 * Class to deal with candle indicators.
 */
template <typename TFP>
class IndicatorTf : public IndicatorCandle<TFP, double, ItemsHistoryTfCandleProvider<double>> {
 protected:
  // Time-frame used to create candles.
  ENUM_TIMEFRAMES tf;

  /* Protected methods */

  /**
   * Initialize class.
   *
   * Called on constructor.
   */
  void Init() { history.SetItemProvider(new ItemsHistoryTfCandleProvider<double>(iparams.GetSecsPerCandle())); }

 public:
  /* Special methods */

  /**
   * Class constructor with timeframe enum.
   */
  IndicatorTf(unsigned int _spc) {
    iparams.SetSecsPerCandle(_spc);
    Init();
  }

  /**
   * Class constructor with timeframe enum.
   */
  IndicatorTf(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    iparams.SetSecsPerCandle(ChartTf::TfToSeconds(_tf));
    tf = _tf;
    Init();
  }

  /**
   * Class constructor with timeframe index.
   */
  IndicatorTf(ENUM_TIMEFRAMES_INDEX _tfi = 0) {
    iparams.SetSecsPerCandle(ChartTf::TfToSeconds(ChartTf::IndexToTf(_tfi)));
    tf = ChartTf::IndexToTf(_tfi);
    Init();
  }

  /**
   * Class constructor with parameters.
   */
  IndicatorTf(TFP& _icparams, const IndicatorDataParams& _idparams) { Init(); }

  /**
   * Gets indicator's time-frame.
   */
  ENUM_TIMEFRAMES GetTf() override { return tf; }
};

#endif  // INDICATOR_TF_H
