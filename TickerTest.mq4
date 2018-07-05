//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2018, 31337 Investments Ltd |
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

// Properties.
#property strict

// Includes.
#include "Market.mqh"
#include "Test.mqh"
#include "Ticker.mqh"

// Global variables.
Market *market;
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

  // Initialize objects.
  market = new Market();
  ticker_csv = new Ticker();
  ticker01 = new Ticker();
  ticker02 = new Ticker();
  ticker03 = new Ticker();
  ticker04 = new Ticker();
  ticker05 = new Ticker();
  ticker06 = new Ticker();
  ticker07 = new Ticker();
  ticker08 = new Ticker();

  // Print market details.
  Print("MARKET: ", market.ToString());

  // Test adding ticks using local scope class.
  Ticker *ticker_test = new Ticker(market);
  assert(ticker_test.GetTotalAdded() == 0, "Incorrect number of ticks added");
  assert(ticker_test.GetTotalIgnored() == 0, "Incorrect number of ticks ignored");
  assert(ticker_test.GetTotalProcessed() == 0, "Incorrect number of ticks processed");
  assert(ticker_test.GetTotalSaved() == 0, "Incorrect number of ticks saved");
  ticker_test.Add();
  assert(ticker_test.GetTotalAdded() == 1, "Incorrect number of ticks added");
  ticker_test.Add();
  assert(ticker_test.GetTotalAdded() == 2, "Incorrect number of ticks added");
  ticker_test.Reset();
  assert(ticker_test.GetTotalAdded() == 0, "Incorrect number of ticks after reset");
  ticker_test.Add();
  assert(ticker_test.GetTotalAdded() == 1, "Incorrect number of ticks added");
  delete ticker_test;

  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {
  total_ticks++;

  // Process the ticks using different methods.
  ticker01.Process(1);
  ticker02.Process(2);
  ticker03.Process(3);
  ticker04.Process(4);
  ticker05.Process(5);
  ticker06.Process(6);
  ticker07.Process(7);
  ticker08.Process(8);
  ticker_csv.Add();
}

/**
 * Implements deinitialization function.
 */
void OnDeinit(const int reason) {

  // Save ticks into CSV.
  ticker_csv.SaveToCSV(StringFormat("ticks_%s.csv", _Symbol));
  // @fixme
  //assertTrueOrExit(ticker_csv.GetTotalSaved() == ticker_csv.GetTotalAdded(), "Incorrect number of ticks added");

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
  delete market;
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