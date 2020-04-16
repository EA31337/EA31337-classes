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
 * Test functionality of Indicator class.
 */

// Defines.
#define __debug__ // Enables debug.

#property indicator_separate_window

// Includes.
#include "../Indicators/Indi_AC.mqh"
#include "../Indicators/Indi_AD.mqh"
#include "../Indicators/Indi_ADX.mqh"
#include "../Indicators/Indi_AO.mqh"
#include "../Indicators/Indi_ATR.mqh"
#include "../Indicators/Indi_Alligator.mqh"
#include "../Indicators/Indi_BWMFI.mqh"
#include "../Indicators/Indi_Bands.mqh"
#include "../Indicators/Indi_BearsPower.mqh"
#include "../Indicators/Indi_BullsPower.mqh"
#include "../Indicators/Indi_CCI.mqh"
#include "../Indicators/Indi_Price.mqh"
#include "../Indicators/Indi_DeMarker.mqh"
#include "../Indicators/Indi_Demo.mqh"
#include "../Indicators/Indi_Envelopes.mqh"
#include "../Indicators/Indi_Force.mqh"
#include "../Indicators/Indi_Fractals.mqh"
#include "../Indicators/Indi_Gator.mqh"
#include "../Indicators/Indi_HeikenAshi.mqh"
#include "../Indicators/Indi_Ichimoku.mqh"
#include "../Indicators/Indi_MA.mqh"
#include "../Indicators/Indi_MACD.mqh"
#include "../Indicators/Indi_MFI.mqh"
#include "../Indicators/Indi_Momentum.mqh"
#include "../Indicators/Indi_OBV.mqh"
#include "../Indicators/Indi_OsMA.mqh"
#include "../Indicators/Indi_RSI.mqh"
#include "../Indicators/Indi_RVI.mqh"
#include "../Indicators/Indi_SAR.mqh"
#include "../Indicators/Indi_StdDev.mqh"
#include "../Indicators/Indi_Stochastic.mqh"
#include "../Indicators/Indi_WPR.mqh"
#include "../Indicators/Indi_ZigZag.mqh"
#include "../Dict.mqh"
#include "../DictObject.mqh"
#include "../Test.mqh"

// Global variables.
Chart *chart;
Dict<long, Indicator*> indis;
Dict<long, bool> tested;
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
  // Print indicator values.
  _result &= PrintIndicators(__FUNCTION__);
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
    if (indis.Size() == 0) {
      return;
    }
    for (DictIterator<long, Indicator*> iter = indis.Begin(); iter.IsValid(); ++iter) {
      if (tested.GetByKey(iter.Key())) {
        // Indicator is already tested, skipping.
        continue;
      }
       
      Indicator *_indi = iter.Value();
      _indi.OnTick();
      IndicatorDataEntry _entry = _indi.GetEntry();
      if (_indi.GetState().IsReady() && _entry.IsValid()) {
        PrintFormat("%s%s: bar %d: %s", _indi.GetName(), _indi.GetParams().indi_data ? (" (over " + _indi.GetParams().indi_data.GetName() + ")") : "", bar_processed, _indi.ToString());
        tested.Set(iter.Key(), true); // Mark as tested.
        _indi.ReleaseHandle(); // Releases indicator's handle.
      }
    }
  }
}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {
  int num_not_tested = 0;
  for (DictIterator<long, bool> iter = tested.Begin(); iter.IsValid(); ++iter) {
    if (!iter.Value()) {
      PrintFormat("%s: Indicator not tested: %s", __FUNCTION__, EnumToString((ENUM_INDICATOR_TYPE) iter.Key()));
      ++num_not_tested;
    }
  }

  PrintFormat("%s: Indicators not tested: %d", __FUNCTION__, num_not_tested);
  assertTrueOrExit(num_not_tested == 0, "Not all indicators has been tested!");

  delete chart;
  
  for (DictIterator<long, Indicator*> iter = indis.Begin(); iter.IsValid(); ++iter) {
   delete iter.Value();
  }
}

/**
 * Initialize indicators.
 */
