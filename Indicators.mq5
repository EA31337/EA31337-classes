//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
   This file is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of Indicators class.
 */

// Properties.
#property strict

// Includes.
#include "Indicators.mqh"

// Define assert macros.
#define assert(cond, msg) \
  if (!(cond)) { \
    Alert(msg + " - Fail on " + #cond + " in " + __FILE__ + ":" + (string) __LINE__); \
    return (INIT_FAILED); \
  }

/**
 * Implements OnInit().
 */
int OnInit() {
  Indicators *inds = new Indicators();
  assert(inds.iAC() > 0, "Invalid value for iAC");
  assert(inds.iAD() > 0, "Invalid value for iAD");
  assert(inds.iADX(14, PRICE_CLOSE, MAIN_LINE) > 0, "Invalid value for iADX");
  assert(inds.iAlligator(_Symbol, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, GATORJAW_LINE) > 0, "Invalid value for iAlligator");
  assert(inds.iAO(_Symbol, 0) > 0, "Invalid value for iAO");
  assert(inds.iATR(_Symbol, 0, 14, 0) > 0, "Invalid value for iATR");
  assert(inds.iBearsPower(13, PRICE_CLOSE, 0) > 0, "Invalid value for iBearsPower");
  assert(inds.iBands(20, 2, 0, PRICE_CLOSE, UPPER_BAND) > 0, "Invalid value for iBands");
  assert(inds.iBullsPower(_Symbol, 0, 13, PRICE_CLOSE, 0) > 0, "Invalid value for iBullsPower");
  assert(inds.iCCI(14, PRICE_CLOSE, 0) > 0, "Invalid value for iCCI");
  assert(inds.iDeMarker(_Symbol, 0, 20, 0) > 0, "Invalid value for iDeMarker");
  assert(inds.iEnvelopes(50, MODE_EMA, 0, PRICE_CLOSE, 0.1, UPPER_LINE) > 0, "Invalid value for iEnvelopes");
  assert(inds.iForce(13, MODE_SMA, PRICE_CLOSE, 0) > 0, "Invalid value for iForce");
  assert(inds.iFractals(_Symbol, 0, UPPER_LINE, 0) > 0, "Invalid value for iFractals");
  assert(inds.iGator(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, GATORJAW_LINE, 0) > 0, "Invalid value for iGator");
  assert(inds.iIchimoku(8, 26, 52, TENKANSEN_LINE, 0) > 0, "Invalid value for iIchimoku");
  assert(inds.iBWMFI(_Symbol, 0) > 0, "Invalid value for iBWMFI");
  assert(inds.iMomentum(7, PRICE_TYPICAL, 0) > 0, "Invalid value for iMomentum");
  assert(inds.iMFI(_Symbol, 0, 14, 0) > 0, "Invalid value for iMFI");
  assert(inds.iMA(20, 0, MODE_SMA, PRICE_CLOSE, 0) > 0, "Invalid value for iMA");
  assert(inds.iOsMA(12, 26, 9, PRICE_CLOSE, 0) > 0, "Invalid value for iOsMA");
  assert(inds.iMACD(12, 26, 9, PRICE_CLOSE, 0) > 0, "Invalid value for iMACD");
  assert(inds.iOBV(PRICE_CLOSE, 0) > 0, "Invalid value for iOBV");
  assert(inds.iSAR(_Symbol, 0, 0.01, 0.1, 0) > 0, "Invalid value for iSAR");
  assert(inds.iRSI(14, PRICE_CLOSE, 0) > 0, "Invalid value for iRSI");
  assert(inds.iStdDev(_Symbol, 0, 7, 0, MODE_SMA, PRICE_CLOSE, 0) > 0, "Invalid value for iStdDev");
  assert(inds.iStochastic(13, 3, 3, MODE_SMA, STO_LOWHIGH, 0) > 0, "Invalid value for iStochastic");
  assert(inds.iWPR(14, 0) > 0, "Invalid value for iWPR");
  assert(inds.iHeikenAshi(HA_CLOSE, 0) > 0, "Invalid value for Heiken Ashi");
  assert(inds.iZigZag(12, 8, 5, 0) > 0, "Invalid value for ZigZag");
  
  return (INIT_SUCCEEDED);
}
