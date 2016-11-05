//+------------------------------------------------------------------+
//| Test functionality of Convert class.
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
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

// Includes.
#include <Convert.mqh>

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
  // Test IndexToTf().
  PrintFormat("Index to timeframe: %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d",
    M1,  Convert::IndexToTf(M1),
    M5,  Convert::IndexToTf(M5),
    M15, Convert::IndexToTf(M15),
    M30, Convert::IndexToTf(M30),
    H1,  Convert::IndexToTf(H1),
    H4,  Convert::IndexToTf(H4),
    D1,  Convert::IndexToTf(D1),
    W1,  Convert::IndexToTf(W1),
    MN1, Convert::IndexToTf(MN1)
    );
  assert(Convert::IndexToTf(0) == PERIOD_M1, "Invalid period for M1 index");
  assert(Convert::IndexToTf(1) == PERIOD_M5, "Invalid period for M5 index");

  // Test TfToIndex().
  PrintFormat("Timeframe to index: %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d",
    PERIOD_M1,  Convert::TfToIndex(PERIOD_M1),
    PERIOD_M5,  Convert::TfToIndex(PERIOD_M5),
    PERIOD_M15, Convert::TfToIndex(PERIOD_M15),
    PERIOD_M30, Convert::TfToIndex(PERIOD_M30),
    PERIOD_H1,  Convert::TfToIndex(PERIOD_H1),
    PERIOD_H4,  Convert::TfToIndex(PERIOD_H4),
    PERIOD_D1,  Convert::TfToIndex(PERIOD_D1),
    PERIOD_W1,  Convert::TfToIndex(PERIOD_W1),
    PERIOD_MN1, Convert::TfToIndex(PERIOD_MN1)
    );
  assert(Convert::TfToIndex(PERIOD_M1) == 0, "Invalid index for M1 period");
  assert(Convert::TfToIndex(PERIOD_M5) == 1, "Invalid index for M5 period");

  // Test OrderTypeToString().
  assert(Convert::OrderTypeToString(OP_BUY) == "Buy", "Invalid text for given order type");
  assert(Convert::OrderTypeToString(OP_SELL) == "Sell", "Invalid text for given order type");

  // Test OrderTypeToValue().
  assert(Convert::OrderTypeToValue(OP_SELL) == -1, "Invalid value for order type");
  assert(Convert::OrderTypeToValue(OP_BUY) == +1, "Invalid value for order type");

  // Test OrderTypeOpp().
  assert(Convert::OrderTypeOpp(OP_BUY) == OP_SELL, "Invalid opposite order for OP_BUY");
  assert(Convert::OrderTypeOpp(OP_SELL) == OP_BUY, "Invalid opposite order for OP_SELL");

  // Test PointsPerPip().
  PrintFormat("%d points per pip for 4-digit symbol price", Convert::PointsPerPip(4));
  PrintFormat("%d points per pip for 5-digit symbol price", Convert::PointsPerPip(5));
  assert(Convert::PointsPerPip(4) == 1, "Invalid points per pip");
  assert(Convert::PointsPerPip(5) == 10, "Invalid points per pip");

  // Test PipsToValue().
  PrintFormat("1 (4-digit) pip = %g", Convert::PipsToValue(1, 4));
  PrintFormat("20 (4-digit) pips = %g", Convert::PipsToValue(20, 4));
  PrintFormat("1 (5-digit) pip = %g", Convert::PipsToValue(1, 5));
  PrintFormat("20 (5-digit) pips = %g", Convert::PipsToValue(20, 5));
  assert(Convert::PipsToValue(1, 4)  == 0.00010, "Invalid conversion from pips to value");
  assert(Convert::PipsToValue(20, 4) == 0.00200, "Invalid conversion from pips to value");
  assert(Convert::PipsToValue(1, 5)  == 0.00010, "Invalid conversion from pips to value");
  assert(Convert::PipsToValue(20, 5) == 0.00200, "Invalid conversion from pips to value");

  // Test ValueToPips().
  assert(Convert::ValueToPips(0.00010, 4) == 1, "Invalid conversion from value to pips");
  assert(Convert::ValueToPips(0.00200, 4) == 20, "Invalid conversion from value to pips");
  assert(Convert::ValueToPips(0.00010, 5) == 1, "Invalid conversion from value to pips");
  assert(Convert::ValueToPips(0.00200, 5) == 20, "Invalid conversion from value to pips");

  // Test PipsToPoints().
  PrintFormat("1 (4-digit) pip = %d points", Convert::PipsToPoints(1, 4));
  PrintFormat("1 (5-digit) pip = %d points", Convert::PipsToPoints(1, 5));
  assert(Convert::PipsToPoints(1, 4) == 1, "Invalid points for a pip");
  assert(Convert::PipsToPoints(1, 5) == 10, "Invalid points for a pip");

  // Test PointsToPips().
  assert(Convert::PointsToPips(1, 4) == 1, "Invalid pips per points");
  assert(Convert::PointsToPips(10, 5) == 1, "Invalid pips per points");

  // Test PointsToValue().
  if (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_CALC_MODE) == 0) {
    if (MarketInfo(_Symbol, MODE_DIGITS) == 4) {
      PrintFormat("1 point for 4-digit symbol price (Forex) = %g",
        Convert::PointsToValue(1));
      PrintFormat("10 points for 4-digit symbol price (Forex) = %g",
        Convert::PointsToValue(10));
      assert(Convert::PointsToValue(1)  == 0.0001, "Invalid conversion of points to value");
      assert(Convert::PointsToValue(10)  == 0.0010, "Invalid conversion of points to value");
    }
    else if (MarketInfo(_Symbol, MODE_DIGITS) == 5) {
      PrintFormat("1 point for 5-digit symbol price (Forex) = %g",
        Convert::PointsToValue(1));
      PrintFormat("10 points for 5-digit symbol price (Forex) = %g",
        Convert::PointsToValue(10));
      assert(Convert::PointsToValue(1)  == 0.00001, "Invalid conversion of points to value");
      assert(Convert::PointsToValue(10)  == 0.00010, "Invalid conversion of points to value");
    }
  }
  PrintFormat("1 point for 4-digit symbol price (Forex) = %g",
    Convert::PointsToValue(1, 0, 4));
  PrintFormat("10 points for 4-digit symbol price (Forex) = %g",
    Convert::PointsToValue(10, 0, 4));
  PrintFormat("1 point for 5-digit symbol price (Forex) = %g",
    Convert::PointsToValue(1, 0, 5));
  PrintFormat("10 points for 5-digit symbol price (Forex) = %g",
    Convert::PointsToValue(10, 0, 5));
  assert(Convert::PointsToValue(1, 0, 4)  == 0.0001, "Invalid conversion of points to value");
  assert(Convert::PointsToValue(10, 0, 4)  == 0.0010, "Invalid conversion of points to value");
  assert(Convert::PointsToValue(1, 0, 5) == 0.00001, "Invalid conversion of points to value");
  assert(Convert::PointsToValue(10, 0, 5) == 0.00010, "Invalid conversion of points to value");
  return (INIT_SUCCEEDED);
}
