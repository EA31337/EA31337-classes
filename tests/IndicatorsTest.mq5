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
#include "../Indicators/Indi_DeMarker.mqh"
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
#include "../Test.mqh"

// Global variables.
Chart *chart;
Indi_MA *ma;

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  chart = new Chart();
  // Initialize MA.
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  MA_Params params(12, 0, MODE_SMA, PRICE_WEIGHTED);
  ma = new Indi_MA(params, iparams, cparams);
#ifdef __MQL4__
  _result &= RunTests();
#endif
  if (_LastError > 0) {
    PrintFormat("Error: %d!", GetLastError());
  }
  return (_result ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
  static int _count = 0;
  if (chart.IsNewBar()) {
    if (++_count > 5) {
      bool _result = true;
#ifdef __MQL5__
      // Standard MA.
      double _ma_res[];
      int _ma_handler = iMA(_Symbol, _Period, 13, 10, MODE_SMA, PRICE_CLOSE);
      int _bars_calc = BarsCalculated(_ma_handler);
      if (_bars_calc > 2) {
        if (CopyBuffer(_ma_handler, 0, 0, 3, _ma_res) < 0) {
          PrintFormat("Error: %d!", GetLastError());
          _result = false;
        }
      }
#endif
      // Dynamic MA.
      ma.GetValue();
      if (GetLastError() > 0) {
        PrintFormat("Error: %d!", GetLastError());
        _result = false;
      }
      // Test all indicators.
      _result &= RunTests();
      // Check results.
      assertTrueOrExit(_result, "Test failed!");
    }
  }
}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {
  delete chart;
  delete ma;
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
  _result &= TestBearsPower();
  _result &= TestBullsPower();
  _result &= TestCCI();
  _result &= TestDeMarker();
  _result &= TestEnvelopes();
  _result &= TestForce();
  _result &= TestFractals();
  _result &= TestGator();
  _result &= TestHeikenAshi();
  _result &= TestIchimoku();
  _result &= TestMA();
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Indi_AC *ac = new Indi_AC(iparams, cparams);
  AC_Entry _entry = ac.GetEntry();
  Print("AC: ", _entry.ToString());
  assertTrueOrReturn(
    ac.GetValue() == ac_value,
    "AC value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value == ac_value,
    "AC entry value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value <= 0,
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Indi_AD *ad = new Indi_AD(iparams, cparams);
  AD_Entry _entry = ad.GetEntry();
  Print("AC: ", _entry.ToString());
  assertTrueOrReturn(
    ad.GetValue() == ad_value,
    "AD value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value == ad_value,
    "AD entry value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value <= 0,
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  ADX_Params params(14, PRICE_HIGH);
  Indi_ADX *adx = new Indi_ADX(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Indi_AO *ao = new Indi_AO(iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  ATR_Params params(14);
  Indi_ATR *atr = new Indi_ATR(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Alligator_Params params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  Indi_Alligator *alligator = new Indi_Alligator(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Indi_BWMFI *bwmfi = new Indi_BWMFI(iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Bands_Params params(20, 2, 0, PRICE_LOW);
  Indi_Bands *bands = new Indi_Bands(params, iparams, cparams);
  Bands_Entry _entry = bands.GetValue();
  Print("Bands: ", _entry.ToString());
  assertTrueOrReturn(
    _entry.value[BAND_BASE] == bands_value,
    "Bands value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value[BAND_LOWER] < _entry.value[BAND_UPPER],
    "Bands lower value should be less than upper value!",
    false);
  assertTrueOrReturn(
    _entry.value[BAND_UPPER] > _entry.value[BAND_BASE],
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  BearsPower_Params params(13, PRICE_CLOSE);
  Indi_BearsPower *bp = new Indi_BearsPower(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  BullsPower_Params params(13, PRICE_CLOSE);
  Indi_BullsPower *bp = new Indi_BullsPower(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  CCI_Params params(14, PRICE_CLOSE);
  Indi_CCI *cci = new Indi_CCI(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  DeMarker_Params params(14);
  Indi_DeMarker *dm = new Indi_DeMarker(params, iparams, cparams);
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
 * Test Envelopes indicator.
 */
bool TestEnvelopes() {
  // Get static value.
  double env_value = Indi_Envelopes::iEnvelopes(_Symbol, PERIOD_CURRENT, 13, 0, MODE_SMA, PRICE_CLOSE, 2, LINE_UPPER);
  // Get dynamic values.
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Envelopes_Params params(13, 0, MODE_SMA, PRICE_CLOSE, 2);
  Indi_Envelopes *env = new Indi_Envelopes(params, iparams, cparams);
  Envelopes_Entry _entry = env.GetValue();
  Print("Envelopes: ", _entry.ToString());
  assertTrueOrReturn(
    _entry.value[LINE_UPPER] == env_value,
    "Envelopes value does not match!",
    false);
  assertTrueOrReturn(
    _entry.value[LINE_LOWER] < _entry.value[LINE_UPPER],
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Force_Params params(13, MODE_SMA, PRICE_CLOSE);
  Indi_Force *force = new Indi_Force(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Indi_Fractals *fractals = new Indi_Fractals(iparams, cparams);
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
  double gator_value = Indi_Gator::iGator(_Symbol, PERIOD_CURRENT, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, LINE_JAW);
  // Get dynamic values.
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Gator_Params params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  Indi_Gator *gator = new Indi_Gator(params, iparams, cparams);
  Print("Gator: ", gator.GetValue(LINE_JAW));
  assertTrueOrReturn(
    gator.GetValue(LINE_JAW) == gator_value,
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Indi_HeikenAshi *ha = new Indi_HeikenAshi(iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Ichimoku_Params params(9, 26, 52);
  Indi_Ichimoku *ichimoku = new Indi_Ichimoku(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  MA_Params params(13, 10, MODE_SMA, PRICE_CLOSE);
  Indi_MA *_ma = new Indi_MA(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  MACD_Params params(12, 26, 9, PRICE_CLOSE);
  Indi_MACD *macd = new Indi_MACD(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  MFI_Params params(14);
  Indi_MFI *mfi = new Indi_MFI(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Momentum_Params params(12, PRICE_CLOSE);
  Indi_Momentum *mom = new Indi_Momentum(params, iparams, cparams);
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
  double obv_value = Indi_OBV::iOBV(_Symbol, PERIOD_CURRENT, PRICE_CLOSE);
  // Get dynamic values.
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  OBV_Params params(PRICE_CLOSE);
  Indi_OBV *obv = new Indi_OBV(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  OsMA_Params params(12, 26, 9, PRICE_CLOSE);
  Indi_OsMA *osma = new Indi_OsMA(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  RSI_Params params(14, PRICE_CLOSE);
  Indi_RSI *rsi = new Indi_RSI(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  RVI_Params params(14);
  Indi_RVI *rvi = new Indi_RVI(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  SAR_Params params(0.02, 0.2);
  Indi_SAR *sar = new Indi_SAR(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  StdDev_Params params(13, 10, MODE_SMA, PRICE_CLOSE);
  Indi_StdDev *sd = new Indi_StdDev(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  Stoch_Params params(5, 3, 3, MODE_SMMA, STO_LOWHIGH);
  Indi_Stochastic *stoch = new Indi_Stochastic(params, iparams, cparams);
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
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  WPR_Params params(14);
  Indi_WPR *wpr = new Indi_WPR(params, iparams, cparams);
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
  double zz_value = Indi_ZigZag::iZigZag(_Symbol, PERIOD_CURRENT, 12, 5, 3, 0);
  // Get dynamic values.
  IndicatorParams iparams;
  ChartParams cparams(PERIOD_CURRENT);
  ZigZag_Params params(12, 5, 3);
  Indi_ZigZag *zz = new Indi_ZigZag(params, iparams, cparams);
  Print("ZigZag: ", zz.GetValue());
  assertTrueOrReturn(
    zz.GetValue() == zz_value,
    "ZigZag value does not match!",
    false);
  zz.SetDepth(zz.GetDepth()+1);
  zz.SetDeviation(zz.GetDeviation()+1);
  zz.SetBackstep(zz.GetBackstep()+1);
  // Clean up.
  delete zz;
  return true;
}
