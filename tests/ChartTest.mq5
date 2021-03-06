//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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

// Properties.
#property strict

/**
 * Implements OnInit().
 */
int OnInit() {
  // Test IndexToTf().
  PrintFormat("Index to timeframe: %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d", M1,
              ChartHistory::IndexToTf(M1), M5,
              ChartHistory::IndexToTf(M5), M15,
              ChartHistory::IndexToTf(M15), M30,
              ChartHistory::IndexToTf(M30), H1,
              ChartHistory::IndexToTf(H1), H4,
              ChartHistory::IndexToTf(H4), D1,
              ChartHistory::IndexToTf(D1), W1,
              ChartHistory::IndexToTf(W1), MN1,
              ChartHistory::IndexToTf(MN1));
  assertTrueOrFail(ChartHistory::IndexToTf(0) == PERIOD_M1, "Invalid period for M1 index");
  assertTrueOrFail(ChartHistory::IndexToTf(1) == PERIOD_M5, "Invalid period for M5 index");

  // Test TfToIndex().
  PrintFormat("Chart to index: %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d", PERIOD_M1,
              ChartHistory::TfToIndex(PERIOD_M1), PERIOD_M5,
              ChartHistory::TfToIndex(PERIOD_M5), PERIOD_M15,
              ChartHistory::TfToIndex(PERIOD_M15), PERIOD_M30,
              ChartHistory::TfToIndex(PERIOD_M30), PERIOD_H1,
              ChartHistory::TfToIndex(PERIOD_H1), PERIOD_H4,
              ChartHistory::TfToIndex(PERIOD_H4), PERIOD_D1,
              ChartHistory::TfToIndex(PERIOD_D1), PERIOD_W1,
              ChartHistory::TfToIndex(PERIOD_W1), PERIOD_MN1,
              ChartHistory::TfToIndex(PERIOD_MN1));
  assertTrueOrFail(ChartHistory::TfToIndex(PERIOD_M1) == 0, "Invalid index for M1 period");
  assertTrueOrFail(ChartHistory::TfToIndex(PERIOD_M5) == 1, "Invalid index for M5 period");

  return (INIT_SUCCEEDED);
}