bool InitIndicators() {

  /* Standard indicators */

  // AC.
  indis.Set(INDI_AC, new Indi_AC());

  // AD.
  indis.Set(INDI_AD, new Indi_AD());

  // ADX.
  ADXParams adx_params(14, PRICE_HIGH);
  indis.Set(INDI_ADX, new Indi_ADX(adx_params));

  // ADX by Welles Wilder (ADXW  
  // @todo INDI_ADXW

  // Alligator.
  AlligatorParams alli_params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  indis.Set(INDI_ALLIGATOR, new Indi_Alligator(alli_params));

  // Adaptive Moving Average (AMA).
  // Awesome Oscillator (AO).
  indis.Set(INDI_AO, new Indi_AO());

  // Average True Range (ATR).
  ATRParams atr_params(14);
  indis.Set(INDI_ATR, new Indi_ATR(atr_params));

  // Bollinger Bands.
  BandsParams bands_params(20, 2, 0, PRICE_MEDIAN);
  indis.Set(INDI_BANDS, new Indi_Bands(bands_params));

  // Bears Power.
  BearsPowerParams bears_params(13, PRICE_CLOSE);
  indis.Set(INDI_BEARS, new Indi_BearsPower(bears_params));

  // Bulls Power.
  BullsPowerParams bulls_params(13, PRICE_CLOSE);
  indis.Set(INDI_BULLS, new Indi_BullsPower(bulls_params));

  // Market Facilitation Index (BWMFI).
  indis.Set(INDI_BWMFI, new Indi_BWMFI());

  // Commodity Channel Index (CCI).
  CCIParams cci_params(14, PRICE_CLOSE);
  indis.Set(INDI_CCI, new Indi_CCI(cci_params));

  // Chaikin Oscillator.
  // @todo INDI_CHAIKIN

  // Double Exponential Moving Average (DEMA).
  // @todo
  // indis.Set(INDI_DEMA, new Indi_Dema(dema_params));

  // DeMarker.
  DeMarkerParams dm_params(14);
  indis.Set(INDI_DEMARKER, new Indi_DeMarker(dm_params));

  // Envelopes.
  EnvelopesParams env_params(13, 0, MODE_SMA, PRICE_CLOSE, 2);
  indis.Set(INDI_ENVELOPES, new Indi_Envelopes(env_params));

  // Force Index.
  ForceParams force_params(13, MODE_SMA, PRICE_CLOSE);
  indis.Set(INDI_FORCE, new Indi_Force(force_params));

  // Fractals.
  indis.Set(INDI_FRACTALS, new Indi_Fractals());

  // Fractal Adaptive Moving Average (FRAMA).
  // @todo
  // indis.Set(INDI_FRAMA, new Indi_Frama(frama_params));

  // Gator Oscillator.
  GatorParams gator_params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  indis.Set(INDI_GATOR, new Indi_Gator(gator_params));

  // Heiken Ashi.
  indis.Set(INDI_HEIKENASHI, new Indi_HeikenAshi());

  // Ichimoku Kinko Hyo.
  IchimokuParams ichi_params(9, 26, 52);
  indis.Set(INDI_ICHIMOKU, new Indi_Ichimoku(ichi_params));

  // Moving Average.
  MAParams ma_params(13, 10, MODE_SMA, PRICE_OPEN);
  Indicator* indi_ma = new Indi_MA(ma_params);
  indis.Set(INDI_MA, indi_ma);

  // MACD.
  MACDParams macd_params(12, 26, 9, PRICE_CLOSE);
  Indicator* macd = new Indi_MACD(macd_params);
  indis.Set(INDI_MACD, macd);

  // Money Flow Index (MFI).
  MFIParams mfi_params(14);
  indis.Set(INDI_MFI, new Indi_MFI(mfi_params));

  // Momentum (MOM).
  MomentumParams mom_params(12, PRICE_CLOSE);
  indis.Set(INDI_MOMENTUM, new Indi_Momentum(mom_params));

  // On Balance Volume (OBV).
  indis.Set(INDI_OBV, new Indi_OBV());

  // OsMA.
  OsMAParams osma_params(12, 26, 9, PRICE_CLOSE);
  indis.Set(INDI_OSMA, new Indi_OsMA(osma_params));

  // Relative Strength Index (RSI).
  RSIParams rsi_params(14, PRICE_OPEN);
  indis.Set(INDI_RSI, new Indi_RSI(rsi_params));

  // Relative Vigor Index (RVI).
  RVIParams rvi_params(14);
  indis.Set(INDI_RVI, new Indi_RVI(rvi_params));

  // Parabolic SAR.
  SARParams sar_params(0.02, 0.2);
  indis.Set(INDI_SAR, new Indi_SAR(sar_params));

  // Standard Deviation (StdDev).
  StdDevParams stddev_params(13, 10, MODE_SMA, PRICE_CLOSE);
  indis.Set(INDI_STDDEV, new Indi_StdDev(stddev_params));

  // Stochastic Oscillator.
  StochParams stoch_params(5, 3, 3, MODE_SMMA, STO_LOWHIGH);
  indis.Set(INDI_STOCHASTIC, new Indi_Stochastic(stoch_params));

  // Triple Exponential Moving Average (TEMA).
  // @todo
  // indis.Set(INDI_TEMA, new Indi_TEMA(tema_params));
  // Triple Exponential Moving Averages Oscillator (TRIX).
  // @todo
  // indis.Set(INDI_TRIX, new Indi_TRIX(trix_params));
  // Variable Index Dynamic Average (VIDYA).
  // @todo
  // indis.Set(INDI_VIDYA, new Indi_VIDYA(vidya_params));
  // Volumes.
  // @todo
  // indis.Set(INDI_VOLUMES, new Indi_Volumes(vol_params));

  // Williams' Percent Range (WPR).
  WPRParams wpr_params(14);
  indis.Set(INDI_WPR, new Indi_WPR(wpr_params));

  // ZigZag.
  ZigZagParams zz_params(12, 5, 3);
  indis.Set(INDI_ZIGZAG, new Indi_ZigZag(zz_params));

  /* Special indicators */

  // Demo/Dummy Indicator.
  indis.Set(INDI_DEMO, new Indi_Demo());

  // Current Price (Used by Bands on custom indicator)  .
  PriceIndiParams price_params_1(PRICE_OPEN);
  Indicator* indi_price_1 = new Indi_Price(price_params_1);
  indis.Set(INDI_PRICE, indi_price_1);

  // Bollinger Bands over Price indicator.
  PriceIndiParams price_params_2(PRICE_OPEN);
  Indicator* indi_price_2 = new Indi_Price(price_params_2);
  BandsParams bands_params_on_price(20, 2, 0, PRICE_MEDIAN);
  bands_params_on_price.is_draw = true;
  bands_params_on_price.indi_data = indi_price_2;
  indis.Set(INDI_BANDS_ON_PRICE, new Indi_Bands(bands_params_on_price));

  // MA over Price indicator.
  // Moving Average.
  PriceIndiParams price_params_3(PRICE_OPEN);
  Indicator* indi_price_3 = new Indi_Price(price_params_3);
  MAParams ma_on_price_params(13, 10, MODE_SMA, PRICE_OPEN);
  ma_on_price_params.is_draw = true;
  ma_on_price_params.idstype = IDATA_INDICATOR;
  ma_on_price_params.indi_data = indi_price_3;
  // @todo Price needs to have four values (OHCL).
  ma_on_price_params.indi_mode = 0; // PRICE_OPEN;
  Indicator* indi_ma_on_price = new Indi_MA(ma_on_price_params);
  indis.Set(INDI_MA_ON_PRICE, indi_ma_on_price);

  // Relative Strength Index (RSI) over Price indicator.
  RSIParams rsi_params_on_price(14, PRICE_OPEN);
  rsi_params_on_price.is_draw = true;
  rsi_params_on_price.idstype = IDATA_INDICATOR;
  rsi_params_on_price.indi_data = indi_price;
  rsi_params_on_price.indi_mode = 0;
  Indi_RSI* rsi = new Indi_RSI(rsi_params_on_price);
  indis.Set(INDI_RSI_ON_PRICE, rsi);

  // Mark all as untested.
  for (DictIterator<long, Indicator*> iter = indis.Begin(); iter.IsValid(); ++iter) {
    tested.Set(iter.Key(), false);
  }
  return GetLastError() == ERR_NO_ERROR;
}

