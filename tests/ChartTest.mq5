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
 * Test functionality of Chart class.
 */

// Includes.
#include "../Chart.mqh"
#include "../Convert.mqh"
#include "../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  // Test IndexToTf().
  PrintFormat("Index to timeframe: %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d", M1,
              ChartTf::IndexToTf(M1), M5, ChartTf::IndexToTf(M5), M15, ChartTf::IndexToTf(M15), M30,
              ChartTf::IndexToTf(M30), H1, ChartTf::IndexToTf(H1), H4, ChartTf::IndexToTf(H4), D1,
              ChartTf::IndexToTf(D1), W1, ChartTf::IndexToTf(W1), MN1, ChartTf::IndexToTf(MN1));
  assertTrueOrFail(ChartTf::IndexToTf(0) == PERIOD_M1, "Invalid period for M1 index");
  assertTrueOrFail(ChartTf::IndexToTf(1) == PERIOD_M2, "Invalid period for M2 index");
  assertTrueOrFail(ChartTf::IndexToTf(4) == PERIOD_M5, "Invalid period for M5 index");

  // Test TfToIndex().
  PrintFormat("Chart to index: %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d", PERIOD_M1,
              ChartTf::TfToIndex(PERIOD_M1), PERIOD_M5, ChartTf::TfToIndex(PERIOD_M5), PERIOD_M15,
              ChartTf::TfToIndex(PERIOD_M15), PERIOD_M30, ChartTf::TfToIndex(PERIOD_M30), PERIOD_H1,
              ChartTf::TfToIndex(PERIOD_H1), PERIOD_H4, ChartTf::TfToIndex(PERIOD_H4), PERIOD_D1,
              ChartTf::TfToIndex(PERIOD_D1), PERIOD_W1, ChartTf::TfToIndex(PERIOD_W1), PERIOD_MN1,
              ChartTf::TfToIndex(PERIOD_MN1));
  assertTrueOrFail(ChartTf::TfToIndex(PERIOD_M1) == 0, "Invalid index for M1 period");
  assertTrueOrFail(ChartTf::TfToIndex(PERIOD_M2) == 1, "Invalid index for M5 period");
  assertTrueOrFail(ChartTf::TfToIndex(PERIOD_M5) == 4, "Invalid index for M5 period");

  return (INIT_SUCCEEDED);
}
