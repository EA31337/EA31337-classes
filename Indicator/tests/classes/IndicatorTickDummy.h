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
#include "../../../Tick/Tick.struct.h"
#include "../../IndicatorTick.h"

// Params for dummy tick-based indicator.
struct IndicatorTickDummyParams : IndicatorParams {
  IndicatorTickDummyParams() : IndicatorParams(INDI_TICK) {}
};

// Dummy tick-based indicator.
class IndicatorTickDummy : public IndicatorTick<IndicatorTickDummyParams, double> {
 public:
  IndicatorTickDummy(string _symbol, int _shift = 0, string _name = "")
      : IndicatorTick(_symbol, INDI_TICK, _shift, _name) {}

  string GetName() override { return "IndicatorTickDummy"; }

  void OnBecomeDataSourceFor(IndicatorData* _base_indi) override {
    // Feeding base indicator with historic entries of this indicator.
    Print(GetName(), " became a data source for ", _base_indi.GetName());

    TickAB<double> _t1(1.0f, 1.01f);
    TickAB<double> _t2(1.5f, 1.51f);
    TickAB<double> _t3(2.0f, 2.01f);
    TickAB<double> _t4(3.0f, 3.01f);
    TickAB<double> _t5(4.0f, 4.01f);
    TickAB<double> _t6(4.1f, 4.11f);
    TickAB<double> _t7(4.2f, 4.21f);
    TickAB<double> _t8(4.8f, 4.81f);

    EmitEntry(TickToEntry(1000, _t1));
    EmitEntry(TickToEntry(1500, _t2));
    EmitEntry(TickToEntry(2000, _t3));
    EmitEntry(TickToEntry(3000, _t4));
    EmitEntry(TickToEntry(4000, _t5));
    EmitEntry(TickToEntry(4100, _t6));
    EmitEntry(TickToEntry(4200, _t7));
    EmitEntry(TickToEntry(4800, _t8));
  };
};
