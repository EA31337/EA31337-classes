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
#include "../../Util.h"
#include "../IndicatorTf.h"
#include "../IndicatorTick.h"

// Params for real tick-based indicator.
struct IndicatorTickRealParams : IndicatorParams {
  IndicatorTickRealParams() : IndicatorParams(INDI_TICK, 3, TYPE_DOUBLE) {}
};

// Real tick-based indicator.
class IndicatorTickReal : public IndicatorTick<IndicatorTickRealParams, double> {
 public:
  IndicatorTickReal(string _symbol, int _shift = 0, string _name = "")
      : IndicatorTick(INDI_TICK, _symbol, _shift, _name) {
    SetSymbol(_symbol);
  }

  string GetName() override { return "IndicatorTickDummy"; }

  void OnBecomeDataSourceFor(IndicatorBase* _base_indi) override {
    // Feeding base indicator with historic entries of this indicator.
    Print(GetName(), " became a data source for ", _base_indi.GetName());

    int _ticks_to_emit = 100;

    // For testing purposes we are emitting 100 last ticks.
    for (int i = 0; i < MathMin(Bars(GetSymbol(), GetTf()), _ticks_to_emit); ++i) {
      long _timestamp = ChartStatic::iTime(GetSymbol(), GetTf(), _ticks_to_emit - i - 1);
      double _bid = ChartStatic::iClose(GetSymbol(), GetTf(), _ticks_to_emit - i - 1);
      EmitEntry(TickToEntry(_timestamp, TickAB<double>(0.0f, _bid)));
    }
  };

  void OnTick() override {
    long _timestamp = ChartStatic::iTime(GetSymbol(), GetTf());
    double _bid = ChartStatic::iClose(GetSymbol(), GetTf());
    // MT doesn't provide historical ask prices, so we're filling tick with bid price only.
    EmitEntry(TickToEntry(_timestamp, TickAB<double>(_bid, _bid)));
  }
};

// Params for dummy tick-based indicator.
struct IndicatorTickDummyParams : IndicatorParams {
  IndicatorTickDummyParams() : IndicatorParams(INDI_TICK, 2, TYPE_DOUBLE) {}
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
 * Helper class to store all indicators and call OnTick() on them.
 */
class _Indicators {
  Ref<IndicatorBase> _indis[];

 public:
  void Add(IndicatorBase* _indi) {
    Ref<IndicatorBase> _ref = _indi;
    ArrayPushObject(_indis, _ref);
  }

  void Remove(IndicatorBase* _indi) {
    Ref<IndicatorBase> _ref = _indi;
    Util::ArrayRemoveFirst(_indis, _ref);
  }

  void Tick() {
    for (int i = 0; i < ArraySize(_indis); ++i) {
      _indis[i].Ptr().OnTick();
    }
  }

} indicators;

Ref<IndicatorTickReal> indi_tick;
Ref<IndicatorTfDummy> indi_tf;

/**
 * Implements OnInit().
 */
int OnInit() {
  indicators.Add(indi_tick = new IndicatorTickReal(_Symbol));

  // 1-second candles.
  indicators.Add(indi_tf = new IndicatorTfDummy(1));

  // Candles will be initialized from tick's history.
  indi_tf.Ptr().SetDataSource(indi_tick.Ptr());

  // Checking if there are candles for last 100 ticks.
  Print(indi_tf.Ptr().GetName(), "'s historic candles (from 100 ticks):");
  Print(indi_tf.Ptr().CandlesToString());
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() { indicators.Tick(); }

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  // Printing all grouped candles.
  Print(indi_tf.Ptr().GetName(), "'s all candles:");
  Print(indi_tf.Ptr().CandlesToString());
}
