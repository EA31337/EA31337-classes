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
 * Test functionality of IndicatorTf class.
 *
 * Idea is to check if ticks from IndicatorTick will be properly grouped by given timespan/timeframe.
 */

// Includes.
#include "../../Test.mqh"
#include "../IndicatorTf.h"
#include "../IndicatorTick.h"

// Structs.
struct IndicatorTickDummyParams : IndicatorParams {
  IndicatorTickDummyParams() : IndicatorParams(INDI_TICK, 3, TYPE_DOUBLE) {}
};

class IndicatorTickDummy : public IndicatorTick<IndicatorTickDummyParams, double> {
 public:
  IndicatorTickDummy(string _symbol, int _shift = 0, string _name = "")
      : IndicatorTick(INDI_TICK, _symbol, _shift, _name) {
    SetSymbol(_symbol);
  }

  string GetName() override { return "IndicatorTickDummy"; }

  void OnBecomeDataSourceFor(IndicatorBase* _base_indi) override {
    // Feeding base indicator with historic entries of this indicator.
    Print(GetName(), " became a data source for ", _base_indi.GetName());

    IndicatorDataEntry _entry;
    EmitEntry(_entry);
    EmitEntry(_entry);
    EmitEntry(_entry);
  };
};

// Structs.
struct IndicatorTfDummyParams : IndicatorTfParams {
  IndicatorTfDummyParams(uint _spc = 60) : IndicatorTfParams(_spc) {}
};

/**
 * Price Indicator.
 */
class IndicatorTfDummy : public IndicatorTf<IndicatorTfDummyParams> {
 public:
  IndicatorTfDummy(uint _spc) : IndicatorTf(_spc) {}
  IndicatorTfDummy(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : IndicatorTf(_tf) {}
  IndicatorTfDummy(ENUM_TIMEFRAMES_INDEX _tfi = 0) : IndicatorTf(_tfi) {}

  string GetName() override { return "IndicatorTfDummy(" + IntegerToString(icparams.spc) + ")"; }

  void OnDataSourceEntry(IndicatorDataEntry& entry) override { Print(GetName(), " got new entry!"); };
};

/**
 * Implements OnInit().
 */
int OnInit() {
  // @todo

  Ref<IndicatorTickDummy> indi_tick = new IndicatorTickDummy(_Symbol);

  // 1-second candles.
  Ref<IndicatorTfDummy> indi_tf = new IndicatorTfDummy(1);
  indi_tf.Ptr().SetDataSource(indi_tick.Ptr());

  return (INIT_SUCCEEDED);
}
