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

#ifndef __MQL__
  // Allows the preprocessor to include a header file when it is needed.
  #pragma once
#endif

// Includes.
#include "../Platform/Chart/Chart.struct.tf.h"
#include "IndicatorCandle.h"
#include "IndicatorTf.provider.h"

/**
 * Class to deal with candle indicators.
 */
template <typename TFP>
class IndicatorTf : public IndicatorCandle<TFP, double, ItemsHistoryTfCandleProvider<double>> {
 protected:
  /* Protected methods */

  /**
   * Initialize class.
   *
   * Called on constructor.
   */
  void Init() {
    THIS_ATTR history.SetItemProvider(
        new ItemsHistoryTfCandleProvider<double>(ChartTf::TfToSeconds(GetTf()), THIS_PTR));
  }

 public:
  /* Special methods */

  /**
   * Class constructor with timeframe enum.
   *
   * @todo
   */

  IndicatorTf(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    SetTf(_tf);
    Init();
  }

  /**
   * Class constructor with timeframe index.
   */
  IndicatorTf(ENUM_TIMEFRAMES_INDEX _tfi = (ENUM_TIMEFRAMES_INDEX)0) {
    SetTf(ChartTf::IndexToTf(_tfi));
    Init();
  }

  /**
   * Class constructor with parameters.
   */
  IndicatorTf(const TFP& _icparams, const IndicatorDataParams& _idparams) { Init(); }

  /**
   * Gets indicator's time-frame.
   */
  ENUM_TIMEFRAMES GetTf() override { return THIS_ATTR iparams.tf.GetTf(); }

  /**
   * Sets indicator's time-frame.
   */
  void SetTf(ENUM_TIMEFRAMES _tf) { THIS_ATTR iparams.tf.SetTf(_tf); }

  /**
   * Returns current tick index (incremented every OnTick()).
   */
  int GetTickIndex() override { return THIS_ATTR history.GetItemProvider() PTR_DEREF GetTickIndex(); }
};
