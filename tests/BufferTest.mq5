//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of Buffer class.
 */

// Includes
#include "../Buffer.mqh"

// Variables.
Buffer<double> *buff_price;
Buffer<int> *buff_spread;

/**
 * Implements OnInit().
 */
int OnInit() {
  buff_price = new Buffer<double>();
  buff_spread = new Buffer<int>();
  return (GetLastError() > 0 ? INIT_FAILED : INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {
  buff_price.Add(SymbolInfoDouble(_Symbol, SYMBOL_ASK));
  buff_spread.Add((int) SymbolInfoInteger(_Symbol, SYMBOL_SPREAD));
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  PrintFormat("Total ticks         : %d", buff_price.Size());
  //PrintFormat("Ticks per min       : %d", buff_price.GetCount(PERIOD_M1));
  //PrintFormat("Ticks per hour      : %d", buff_price.GetCount(PERIOD_H1));
  //PrintFormat("Price (min/max)     : %g/%g", buff_price.XXX(), buff_price.YYY());
  //PrintFormat("Price (avg/med)     : %g/%g", buff_price.XXX(), buff_price.YYY());
  //PrintFormat("Spread (min/max)    : %g/%g", buff_spread.XXX());
  //PrintFormat("Spread (avg/med)    : %g/%g", buff_spread.XXX(), buff_spread.YYY());
  CleanUp();
}

/**
 * Deletes created objects to free allocated memory.
 */
void CleanUp() {
  delete buff_price;
  delete buff_spread;
}