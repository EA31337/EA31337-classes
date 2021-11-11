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
#include "IndicatorTf.struct.h"

/**
 * Class to deal with candle indicators.
 */
class IndicatorTf : public IndicatorCandle<IndicatorTfParams, double> {
 protected:
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
   * Class constructor.
   */
  IndicatorTf(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) { Init(); }

  /**
   * Class constructor.
   */
  IndicatorTf(ENUM_TIMEFRAMES_INDEX _tfi = 0) { Init(); }

  /**
   * Class constructor with parameters.
   */
  IndicatorTf(IndicatorTfParams &_params) : IndicatorCandle<IndicatorTfParams, double>(_params) { Init(); }
};

#endif
