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
        new ItemsHistoryTfCandleProvider<double>(THIS_ATTR iparams.GetSecsPerCandle(), THIS_PTR));
  }

 public:
  /* Special methods */

  /**
   * Class constructor with timeframe enum.
   *
   * @todo
   */
  /*
  IndicatorTf(unsigned int _spc) {
    THIS_ATTR iparams.SetSecsPerCandle(_spc);
    Init();
  }
  */

  /**
   * Class constructor with parameters.
   */
  IndicatorTf(const TFP& _icparams, const IndicatorDataParams& _idparams)
      : IndicatorCandle<TFP, double, ItemsHistoryTfCandleProvider<double>>(_icparams, _idparams) {
    Init();
  }

  /**
   * Gets indicator's time-frame.
   */
  ENUM_TIMEFRAMES GetTf() override { return THIS_ATTR iparams.tf.GetTf(); }

  /**
   * Returns current tick index (incremented every OnTick()).
   */
  int GetTickIndex() override { return THIS_ATTR history.GetItemProvider() PTR_DEREF GetTickIndex(); }
};

#endif  // INDICATOR_TF_H
