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
#include "../../Indicators/Indi_AMA.mqh"
#include "../../Test.mqh"
#include "../../Util.h"
#include "../IndicatorTf.h"
#include "../IndicatorTick.h"
#include "classes/IndicatorTfDummy.h"
#include "classes/IndicatorTickReal.h"
#include "classes/Indicators.h"

Indicators indicators;
Ref<IndicatorTickReal> indi_tick;
Ref<IndicatorTfDummy> indi_tf;
Ref<Indi_AMA> indi_ama;

/**
 * Implements OnInit().
 */
int OnInit() {
  indicators.Add(indi_tick = new IndicatorTickReal(_Symbol));

  // 1-second candles.
  indicators.Add(indi_tf = new IndicatorTfDummy(1));

  // 1-second candles.
  indicators.Add(indi_ama = new Indi_AMA());

  // Candles will be initialized from tick's history.
  indi_tf.Ptr().SetDataSource(indi_tick.Ptr());

  // AMA will work on the candle indicator.
  indi_ama.Ptr().SetDataSource(indi_tf.Ptr());

  // Checking if there are candles for last 100 ticks.
  Print(indi_tf.Ptr().GetName(), "'s historic candles (from 100 ticks):");
  Print(indi_tf.Ptr().CandlesToString());
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {
  indicators.Tick();
  Print("Tick: \n" + indicators.ToString(0));
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  // Printing all grouped candles.
  Print(indi_tf.Ptr().GetName(), "'s all candles:");
  Print(indi_tf.Ptr().CandlesToString());
}
