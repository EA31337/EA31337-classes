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

Ref<IndicatorData> indi_tick;
Ref<IndicatorData> indi_renko;

/**
 * Implements OnInit().
 */
int OnInit() {
  Platform::Init();
  // Platform ticks.
  indi_tick = Platform::FetchDefaultTickIndicator();

  // Renko with 10 pips limit.
  indi_renko = new IndicatorRenko(10);

  double _pip_value = SymbolInfoStatic::GetPipValue(_Symbol);
  Print("Pip Value: ", _pip_value);

  // Renko will be run over default tick indicator.
  indi_renko.Ptr().SetDataSource(indi_tick.Ptr());

  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {
  Platform::Tick();

#ifdef __debug__
  if (indi_renko.Ptr().IsNewBar()) {
    Print("New bar: ", indi_renko_real.Ptr().GetBarIndex());
  }

  string o = DoubleToStr(iOpen(_Symbol, PERIOD_CURRENT, 0), 5);
  string h = DoubleToStr(iHigh(_Symbol, PERIOD_CURRENT, 0), 5);
  string l = DoubleToStr(iLow(_Symbol, PERIOD_CURRENT, 0), 5);
  string c = DoubleToStr(iClose(_Symbol, PERIOD_CURRENT, 0), 5);
  string time = TimeToString(iTime(_Symbol, PERIOD_CURRENT, 0), TIME_DATE | TIME_MINUTES | TIME_SECONDS);

  Util::Print("Tick: " + IntegerToString((long)iTime(indi_renko.Ptr().GetSymbol(), indi_renko.Ptr().GetTf(), 0)) +
              " (" + time + "), real   = " + o + ", " + h + ", " + l + ", " + c);

  string c_o = DoubleToStr(indi_renko.Ptr().GetOpen(0), 5);
  string c_h = DoubleToStr(indi_renko.Ptr().GetHigh(0), 5);
  string c_l = DoubleToStr(indi_renko.Ptr().GetLow(0), 5);
  string c_c = DoubleToStr(indi_renko.Ptr().GetClose(0), 5);

  Util::Print("Tick: " + IntegerToString(indi_renko.Ptr().GetBarTime(0)) + " (" + time + "), candle = " + c_o + ", " +
              c_h + ", " + c_l + ", " + c_c);

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
