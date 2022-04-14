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
  IndicatorTf(TFP &_params) : IndicatorCandle<TFP, double>(_params) { Init(); }

  /**
   * Returns time of the bar for a given shift (MT-compatible shift).
   */
  datetime GetBarTimeLegacy(int _shift = 0) {
    datetime _curr = ::iTime(GetSymbol(), GetTf(), 0);

    while (_curr >= icdata.GetMin()) {
      if (icdata.KeyExists(_curr)) {
        if (_shift-- == 0) {
          return _curr;
        }
      } else {
        // Going back in time by TF.
        _curr -= ChartTf::TfToSeconds(tf);
      }
    }

    // No entry found. Returning last valid candle.
    if (icdata.KeyExists(_curr)) {
      return _curr;
    } else {
      // Not a single valid candle found.
      return 0;
    }
  }

  /* Virtual methods */

  /**
   * Returns time of the bar for a given shift.
   */
  datetime GetBarTime(int _shift = 0) override {
    // @fixit Should be replaced by MT-compatible bar time calculation for the given shift.
    return GetBarTimeLegacy(_shift);
  }

  /**
   * Gets indicator's time-frame.
   */
  ENUM_TIMEFRAMES GetTf() override { return tf; }
};

#endif
