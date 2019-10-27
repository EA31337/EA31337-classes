//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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
 * Test functionality of Market class.
 */

// Includes.
#include "../Market.mqh"
#include "../Test.mqh"

// Properties.
#property strict

/**
 * Implements OnInit().
 */
int OnInit() {
  Market *market = new Market();
  //assertTrueOrFail(market.GetPipDigits() > 0 && market.GetPipDigits() == Market::GetPipDigits(), "Invalid GetPipDigits()!"); // @fixme: error 244: tree optimization error
  //assertTrueOrFail(market.GetPipValue() > 0 && market.GetPipValue() < 1, "Invalid GetPipValue()!"); // @fixme: error 244: tree optimization error
  //assertTrueOrFail((market.GetSpreadInPts() > 0 && market.GetSpreadInPts() == Market::GetSpreadInPts()), "Invalid GetSpreadInPts()!"); // @fixme: error 244: tree optimization error
  //assertTrueOrFail((market.GetSpreadInPct() > 0 && market.GetSpreadInPct() == Market::GetSpreadInPct()), "Invalid GetSpreadInPct()!"); // @fixme: error 244: tree optimization error
  //assertTrueOrFail((market.GetPointsPerPip() > 0 && market.GetPointsPerPip() == Market::GetPointsPerPip()), "Invalid GetPointsPerPip()!"); // @fixme: error 244: tree optimization error
  //assertTrueOrFail((market.GetTradeDistanceInPts() > 0 && market.GetTradeDistanceInPts() == Market::GetTradeDistanceInPts()), "Invalid GetTradeDistanceInPts()!"); // @fixme: error 244: tree optimization error
  //assertTrueOrFail((market.GetTradeDistanceInPips() > 0 && market.GetTradeDistanceInPips() == Market::GetTradeDistanceInPips()), "Invalid GetTradeDistanceInPips()!"); // @fixme: error 244: tree optimization error
  //assertTrueOrFail((market.GetTradeDistanceInValue() > 0 && market.GetTradeDistanceInValue() == Market::GetTradeDistanceInValue()), "Invalid GetTradeDistanceInValue()!"); // @fixme: error 244: tree optimization error
  //assertTrueOrFail(market.GetVolumeDigits() > 0 && market.GetVolumeDigits() == Market::GetVolumeDigits(), "Invalid GetVolumeDigits()!"); // @fixme: error 244: tree optimization error
  Market::RefreshRates();
  // Test MarketInfo().
  delete market;

  return (INIT_SUCCEEDED);
}
