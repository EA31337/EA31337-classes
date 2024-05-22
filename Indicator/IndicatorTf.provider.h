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
#ifndef INDICATOR_TF_PROVIDER_H
#define INDICATOR_TF_PROVIDER_H

#ifndef __MQL__
  // Allows the preprocessor to include a header file when it is needed.
  #pragma once
#endif

/**
 * Candle grouping and regeneration for time-frame based candles.
 */
template <typename TV>
class ItemsHistoryTfCandleProvider : public ItemsHistoryCandleProvider<TV> {
  // Seconds per candle.
  int spc;

  // Pointer to IndicatorTick. Used to fetch data from IndicatorTick in the hierarchy.
  IndicatorData* indi;

  // Current tick index. Effectively a number of ticks generated by attached
  // IndicatorTick.
  int tick_index;

 public:
  /**
   * Constructor.
   */
  ItemsHistoryTfCandleProvider(int _spc, IndicatorData* _indi_tf) : spc(_spc), indi(_indi_tf), tick_index(0) {}

  /**
   * Called when new tick was emitted from IndicatorTick-based source.
   */
  virtual void OnTick(ItemsHistory<CandleOCTOHLC<TV>, ItemsHistoryTfCandleProvider<TV>>* _history, long _time_ms,
                      float _ask, float _bid) {
    ++tick_index;

    // Print("IndicatorTf's history: New tick: ", TimeToString(_time_ms / 1000, TIME_DATE | TIME_MINUTES |
    // TIME_SECONDS),
    //      ", ", _ask, ", ", _bid);

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

    if (_history PTR_DEREF TryGetItemByShift(0, _candle, false) && _candle.ContainsTimeMs(_time_ms)) {
      // Time given fits in the last added candle's time-frame, updating the candle with given price.
      _candle.Update(_time_ms, _bid);

      // Storing candle in the history.
      _history PTR_DEREF Update(_candle, _history PTR_DEREF GetShiftIndex(0));
    } else {
      CandleOCTOHLC<TV> _candle_tmp;

      // We don't want to regenerate history, because at the start there will bo no candle however.
      if (_history PTR_DEREF TryGetItemByShift(0, _candle_tmp, false)) {
        // Print("Completed candle: ", _candle_tmp.ToString());
        // Print("Real candle:      ", iOpen(NULL, Period(), 1), " ", iHigh(NULL, Period(), 1), " ",
        //       iLow(NULL, Period(), 1), " ", ChartStatic::iClose(NULL, (ENUM_TIMEFRAMES)Period(), 1));
        // Print("--");
      }

      // Either there is no candle at shift 0 or given time doesn't fit in the #0 candle's time-frame.
      _candle.Init(GetCandleTimeFromTimeMs(_time_ms, spc), spc, _time_ms, _bid);

      // Adding candle as the most recent item in the history. It will now become the candle at shift 0.
      _history PTR_DEREF Append(_candle);
    }
  }

  /**
   * Returns current tick index. Effectively a number of ticks generated by
   * attached IndicatorTick.
   */
  int GetTickIndex() { return tick_index; }

  /**
   * Returns start time of the candle (the place it's on the chart) for the given tick's time in milliseconds.
   */
  int GetCandleTimeFromTimeMs(long _time_ms, int _length_in_secs) {
    return (int)((_time_ms - _time_ms % ((long)_length_in_secs * 1000)) / 1000);
  }

  /**
   * Retrieves given number of items starting from the given microseconds or index (inclusive). "_dir" identifies if we
   * want previous or next items from selected starting point.
   */
  void GetItems(ItemsHistory<CandleOCTOHLC<TV>, ItemsHistoryTfCandleProvider<TV>>* _history, long _from_time_ms,
                ENUM_ITEMS_HISTORY_DIRECTION _dir, int _num_items, ARRAY_REF(CandleOCTOHLC<TV>, _out_arr)) {
    // Method is called if there is a missing item (candle) in the history. We need to regenerate it.
    if (_from_time_ms != 0) {
      // In order to (re)generate candle, we need to fetch ticks within a fixed time-frame and then update that candle
      // with all fetched ticks. For IndicatorTf, there is no difference between (re)generating backwards or forwards,
      // as candles are time-framed. The only problem is that there may be missing candles in fetched time-frames. We
      // just need to skip such time-frame and fetch ticks for next time-frame. In order to determine

      IndicatorData* _indi_tick = indi PTR_DEREF GetTick();

      // Ticks to form a candle.
      static ARRAY(TickTAB<TV>, _ticks);

      while (_num_items > 0) {
        // Calculating time from which and to which we want to retrieve ticks to form a candle.
        int _ticks_from_s = GetCandleTimeFromTimeMs(_from_time_ms, spc);
        long _ticks_from_ms = (long)_ticks_from_s * 1000;
        long _candle_length_ms = (long)spc * 1000;
        long _ticks_to_ms = _ticks_from_ms + _candle_length_ms - 1;

        // We will try to fetch history by two methods.
        // 1. By time range if IndicatorTick supports that way.
        if (!_indi_tick PTR_DEREF FetchHistoryByTimeRange(_ticks_from_ms, _ticks_to_ms, _ticks)) {
          // 2. By number of bars if IndicatorTick supports that way.
          // if (!_indi_tick PTR_DEREF FetchHistoryByIndexRange(_ticks_from_index, _ticks_to_ms, _ticks))) {
          // There is no more ticks in the history, giving up.
          break;
          //}
        }

        if (ArraySize(_ticks) > 0) {
          // Forming a candle.
          CandleOCTOHLC<TV> _candle;
          _candle.Init(_ticks_from_s, spc);
          for (int i = 0; i < ArraySize(_ticks); ++i) {
            _candle.Update(_ticks[i].time_ms, _ticks[i].bid);
          }

          // Adding candle to the output array.
          ArrayPushObject(_out_arr, _candle);
        }

        // Even if we don't form an item (a candle), we assume we've done one item.
        --_num_items;

        if (_dir == ITEMS_HISTORY_DIRECTION_FORWARD) {
          _from_time_ms += _candle_length_ms;
        } else {
          _from_time_ms -= _candle_length_ms;
        }
      }
    } else {
      Print("Error: GetItems() for IndicatorTf can only work with given _from_time_ms!");
      DebugBreak();
    }
  }

  /**
   * Returns information about item provider.
   */
  string ToString() override { return "IndicatorTf candle provider on " + indi PTR_DEREF GetFullName(); }
};

#endif  // INDICATOR_TF_PROVIDER_H