/**
 * Print indicators.
 */
bool PrintIndicators(string _prefix = "") {
  for (DictIterator<long, Indicator*> iter = indis.Begin(); iter.IsValid(); ++iter) {
    Indicator *_indi = iter.Value();
    MqlParam _value = _indi.GetEntryValue();
    if (GetLastError() == ERR_INDICATOR_DATA_NOT_FOUND || GetLastError() == ERR_USER_ERROR_FIRST + ERR_USER_INVALID_BUFF_NUM) {
      ResetLastError();
      continue;
    }
    if (_indi.GetState().IsReady()) {
      PrintFormat("%s: %s: %s%s", _prefix, _indi.GetName(), _indi.ToString(), _indi.GetParams().indi_data ? (" (over " + _indi.GetParams().indi_data.GetName() + ")") : "");
    }
  }
  return GetLastError() == ERR_NO_ERROR;
}

/**
 * Run all tests.
 */
bool RunTests() {
  bool _result = true;
  _result &= TestAC();
  _result &= TestAD();
  _result &= TestADX();
  _result &= TestAO();
  _result &= TestATR();
  _result &= TestAlligator();
  _result &= TestBWMFI();
  _result &= TestBands();
  // @todo
  // _result &= TestBandsOnPrice();
  _result &= TestBearsPower();
  _result &= TestBullsPower();
  _result &= TestCCI();
  // @todo
  // _result &= TestPrice();
  _result &= TestDeMarker();
  _result &= TestDemo();
  _result &= TestEnvelopes();
  _result &= TestForce();
  _result &= TestFractals();
  _result &= TestGator();
  _result &= TestHeikenAshi();
  _result &= TestIchimoku();
  _result &= TestMA();
  // @todo
  // _result &= TestMAOnPrice();
  _result &= TestMACD();
  _result &= TestMFI();
  _result &= TestMomentum();
  _result &= TestOBV();
  _result &= TestOsMA();
  _result &= TestRSI();
  _result &= TestRVI();
  _result &= TestSAR();
  _result &= TestStdDev();
  _result &= TestStochastic();
  _result &= TestWPR();
  _result &= TestZigZag();
  return _result;
}

/**
 * Test AC indicator.
 */
