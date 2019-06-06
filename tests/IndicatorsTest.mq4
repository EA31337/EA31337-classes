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
 * Test functionality for Indicator class.
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
#include "../Indicators/Indi_RSI.mqh"
#include "../Indicators/Indi_RVI.mqh"
#include "../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  bool _result = True;
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
  _result &= TestRSI();
  _result &= TestRVI();
  return (INIT_SUCCEEDED);
}

/**
 * Test AC indicator.
 */
bool TestAC() {
  // Initialize params.
  AC_Params params;
  params.shift = 0;
  // Get static value.
  double ac_value = Indi_AC::iAC(_Symbol, (ENUM_TIMEFRAMES) _Period, params.shift);
  // Get dynamic values.
  Indi_AC *ac = new Indi_AC(params);
  Print("AC: ", ac.GetValue());
  assertTrueOrReturn(
    ac.GetValue() == ac_value,
    "AC value does not match!",
    False);
  ac.SetShift(ac.GetShift()+1);
  // Clean up.
  delete ac;
  return True;
}

/**
 * Test AD indicator.
 */
bool TestAD() {
  // Initialize params.
  AD_Params params;
  params.shift = 0;
  // Get static value.
  double ad_value = Indi_AD::iAD(_Symbol, (ENUM_TIMEFRAMES) _Period, params.shift);
  // Get dynamic values.
  Indi_AD *ad = new Indi_AD(params);
  Print("AD: ", ad.GetValue());
  assertTrueOrReturn(
    ad.GetValue() == ad_value,
    "AD value does not match!",
    False);
  ad.SetShift(ad.GetShift()+1);
  // Clean up.
  delete ad;
  return True;
}

/**
 * Test ADX indicator.
 */
bool TestADX() {
  // Initialize params.
  ADX_Params params;
  params.period = 14;
  params.applied_price = PRICE_HIGH;
  params.mode = LINE_MAIN_ADX;
  params.shift = 0;
  // Get static value.
  double adx_value = Indi_ADX::iADX(_Symbol, (ENUM_TIMEFRAMES) _Period, params.period, params.applied_price, params.mode, params.shift);
  // Get dynamic values.
  Indi_ADX *adx = new Indi_ADX(params);
  Print("ADX: ", adx.GetValue());
  assertTrueOrReturn(
    adx.GetValue() == adx_value,
    "ADX value does not match!",
    False);
  adx.SetPeriod(adx.GetPeriod()+1);
  adx.SetShift(adx.GetShift()+1);
  // Clean up.
  delete adx;
  return True;
}

/**
 * Test AO indicator.
 */
bool TestAO() {
  // Initialize params.
  AO_Params params;
  params.shift = 0;
  // Get static value.
  double ao_value = Indi_AO::iAO(_Symbol, (ENUM_TIMEFRAMES) _Period, params.shift);
  // Get dynamic values.
  Indi_AO *ao = new Indi_AO(params);
  Print("AO: ", ao.GetValue());
  assertTrueOrReturn(
    ao.GetValue() == ao_value,
    "AO value does not match!",
    False);
  ao.SetShift(ao.GetShift()+1);
  // Clean up.
  delete ao;
  return True;
}

/**
 * Test ATR indicator.
 */
bool TestATR() {
  // Initialize params.
  ATR_Params params;
  params.period = 14;
  params.shift = 0;
  // Get static value.
  double atr_value = Indi_ATR::iATR(_Symbol, (ENUM_TIMEFRAMES) _Period, params.period, params.shift);
  // Get dynamic values.
  Indi_ATR *atr = new Indi_ATR(params);
  Print("ATR: ", atr.GetValue());
  assertTrueOrReturn(
    atr.GetValue() == atr_value,
    "ATR value does not match!",
    False);
  atr.SetPeriod(atr.GetPeriod()+1);
  atr.SetShift(atr.GetShift()+1);
  // Clean up.
  delete atr;
  return True;
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
  params.mode = LINE_JAW;
  params.shift = 0;
  // Get static value.
  double alligator_value = Indi_Alligator::iAlligator(
    _Symbol,
    (ENUM_TIMEFRAMES) _Period,
    params.jaw_period,
    params.jaw_shift,
    params.teeth_period,
    params.teeth_shift,
    params.lips_period,
    params.lips_shift,
    params.ma_method,
    params.applied_price,
    params.mode,
    params.shift
    );
  // Get dynamic values.
  Indi_Alligator *alligator = new Indi_Alligator(params);
  Print("Alligator: ", alligator.GetValue());
  assertTrueOrReturn(
    alligator.GetValue() == alligator_value,
    "Alligator value does not match!",
    False);
  alligator.SetJawPeriod(alligator.GetJawPeriod()+1);
  alligator.SetJawShift(alligator.GetJawShift()+1);
  alligator.SetTeethPeriod(alligator.GetTeethPeriod()+1);
  alligator.SetTeethShift(alligator.GetTeethShift()+1);
  alligator.SetLipsPeriod(alligator.GetLipsPeriod()+1);
  alligator.SetLipsShift(alligator.GetLipsShift()+1);
  alligator.SetMode(LINE_TEETH);
  alligator.SetShift(alligator.GetShift()+1);
  // Clean up.
  delete alligator;
  return True;
}

