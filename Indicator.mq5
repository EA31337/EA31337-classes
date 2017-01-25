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
 * Test functionality of Indicator class.
 */

// Includes.
#include "Indicator.mqh"

// Properties.
#property strict

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
  // MA
  IndicatorParams ma_params;
  ma_params.max_buffer = 5;
  ma_params.type = S_IND_MA;
  Indicator *indi_ma = new Indicator(ma_params);
  indi_ma.Add(0.1);
  indi_ma.Add(0.2);
  Print(indi_ma.GetValue(CURR, 0, (double) NULL));
  // MACD
  IndicatorParams macd_params;
  macd_params.type = S_IND_MACD;
  Indicator *indi_macd = new Indicator(macd_params);
  indi_macd.Add(0.1, MODE_MAIN);
  indi_macd.Add(0.2, MODE_SIGNAL);
  PrintFormat("%s: Main=%g", indi_macd.GetName(), indi_macd.GetValue(CURR, MODE_MAIN, (double) NULL));
  PrintFormat("%s: Signal=%g", indi_macd.GetName(), indi_macd.GetValue(CURR, MODE_SIGNAL, (double) NULL));
  indi_macd.PrintData();
  return (INIT_SUCCEEDED);
}