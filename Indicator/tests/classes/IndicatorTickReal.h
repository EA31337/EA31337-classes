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
 * Real tick-based indicator.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

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
      TickAB<double> _tick(0.0f, _bid);
      EmitEntry(TickToEntry(_timestamp, _tick));
    }
  };

  void OnTick() override {
    long _timestamp = ChartStatic::iTime(GetSymbol(), GetTf());
    double _bid = ChartStatic::iClose(GetSymbol(), GetTf());
    // MT doesn't provide historical ask prices, so we're filling tick with bid price only.
    TickAB<double> _tick(_bid, _bid);
    EmitEntry(TickToEntry(_timestamp, _tick));
  }
};
