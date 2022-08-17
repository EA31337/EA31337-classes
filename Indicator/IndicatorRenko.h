//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
 * An abstract class to implement Renko indicators.
 */

// Ignore processing of this file if already included.
#ifndef INDICATOR_RENKO_H
#define INDICATOR_RENKO_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Chart.struct.tf.h"
#include "IndicatorCandle.h"
#include "IndicatorRenko.struct.h"

/**
 * Renko indicator parameters.
 */
struct RenkoParams : IndicatorTfParams {
  int pips_limit;

  RenkoParams(int _pips_limit = 10, int _shift = 0) : IndicatorTfParams("Renko") {
    pips_limit = _pips_limit;
    shift = _shift;
  };
  RenkoParams(RenkoParams &_params) : IndicatorTfParams("Renko") { THIS_REF = _params; };

  // Getters.
  unsigned int GetSecsPerCandle() {
    // Renko doesn't use timeframe-based candles.
    return 0;
  }
};

/**
 * Renko candles.
 *
 * Note that Renko acts as a Candle indicator and thus has the same number of
 * modes and same list of ValueStorage buffers as IndicatorCandle one.
 */
class IndicatorRenko : public IndicatorCandle<RenkoParams, double> {
 protected:
  // @todo Time-frame used to create candles.
  ENUM_TIMEFRAMES tf;

  long last_entry_ts;
  long last_completed_candle_ts;
  long last_incomplete_candle_ts;

  /* Protected methods */

  /**
   * Initialize class.
   *
   * Called on constructor.
   */
  void Init() {
    last_entry_ts = 0;
    last_completed_candle_ts = 0;
    last_incomplete_candle_ts = 0;
  }

 public:
  /* Special methods */

  /**
   * Class constructor with timeframe enum.
   */
  IndicatorRenko(int _pips_limit = 10) {
    iparams.pips_limit = _pips_limit;
    Init();
  }

  /**
   * Class constructor with parameters.
   */
  IndicatorRenko(RenkoParams &_params)
      : IndicatorCandle<RenkoParams, double>(_params, IndicatorDataParams(FINAL_INDI_CANDLE_MODE_ENTRY)) {
    Init();
  }

  /**
   * Checks for pips limit.
   */
  bool RenkoConditionMet(CandleOCTOHLC<double> &_candle, double _price) {
    double _price_diff_limit = GetSymbolProps().GetPipValue() * iparams.pips_limit;
    double _price_diff = MathAbs(_price - _candle.open);
    return _price_diff >= _price_diff_limit;
  }

  /**
   * Called when data source emits new entry (historic or future one).
   */
  void OnDataSourceEntry(IndicatorDataEntry &entry) override {
    if (entry.timestamp < last_entry_ts) {
      Print("Error: IndicatorRenko doesn't support sending entries in non-ascending order!");
      DebugBreak();
    }

    // We'll be updating candle from bid price.
    double _price = entry[1];

    CandleOCTOHLC<double> _candle;

    if (last_incomplete_candle_ts != 0) {
      // There is previous candle. Retrieving and updating it.
      _candle = icdata.GetByKey(last_incomplete_candle_ts);
      _candle.Update(entry.timestamp, _price);

      // Checking for close price difference.
      if (RenkoConditionMet(_candle, _price)) {
        // Closing current candle.
        _candle.is_complete = true;
      }

      // Updating candle.
      icdata.Add(_candle, last_incomplete_candle_ts);

      if (_candle.is_complete) {
        last_completed_candle_ts = last_incomplete_candle_ts;
        last_incomplete_candle_ts = 0;
      }
    } else {
      // There is no incomplete candle, creating one.
      _candle = CandleOCTOHLC<double>(_price, _price, _price, _price, entry.timestamp, entry.timestamp);
      _candle.is_complete = false;

      // Creating new candle.
      icdata.Add(_candle, entry.timestamp);

      last_incomplete_candle_ts = entry.timestamp;
    }

    // Updating tick & bar indices. Bar time is time of the last completed candle.
    // Print(last_completed_candle_ts);
    counter.OnTick(last_completed_candle_ts);

    last_entry_ts = entry.timestamp;
  };

  /**
   * Gets indicator's time-frame.
   */
  ENUM_TIMEFRAMES GetTf() override { return tf; }

  /**
   * Returns time of the bar for a given shift.
   *
   * Note: For Renko it returns last completed bar.
   */
  datetime GetBarTime(int _shift = 0) override {
    if (_shift != 0) {
      Print("Error: IndicatorRenko doesn't yet support shift other than 0!");
      DebugBreak();
      return 0;
    }

    return (datetime)last_completed_candle_ts;
  }
};

#endif
