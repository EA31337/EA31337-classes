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
 * Test functionality of Convert class.
 */

// Includes.
#include "../Convert.mqh"
#include "../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  // Test OrderTypeBuyOrSell().
  assertTrueOrFail(Convert::OrderTypeBuyOrSell(ORDER_TYPE_SELL) == ORDER_TYPE_SELL, "Invalid value for order type");
  assertTrueOrFail(Convert::OrderTypeBuyOrSell(ORDER_TYPE_SELL_LIMIT) == ORDER_TYPE_SELL,
                   "Invalid value for order type");
  assertTrueOrFail(Convert::OrderTypeBuyOrSell(ORDER_TYPE_BUY) == ORDER_TYPE_BUY, "Invalid value for order type");
  assertTrueOrFail(Convert::OrderTypeBuyOrSell(ORDER_TYPE_BUY_LIMIT) == ORDER_TYPE_BUY, "Invalid value for order type");

  // Test PointsPerPip().
  PrintFormat("%d points per pip for 4-digit symbol price", Convert::PointsPerPip(4));
  PrintFormat("%d points per pip for 5-digit symbol price", Convert::PointsPerPip(5));
  assertTrueOrFail(Convert::PointsPerPip(4) == 1, "Invalid points per pip");
  assertTrueOrFail(Convert::PointsPerPip(5) == 10, "Invalid points per pip");

  // Test PipsToValue().
  PrintFormat("1 (4-digit) pip = %g", Convert::PipsToValue(1, 4));
  PrintFormat("20 (4-digit) pips = %g", Convert::PipsToValue(20, 4));
  PrintFormat("1 (5-digit) pip = %g", Convert::PipsToValue(1, 5));
  PrintFormat("20 (5-digit) pips = %g", Convert::PipsToValue(20, 5));
  assertTrueOrFail(Convert::PipsToValue(1, 4) == 0.00010, "Invalid conversion from pips to value");
  assertTrueOrFail(Convert::PipsToValue(20, 4) == 0.00200, "Invalid conversion from pips to value");
  assertTrueOrFail(Convert::PipsToValue(1, 5) == 0.00010, "Invalid conversion from pips to value");
  assertTrueOrFail(Convert::PipsToValue(20, 5) == 0.00200, "Invalid conversion from pips to value");

  // Test ValueToPips().
  assertTrueOrFail(Convert::ValueToPips(0.00010, 4) == 1, "Invalid conversion from value to pips");
  assertTrueOrFail(Convert::ValueToPips(0.00200, 4) == 20, "Invalid conversion from value to pips");
  assertTrueOrFail(Convert::ValueToPips(0.00010, 5) == 1, "Invalid conversion from value to pips");
  assertTrueOrFail(Convert::ValueToPips(0.00200, 5) == 20, "Invalid conversion from value to pips");

  // Test PipsToPoints().
  PrintFormat("1 (4-digit) pip = %d points", Convert::PipsToPoints(1, 4));
  PrintFormat("1 (5-digit) pip = %d points", Convert::PipsToPoints(1, 5));
  assertTrueOrFail(Convert::PipsToPoints(1, 4) == 1, "Invalid points for a pip");
  assertTrueOrFail(Convert::PipsToPoints(1, 5) == 10, "Invalid points for a pip");

  // Test PointsToPips().
  assertTrueOrFail(Convert::PointsToPips(1, 4) == 1, "Invalid pips per points");
  assertTrueOrFail(Convert::PointsToPips(10, 5) == 1, "Invalid pips per points");

  // Test PointsToValue().
  if (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_CALC_MODE) == 0) {
    if (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 4) {
      PrintFormat("1 point for 4-digit symbol price (Forex) = %g", Convert::PointsToValue(1));
      PrintFormat("10 points for 4-digit symbol price (Forex) = %g", Convert::PointsToValue(10));
      assertTrueOrFail(Convert::PointsToValue(1) == 0.0001, "Invalid conversion of points to value");
      assertTrueOrFail(Convert::PointsToValue(10) == 0.0010, "Invalid conversion of points to value");
    } else if (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 5) {
      PrintFormat("1 point for 5-digit symbol price (Forex) = %g", Convert::PointsToValue(1));
      PrintFormat("10 points for 5-digit symbol price (Forex) = %g", Convert::PointsToValue(10));
      assertTrueOrFail(Convert::PointsToValue(1) == 0.00001, "Invalid conversion of points to value");
      assertTrueOrFail(Convert::PointsToValue(10) == 0.00010, "Invalid conversion of points to value");
    }
  }
  PrintFormat("1 point for 4-digit symbol price (Forex) = %g", Convert::PointsToValue(1, 0, 4));
  PrintFormat("10 points for 4-digit symbol price (Forex) = %g", Convert::PointsToValue(10, 0, 4));
  PrintFormat("1 point for 5-digit symbol price (Forex) = %g", Convert::PointsToValue(1, 0, 5));
  PrintFormat("10 points for 5-digit symbol price (Forex) = %g", Convert::PointsToValue(10, 0, 5));
  assertTrueOrFail(Convert::PointsToValue(1, 0, 4) == 0.0001, "Invalid conversion of points to value");
  assertTrueOrFail(Convert::PointsToValue(10, 0, 4) == 0.0010, "Invalid conversion of points to value");
  assertTrueOrFail(Convert::PointsToValue(1, 0, 5) == 0.00001, "Invalid conversion of points to value");
  assertTrueOrFail(Convert::PointsToValue(10, 0, 5) == 0.00010, "Invalid conversion of points to value");

  // Test GetPipDiff().
  assertTrueOrFail(Convert::GetValueDiffInPips(0.00010, 0.00020, true, 4) == 1, "Invalid result of diff value");
  assertTrueOrFail(Convert::GetValueDiffInPips(0.00020, 0.00010, false, 4) == 1, "Invalid result of diff value");
  assertTrueOrFail(Convert::GetValueDiffInPips(0.00020, 0.00010, false, 5) == 1, "Invalid result of diff value");
  assertTrueOrFail(Convert::GetValueDiffInPips(0.00400, 0.00200, false, 4) == 20, "Invalid result of diff value");
  assertTrueOrFail(Convert::GetValueDiffInPips(0.00400, 0.00200, false, 5) == 20, "Invalid result of diff value");

  // Test ValueWithCurrency().
  // Print("Euro sign: " + ShortToString(0x20A0));
  PrintFormat("1000 USD = %s", Convert::ValueWithCurrency(1000, 2, "USD"));
  PrintFormat("1000 EUR = %s", Convert::ValueWithCurrency(1000, 2, "EUR"));
  PrintFormat("1000 GBP = %s", Convert::ValueWithCurrency(1000, 2, "GBP"));
  assertTrueOrFail(Convert::ValueWithCurrency(1000, 2, "USD") == "$1000.00", "Invalid currency value result");
  return (INIT_SUCCEEDED);
}
