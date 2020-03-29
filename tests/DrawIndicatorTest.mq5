//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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

// Includes.
#include "../DrawIndicator.mqh"
#include "../Indicators/Indi_Bands.mqh"
#include "../Indicators/Indi_Demo.mqh"
#include "../Indicators/Indi_Price.mqh"
#include "../Test.mqh"

// Global variables.
Chart *chart;
Dict<long, Indicator *> indis;
int bar_processed;

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  // Initialize chart.
  chart = new Chart();
  // Initialize indicators.
  _result &= InitIndicators();
  Print("Indicators to test: ", indis.Size());
  // Check for any errors.
  assertTrueOrFail(GetLastError() == ERR_NO_ERROR, StringFormat("Error: %d", GetLastError()));
  bar_processed = 0;
  return (_result && _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
  chart.OnTick();

  if (chart.IsNewBar()) {
    bar_processed++;

    for (DictIterator<long, Indicator *> iter = indis.Begin(); iter.IsValid(); ++iter) {
      Indicator *_indi = iter.Value();
      _indi.OnTick();
      IndicatorDataEntry _entry = _indi.GetEntry();
      if (_indi.GetState().IsReady() && _entry.IsValid()) {
        PrintFormat("%s: bar %d: %s", _indi.GetName(), bar_processed, _indi.ToString());
      }
    }
  }
}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {
  delete chart;

  for (DictIterator<long, Indicator *> iter = indis.Begin(); iter.IsValid(); ++iter) {
    delete iter.Value();
  }
}

/**
 * Initialize indicators.
 */
bool InitIndicators() {
  /* Standard indicators */

  // Bollinger Bands.
  BandsParams bands_params(20, 2, 0, PRICE_MEDIAN);
  indis.Set(INDI_BANDS, new Indi_Bands(bands_params));

  /* Special indicators */

  // Demo/Dummy Indicator.
  DemoIndiParams demo_params;
  Indicator *indi_demo = new Indi_Demo(demo_params);
  indis.Set(INDI_DEMO, indi_demo);

  // Current Price (used by Bands on custom indicator)  .
  PriceIndiParams price_params(PRICE_MEDIAN);
  price_params.SetDraw();
  Indicator *indi_price = new Indi_Price(price_params);
  indis.Set(INDI_PRICE, indi_price);

  // Bollinger Bands over Price indicator.
  BandsParams bands_params_on_price(20, 2, 0, PRICE_MEDIAN);
  bands_params_on_price.SetDraw();
  bands_params_on_price.SetIndicatorData(indi_price);
  bands_params_on_price.SetIndicatorType(INDI_BANDS_ON_PRICE);
  indis.Set(INDI_BANDS_ON_PRICE, new Indi_Bands(bands_params_on_price));

  return _LastError == ERR_NO_ERROR;
}

/**
 * Print indicators.
 */
bool PrintIndicators(string _prefix = "") {
  for (DictIterator<long, Indicator *> iter = indis.Begin(); iter.IsValid(); ++iter) {
    Indicator *_indi = iter.Value();
    MqlParam _value = _indi.GetEntryValue();
    if (GetLastError() == ERR_INDICATOR_DATA_NOT_FOUND ||
        GetLastError() == ERR_USER_ERROR_FIRST + ERR_USER_INVALID_BUFF_NUM) {
      ResetLastError();
      continue;
    }
    if (_indi.GetState().IsReady()) {
      PrintFormat("%s: %s: %s", _prefix, _indi.GetName(), _indi.ToString());
    }
  }
  return GetLastError() == ERR_NO_ERROR;
}
