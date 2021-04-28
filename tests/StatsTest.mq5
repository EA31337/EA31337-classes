//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
Stats *stats;

/**
 * Implements OnInit().
 */
int OnInit() {
  stats = new Stats();
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() { stats.OnTick(); }

/**
 * Deletes created objects to free allocated memory.
 */
void CleanUp() { delete stats; }

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  PrintFormat("Total bars    : %d", stats.GetTotalBars());
  PrintFormat("Bars per hour : %d", stats.GetBarsPerPeriod(PERIOD_H1));
  PrintFormat("Total ticks   : %d", stats.GetTotalTicks());
  PrintFormat("Ticks per bar : %d", stats.GetTicksPerBar());
  PrintFormat("Ticks per hour: %d", stats.GetTicksPerPeriod(PERIOD_H1));
  PrintFormat("Ticks per min : %d", stats.GetTicksPerMin());
  PrintFormat("Ticks per sec : %.2f", stats.GetTicksPerSec());
  CleanUp();
}
