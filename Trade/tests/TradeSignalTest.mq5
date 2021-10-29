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
 * Test functionality of TradeSignal class.
 */

// Includes.
#include "../../Test.mqh"
#include "../TradeSignal.h"

// Test signals to close buy trade with filters.
bool TestTradeSignalCloseBuyWithFilters() {
  bool _result = true;
  // 1st method.
  TradeSignalEntry _entry1(SIGNAL_CLOSE_BUY_MAIN | SIGNAL_CLOSE_BUY_FILTER);
  TradeSignal _signal1(_entry1);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_SELL);
  // Do not close due to buy filter flag.
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal1.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 1.0f;
  _result &= _signal1.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 0.0f;
  Print(_signal1.ToString());
  // 2nd method.
  TradeSignalEntry _entry2;
  _entry2.Set(SIGNAL_CLOSE_BUY_MAIN, true);
  _entry2.Set(SIGNAL_CLOSE_BUY_FILTER, true);
  _entry2.Set(SIGNAL_CLOSE_TIME_FILTER, true);
  TradeSignal _signal2(_entry2);
  // Do not close due to buy and time filter flags.
  _result &= !_signal2.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_SELL);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal2.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 1.0f;
  _result &= _signal2.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 0.0f;
  Print(_signal2.ToString());
  return _result;
}

// Test signals to close buy trade without filters.
bool TestTradeSignalCloseBuyWithoutFilters() {
  bool _result = true;
  // 1st method.
  TradeSignalEntry _entry1(SIGNAL_CLOSE_BUY_MAIN);
  TradeSignal _signal1(_entry1);
  _result &= _signal1.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_SELL);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal1.GetSignalClose() >= 0.5;
  _result &= _signal1.GetSignalCloseDirection() == 1.0f;
  _result &= _signal1.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 0.0f;
  Print(_signal1.ToString());
  // 2nd method.
  TradeSignalEntry _entry2;
  _entry2.Set(SIGNAL_CLOSE_BUY_MAIN, true);
  TradeSignal _signal2(_entry2);
  _result &= _signal2.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_SELL);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal2.GetSignalClose() >= 0.5f;
  _result &= _signal1.GetSignalCloseDirection() == 1.0f;
  _result &= _signal2.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 0.0f;
  Print(_signal2.ToString());
  return _result;
}

// Test signals to close sell trade with filters.
bool TestTradeSignalCloseSellWithFilters() {
  bool _result = true;
  // 1st method.
  TradeSignalEntry _entry1(SIGNAL_CLOSE_SELL_MAIN | SIGNAL_CLOSE_SELL_FILTER);
  TradeSignal _signal1(_entry1);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_SELL);
  // Do not close due to sell filter flag.
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal1.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == -1.0f;
  _result &= _signal1.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 0.0f;
  Print(_signal1.ToString());
  // 2nd method.
  TradeSignalEntry _entry2;
  _entry2.Set(SIGNAL_CLOSE_SELL_MAIN, true);
  _entry2.Set(SIGNAL_CLOSE_SELL_FILTER, true);
  _entry2.Set(SIGNAL_CLOSE_TIME_FILTER, true);
  TradeSignal _signal2(_entry2);
  // Do not close due to sell and time filter flags.
  _result &= !_signal2.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_SELL);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal2.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == -1.0f;
  _result &= _signal2.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 0.0f;
  Print(_signal2.ToString());
  return _result;
}

