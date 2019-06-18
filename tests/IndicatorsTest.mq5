//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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
 * Test functionality for Indicator classes.
 */

// Properties.
#property strict

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

/**
 * Implements Init event handler.
 */
int OnInit() {
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
  return (INIT_SUCCEEDED);
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
}

/**
 * Test AC indicator.
 */
bool TestAC() {
  // Get static value.
  double ac_value = Indi_AC::iAC();
  // Get dynamic values.
  Indi_AC *ac = new Indi_AC();
  Print("AC: ", ac.GetValue());
  assertTrueOrReturn(
    ac.GetValue() == ac_value,
    "AC value does not match!",
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
  Indi_AD *ad = new Indi_AD();
  Print("AD: ", ad.GetValue());
  assertTrueOrReturn(
    ad.GetValue() == ad_value,
    "AD value does not match!",
    false);
  // Clean up.
  delete ad;
  return true;
}

/**
 * Test ADX indicator.
 */
bool TestADX() {
  // Initialize params.
  ADX_Params params = {14, PRICE_HIGH};
  // Get static value.
  double adx_value = Indi_ADX::iADX(_Symbol, PERIOD_CURRENT, params.period, params.applied_price, LINE_MAIN_ADX);
  // Get dynamic values.
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
  Indi_AO *ao = new Indi_AO();
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
  // Initialize params.
  ATR_Params params = {14};
  // Get static value.
  double atr_value = Indi_ATR::iATR(_Symbol, PERIOD_CURRENT, params.period);
  // Get dynamic values.
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
  // Initialize params.
  Alligator_Params params;
  params.jaw_period = 13;
  params.jaw_shift = 8;
  params.teeth_period = 8;
  params.teeth_shift = 5;
  params.lips_period = 5;
  params.lips_shift = 3;
  params.ma_method = MODE_SMMA;
  params.applied_price = PRICE_MEDIAN;
  // Get static value.
  double alligator_value = Indi_Alligator::iAlligator(
    _Symbol,
    PERIOD_CURRENT,
    params.jaw_period,
    params.jaw_shift,
    params.teeth_period,
    params.teeth_shift,
    params.lips_period,
    params.lips_shift,
    params.ma_method,
    params.applied_price,
    LINE_JAW
    );
  // Get dynamic values.
  Indi_Alligator *alligator = new Indi_Alligator(params);
  Print("Alligator: ", alligator.GetValue(LINE_JAW));
  assertTrueOrReturn(
    alligator.GetValue(LINE_JAW) == alligator_value,
    "Alligator value does not match!",
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
  Indi_BWMFI *bwmfi = new Indi_BWMFI();
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
  // Initialize params.
  Bands_Params params;
  params.period = 20;
  params.deviation = 2;
  params.bands_shift = 0;
  params.applied_price = PRICE_LOW;
  // Get static value.
  double bands_value = Indi_Bands::iBands(
    _Symbol,
    PERIOD_CURRENT,
    params.period,
    params.deviation,
    params.bands_shift,
    params.applied_price,
    BAND_BASE
    );
  // Get dynamic values.
  Indi_Bands *bands = new Indi_Bands(params);
  Print("Bands: ", bands.GetValue(BAND_BASE));
  assertTrueOrReturn(
    bands.GetValue(BAND_BASE) == bands_value,
    "Bands value does not match!",
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
  // Initialize params.
  BearsPower_Params params;
  params.period = 13;
  params.applied_price = PRICE_CLOSE;
  // Get static value.
  double bp_value = Indi_BearsPower::iBearsPower(_Symbol, PERIOD_CURRENT, params.period, params.applied_price);
  // Get dynamic values.
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
  // Initialize params.
  BullsPower_Params params;
  params.period = 13;
  params.applied_price = PRICE_CLOSE;
  // Get static value.
  double bp_value = Indi_BullsPower::iBullsPower(_Symbol, PERIOD_CURRENT, params.period, params.applied_price);
  // Get dynamic values.
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
  // Initialize params.
  CCI_Params params;
  params.period = 14;
  params.applied_price = PRICE_CLOSE;
  // Get static value.
  double cci_value = Indi_CCI::iCCI(_Symbol, PERIOD_CURRENT, params.period, params.applied_price);
  // Get dynamic values.
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
  // Initialize params.
  DeMarker_Params params;
  params.period = 14;
  // Get static value.
  double dm_value = Indi_DeMarker::iDeMarker(_Symbol, PERIOD_CURRENT, params.period);
  // Get dynamic values.
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
 * Test Envelopes indicator.
 */
bool TestEnvelopes() {
  // Initialize params.
  Envelopes_Params params;
  params.ma_period = 13;
  params.ma_method = MODE_SMA;
  params.ma_shift = 10;
  params.applied_price = PRICE_CLOSE;
  params.deviation = 2;
  // Get static value.
  double env_value = Indi_Envelopes::iEnvelopes(
    _Symbol,
    PERIOD_CURRENT,
    params.ma_period,
    params.ma_method,
    params.ma_shift,
    params.applied_price,
    params.deviation,
    LINE_UPPER
    );
  // Get dynamic values.
  Indi_Envelopes *env = new Indi_Envelopes(params);
  Print("Envelopes: ", env.GetValue(LINE_UPPER));
  assertTrueOrReturn(
    env.GetValue(LINE_UPPER) == env_value,
    "Envelopes value does not match!",
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
  // Initialize params.
  Force_Params params;
  params.period = 13;
  params.ma_method = MODE_SMA;
  params.applied_price = PRICE_CLOSE;
  // Get static value.
  double force_value = Indi_Force::iForce(
    _Symbol,
    PERIOD_CURRENT,
    params.period,
    params.ma_method,
    params.applied_price
    );
  // Get dynamic values.
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
  Indi_Fractals *fractals = new Indi_Fractals();
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
  // Initialize params.
  Gator_Params params;
  params.jaw_period = 13;
  params.jaw_shift = 8;
  params.teeth_period = 8;
  params.teeth_shift = 5;
  params.lips_period = 5;
  params.lips_shift = 3;
  params.ma_method = MODE_SMMA;
  params.applied_price = PRICE_MEDIAN;
  // Get static value.
  double gator_value = Indi_Gator::iGator(
    _Symbol,
    PERIOD_CURRENT,
    params.jaw_period,
    params.jaw_shift,
    params.teeth_period,
    params.teeth_shift,
    params.lips_period,
    params.lips_shift,
    params.ma_method,
    params.applied_price,
    LINE_JAW
    );
  // Get dynamic values.
  Indi_Gator *gator = new Indi_Gator(params);
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
  Indi_HeikenAshi *ha = new Indi_HeikenAshi();
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
  // Initialize params.
  Ichimoku_Params params;
  params.tenkan_sen = 9;
  params.kijun_sen = 26;
  params.senkou_span_b = 52;
  // Get static value.
  double ichimoku_value = Indi_Ichimoku::iIchimoku(
    _Symbol,
    PERIOD_CURRENT,
    params.tenkan_sen,
    params.kijun_sen,
    params.senkou_span_b,
    LINE_TENKANSEN
    );
  // Get dynamic values.
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
  // Initialize params.
  MA_Params params;
  params.ma_period = 13;
  params.ma_shift = 10;
  params.ma_method = MODE_SMA;
  params.applied_price = PRICE_CLOSE;
  // Get static value.
  double ma_value = Indi_MA::iMA(
    _Symbol,
    PERIOD_CURRENT,
    params.ma_period,
    params.ma_shift,
    params.ma_method,
    params.applied_price
    );
  // Get dynamic values.
  Indi_MA *ma = new Indi_MA(params);
  Print("MA: ", ma.GetValue());
  assertTrueOrReturn(
    ma.GetValue() == ma_value,
    "MA value does not match!",
    false);
  ma.SetPeriod(ma.GetPeriod()+1);
  ma.SetMAShift(ma.GetMAShift()+1);
  ma.SetMAMethod(MODE_SMA);
  ma.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete ma;
  return true;
}

/**
 * Test MACD indicator.
 */
bool TestMACD() {
  // Initialize params.
  MACD_Params params;
  params.ema_fast_period = 12;
  params.ema_slow_period = 26;
  params.signal_period = 9;
  params.applied_price = PRICE_CLOSE;
  // Get static value.
  double macd_value = Indi_MACD::iMACD(
    _Symbol,
    PERIOD_CURRENT,
    params.ema_fast_period,
    params.ema_slow_period,
    params.signal_period,
    params.applied_price,
    LINE_MAIN
    );
  // Get dynamic values.
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
  // Initialize params.
  MFI_Params params;
  params.ma_period = 14;
  params.applied_volume = VOLUME_TICK; // Used in MT5 only.
  // Get static value.
  double mfi_value = Indi_MFI::iMFI(_Symbol, PERIOD_CURRENT, params.ma_period);
  // Get dynamic values.
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
  // Initialize params.
  Momentum_Params params;
  params.period = 12;
  params.applied_price = PRICE_CLOSE;
  // Get static value.
  double mom_value = Indi_Momentum::iMomentum(_Symbol, PERIOD_CURRENT, params.period, params.applied_price);
  // Get dynamic values.
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
  // Initialize params.
  OBV_Params params;
  params.applied_price = PRICE_CLOSE; // Used in MT4.
  params.applied_volume = VOLUME_TICK; // Used in MT5.
  // Get static value.
  double obv_value = Indi_OBV::iOBV(_Symbol, PERIOD_CURRENT, params.applied_price);
  // Get dynamic values.
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
  // Initialize params.
  OsMA_Params params;
  params.ema_fast_period = 12;
  params.ema_slow_period = 26;
  params.signal_period = 9;
  params.applied_price = PRICE_CLOSE;
  // Get static value.
  double osma_value = Indi_OsMA::iOsMA(
    _Symbol,
    PERIOD_CURRENT,
    params.ema_fast_period,
    params.ema_slow_period,
    params.signal_period,
    params.applied_price
    );
  // Get dynamic values.
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
  // Initialize params.
  RSI_Params params;
  params.period = 14;
  params.applied_price = PRICE_CLOSE;
  // Get static value.
  double rsi_value = Indi_RSI::iRSI(_Symbol, PERIOD_CURRENT, params.period, params.applied_price);
  // Get dynamic values.
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
  // Initialize params.
  RVI_Params params;
  params.period = 14;
  // Get static value.
  double rvi_value = Indi_RVI::iRVI(_Symbol, PERIOD_CURRENT, params.period, LINE_MAIN);
  // Get dynamic values.
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
  // Initialize params.
  SAR_Params params;
  params.step = 0.02;
  params.max  = 0.2;
  // Get static value.
  double sar_value = Indi_SAR::iSAR();
  // Get dynamic values.
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
  // Initialize params.
  StdDev_Params params;
  params.ma_period = 13;
  params.ma_shift = 10;
  params.ma_method = MODE_SMA;
  params.applied_price = PRICE_CLOSE;
  // Get static value.
  double sd_value = Indi_StdDev::iStdDev(
    _Symbol,
    PERIOD_CURRENT,
    params.ma_period,
    params.ma_shift,
    params.ma_method,
    params.applied_price
    );
  // Get dynamic values.
  Indi_StdDev *sd = new Indi_StdDev(params);
  Print("StdDev: ", sd.GetValue());
  assertTrueOrReturn(
    sd.GetValue() == sd_value,
    "StdDev value does not match!",
    false);
  sd.SetPeriod(sd.GetPeriod()+1);
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
  // Initialize params.
  Stoch_Params params;
  params.kperiod = 5;
  params.dperiod = 3;
  params.slowing = 3;
  params.ma_method = MODE_SMMA;
  params.price_field = STO_LOWHIGH;
  // Get static value.
  double stoch_value = Indi_Stochastic::iStochastic(
    _Symbol,
    PERIOD_CURRENT,
    params.kperiod,
    params.dperiod,
    params.slowing,
    params.ma_method,
    params.price_field,
    LINE_MAIN,
    0
    );
  // Get dynamic values.
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
  // Initialize params.
  WPR_Params params;
  params.period = 14;
  // Get static value.
  double wpr_value = Indi_WPR::iWPR(_Symbol, PERIOD_CURRENT, params.period, 0);
  // Get dynamic values.
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
  // Initialize params.
  ZigZag_Params params;
  params.depth = 12;
  params.deviation = 5;
  params.backstep = 3;
  // Get static value.
  double zz_value = Indi_ZigZag::iZigZag(_Symbol, PERIOD_CURRENT, params.depth, params.deviation, params.backstep, 0);
  // Get dynamic values.
  Indi_ZigZag *zz = new Indi_ZigZag(params);
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
