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

// #define __debug__
// #define __debug_verbose__

// Forward declaration.
struct DataParamEntry;

// Includes.
#include "../Platform/Chart/ChartMt.h"
#include "../Indicators/Tick/Indi_TickMt.h"
#include "../Platform/Platform.h"
#include "../Test.mqh"
#include "../Trade.mqh"

Ref<IndicatorData> _chart_m1;
Ref<IndicatorData> _chart_m5;
bool _finish_test = false;

/**
 * Implements OnInit().
 */
int OnInit() {
  Platform::Init();
  _chart_m1 = Platform::FetchDefaultCandleIndicator("EURUSD", PERIOD_M1);
  _chart_m5 = Platform::FetchDefaultCandleIndicator("EURUSD", PERIOD_M5);

  return INIT_SUCCEEDED;
}

void OnTick() {
  if (_finish_test) {
    // We don't need to process further ticks.
    return;
  }
  Platform::Tick();
  // We need some bars in order to make trades.
  if (_chart_m5 REF_DEREF GetBarIndex() > trade_params_defaults.GetBarsMin()) {
    if (Test() == INIT_FAILED) {
      Print("ERROR: Test failed!");
    }
    // We only want to test on a single (late) bar.
    _finish_test = true;
  }
}

/**
 * Testing Trade class. Returns INIT_FAILED on failure.
 */
int Test() {
  // Initial market tests.
  assertTrueOrFail(SymbolInfoStatic::GetAsk(_Symbol) > 0, "Invalid Ask price!");

  // Test 1.

  Trade *trade1 = new Trade(trade_params_defaults, _chart_m1.Ptr());

  // Test market.
  assertTrueOrFail(trade1 PTR_DEREF IsTradeAllowed(), "Trade not allowed!");
  assertTrueOrFail(trade1 PTR_DEREF GetSource() PTR_DEREF GetTf() == PERIOD_M1,
                   StringFormat("Fail on GetTf() => [%d]!", trade1 PTR_DEREF GetSource() PTR_DEREF GetTf()));
  assertTrueOrFail(trade1 PTR_DEREF GetSource() PTR_DEREF GetOpen() > 0, "Fail on GetOpen()!");
  assertTrueOrFail(trade1 PTR_DEREF GetSource() PTR_DEREF GetSymbol() == _Symbol, "Fail on GetSymbol()!");
  // assertTrueOrFail(trade1.IsTradeAllowed(), "Fail on IsTradeAllowed()!"); // @fixme

  assertTrueOrFail(trade1 PTR_DEREF GetTradeDistanceInPts() >= 0 &&
                       trade1 PTR_DEREF GetTradeDistanceInPts() == Trade::GetTradeDistanceInPts(_Symbol),
                   "Invalid GetTradeDistanceInPts()!");
  assertTrueOrFail(trade1 PTR_DEREF GetTradeDistanceInPips() >= 0 &&
                       trade1 PTR_DEREF GetTradeDistanceInPips() == Trade::GetTradeDistanceInPips(_Symbol),
                   "Invalid GetTradeDistanceInPips()!");
  assertTrueOrFail(trade1.GetTradeDistanceInValue() >= 0 && (float)trade1 PTR_DEREF GetTradeDistanceInValue() ==
                                                                (float)Trade::GetTradeDistanceInValue(_Symbol),
                   "Invalid GetTradeDistanceInValue()!");
  Print("Trade1: ", trade1 PTR_DEREF ToString());
  // Clean up.
  delete trade1;

  // Test 2.
  Trade *trade2 = new Trade(trade_params_defaults, _chart_m5.Ptr());

  // Test market.
  assertTrueOrFail(
      trade2 PTR_DEREF GetSource() PTR_DEREF GetTf() == PERIOD_M5,
      StringFormat("Fail on GetTf() => [%s]!", EnumToString(trade2 PTR_DEREF GetSource() PTR_DEREF GetTf())));
  assertTrueOrFail(trade2 PTR_DEREF GetSource() PTR_DEREF GetOpen() > 0, "Fail on GetOpen()!");
  assertTrueOrFail(trade2 PTR_DEREF GetSource() PTR_DEREF GetSymbol() == _Symbol, "Fail on GetSymbol()!");
  assertTrueOrFail(trade2 PTR_DEREF IsTradeAllowed(), "Fail on IsTradeAllowed()!");
  Print("Trade2: ", trade2 PTR_DEREF ToString());
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

  if (_LastError != ERR_NO_ERROR) {
    Print("Error: ", _LastError);
    return INIT_FAILED;
  }

  return INIT_SUCCEEDED;
}