/**
 * Test BWMFI indicator.
 */
bool TestBWMFI() {
  // Initialize params.
  BWMFI_Params params;
  params.shift = 0;
  // Get static value.
  double bwmfi_value = Indi_BWMFI::iBWMFI(_Symbol, (ENUM_TIMEFRAMES) _Period, params.shift);
  // Get dynamic values.
  Indi_BWMFI *bwmfi = new Indi_BWMFI(params);
  Print("BWMFI: ", bwmfi.GetValue());
  assertTrueOrReturn(
    bwmfi.GetValue() == bwmfi_value,
    "BWMFI value does not match!",
    False);
  bwmfi.SetShift(bwmfi.GetShift()+1);
  // Clean up.
  delete bwmfi;
  return True;
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
  params.mode = BAND_BASE;
  params.shift = 0;
  // Get static value.
  double bands_value = Indi_Bands::iBands(
    _Symbol,
    (ENUM_TIMEFRAMES) _Period,
    params.period,
    params.deviation,
    params.bands_shift,
    params.applied_price,
    params.mode,
    params.shift
    );
  // Get dynamic values.
  Indi_Bands *bands = new Indi_Bands(params);
  Print("Bands: ", bands.GetValue());
  assertTrueOrReturn(
    bands.GetValue() == bands_value,
    "Bands value does not match!",
    False);
  bands.SetPeriod(bands.GetPeriod()+1);
  bands.SetDeviation(bands.GetDeviation()+0.1);
  bands.SetBandsShift(bands.GetBandsShift()+1);
  bands.SetMode(BAND_LOWER);
  bands.SetShift(bands.GetShift()+1);
  // Clean up.
  delete bands;
  return True;
}

/**
 * Test BearsPower indicator.
 */
bool TestBearsPower() {
  // Initialize params.
  BearsPower_Params params;
  params.period = 13;
  params.applied_price = PRICE_CLOSE;
  params.shift = 0;
  // Get static value.
  double bp_value = Indi_BearsPower::iBearsPower(_Symbol, (ENUM_TIMEFRAMES) _Period, params.period, params.applied_price, params.shift);
  // Get dynamic values.
  Indi_BearsPower *bp = new Indi_BearsPower(params);
  Print("BearsPower: ", bp.GetValue());
  assertTrueOrReturn(
    bp.GetValue() == bp_value,
    "BearsPower value does not match!",
    False);
  bp.SetPeriod(bp.GetPeriod()+1);
  bp.SetAppliedPrice(PRICE_MEDIAN);
  bp.SetShift(bp.GetShift()+1);
  // Clean up.
  delete bp;
  return True;
}

/**
 * Test BullsPower indicator.
 */
bool TestBullsPower() {
  // Initialize params.
  BullsPower_Params params;
  params.period = 13;
  params.applied_price = PRICE_CLOSE;
  params.shift = 0;
  // Get static value.
  double bp_value = Indi_BullsPower::iBullsPower(_Symbol, (ENUM_TIMEFRAMES) _Period, params.period, params.applied_price, params.shift);
  // Get dynamic values.
  Indi_BullsPower *bp = new Indi_BullsPower(params);
  Print("BullsPower: ", bp.GetValue());
  assertTrueOrReturn(
    bp.GetValue() == bp_value,
    "BullsPower value does not match!",
    False);
  bp.SetPeriod(bp.GetPeriod()+1);
  bp.SetAppliedPrice(PRICE_MEDIAN);
  bp.SetShift(bp.GetShift()+1);
  // Clean up.
  delete bp;
  return True;
}

/**
 * Test CCI indicator.
 */
