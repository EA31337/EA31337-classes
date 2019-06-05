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