// Test signals to close sell trade without filters.
bool TestTradeSignalCloseSellWithoutFilters() {
  bool _result = true;
  // 1st method.
  TradeSignalEntry _entry1(SIGNAL_CLOSE_SELL_MAIN);
  TradeSignal _signal1(_entry1);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_BUY);
  _result &= _signal1.ShouldClose(ORDER_TYPE_SELL);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal1.GetSignalClose() <= -0.5;
  _result &= _signal1.GetSignalCloseDirection() == -1.0f;
  _result &= _signal1.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 0.0f;
  Print(_signal1.ToString());
  // 2nd method.
  TradeSignalEntry _entry2;
  _entry2.Set(SIGNAL_CLOSE_SELL_MAIN, true);
  TradeSignal _signal2(_entry2);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_BUY);
  _result &= _signal2.ShouldClose(ORDER_TYPE_SELL);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal2.GetSignalClose() <= -0.5;
  _result &= _signal1.GetSignalCloseDirection() == -1.0f;
  _result &= _signal2.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 0.0f;
  Print(_signal2.ToString());
  return _result;
}

// Test signals to open buy trade with filters.
bool TestTradeSignalOpenBuyWithFilters() {
  bool _result = true;
  // 1st method.
  TradeSignalEntry _entry1(SIGNAL_OPEN_BUY_MAIN | SIGNAL_OPEN_BUY_FILTER);
  TradeSignal _signal1(_entry1);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_SELL);
  // Do not open due to buy filter flag.
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal1.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 0.0f;
  _result &= _signal1.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 1.0f;
  Print(_signal1.ToString());
  // 2nd method.
  TradeSignalEntry _entry2;
  _entry2.Set(SIGNAL_OPEN_BUY_MAIN, true);
  _entry2.Set(SIGNAL_OPEN_BUY_FILTER, true);
  _entry2.Set(SIGNAL_OPEN_TIME_FILTER, true);
  TradeSignal _signal2(_entry2);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_SELL);
  // Do not open due to buy and time filter flags.
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal2.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 0.0f;
  _result &= _signal2.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 1.0f;
  Print(_signal2.ToString());
  return _result;
}

// Test signals to open buy trade without filters.
bool TestTradeSignalOpenBuyWithoutFilters() {
  bool _result = true;
  // 1st method.
  TradeSignalEntry _entry1(SIGNAL_OPEN_BUY_MAIN);
  TradeSignal _signal1(_entry1);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_SELL);
  _result &= _signal1.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal1.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 0.0f;
  _result &= _signal1.GetSignalOpen() >= 0.5;
  _result &= _signal1.GetSignalOpenDirection() == 1.0f;
  Print(_signal1.ToString());
  // 2nd method.
  TradeSignalEntry _entry2;
  _entry2.Set(SIGNAL_OPEN_BUY_MAIN, true);
  _entry2.Set(SIGNAL_CLOSE_BUY_MAIN, true);     // This should not affect anything.
  _entry2.Set(SIGNAL_CLOSE_BUY_FILTER, true);   // This should not affect anything.
  _entry2.Set(SIGNAL_CLOSE_SELL_FILTER, true);  // This should not affect anything.
  _entry2.Set(SIGNAL_CLOSE_SELL_MAIN, true);    // This should not affect anything.
  TradeSignal _signal2(_entry2);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_SELL);
  _result &= _signal2.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal2.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 0.0f;
  _result &= _signal2.GetSignalOpen() >= 0.5f;
  _result &= _signal1.GetSignalOpenDirection() == 1.0f;
  Print(_signal2.ToString());
  return _result;
}

// Test signals to open sell trade with filters.
bool TestTradeSignalOpenSellWithFilters() {
  bool _result = true;
  // 1st method.
  TradeSignalEntry _entry1(SIGNAL_OPEN_SELL_MAIN | SIGNAL_OPEN_SELL_FILTER);
  TradeSignal _signal1(_entry1);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_SELL);
  // Do not open due to sell filter flag.
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal1.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 0.0f;
  _result &= _signal1.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == -1.0f;
  Print(_signal1.ToString());
  // 2nd method.
  TradeSignalEntry _entry2;
  _entry2.Set(SIGNAL_OPEN_SELL_MAIN, true);
  _entry2.Set(SIGNAL_OPEN_SELL_FILTER, true);
  _entry2.Set(SIGNAL_OPEN_TIME_FILTER, true);
  _entry2.Set(SIGNAL_CLOSE_BUY_FILTER, true);   // This should not affect anything.
  _entry2.Set(SIGNAL_CLOSE_BUY_MAIN, true);     // This should not affect anything.
  _entry2.Set(SIGNAL_CLOSE_SELL_FILTER, true);  // This should not affect anything.
  _entry2.Set(SIGNAL_CLOSE_SELL_MAIN, true);    // This should not affect anything.
  TradeSignal _signal2(_entry2);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_SELL);
  // Do not open due to sell and time filter flags.
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal2.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 0.0f;
  _result &= _signal2.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == -1.0f;
  Print(_signal2.ToString());
  return _result;
}

