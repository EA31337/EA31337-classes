//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
 * Test functionality of Stats class.
 */

// Includes
#include "../Stats.mqh"

// Variables.
Stats<double> *stats_price;
Stats<int> *stats_spread;

/**
 * Implements OnInit().
 */
int OnInit() {
  stats_price = new Stats<double>();
  stats_spread = new Stats<int>();
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {
  stats_price.Add(SymbolInfoDouble(_Symbol, SYMBOL_ASK));
  stats_spread.Add((int) SymbolInfoInteger(_Symbol, SYMBOL_SPREAD));
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  PrintFormat("Total ticks         : %d", stats_price.GetCount());
  PrintFormat("Ticks per min       : %d", stats_price.GetCount(PERIOD_M1));
  PrintFormat("Ticks per hour      : %d", stats_price.GetCount(PERIOD_H1));
  PrintFormat("Price (minimum)     : %g", stats_price.GetStats(STATS_MIN));
  PrintFormat("Price (average)     : %g", stats_price.GetStats(STATS_AVG));
  PrintFormat("Price (median)      : %g", stats_price.GetStats(STATS_MED));
  PrintFormat("Price (maximum)     : %g", stats_price.GetStats(STATS_MAX));
  PrintFormat("Price (avg/hour)    : %g", stats_price.GetStats(STATS_AVG, OBJ_PERIOD_H1));
  PrintFormat("Price (avg/???)     : %g", stats_price.GetStats(STATS_MIN, OBJ_PERIOD_H1 | OBJ_PERIOD_H4));
  CleanUp();
}

/**
 * Deletes created objects to free allocated memory.
 */
void CleanUp() {
  delete stats_price;
  delete stats_spread;
}
