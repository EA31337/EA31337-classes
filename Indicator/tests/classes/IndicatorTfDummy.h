//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * Dummy candle-based indicator.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../../../Platform.define.h"
#include "../../IndicatorTf.h"
#include "../../IndicatorTf.struct.h"

// Params for dummy candle-based indicator.
struct IndicatorTfDummyParams : IndicatorTfParams {
  IndicatorTfDummyParams(ENUM_TIMEFRAMES _tf = PLATFORM_WRONG_TIMEFRAME) : IndicatorTfParams("IndicatorTf", _tf) {}
};

/**
 * Dummy candle-based indicator.
 */
class IndicatorTfDummy : public IndicatorTf<IndicatorTfDummyParams> {
 public:
  /*
    @todo

    IndicatorTfDummy(unsigned int _spc) : IndicatorTf(_spc) {}
  */

  IndicatorTfDummy(ENUM_TIMEFRAMES _tf) : IndicatorTf(IndicatorTfDummyParams(_tf), IndicatorDataParams()) {}
  IndicatorTfDummy(ENUM_TIMEFRAMES_INDEX _tfi)
      : IndicatorTf(IndicatorTfDummyParams(ChartTf::IndexToTf(_tfi)), IndicatorDataParams()) {}

  string GetName() override { return "IndicatorTfDummy(" + iparams.tf.GetString() + ")"; }

  void OnDataSourceEntry(IndicatorDataEntry& entry) override {
    // When overriding OnDataSourceEntry() we have to remember to call parent
    // method, because IndicatorCandle also need to invoke it in order to
    // create/update matching candle.
    IndicatorTf<IndicatorTfDummyParams>::OnDataSourceEntry(entry);

#ifdef __debug_indicator__
    Print(GetFullName(), " got new tick at ", entry.timestamp,
          " (" + TimeToString(entry.timestamp) + "): ", entry.ToString<double>());
#endif
  }
};
