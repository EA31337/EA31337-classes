//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Tf-based candle indicator for MT.
 */

#ifndef __MQL__
  // Allows the preprocessor to include a header file when it is needed.
  #pragma once
#endif

// Includes.
#include "../../Indicator/IndicatorCandle.h"
#include "Indi_TfMt.provider.h"

// Params for MT Tf-based candle indicator.
struct Indi_TfMtParams : IndicatorTfParams {
  Indi_TfMtParams(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : IndicatorTfParams("IndicatorTf", _tf) {}
};

/**
 * Tf-based candle indicator for MT.
 */
class Indi_TfMt : public IndicatorCandle<Indi_TfMtParams, double, ItemsHistoryTfMtCandleProvider<double>> {
 protected:
  // Time-frame used to create candles.
  ENUM_TIMEFRAMES tf;

  /* Protected methods */

  /**
   * Initialize class.
   *
   * Called on constructor.
   */
  void Init() { history.SetItemProvider(new ItemsHistoryTfMtCandleProvider<double>(THIS_PTR)); }

 public:
  /* Special methods */

  /**
   * Class constructor with timeframe enum.
   */
  Indi_TfMt(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    tf = _tf;
    Init();
  }

  /**
   * Class constructor with timeframe index.
   */
  Indi_TfMt(ENUM_TIMEFRAMES_INDEX _tfi = 0) {
    tf = ChartTf::IndexToTf(_tfi);
    Init();
  }

  /**
   * Class constructor with parameters.
   */
  Indi_TfMt(Indi_TfMtParams& _icparams, const IndicatorDataParams& _idparams) { Init(); }

  /**
   * Gets indicator's time-frame.
   */
  ENUM_TIMEFRAMES GetTf() override { return tf; }

  /**
   * Returns current tick index (incremented every OnTick()).
   */
  int GetTickIndex() override { return history.GetItemProvider() PTR_DEREF GetTickIndex(); }

  /**
   * Returns the number of bars on the chart decremented by iparams.shift.
   */
  int GetBars() override {
    // Will return number of bars prepended and appended to the history,
    // even if those bars were cleaned up because of history's candle limit.
    return ::Bars(GetSymbol(), GetTf()) - iparams.shift;
  }
};
