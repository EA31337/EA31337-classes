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

// Parasms for dummy tick-based indicator.
struct IndicatorTickDummyParams : IndicatorParams {
  IndicatorTickDummyParams() : IndicatorParams(INDI_TICK, 3, TYPE_DOUBLE) {}
};

// Dummy tick-based indicator.
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

    EmitEntry(TickToEntry(1000, TickAB<double>(1.0f, 1.01f)));
    EmitEntry(TickToEntry(1500, TickAB<double>(1.5f, 1.51f)));
    EmitEntry(TickToEntry(2000, TickAB<double>(2.0f, 2.01f)));
    EmitEntry(TickToEntry(3000, TickAB<double>(3.0f, 3.01f)));
    EmitEntry(TickToEntry(4000, TickAB<double>(4.0f, 4.01f)));
    EmitEntry(TickToEntry(4100, TickAB<double>(4.1f, 4.11f)));
    EmitEntry(TickToEntry(4200, TickAB<double>(4.2f, 4.21f)));
    EmitEntry(TickToEntry(4800, TickAB<double>(4.8f, 4.81f)));
  };
};

// Params for dummy candle-based indicator.
struct IndicatorTfDummyParams : IndicatorTfParams {
  IndicatorTfDummyParams(uint _spc = 60) : IndicatorTfParams(_spc) {}
};

/**
 * Dummy candle-based indicator.
 */
class IndicatorTfDummy : public IndicatorTf<IndicatorTfDummyParams> {
 public:
  IndicatorTfDummy(uint _spc) : IndicatorTf(_spc) {}
  IndicatorTfDummy(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : IndicatorTf(_tf) {}
  IndicatorTfDummy(ENUM_TIMEFRAMES_INDEX _tfi = 0) : IndicatorTf(_tfi) {}

  string GetName() override { return "IndicatorTfDummy(" + IntegerToString(icparams.spc) + ")"; }

  void OnDataSourceEntry(IndicatorDataEntry& entry) override {
    // When overriding OnDataSourceEntry() we have to remember to call parent
    // method, because IndicatorCandle also need to invoke it in order to
    // create/update matching candle.
    IndicatorTf<IndicatorTfDummyParams>::OnDataSourceEntry(entry);

    Print(GetName(), " got new tick at ", entry.timestamp, ": ", entry.ToString<double>());
  }
};

/**
 * Implements OnInit().
 */
int OnInit() {
  Ref<IndicatorTickDummy> indi_tick = new IndicatorTickDummy(_Symbol);

  // 1-second candles.
  Ref<IndicatorTfDummy> indi_tf = new IndicatorTfDummy(1);

  // Candles will take data from tick indicator.
  indi_tf.Ptr().SetDataSource(indi_tick.Ptr());

  // Printing all grouped candles.
  Print(indi_tf.Ptr().GetName(), "'s candles:");
  Print(indi_tf.Ptr().CandlesToString());

  return (INIT_SUCCEEDED);
}