bool TestAC() {
  // Get static value.
  double ac_value = Indi_AC::iAC();
  // Get dynamic values.
  ACParams params(PERIOD_CURRENT);
  Indi_AC *ac = new Indi_AC(params);
  IndicatorDataEntry _entry = ac.GetEntry();
  Print("AC: ", _entry.value.ToString(params.idvtype));
  assertTrueOrReturn(
    ac.GetValue() == ac_value,
    "AC value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype) == ac_value,
    "AC entry value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype) <= 0,
    "AC value is zero or negative!",
    false);
  // Clean up.
  delete ac;
  return true;
}

/**
 * Test AD indicator.
 */
bool TestAD() {
  // Get static value.
  double ad_value = Indi_AD::iAD();
  // Get dynamic values.
  ADParams params(PERIOD_CURRENT);
  Indi_AD *ad = new Indi_AD(params);
  IndicatorDataEntry _entry = ad.GetEntry();
  Print("AD: ", _entry.value.ToString(params.idvtype));
  assertTrueOrReturn(
    ad.GetValue() == ad_value,
    "AD value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype) == ad_value,
    "AD entry value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype) <= 0,
    "AD value is zero or negative!",
    false);
  // Clean up.
  delete ad;
  return true;
}

/**
 * Test ADX indicator.
 */
bool TestADX() {
  // Get static value.
  double adx_value = Indi_ADX::iADX(_Symbol, PERIOD_CURRENT, 14, PRICE_HIGH, LINE_MAIN_ADX);
  // Get dynamic values.
  ADXParams params(14, PRICE_HIGH);
  Indi_ADX *adx = new Indi_ADX(params);
  Print("ADX: ", adx.GetValue());
  assertTrueOrReturn(
    adx.GetValue() == adx_value,
    "ADX value does not match!",
    false);
  adx.SetPeriod(adx.GetPeriod()+1);
  // Clean up.
  delete adx;
  return true;
}

/**
 * Test AO indicator.
 */
bool TestAO() {
  // Get static value.
  double ao_value = Indi_AO::iAO();
  // Get dynamic values.
  AOParams params(PERIOD_CURRENT);
  Indi_AO *ao = new Indi_AO(params);
  Print("AO: ", ao.GetValue());
  assertTrueOrReturn(
    ao.GetValue() == ao_value,
    "AO value does not match!",
    false);
  // Clean up.
  delete ao;
  return true;
}

/**
 * Test ATR indicator.
 */
bool TestATR() {
  // Get static value.
  double atr_value = Indi_ATR::iATR(_Symbol, PERIOD_CURRENT, 14);
  // Get dynamic values.
  ATRParams params(14);
  Indi_ATR *atr = new Indi_ATR(params);
  Print("ATR: ", atr.GetValue());
  assertTrueOrReturn(
    atr.GetValue() == atr_value,
    "ATR value does not match!",
    false);
  atr.SetPeriod(atr.GetPeriod()+1);
  // Clean up.
  delete atr;
  return true;
}

/**
 * Test Alligator indicator.
 */
bool TestAlligator() {
  // Get static value.
  double alligator_value = Indi_Alligator::iAlligator(_Symbol, PERIOD_CURRENT, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, LINE_JAW);
  // Get dynamic values.
  AlligatorParams params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  Indi_Alligator *alligator = new Indi_Alligator(params);
  PrintFormat("Alligator: %g/%g/%g", alligator.GetValue(LINE_JAW), alligator.GetValue(LINE_TEETH), alligator.GetValue(LINE_LIPS));
  assertTrueOrReturn(
    alligator.GetValue(LINE_JAW) == alligator_value,
    "Alligator jaw value does not match!",
    false);
  assertTrueOrReturn(
    alligator.GetValue(LINE_JAW) != alligator.GetValue(LINE_TEETH),
    "Alligator jaw value should be different than teeth value!",
    false);
  assertTrueOrReturn(
    alligator.GetValue(LINE_TEETH) != alligator.GetValue(LINE_LIPS),
    "Alligator teeth value should be different than lips value!",
    false);
  alligator.SetJawPeriod(alligator.GetJawPeriod()+1);
  alligator.SetJawShift(alligator.GetJawShift()+1);
  alligator.SetTeethPeriod(alligator.GetTeethPeriod()+1);
  alligator.SetTeethShift(alligator.GetTeethShift()+1);
  alligator.SetLipsPeriod(alligator.GetLipsPeriod()+1);
  alligator.SetLipsShift(alligator.GetLipsShift()+1);
  // Clean up.
  delete alligator;
  return true;
}

/**
 * Test BWMFI indicator.
 */
bool TestBWMFI() {
  // Get static value.
  double bwmfi_value = Indi_BWMFI::iBWMFI();
  // Get dynamic values.
  BWMFIParams params(PERIOD_CURRENT);
  Indi_BWMFI *bwmfi = new Indi_BWMFI(params);
  Print("BWMFI: ", bwmfi.GetValue());
  assertTrueOrReturn(
    bwmfi.GetValue() == bwmfi_value,
    "BWMFI value does not match!",
    false);
  // Clean up.
  delete bwmfi;
  return true;
}

