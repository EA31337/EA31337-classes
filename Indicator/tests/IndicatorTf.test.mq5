//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
Ref<IndicatorTfDummy> indi_tf_orig_sim;
Ref<Indi_AMA> indi_ama;
Ref<Indi_AMA> indi_ama_orig;
Ref<Indi_AMA> indi_ama_orig_sim;

/**
 * Implements OnInit().
 */
int OnInit() {
  indicators.Add(indi_tick = new IndicatorTickReal(PERIOD_CURRENT));

  // 1-second candles.
  // indicators.Add(indi_tf = new IndicatorTfDummy(1));

  // 1:1 candles from platform using current timeframe.
  indicators.Add(indi_tf_orig_sim = new IndicatorTfDummy(ChartTf::TfToSeconds(PERIOD_CURRENT)));

  // 1-second candles.
  // indicators.Add(indi_ama = new Indi_AMA());

  IndiAMAParams _ama_params;
  _ama_params.applied_price = PRICE_OPEN;

  // AMA on platform candles.
  indicators.Add(indi_ama_orig_sim = new Indi_AMA(_ama_params));

  // Original built-in or OnCalculate()-based AMA indicator on platform OHLCs.
  indicators.Add(indi_ama_orig = new Indi_AMA(_ama_params));

  // Candles will be initialized from tick's history.
  // indi_tf.Ptr().SetDataSource(indi_tick.Ptr());
  indi_tf_orig_sim.Ptr().SetDataSource(indi_tick.Ptr());

  // AMA will work on the candle indicator.
  // indi_ama.Ptr().SetDataSource(indi_tf.Ptr());

  // AMA will work on the simulation of real candles.
  indi_ama_orig_sim.Ptr().SetDataSource(indi_tf_orig_sim.Ptr());

  // Checking if there are candles for last 100 ticks.
  // Print(indi_tf.Ptr().GetName(), "'s historic candles (from 100 ticks):");
  // Print(indi_tf.Ptr().CandlesToString());
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {
  string o = DoubleToStr(iOpen(_Symbol, PERIOD_CURRENT, 0), 5);
  string h = DoubleToStr(iHigh(_Symbol, PERIOD_CURRENT, 0), 5);
  string l = DoubleToStr(iLow(_Symbol, PERIOD_CURRENT, 0), 5);
  string c = DoubleToStr(iClose(_Symbol, PERIOD_CURRENT, 0), 5);
  string time = TimeToString(iTime(_Symbol, PERIOD_CURRENT, 0));

  Util::Print("Tick: " + IntegerToString((long)iTime(_Symbol, PERIOD_CURRENT, 0)) + " (" + time + "), real = " + o +
              ", " + h + ", " + l + ", " + c);

  indicators.Tick();

  Util::Print(indicators.ToString(0));
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  // Printing all grouped candles.
  Print(indi_tf_orig_sim.Ptr().GetName(), "'s all candles:");
  Print(indi_tf_orig_sim.Ptr().CandlesToString());
}
