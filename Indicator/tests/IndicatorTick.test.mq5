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
 * Test functionality of IndicatorTick class.
 */

// Includes.
#include "../../Test.mqh"
#include "../IndicatorTick.h"

// Structs.
struct IndicatorTickDummyParams : IndicatorParams {
  IndicatorTickDummyParams() : IndicatorParams(INDI_TICK, 3, TYPE_DOUBLE) {}
};

/**
 * Tick indicator is an indicator that provides per-tick information.
 * When asked to return data via GetEntry() it could fetch data from pre-made
 * tick history or generate tick on-the-fly from remote source and save it in
 * the history.
 *
 * Note that indicators could provide data also for future shifts, so shift=-10
 * is perfectly valid for them when doing GetEntry()/GetValue().
 *
 * Tick indicator may become a data source for Candle indicator. In this
 * scenario, when trying to fetch candle for a given shift, tick indicator is
 * asked for ticks in a given timespan. E.g., Candle indicator may work in a 5s
 * timespans, so when fetching candle with shift now+1, Tick indicator will be
 * asked for ticks between now+5s and now+10s.
 *rmf
 * In order to fetch consecutive candles, you have to call
 * IndicatorCandle::NextMaybe() to check whether new candle is ready to be
 * processed. If yes, then new candle will be at index 0.
 *
 * if (indi_candle.NextMaybe()) {
 *   double _open  = indi_candle.Open(0);  // Shift 0 = current candle.
 *   double _close = indi_candle.Close(0); // Shift 0 = current candle.
 * }
 */
class IndicatorTickDummy : public IndicatorTick<IndicatorTickDummyParams, double> {
 public:
  IndicatorTickDummy(string _symbol, int _shift = 0, string _name = "")
      : IndicatorTick(INDI_TICK, _symbol, _shift, _name) {
    SetSymbol(_symbol);
  }
};

/**
 * Implements OnInit().
 */
int OnInit() {
  IndicatorTickDummy _indi_tick(_Symbol);
  long _time = 1;
  for (double _price = 0.1; _price <= 2.0; _price += 0.1) {
    MqlTick _tick;
    _tick.time = (datetime)_time++;
    _tick.ask = _price;
    _tick.bid = _price;
    _indi_tick.SetTick(_tick, _tick.time);
  }
  // Print(_indi_tick.ToString());
  return (INIT_SUCCEEDED);
}
