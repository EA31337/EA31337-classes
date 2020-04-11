//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
 * Test functionality of Action class.
 */

// Includes.
#include "../Action.mqh"
#include "../DictObject.mqh"
#include "../Test.mqh"

// Global variables.
Chart *chart;
DictObject<short, Action> actions;
int bar_processed;

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  bar_processed = 0;
  chart = new Chart(PERIOD_M1);
  _result &= TestEAActions();
  _result &= TestOrderActions();
  _result &= TestStrategyActions();
  _result &= TestTradeActions();
  _result &= GetLastError() == ERR_NO_ERROR;
  return _result ? INIT_SUCCEEDED : INIT_FAILED;
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
  if (chart.IsNewBar()) {
    // ...
    bar_processed++;
  }
}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) { delete chart; }

/**
 * Test EA actions.
 */
bool TestEAActions() {
  bool _result = true;
  // @todo
  return _result;
}

/**
 * Test order actions.
 */
bool TestOrderActions() {
  bool _result = true;
  // @todo
  return _result;
}

/**
 * Test strategy actions.
 */
bool TestStrategyActions() {
  bool _result = true;
  // @todo
  return _result;
}

/**
 * Test trade actions.
 */
bool TestTradeActions() {
  bool _result = true;
  Trade *_trade = new Trade();
  /*
  assertTrueOrReturnFalse(
      (new Condition(TRADE_COND_ALLOWED_NOT, _trade)).Test() == _trade.Condition(TRADE_COND_ALLOWED_NOT),
      "Wrong condition: TRADE_COND_ALLOWED_NOT!");
  */
  return _result;
}