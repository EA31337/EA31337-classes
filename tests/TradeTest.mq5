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
 * Test functionality of Trade class.
 */

// Forward declaration.
struct DataParamEntry;

// Includes.
#include "../Test.mqh"
#include "../Trade.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  // Initial market tests.
  assertTrueOrFail(SymbolInfoStatic::GetAsk(_Symbol) > 0, "Invalid Ask price!");

  // Test 1.
  ChartParams _cparams_m1(PERIOD_M1, _Symbol);
  Trade *trade1 = new Trade(trade_params_defaults, _cparams_m1);

  // Test market.
  assertTrueOrFail(trade1.IsTradeAllowed(), "Trade not allowed!");
  assertTrueOrFail(trade1.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF) == PERIOD_M1,
                   StringFormat("Fail on GetTf() => [%s]!", trade1.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF)));
  assertTrueOrFail(trade1.GetChart().GetOpen() > 0, "Fail on GetOpen()!");
  assertTrueOrFail(trade1.GetChart().Get<string>(CHART_PARAM_SYMBOL) == _Symbol, "Fail on GetSymbol()!");
  // assertTrueOrFail(trade1.IsTradeAllowed(), "Fail on IsTradeAllowed()!"); // @fixme

  assertTrueOrFail(
      trade1.GetTradeDistanceInPts() >= 0 && trade1.GetTradeDistanceInPts() == Trade::GetTradeDistanceInPts(_Symbol),
      "Invalid GetTradeDistanceInPts()!");
  assertTrueOrFail(
      trade1.GetTradeDistanceInPips() >= 0 && trade1.GetTradeDistanceInPips() == Trade::GetTradeDistanceInPips(_Symbol),
      "Invalid GetTradeDistanceInPips()!");
  assertTrueOrFail(trade1.GetTradeDistanceInValue() >= 0 &&
                       (float)trade1.GetTradeDistanceInValue() == (float)Trade::GetTradeDistanceInValue(_Symbol),
                   "Invalid GetTradeDistanceInValue()!");
  Print("Trade1: ", trade1.ToString());
  // Clean up.
  delete trade1;

  // Test 2.
  ChartParams _cparams_m5(PERIOD_M5, _Symbol);
  Trade *trade2 = new Trade(trade_params_defaults, _cparams_m5);

  // Test market.
  assertTrueOrFail(trade2.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF) == PERIOD_M5,
                   StringFormat("Fail on GetTf() => [%s]!", EnumToString(trade2.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF))));
  assertTrueOrFail(trade2.GetChart().GetOpen() > 0, "Fail on GetOpen()!");
  assertTrueOrFail(trade2.GetChart().GetSymbol() == _Symbol, "Fail on GetSymbol()!");
  assertTrueOrFail(trade2.IsTradeAllowed(), "Fail on IsTradeAllowed()!");
  Print("Trade2: ", trade2.ToString());
  // Clean up.
  delete trade2;

  // Test TradeStates struct.
  TradeStates tstates;
  assertTrueOrFail(tstates.GetStates() == 0, __FUNCTION_LINE__);
  tstates.AddState(TRADE_STATE_TRADE_NOT_ALLOWED);
  assertTrueOrFail(!tstates.CheckState(TRADE_STATE_ORDERS_ACTIVE), __FUNCTION_LINE__);
  assertTrueOrFail(tstates.CheckState(TRADE_STATE_TRADE_NOT_ALLOWED), __FUNCTION_LINE__);
  assertTrueOrFail(tstates.CheckState(TRADE_STATE_TRADE_CANNOT), __FUNCTION_LINE__);
  assertTrueOrFail(tstates.CheckState(TRADE_STATE_TRADE_WONT), __FUNCTION_LINE__);

  // Test TradeStats struct.
  TradeStats tstats;
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_ALL) == 0, __FUNCTION_LINE__);
  tstats.Add(TRADE_STAT_ORDERS_OPENED);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_PER_HOUR) == 1, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_PER_DAY) == 1, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_PER_WEEK) == 1, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_PER_MONTH) == 1, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_ALL) == 1, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_CLOSED, TRADE_STAT_ALL) == 0, __FUNCTION_LINE__);
  tstats.Add(TRADE_STAT_ORDERS_CLOSED);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_PER_HOUR) == 1, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_CLOSED, TRADE_STAT_ALL) == 1, __FUNCTION_LINE__);
  tstats.ResetStats(TRADE_STAT_PER_HOUR);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_CLOSED, TRADE_STAT_PER_HOUR) == 0, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_PER_HOUR) == 0, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_CLOSED, TRADE_STAT_PER_DAY) == 1, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_PER_DAY) == 1, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_ALL) == 1, __FUNCTION_LINE__);
  assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_CLOSED, TRADE_STAT_ALL) == 1, __FUNCTION_LINE__);
  // tstats.ResetStats(DATETIME_DAY | DATETIME_WEEK);
  // assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_CLOSED, TRADE_STAT_PER_DAY) == 0, __FUNCTION_LINE__);
  // assertTrueOrFail(tstats.GetOrderStats(TRADE_STAT_ORDERS_OPENED, TRADE_STAT_PER_DAY) == 0, __FUNCTION_LINE__);

  return GetLastError() == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED;
}
