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
 * Test functionality of IndicatorRenko class.
 *
 * Idea is to check if ticks from IndicatorTick will be properly grouped by given timespan/timeframe.
 */

// Includes.
#include "../../Indicators/Indi_AMA.mqh"
#include "../../Indicators/Tick/Indi_TickMt.mqh"
#include "../../Platform.h"
#include "../../Test.mqh"
#include "../../Util.h"
#include "../IndicatorRenko.h"
#include "../IndicatorTick.h"
#include "classes/Indicators.h"

Ref<Indi_TickMt> indi_tick;
Ref<Indi_AMA> indi_ama;
Ref<Indi_AMA> indi_ama_orig;
Ref<Indi_AMA> indi_ama_orig_sim;
Ref<Indi_AMA> indi_ama_oncalculate;
Ref<Indi_AMA> indi_ama_custom;

/**
 * Implements OnInit().
 */
int OnInit() {
  Platform::Init();
  // Platform ticks.
  indi_tick = Platform::FetchDefaultTickIndicator();

  // @todo: E.g. 1 pip candles, 10 pip candles

  // float _pip_value = SymbolInfoStatic::GetPipValue(_Symbol);

  /*
  // 1-second candles.
  // indicators.Add(indi_tf = new IndicatorRenkoDummy(1));

  // 1:1 candles from platform using current timeframe.
  indi_renko_real = Platform::FetchDefaultCandleIndicator();

  // 1-second candles.
  // indicators.Add(indi_ama = new Indi_AMA());

  IndiAMAParams _ama_params;
  _ama_params.applied_price = PRICE_OPEN;

  // AMA on platform candles.
  Platform::Add(indi_ama_orig_sim = new Indi_AMA(_ama_params));

  // Original built-in AMA indicator on platform OHLCs.
  _ama_params.SetDataSourceType(IDATA_BUILTIN);
  Platform::Add(indi_ama_orig = new Indi_AMA(_ama_params));
  indi_ama_orig.Ptr().SetDataSource(indi_renko_real.Ptr());

  // OnCalculate()-based version of AMA indicator on platform OHLCs.
  _ama_params.SetDataSourceType(IDATA_ONCALCULATE);
  Platform::Add(indi_ama_oncalculate = new Indi_AMA(_ama_params));
  indi_ama_oncalculate.Ptr().SetDataSource(indi_renko_real.Ptr());

  // iCustom()-based version of AMA indicator on platform OHLCs.
  _ama_params.SetDataSourceType(IDATA_ICUSTOM);
  Platform::Add(indi_ama_custom = new Indi_AMA(_ama_params));
  indi_ama_custom.Ptr().SetDataSource(indi_renko_real.Ptr());

  // Candles will be initialized from tick's history.
  // indi_tf.Ptr().SetDataSource(indi_tick.Ptr());
  indi_renko_real.Ptr().SetDataSource(indi_tick.Ptr());

  // AMA will work on the candle indicator.
  // indi_ama.Ptr().SetDataSource(indi_tf.Ptr());

  // AMA will work on the simulation of real candles.
  indi_ama_orig_sim.Ptr().SetDataSource(indi_renko_real.Ptr());
  */

  // Checking if there are candles for last 100 ticks.
  // Print(indi_tf.Ptr().GetName(), "'s historic candles (from 100 ticks):");
  // Print(indi_tf.Ptr().CandlesToString());
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {
  Platform::Tick();

#ifdef __debug__
  if (indi_renko_real.Ptr().IsNewBar()) {
    Print("New bar: ", indi_renko_real.Ptr().GetBarIndex());
  }

  string o = DoubleToStr(iOpen(_Symbol, PERIOD_CURRENT, 0), 5);
  string h = DoubleToStr(iHigh(_Symbol, PERIOD_CURRENT, 0), 5);
  string l = DoubleToStr(iLow(_Symbol, PERIOD_CURRENT, 0), 5);
  string c = DoubleToStr(iClose(_Symbol, PERIOD_CURRENT, 0), 5);
  string time = TimeToString(iTime(_Symbol, PERIOD_CURRENT, 0), TIME_DATE | TIME_MINUTES | TIME_SECONDS);

  Util::Print(
      "Tick: " + IntegerToString((long)iTime(indi_renko_real.Ptr().GetSymbol(), indi_renko_real.Ptr().GetTf(), 0)) +
      " (" + time + "), real   = " + o + ", " + h + ", " + l + ", " + c);

  string c_o = DoubleToStr(indi_renko_real.Ptr().GetOpen(0), 5);
  string c_h = DoubleToStr(indi_renko_real.Ptr().GetHigh(0), 5);
  string c_l = DoubleToStr(indi_renko_real.Ptr().GetLow(0), 5);
  string c_c = DoubleToStr(indi_renko_real.Ptr().GetClose(0), 5);

  Util::Print("Tick: " + IntegerToString(indi_renko_real.Ptr().GetBarTime(0)) + " (" + time + "), candle = " + c_o +
              ", " + c_h + ", " + c_l + ", " + c_c);

  Util::Print(Platform::IndicatorsToString(0));
#endif
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  // Printing all grouped candles.
  // Print(indi_renko_real.Ptr().GetName(), "'s all candles:");
  // Print(indi_renko_real.Ptr().CandlesToString());
}