/**
 * Test bands indicator.
 */
bool TestBands() {
  // Get static value.
  double bands_value = Indi_Bands::iBands(_Symbol, PERIOD_CURRENT, 20, 2, 0, PRICE_LOW);
  // Get dynamic values.
  BandsParams params(20, 2, 0, PRICE_LOW);
  Indi_Bands *bands = new Indi_Bands(params);
  IndicatorDataEntry _entry = bands.GetEntry();
  Print("Bands: ", _entry.value.ToString(params.idvtype));
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype, BAND_BASE) == bands_value,
    "Bands value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype, BAND_BASE) == bands.GetValue(BAND_BASE),
    "Bands BAND_BASE value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype, BAND_LOWER) == bands.GetValue(BAND_LOWER),
    "Bands BAND_LOWER value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype, BAND_UPPER) == bands.GetValue(BAND_UPPER),
    "Bands BAND_UPPER value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype, BAND_LOWER) < _entry.value.GetValueDbl(params.idvtype, BAND_UPPER),
    "Bands lower value should be less than upper value!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype, BAND_UPPER) > _entry.value.GetValueDbl(params.idvtype, BAND_BASE),
    "Bands upper value should be greater than base value!",
    false);
  bands.SetPeriod(bands.GetPeriod()+1);
  bands.SetDeviation(bands.GetDeviation()+0.1);
  // Clean up.
  delete bands;
  return true;
}

/**
 * Test BearsPower indicator.
 */
bool TestBearsPower() {
  // Get static value.
  double bp_value = Indi_BearsPower::iBearsPower(_Symbol, PERIOD_CURRENT, 13, PRICE_CLOSE);
  // Get dynamic values.
  BearsPowerParams params(13, PRICE_CLOSE);
  Indi_BearsPower *bp = new Indi_BearsPower(params);
  Print("BearsPower: ", bp.GetValue());
  assertTrueOrReturn(
    bp.GetValue() == bp_value,
    "BearsPower value does not match!",
    false);
  bp.SetPeriod(bp.GetPeriod()+1);
  bp.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete bp;
  return true;
}

/**
 * Test BullsPower indicator.
 */
bool TestBullsPower() {
  // Get static value.
  double bp_value = Indi_BullsPower::iBullsPower(_Symbol, PERIOD_CURRENT, 13, PRICE_CLOSE);
  // Get dynamic values.
  BullsPowerParams params(13, PRICE_CLOSE);
  Indi_BullsPower *bp = new Indi_BullsPower(params);
  Print("BullsPower: ", bp.GetValue());
  assertTrueOrReturn(
    bp.GetValue() == bp_value,
    "BullsPower value does not match!",
    false);
  bp.SetPeriod(bp.GetPeriod()+1);
  bp.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete bp;
  return true;
}

/**
 * Test CCI indicator.
 */
bool TestCCI() {
  // Get static value.
  double cci_value = Indi_CCI::iCCI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
  // Get dynamic values.
  CCIParams params(14, PRICE_CLOSE);
  Indi_CCI *cci = new Indi_CCI(params);
  Print("CCI: ", cci.GetValue());
  assertTrueOrReturn(
    cci.GetValue() == cci_value,
    "CCI value does not match!",
    false);
  cci.SetPeriod(cci.GetPeriod()+1);
  // Clean up.
  delete cci;
  return true;
}

/**
 * Test DeMarker indicator.
 */
bool TestDeMarker() {
  // Get static value.
  double dm_value = Indi_DeMarker::iDeMarker(_Symbol, PERIOD_CURRENT, 14);
  // Get dynamic values.
  DeMarkerParams params(14);
  Indi_DeMarker *dm = new Indi_DeMarker(params);
  Print("DeMarker: ", dm.GetValue());
  assertTrueOrReturn(
    dm.GetValue() == dm_value,
    "DeMarker value does not match!",
    false);
  dm.SetPeriod(dm.GetPeriod()+1);
  // Clean up.
  delete dm;
  return true;
}

/**
 * Test Demo indicator.
 */
bool TestDemo() {
  // Get static value.
  double demo_value = Indi_Demo::iDemo();
  // Get dynamic values.
  DemoIndiParams params(PERIOD_CURRENT);
  Indi_Demo *demo = new Indi_Demo(params);
  IndicatorDataEntry _entry = demo.GetEntry();
  Print("Demo: ", _entry.value.ToString(params.idvtype));
  assertTrueOrReturn(
    demo.GetValue() == demo_value,
    "Demo value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype) == demo_value,
    "Demo entry value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype) <= 0,
    "Demo value is zero or negative!",
    false);
  // Clean up.
  delete demo;
  return true;
}

/**
 * Test Envelopes indicator.
 */