bool TestCCI() {
  // Initialize params.
  CCI_Params params;
  params.period = 14;
  params.applied_price = PRICE_CLOSE;
  params.shift = 0;
  // Get static value.
  double cci_value = Indi_CCI::iCCI(_Symbol, (ENUM_TIMEFRAMES) _Period, params.period, params.applied_price, params.shift);
  // Get dynamic values.
  Indi_CCI *cci = new Indi_CCI(params);
  Print("CCI: ", cci.GetValue());
  assertTrueOrReturn(
    cci.GetValue() == cci_value,
    "CCI value does not match!",
    False);
  cci.SetPeriod(cci.GetPeriod()+1);
  cci.SetShift(cci.GetShift()+1);
  // Clean up.
  delete cci;
  return True;
}

/**
 * Test DeMarker indicator.
 */
bool TestDeMarker() {
  // Initialize params.
  DeMarker_Params params;
  params.period = 14;
  params.shift = 0;
  // Get static value.
  double dm_value = Indi_DeMarker::iDeMarker(_Symbol, (ENUM_TIMEFRAMES) _Period, params.period, params.shift);
  // Get dynamic values.
  Indi_DeMarker *dm = new Indi_DeMarker(params);
  Print("DeMarker: ", dm.GetValue());
  assertTrueOrReturn(
    dm.GetValue() == dm_value,
    "DeMarker value does not match!",
    False);
  dm.SetPeriod(dm.GetPeriod()+1);
  dm.SetShift(dm.GetShift()+1);
  // Clean up.
  delete dm;
  return True;
}

/**
 * Test env indicator.
 */
bool TestEnvelopes() {
  // Initialize params.
  Envelopes_Params params;
  params.ma_period = 13;
  params.ma_method = MODE_SMA;
  params.ma_shift = 10;
  params.applied_price = PRICE_CLOSE;
  params.deviation = 2;
  params.mode = LINE_UPPER;
  params.shift = 0;
  // Get static value.
  double env_value = Indi_Envelopes::iEnvelopes(
    _Symbol,
    (ENUM_TIMEFRAMES) _Period,
    params.ma_period,
    params.ma_method,
    params.ma_shift,
    params.applied_price,
    params.deviation,
    params.mode,
    params.shift
    );
  // Get dynamic values.
  Indi_Envelopes *env = new Indi_Envelopes(params);
  Print("Envelopes: ", env.GetValue());
  assertTrueOrReturn(
    env.GetValue() == env_value,
    "Envelopes value does not match!",
    False);
  env.SetMAPeriod(env.GetMAPeriod()+1);
  env.SetMAMethod(MODE_SMA);
  env.SetMAShift(env.GetMAShift()+1);
  env.SetAppliedPrice(PRICE_MEDIAN);
  env.SetDeviation(env.GetDeviation()+0.1);
  env.SetMode(LINE_LOWER);
  env.SetShift(env.GetShift()+1);
  // Clean up.
  delete env;
  return True;
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
  params.shift = 0;
  // Get static value.
  double force_value = Indi_Force::iForce(
    _Symbol,
    (ENUM_TIMEFRAMES) _Period,
    params.period,
    params.ma_method,
    params.applied_price,
    params.shift
    );
  // Get dynamic values.
  Indi_Force *force = new Indi_Force(params);
  Print("Force: ", force.GetValue());
  assertTrueOrReturn(
    force.GetValue() == force_value,
    "Force value does not match!",
    False);
  force.SetPeriod(force.GetPeriod()+1);
  force.SetMAMethod(MODE_SMA);
  force.SetAppliedPrice(PRICE_MEDIAN);
  force.SetShift(force.GetShift()+1);
  // Clean up.
  delete force;
  return True;
}

/**
 * Test Fractals indicator.
 */
bool TestFractals() {
  // Initialize params.
  Fractals_Params params;
  params.mode = LINE_UPPER;
  params.shift = 0;
  // Get static value.
  double fractals_value = Indi_Fractals::iFractals(
    _Symbol,
    (ENUM_TIMEFRAMES) _Period,
    params.mode,
    params.shift
    );
  // Get dynamic values.
  Indi_Fractals *fractals = new Indi_Fractals(params);
  Print("Fractals: ", fractals.GetValue());
  assertTrueOrReturn(
    fractals.GetValue() == fractals_value,
    "Fractals value does not match!",
    False);
  fractals.SetMode(LINE_LOWER);
  fractals.SetShift(fractals.GetShift()+1);
  // Clean up.
  delete fractals;
  return True;
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
  params.mode = LINE_JAW;
  params.shift = 0;
  // Get static value.
  double gator_value = Indi_Gator::iGator(
    _Symbol,
    (ENUM_TIMEFRAMES) _Period,
    params.jaw_period,
    params.jaw_shift,
    params.teeth_period,
    params.teeth_shift,
    params.lips_period,
    params.lips_shift,
    params.ma_method,
    params.applied_price,
    params.mode,
    params.shift
    );
  // Get dynamic values.
  Indi_Gator *gator = new Indi_Gator(params);
  Print("Gator: ", gator.GetValue());
  assertTrueOrReturn(
    gator.GetValue() == gator_value,
    "Gator value does not match!",
    False);
  gator.SetJawPeriod(gator.GetJawPeriod()+1);
  gator.SetJawShift(gator.GetJawShift()+1);
  gator.SetTeethPeriod(gator.GetTeethPeriod()+1);
  gator.SetTeethShift(gator.GetTeethShift()+1);
  gator.SetLipsPeriod(gator.GetLipsPeriod()+1);
  gator.SetLipsShift(gator.GetLipsShift()+1);
  gator.SetMode(LINE_TEETH);
  gator.SetShift(gator.GetShift()+1);
  // Clean up.
  delete gator;
  return True;
}

