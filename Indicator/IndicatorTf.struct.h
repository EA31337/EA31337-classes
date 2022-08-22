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

/**
 * @file
 * Includes IndicatorTf's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Indicator.struct.h"

/* Structure for IndicatorTf class parameters. */
struct IndicatorTfParams : IndicatorParams {
  ChartTf tf;
  unsigned int spc;  // Seconds per candle.
  // Struct constructor.
  IndicatorTfParams(unsigned int _spc = 60) : spc(_spc) {}
  // Getters.
  unsigned int GetSecsPerCandle() { return spc; }
  // Setters.
  void SetSecsPerCandle(unsigned int _spc) { spc = _spc; }
  // Copy constructor.
  IndicatorTfParams(const IndicatorTfParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    THIS_REF = _params;
    if (_tf != PERIOD_CURRENT) {
      tf.SetTf(_tf);
    }
  }
};
