//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
 * Test functionality of DrawIndicator class.
 */

#define __debug__
#define __debug_verbose__

// Includes.
#include "../DictStruct.mqh"
#include "../DrawIndicator.mqh"
#include "../Indicator/Indicator.struct.serialize.h"
#include "../Indicators/Indi_Bands.mqh"
#include "../Indicators/Indi_Demo.mqh"
#include "../Indicators/Indi_MA.mqh"
#include "../Indicators/Indi_RSI.mqh"
#include "../Indicators/Price/Indi_Price.mqh"
#include "../Test.mqh"

// Global variables.
Ref<IndicatorData> candles;
int bar_processed;

/**
 * Implements Init event handler.
 */
int OnInit() {
  Platform::Init();
  candles = Platform::FetchDefaultCandleIndicator();
  bool _result = true;
  // Initialize indicators.
  _result &= InitIndicators();
  Print("Indicators to test: ", Platform::GetIndicators().Size());
  // Check for any errors.
  assertTrueOrFail(GetLastError() == ERR_NO_ERROR, StringFormat("Error: %d", GetLastError()));
  bar_processed = 0;
  return (_result && _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
  Platform::Tick();

  if (candles REF_DEREF IsNewBar()) {
    bar_processed++;

    for (DictIterator<long, Ref<IndicatorData>> iter = Platform::GetIndicators() PTR_DEREF Begin(); iter.IsValid();
         ++iter) {
      IndicatorData *_indi = iter.Value().Ptr();
      _indi.OnTick();
      IndicatorDataEntry _entry = _indi.GetEntry();
      if (_indi.Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY)) && _entry.IsValid()) {
        PrintFormat("%s: bar %d: %s", _indi.GetName(), bar_processed, _indi.ToString());
      }
    }
  }
}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {}

/**
 * Initialize indicators.
 */
bool InitIndicators() {
  /* Standard indicators */

  // Bollinger Bands.
  IndiBandsParams bands_params(20, 2, 0, PRICE_MEDIAN);
  Platform::AddWithDefaultBindings(new Indi_Bands(bands_params));

  // Moving Average.
  IndiMAParams ma_params(13, 10, MODE_SMA, PRICE_OPEN);
  Platform::AddWithDefaultBindings(new Indi_MA(ma_params));

  // Relative Strength Index (RSI).
  IndiRSIParams rsi_params(14, PRICE_OPEN);
  Platform::AddWithDefaultBindings(new Indi_RSI(rsi_params));

  /* Special indicators */

  // Demo/Dummy Indicator.
  IndiDemoParams demo_params;
  Platform::AddWithDefaultBindings(new Indi_Demo(demo_params));

#ifndef __MQL4__
  // @fixme: Make it work for MT4.
  // Current Price (used by custom indicators)  .
  PriceIndiParams price_params();
  // price_params.SetDraw(clrGreenYellow);
  Platform::AddWithDefaultBindings(new Indi_Price(price_params));
#endif

  /* @fixme: Array out of range.
  // Bollinger Bands over Price indicator.
  /*
  PriceIndiParams price_params_4_bands();
  IndicatorBase *indi_price_4_bands = new Indi_Price(price_params_4_bands);
  IndiBandsParams bands_on_price_params();
  bands_on_price_params.SetDraw(clrCadetBlue);
  // bands_on_price_params.SetDataSource(indi_price_4_bands, true, INDI_PRICE_MODE_OPEN);
  Platform::AddWithDefaultBindings(new Indi_Bands(bands_on_price_params, indi_price_4_bands, true));
  */

  // Moving Average (MA) over Price indicator.
  /*
  PriceIndiParams price_params_4_ma();
  IndicatorBase *indi_price_4_ma = new Indi_Price(price_params_4_ma);
  IndiMAParams ma_on_price_params();
  ma_on_price_params.SetDraw(clrYellowGreen);
  // ma_on_price_params.SetDataSource(indi_price_4_ma, true, INDI_PRICE_MODE_OPEN);
  ma_on_price_params.SetIndicatorType(INDI_MA_ON_PRICE);
  Platform::AddWithDefaultBindings(new Indi_MA(ma_on_price_params, indi_price_4_ma));

  // Relative Strength Index (RSI) over Price indicator.
  PriceIndiParams price_params_4_rsi();
  IndicatorData *indi_price_4_rsi = new Indi_Price(price_params_4_rsi);
  IndiRSIParams rsi_on_price_params();
  rsi_on_price_params.SetDraw(clrBisque, 1);
  IndicatorBase *indi_rsi_on_price = new Indi_RSI(rsi_on_price_params, IDATA_INDICATOR, indi_price_4_rsi);
  indis.Set(INDI_RSI_ON_PRICE, indi_rsi_on_price);
  */

  // We'll be drawing all indicators' values on the chart.
  for (DictIterator<long, Ref<IndicatorData>> iter = Platform::GetIndicators() PTR_DEREF Begin(); iter.IsValid();
       ++iter) {
    // iter.Value() REF_DEREF SetDraw(true); // @fixme
  }

  return _LastError == ERR_NO_ERROR;
}

/**
 * Print indicators.
 */
bool PrintIndicators(string _prefix = "") {
  ResetLastError();
  for (DictIterator<long, Ref<IndicatorData>> iter = Platform::GetIndicators() PTR_DEREF Begin(); iter.IsValid();
       ++iter) {
    IndicatorData *_indi = iter.Value().Ptr();
    if (_indi.Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      PrintFormat("%s: %s: %s", _prefix, _indi.GetName(), _indi.ToString());
    }
  }
  return GetLastError() == ERR_NO_ERROR;
}