/**
 * Test HeikenAshi indicator.
 */
bool TestHeikenAshi() {
  // Initialize params.
  HeikenAshi_Params params;
  params.mode = HA_OPEN;
  params.shift = 0;
  // Get static value.
  double ha_value = Indi_HeikenAshi::iHeikenAshi(_Symbol, (ENUM_TIMEFRAMES) _Period, params.mode, params.shift);
  // Get dynamic values.
  Indi_HeikenAshi *ha = new Indi_HeikenAshi(params);
  Print("HeikenAshi: ", ha.GetValue());
  assertTrueOrReturn(
    ha.GetValue() == ha_value,
    "HeikenAshi value does not match!",
    False);
  ha.SetMode(HA_CLOSE);
  ha.SetShift(ha.GetShift()+1);
  // Clean up.
  delete ha;
  return True;
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
  params.mode = LINE_TENKANSEN;
  params.shift = 0;
  // Get static value.
  double ichimoku_value = Indi_Ichimoku::iIchimoku(
    _Symbol,
    (ENUM_TIMEFRAMES) _Period,
    params.tenkan_sen,
    params.kijun_sen,
    params.senkou_span_b,
    params.mode,
    params.shift
    );
  // Get dynamic values.
  Indi_Ichimoku *ichimoku = new Indi_Ichimoku(params);
  Print("Ichimoku: ", ichimoku.GetValue(LINE_TENKANSEN));
  assertTrueOrReturn(
    ichimoku.GetValue(LINE_TENKANSEN) == ichimoku_value,
    "Ichimoku value does not match!",
    False);
  ichimoku.SetTenkanSen(ichimoku.GetTenkanSen()+1);
  ichimoku.SetKijunSen(ichimoku.GetKijunSen()+1);
  ichimoku.SetSenkouSpanB(ichimoku.GetSenkouSpanB()+1);
  ichimoku.SetMode(LINE_KIJUNSEN);
  ichimoku.SetShift(ichimoku.GetShift()+1);
  // Clean up.
  delete ichimoku;
  return True;
}

/**
 * Test RSI indicator.
 */
bool TestRSI() {
  // Initialize params.
  RSI_Params params;
  params.period = 14;
  params.applied_price = PRICE_CLOSE;
  params.shift = 0;
  // Get static value.
  double rsi_value = Indi_RSI::iRSI(_Symbol, (ENUM_TIMEFRAMES) _Period, params.period, params.applied_price, params.shift);
  // Get dynamic values.
  Indi_RSI *rsi = new Indi_RSI(params);
  Print("RSI: ", rsi.GetValue());
  assertTrueOrReturn(
    rsi.GetValue() == rsi_value,
    "RSI value does not match!",
    False);
  rsi.SetPeriod(rsi.GetPeriod()+1);
  rsi.SetShift(rsi.GetShift()+1);
  rsi.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete rsi;
  return True;
}

/**
 * Test RVI indicator.
 */
bool TestRVI() {
  // Initialize params.
  RVI_Params params;
  params.period = 14;
  params.mode = LINE_MAIN;
  params.shift = 0;
  // Get static value.
  double rvi_value = Indi_RVI::iRVI(_Symbol, (ENUM_TIMEFRAMES) _Period, params.period, params.mode, params.shift);
  // Get dynamic values.
  Indi_RVI *rvi = new Indi_RVI(params);
  Print("RVI: ", rvi.GetValue());
  assertTrueOrReturn(
    rvi.GetValue() == rvi_value,
    "RVI value does not match!",
    False);
  rvi.SetPeriod(rvi.GetPeriod()+1);
  rvi.SetShift(rvi.GetShift()+1);
  // Clean up.
  delete rvi;
  return True;
}
