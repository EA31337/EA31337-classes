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
 * Candle grouping and regenerationf for time-frame based candles.
 */
template <typename TV>
class ItemsHistoryTfCandleProvider : public ItemsHistoryCandleProvider<TV> {
 public:
  /**
   * Called when new tick was emitted from IndicatorTick-based source.
   */
  virtual void OnTick(long _timestamp_ms, float _ask, float _bid) {
    // @todo Check if tick is outside current candle and if yes, close the candle,
    // mark as completed and open new candle.
  }
};

/**
 * Class to deal with candle indicators.
 */
template <typename TFP>
class IndicatorTf : public IndicatorCandle<TFP, double> {
 protected:
  // Time-frame used to create candles.
  ENUM_TIMEFRAMES tf;

  /* Protected methods */

  /**
   * Initialize class.
   *
   * Called on constructor.
   */
  void Init() {}

 public:
  /* Special methods */

  /**
   * Class constructor with timeframe enum.
   */
  IndicatorTf(unsigned int _spc) : IndicatorCandle<TFP, double>(new ItemsHistoryTfCandleProvider<double>()) {
    iparams.SetSecsPerCandle(_spc);
    Init();
  }

  /**
   * Class constructor with timeframe enum.
   */
  IndicatorTf(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
      : IndicatorCandle<TFP, double>(new ItemsHistoryTfCandleProvider<double>()) {
    iparams.SetSecsPerCandle(ChartTf::TfToSeconds(_tf));
    tf = _tf;
    Init();
  }

  /**
   * Class constructor with timeframe index.
   */
  IndicatorTf(ENUM_TIMEFRAMES_INDEX _tfi = 0)
      : IndicatorCandle<TFP, double>(new ItemsHistoryTfCandleProvider<double>()) {
    iparams.SetSecsPerCandle(ChartTf::TfToSeconds(ChartTf::IndexToTf(_tfi)));
    tf = ChartTf::IndexToTf(_tfi);
    Init();
  }

  /**
   * Class constructor with parameters.
   */
  IndicatorTf(TFP& _icparams, const IndicatorDataParams& _idparams)
      : IndicatorCandle<TFP, double>(_icparams, _idparams, new ItemsHistoryTfCandleProvider<double>()) {
    Init();
  }

  /**
   * Gets indicator's time-frame.
   */
  ENUM_TIMEFRAMES GetTf() override { return tf; }
};

#endif  // INDICATOR_TF_H
