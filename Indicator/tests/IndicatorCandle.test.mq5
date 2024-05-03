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
 * Test functionality of IndicatorCandle class.
 */

// Includes.
#include "../../Platform.h"
#include "../../Test.mqh"
#include "../IndicatorCandle.h"

Ref<IndicatorData> indi_candle;

/**
 * Implements OnInit().
 */
int OnInit() {
  Platform::Init();
  Platform::Add(indi_candle = Platform::FetchDefaultCandleIndicator());
  return _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED;
}

void OnTick() {
  Platform::Tick();
  if (Platform::IsNewHour() && indi_candle REF_DEREF GetBarIndex() > 0) {
    // If a new hour occur, we check for a candle OHLCs, then we invalidate the
    // candle and try to regenerate it by checking again the OHLCs.
    BarOHLC _ohlc1 = indi_candle REF_DEREF GetOHLC();

    // Now we invalidate current candle (candle will be removed from the IndicatorCandle's cache).
    // @fixit @todo Fix candle invalidation.
    // indi_candle REF_DEREF InvalidateCandle(indi_candle REF_DEREF GetBarIndex());

    // Retrieving candle again.
    BarOHLC _ohlc2 = indi_candle REF_DEREF GetOHLC();
    assertEqualOrExit(
        _ohlc2.time, _ohlc1.time,
        "Difference between consecutive OHLC values after invalidating and then regenerating the candle!");
    assertEqualOrExit(
        _ohlc2.open, _ohlc1.open,
        "Difference between consecutive OHLC values after invalidating and then regenerating the candle!");
    assertEqualOrExit(
        _ohlc2.high, _ohlc1.high,
        "Difference between consecutive OHLC values after invalidating and then regenerating the candle!");
    assertEqualOrExit(
        _ohlc2.low, _ohlc1.low,
        "Difference between consecutive OHLC values after invalidating and then regenerating the candle!");
    assertEqualOrExit(
        _ohlc2.close, _ohlc1.close,
        "Difference between consecutive OHLC values after invalidating and then regenerating the candle!");
  }
}