bool TestEnvelopes() {
  // Get static value.
  double env_value = Indi_Envelopes::iEnvelopes(_Symbol, PERIOD_CURRENT, 13, 0, MODE_SMA, PRICE_CLOSE, 2, LINE_UPPER);
  // Get dynamic values.
  EnvelopesParams params(13, 0, MODE_SMA, PRICE_CLOSE, 2);
  Indi_Envelopes *env = new Indi_Envelopes(params);
  IndicatorDataEntry _entry = env.GetEntry();
  Print("Envelopes: ", _entry.value.ToString(params.idvtype));
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype, LINE_UPPER) == env_value,
    "Envelopes value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype, LINE_LOWER) == env.GetValue(LINE_LOWER),
    "Envelopes LINE_LOWER value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype, LINE_UPPER) == env.GetValue(LINE_UPPER),
    "Envelopes LINE_UPPER value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value.GetValueDbl(params.idvtype, LINE_LOWER) < _entry.value.GetValueDbl(params.idvtype, LINE_UPPER),
    "Envelopes lower value should be less than upper value!",
    false);
  env.SetMAPeriod(env.GetMAPeriod()+1);
  env.SetMAMethod(MODE_SMA);
  env.SetMAShift(env.GetMAShift()+1);
  env.SetAppliedPrice(PRICE_MEDIAN);
  env.SetDeviation(env.GetDeviation()+0.1);
  // Clean up.
  delete env;
  return true;
}

/**
 * Test Force indicator.
 */
bool TestForce() {
  // Get static value.
  double force_value = Indi_Force::iForce(_Symbol, PERIOD_CURRENT, 13, MODE_SMA, PRICE_CLOSE);
  // Get dynamic values.
  ForceParams params(13, MODE_SMA, PRICE_CLOSE);
  Indi_Force *force = new Indi_Force(params);
  Print("Force: ", force.GetValue());
  assertTrueOrReturn(
    force.GetValue() == force_value,
    "Force value does not match!",
    false);
  force.SetPeriod(force.GetPeriod()+1);
  force.SetMAMethod(MODE_SMA);
  force.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete force;
  return true;
}

/**
 * Test Fractals indicator.
 */
bool TestFractals() {
  // Get static value.
  double fractals_value = Indi_Fractals::iFractals(
    _Symbol,
    PERIOD_CURRENT,
    LINE_UPPER
    );
  // Get dynamic values.
  FractalsParams params(PERIOD_CURRENT);
  Indi_Fractals *fractals = new Indi_Fractals(params);
  Print("Fractals: ", fractals.GetValue(LINE_UPPER));
  assertTrueOrReturn(
    fractals.GetValue(LINE_UPPER) == fractals_value,
    "Fractals value does not match!",
    false);
  // Clean up.
  delete fractals;
  return true;
}

/**
 * Test Gator indicator.
 */
bool TestGator() {
  // Get static value.
  double gator_value = Indi_Gator::iGator(_Symbol, PERIOD_CURRENT, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, LINE_UPPER_HISTOGRAM);
  // Get dynamic values.
  GatorParams params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  Indi_Gator *gator = new Indi_Gator(params);
  Print("Gator upper: ", gator.GetValue(LINE_UPPER_HISTOGRAM));
  assertTrueOrReturn(
    gator.GetValue(LINE_UPPER_HISTOGRAM) == gator_value,
    "Gator value does not match!",
    false);
  gator.SetJawPeriod(gator.GetJawPeriod()+1);
  gator.SetJawShift(gator.GetJawShift()+1);
  gator.SetTeethPeriod(gator.GetTeethPeriod()+1);
  gator.SetTeethShift(gator.GetTeethShift()+1);
  gator.SetLipsPeriod(gator.GetLipsPeriod()+1);
  gator.SetLipsShift(gator.GetLipsShift()+1);
  // Clean up.
  delete gator;
  return true;
}

/**
 * Test HeikenAshi indicator.
 */
bool TestHeikenAshi() {
  // Get static value.
  double ha_value = Indi_HeikenAshi::iHeikenAshi(_Symbol, PERIOD_CURRENT, HA_OPEN);
  // Get dynamic values.
  HeikenAshiParams params(PERIOD_CURRENT);
  Indi_HeikenAshi *ha = new Indi_HeikenAshi(params);
  Print("HeikenAshi: ", ha.GetValue(HA_OPEN));
  assertTrueOrReturn(
    ha.GetValue(HA_OPEN) == ha_value,
    "HeikenAshi value does not match!",
    false);
  // Clean up.
  delete ha;
  return true;
}

/**
 * Test Ichimoku indicator.
 */
bool TestIchimoku() {
  // Get static value.
  double ichimoku_value = Indi_Ichimoku::iIchimoku(_Symbol, PERIOD_CURRENT, 9, 26, 52, LINE_TENKANSEN);
  // Get dynamic values.
  IchimokuParams params(9, 26, 52);
  Indi_Ichimoku *ichimoku = new Indi_Ichimoku(params);
  Print("Ichimoku: ", ichimoku.GetValue(LINE_TENKANSEN));
  assertTrueOrReturn(
    ichimoku.GetValue(LINE_TENKANSEN) == ichimoku_value,
    "Ichimoku value does not match!",
    false);
  ichimoku.SetTenkanSen(ichimoku.GetTenkanSen()+1);
  ichimoku.SetKijunSen(ichimoku.GetKijunSen()+1);
  ichimoku.SetSenkouSpanB(ichimoku.GetSenkouSpanB()+1);
  // Clean up.
  delete ichimoku;
  return true;
}

