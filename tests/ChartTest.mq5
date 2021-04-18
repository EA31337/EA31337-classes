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

/**
 * Implements OnInit().
 */
int OnInit() {
  // Test IndexToTf().
  PrintFormat("Index to timeframe: %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d", M1,
              Chart::IndexToTf(M1), M5,
              Chart::IndexToTf(M5), M15,
              Chart::IndexToTf(M15), M30,
              Chart::IndexToTf(M30), H1,
              Chart::IndexToTf(H1), H4,
              Chart::IndexToTf(H4), D1,
              Chart::IndexToTf(D1), W1,
              Chart::IndexToTf(W1), MN1,
              Chart::IndexToTf(MN1));
  assertTrueOrFail(Chart::IndexToTf(0) == PERIOD_M1, "Invalid period for M1 index");
  assertTrueOrFail(Chart::IndexToTf(1) == PERIOD_M5, "Invalid period for M5 index");

  // Test TfToIndex().
  PrintFormat("Chart to index: %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d", PERIOD_M1,
              Chart::TfToIndex(PERIOD_M1), PERIOD_M5,
              Chart::TfToIndex(PERIOD_M5), PERIOD_M15,
              Chart::TfToIndex(PERIOD_M15), PERIOD_M30,
              Chart::TfToIndex(PERIOD_M30), PERIOD_H1,
              Chart::TfToIndex(PERIOD_H1), PERIOD_H4,
              Chart::TfToIndex(PERIOD_H4), PERIOD_D1,
              Chart::TfToIndex(PERIOD_D1), PERIOD_W1,
              Chart::TfToIndex(PERIOD_W1), PERIOD_MN1,
              Chart::TfToIndex(PERIOD_MN1));
  assertTrueOrFail(Chart::TfToIndex(PERIOD_M1) == 0, "Invalid index for M1 period");
  assertTrueOrFail(Chart::TfToIndex(PERIOD_M5) == 1, "Invalid index for M5 period");

  return (INIT_SUCCEEDED);
}