// Test signals to open sell trade without filters.
bool TestTradeSignalOpenSellWithoutFilters() {
  bool _result = true;
  // 1st method.
  TradeSignalEntry _entry1(SIGNAL_OPEN_SELL_MAIN);
  TradeSignal _signal1(_entry1);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_SELL);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_BUY);
  _result &= _signal1.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal1.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 0.0f;
  _result &= _signal1.GetSignalOpen() <= -0.5;
  _result &= _signal1.GetSignalOpenDirection() == -1.0f;
  Print(_signal1.ToString());
  // 2nd method.
  TradeSignalEntry _entry2;
  _entry2.Set(SIGNAL_OPEN_SELL_MAIN, true);
  TradeSignal _signal2(_entry2);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_SELL);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_BUY);
  _result &= _signal2.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal2.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 0.0f;
  _result &= _signal2.GetSignalOpen() <= -0.5;
  _result &= _signal1.GetSignalOpenDirection() == -1.0f;
  Print(_signal2.ToString());
  return _result;
}

// Test empty signal.
bool TestTradeSignalNone() {
  bool _result = true;
  // 1st method.
  TradeSignalEntry _entry1(SIGNAL_CLOSE_BUY_FILTER | SIGNAL_CLOSE_SELL_FILTER);
  TradeSignal _signal1(_entry1);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldClose(ORDER_TYPE_SELL);
  // Do not close due to buy filter flag.
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal1.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal1.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 0.0f;
  _result &= _signal1.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 0.0f;
  Print(_signal1.ToString());
  // 2nd method.
  TradeSignalEntry _entry2;
  TradeSignal _signal2(_entry2);
  // Do not close due to buy and time filter flags.
  _result &= !_signal2.ShouldClose(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldClose(ORDER_TYPE_SELL);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_BUY);
  _result &= !_signal2.ShouldOpen(ORDER_TYPE_SELL);
  _result &= _signal2.GetSignalClose() == 0.0f;
  _result &= _signal1.GetSignalCloseDirection() == 0.0f;
  _result &= _signal2.GetSignalOpen() == 0.0f;
  _result &= _signal1.GetSignalOpenDirection() == 0.0f;
  Print(_signal2.ToString());
  return _result;
}

/**
 * Implements OnInit().
 */
int OnInit() {
  bool _result = true;
  assertTrueOrFail(TestTradeSignalCloseBuyWithFilters(), "Fail!");
  assertTrueOrFail(TestTradeSignalCloseBuyWithoutFilters(), "Fail!");
  assertTrueOrFail(TestTradeSignalCloseSellWithFilters(), "Fail!");
  assertTrueOrFail(TestTradeSignalCloseSellWithoutFilters(), "Fail!");
  assertTrueOrFail(TestTradeSignalOpenBuyWithFilters(), "Fail!");
  assertTrueOrFail(TestTradeSignalOpenBuyWithoutFilters(), "Fail!");
  assertTrueOrFail(TestTradeSignalOpenSellWithFilters(), "Fail!");
  assertTrueOrFail(TestTradeSignalOpenSellWithoutFilters(), "Fail!");
  assertTrueOrFail(TestTradeSignalNone(), "Fail!");
  return _result && GetLastError() == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED;
}