/**
 * Test MA indicator.
 */
bool TestMA() {
  // Get static value.
  double ma_value = Indi_MA::iMA(_Symbol, PERIOD_CURRENT, 13, 10, MODE_SMA, PRICE_CLOSE);
  // Get dynamic values.
  MAParams params(13, 10, MODE_SMA, PRICE_CLOSE);
  Indi_MA *_ma = new Indi_MA(params);
  Print("MA: ", _ma.GetValue());
  assertTrueOrReturn(
    _ma.GetValue() == ma_value,
    "MA value does not match!",
    false);
  _ma.SetPeriod(_ma.GetPeriod()+1);
  _ma.SetShift(_ma.GetShift()+1);
  _ma.SetMAMethod(MODE_SMA);
  _ma.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete _ma;
  return true;
}

/**
 * Test MACD indicator.
 */
bool TestMACD() {
  // Get static value.
  double macd_value = Indi_MACD::iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
  // Get dynamic values.
  MACDParams params(12, 26, 9, PRICE_CLOSE);
  Indi_MACD *macd = new Indi_MACD(params);
  Print("MACD: ", macd.GetValue(LINE_MAIN));
  assertTrueOrReturn(
    macd.GetValue(LINE_MAIN) == macd_value,
    "MACD value does not match!",
    false);
  macd.SetEmaFastPeriod(macd.GetEmaFastPeriod()+1);
  macd.SetEmaSlowPeriod(macd.GetEmaSlowPeriod()+1);
  macd.SetSignalPeriod(macd.GetSignalPeriod()+1);
  macd.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete macd;
  return true;
}

/**
 * Test MFI indicator.
 */
bool TestMFI() {
  // Get static value.
  double mfi_value = Indi_MFI::iMFI(_Symbol, PERIOD_CURRENT, 14);
  // Get dynamic values.
  MFIParams params(14);
  Indi_MFI *mfi = new Indi_MFI(params);
  Print("MFI: ", mfi.GetValue());
  assertTrueOrReturn(
    mfi.GetValue() == mfi_value,
    "MFI value does not match!",
    false);
  mfi.SetPeriod(mfi.GetPeriod()+1);
  mfi.SetAppliedVolume(VOLUME_REAL);
  // Clean up.
  delete mfi;
  return true;
}

/**
 * Test Momentum indicator.
 */
bool TestMomentum() {
  // Get static value.
  double mom_value = Indi_Momentum::iMomentum(_Symbol, PERIOD_CURRENT, 12, PRICE_CLOSE);
  // Get dynamic values.
  MomentumParams params(12, PRICE_CLOSE);
  Indi_Momentum *mom = new Indi_Momentum(params);
  Print("Momentum: ", mom.GetValue());
  assertTrueOrReturn(
    mom.GetValue() == mom_value,
    "Momentum value does not match!",
    false);
  mom.SetPeriod(mom.GetPeriod()+1);
  mom.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete mom;
  return true;
}

/**
 * Test OBV indicator.
 */
bool TestOBV() {
  // Get static value.
  double obv_value = Indi_OBV::iOBV(_Symbol, PERIOD_CURRENT);
  // Get dynamic values.
  OBVParams params;
  Indi_OBV *obv = new Indi_OBV(params);
  Print("OBV: ", obv.GetValue());
  assertTrueOrReturn(
    obv.GetValue() == obv_value,
    "OBV value does not match!",
    false);
  obv.SetAppliedPrice(PRICE_MEDIAN);
  obv.SetAppliedVolume(VOLUME_REAL);
  // Clean up.
  delete obv;
  return true;
}

/**
 * Test OsMA indicator.
 */
