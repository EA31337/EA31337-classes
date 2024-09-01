//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of ItemsHistory class.
 */

// Defines
#define INDI_CANDLE_HISTORY_SIZE 4

// Includes
#include "../../Platform/Platform.h"
#include "../../Test.mqh"
#include "../ItemsHistory.h"

// Candles buffer.
ARRAY(BarOHLC, _ohlcs);

/**
 * Implements OnInit().
 */
int OnInit() {
  Platform::Init();

  return (GetLastError() > 0 ? INIT_FAILED : INIT_SUCCEEDED);
};

/**
 * Implements OnTick().
 */
void OnTick() {
  Platform::Tick();

  IndicatorData* _candles = Platform::FetchDefaultCandleIndicator(_Symbol, PERIOD_CURRENT);

  if (_candles PTR_DEREF IsNewBar()) {
    BarOHLC _ohlc = _candles PTR_DEREF GetOHLC(0);
    ArrayPushObject(_ohlcs, _ohlc);

    Print(_ohlc.ToCSV());

    if (_candles PTR_DEREF GetBarIndex() == 1) {
      // Updating first candle to be sure it was formed by all possible ticks.
      _ohlcs[0] = _candles PTR_DEREF GetOHLC(1);
    }

    if (_candles PTR_DEREF GetBarIndex() == INDI_CANDLE_HISTORY_SIZE) {
      // Now first candle should be forgotten by candle history. We'll check if candle regeneration works.
      Print("First candle was:      ", _ohlcs[0].ToCSV());

      BarOHLC _ohlc_regenerated = _candles PTR_DEREF GetOHLC(INDI_CANDLE_HISTORY_SIZE);
      Print("Regenerated candle is: ", _ohlc_regenerated.ToCSV());

      if (_ohlcs[0] != _ohlc_regenerated) {
        Print("Error: Candle regeneration resulted in OHLC/time difference!");
        Print("Expected: ", _ohlcs[0].ToCSV());
        Print("Got:      ", _ohlc_regenerated.ToCSV());
        ExpertRemove();
      }
    }
  }
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {}
