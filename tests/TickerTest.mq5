//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * Test functionality of Ticker class.
 */

// Includes.
#include "../Test.mqh"
#include "../Ticker.mqh"

// Global variables.
Chart *chart;
SymbolInfo *symbol;
ulong total_ticks;
Ticker *ticker_csv;
Ticker *ticker01;
Ticker *ticker02;
Ticker *ticker03;
Ticker *ticker04;
Ticker *ticker05;
Ticker *ticker06;
Ticker *ticker07;
Ticker *ticker08;

/**
 * Implements initialization function.
 */
int OnInit() {
  // Initialize instances.
  // SymbolInfo symbol = new SymbolInfo();
  chart = new Chart();
  symbol = (SymbolInfo *)chart;

  // Print market details.
  Print("SYMBOL: ", symbol.ToString());
  Print("CHART: ", chart.ToString());

  // Initialize Ticker instances.
  ticker_csv = new Ticker(symbol);
  ticker01 = new Ticker(symbol);
  ticker02 = new Ticker(symbol);
  ticker03 = new Ticker(symbol);
  ticker04 = new Ticker(symbol);
  ticker05 = new Ticker(symbol);
  ticker06 = new Ticker(symbol);
  ticker07 = new Ticker(symbol);
  ticker08 = new Ticker(symbol);

  // Test adding ticks using local scope class.
  Ticker *ticker_test = new Ticker();
  assertTrueOrFail(ticker_test.GetTotalAdded() == 0, "Incorrect number of ticks added");
  assertTrueOrFail(ticker_test.GetTotalIgnored() == 0, "Incorrect number of ticks ignored");
  assertTrueOrFail(ticker_test.GetTotalProcessed() == 0, "Incorrect number of ticks processed");
  assertTrueOrFail(ticker_test.GetTotalSaved() == 0, "Incorrect number of ticks saved");
  ticker_test.Add();
  assertTrueOrFail(ticker_test.GetTotalAdded() == 1, "Incorrect number of ticks added");
  ticker_test.Add();
  assertTrueOrFail(ticker_test.GetTotalAdded() == 2, "Incorrect number of ticks added");
  ticker_test.Reset();
  assertTrueOrFail(ticker_test.GetTotalAdded() == 0, "Incorrect number of ticks after reset");
  ticker_test.Add();
  assertTrueOrFail(ticker_test.GetTotalAdded() == 1, "Incorrect number of ticks added");
  delete ticker_test;

  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {
  total_ticks++;

  // Process the ticks using different methods.
  ticker01.Process(chart, 1);
  ticker02.Process(chart, 2);
  ticker03.Process(chart, 3);
  ticker04.Process(chart, 4);
  ticker05.Process(chart, 5);
  ticker06.Process(chart, 6);
  ticker07.Process(chart, 7);
  ticker08.Process(chart, 8);
  ticker_csv.Add();
}

/**
 * Implements deinitialization function.
 */
void OnDeinit(const int reason) {
  // Save ticks into CSV.
  ticker_csv.SaveToCSV(StringFormat("ticks_%s.csv", _Symbol));
  // @fixme
  // assertTrueOrExit(ticker_csv.GetTotalSaved() == ticker_csv.GetTotalAdded(), "Incorrect number of ticks added");

  // Print final details.
  Print("TICKER01: ", ticker01.ToString());
  Print("TICKER02: ", ticker02.ToString());
  Print("TICKER03: ", ticker03.ToString());
  Print("TICKER04: ", ticker04.ToString());
  Print("TICKER05: ", ticker05.ToString());
  Print("TICKER06: ", ticker06.ToString());
  Print("TICKER07: ", ticker07.ToString());
  Print("TICKER08: ", ticker08.ToString());
  Print("TICKER CSV: ", ticker_csv.ToString());

  // Deinitialize objects.
  delete chart;
  delete symbol;
  delete ticker_csv;
  delete ticker01;
  delete ticker02;
  delete ticker03;
  delete ticker04;
  delete ticker05;
  delete ticker06;
  delete ticker07;
  delete ticker08;
}