bool TestOsMA() {
  // Get static value.
  double osma_value = Indi_OsMA::iOsMA(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
  // Get dynamic values.
  OsMAParams params(12, 26, 9, PRICE_CLOSE);
  Indi_OsMA *osma = new Indi_OsMA(params);
  Print("OsMA: ", osma.GetValue());
  assertTrueOrReturn(
    osma.GetValue() == osma_value,
    "OsMA value does not match!",
    false);
  osma.SetEmaFastPeriod(osma.GetEmaFastPeriod()+1);
  osma.SetEmaSlowPeriod(osma.GetEmaSlowPeriod()+1);
  osma.SetSignalPeriod(osma.GetSignalPeriod()+1);
  osma.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete osma;
  return true;
}

/**
 * Test RSI indicator.
 */
bool TestRSI() {
  // Get static value.
  double rsi_value = Indi_RSI::iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
  // Get dynamic values.
  RSIParams params(14, PRICE_CLOSE);
  Indi_RSI *rsi = new Indi_RSI(params);
  Print("RSI: ", rsi.GetValue());
  assertTrueOrReturn(
    rsi.GetValue() == rsi_value,
    "RSI value does not match!",
    false);
  rsi.SetPeriod(rsi.GetPeriod()+1);
  rsi.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete rsi;
  return true;
}

/**
 * Test RVI indicator.
 */
bool TestRVI() {
  // Get static value.
  double rvi_value = Indi_RVI::iRVI(_Symbol, PERIOD_CURRENT, 14, LINE_MAIN);
  // Get dynamic values.
  RVIParams params(14);
  Indi_RVI *rvi = new Indi_RVI(params);
  Print("RVI: ", rvi.GetValue(LINE_MAIN));
  assertTrueOrReturn(
    rvi.GetValue(LINE_MAIN) == rvi_value,
    "RVI value does not match!",
    false);
  rvi.SetPeriod(rvi.GetPeriod()+1);
  // Clean up.
  delete rvi;
  return true;
}

/**
 * Test SAR indicator.
 */
bool TestSAR() {
  // Get static value.
  double sar_value = Indi_SAR::iSAR();
  // Get dynamic values.
  SARParams params(0.02, 0.2);
  Indi_SAR *sar = new Indi_SAR(params);
  Print("SAR: ", sar.GetValue());
  assertTrueOrReturn(
    sar.GetValue() == sar_value,
    "SAR value does not match!",
    false);
  sar.SetStep(sar.GetStep()*2);
  sar.SetMax(sar.GetMax()*2);
  // Clean up.
  delete sar;
  return true;
}

/**
 * Test StdDev indicator.
 */
bool TestStdDev() {
  // Get static value.
  double sd_value = Indi_StdDev::iStdDev(_Symbol, PERIOD_CURRENT, 13, 10, MODE_SMA, PRICE_CLOSE);
  // Get dynamic values.
  StdDevParams params(13, 10, MODE_SMA, PRICE_CLOSE);
  Indi_StdDev *sd = new Indi_StdDev(params);
  Print("StdDev: ", sd.GetValue());
  assertTrueOrReturn(
    sd.GetValue() == sd_value,
    "StdDev value does not match!",
    false);
  sd.SetMAPeriod(sd.GetMAPeriod()+1);
  sd.SetMAShift(sd.GetMAShift()+1);
  sd.SetMAMethod(MODE_SMA);
  sd.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete sd;
  return true;
}

/**
 * Test Stochastic indicator.
 */
bool TestStochastic() {
  // Get static value.
  double stoch_value = Indi_Stochastic::iStochastic(_Symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMMA, STO_LOWHIGH, LINE_MAIN);
  // Get dynamic values.
  StochParams params(5, 3, 3, MODE_SMMA, STO_LOWHIGH);
  Indi_Stochastic *stoch = new Indi_Stochastic(params);
  Print("Stochastic: ", stoch.GetValue());
  assertTrueOrReturn(
    stoch.GetValue() == stoch_value,
    "Stochastic value does not match!",
    false);
  stoch.SetKPeriod(stoch.GetKPeriod()+1);
  stoch.SetDPeriod(stoch.GetDPeriod()+1);
  stoch.SetSlowing(stoch.GetSlowing()+1);
  stoch.SetMAMethod(MODE_SMA);
  stoch.SetPriceField(STO_CLOSECLOSE);
  // Clean up.
  delete stoch;
  return true;
}

/**
 * Test WPR indicator.
 */
bool TestWPR() {
  // Get static value.
  double wpr_value = Indi_WPR::iWPR(_Symbol, PERIOD_CURRENT, 14, 0);
  // Get dynamic values.
  WPRParams params(14);
  Indi_WPR *wpr = new Indi_WPR(params);
  Print("WPR: ", wpr.GetValue());
  assertTrueOrReturn(
    wpr.GetValue() == wpr_value,
    "WPR value does not match!",
    false);
  wpr.SetPeriod(wpr.GetPeriod()+1);
  // Clean up.
  delete wpr;
  return true;
}

/**
 * Test ZigZag indicator.
 */
bool TestZigZag() {
  // Get static value.
  double zz_value = Indi_ZigZag::iZigZag(_Symbol, PERIOD_CURRENT, 12, 5, 3, ZIGZAG_BUFFER, 0);
  // Get dynamic values.
  ZigZagParams params(12, 5, 3);
  Indi_ZigZag *zz = new Indi_ZigZag(params);
  Print("ZigZag: ", zz.GetValue(ZIGZAG_BUFFER));
  assertTrueOrReturn(
    zz.GetValue(ZIGZAG_BUFFER) == zz_value,
    "ZigZag value does not match!",
    false);
  zz.SetDepth(zz.GetDepth()+1);
  zz.SetDeviation(zz.GetDeviation()+1);
  zz.SetBackstep(zz.GetBackstep()+1);
  // Clean up.
  delete zz;
  return true;
}
