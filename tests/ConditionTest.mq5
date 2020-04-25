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
 * Test functionality of Condition class.
 */

// Includes.
#include "../Condition.mqh"
#include "../DictObject.mqh"
#include "../Indicators/Indi_Demo.mqh"
#include "../Test.mqh"

// Global variables.
Chart *chart;
DictObject<short, Condition> conds;
int bar_processed;

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  bar_processed = 0;
  chart = new Chart(PERIOD_M1);
  _result &= TestAccountConditions();
  _result &= TestChartConditions();
  _result &= TestDateTimeConditions();
  _result &= TestIndicatorConditions();
  _result &= TestMarketConditions();
  _result &= TestMathConditions();
  _result &= TestOrderConditions();
  _result &= TestTradeConditions();
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
 * Test account conditions.
 */
bool TestAccountConditions() {
  bool _result = true;
  Account *_acc = new Account();
  assertTrueOrReturnFalse((new Condition(ACCOUNT_COND_BAL_IN_LOSS)).Test() == _acc.Condition(ACCOUNT_COND_BAL_IN_LOSS),
                          "Wrong condition: ACCOUNT_COND_BAL_IN_LOSS!");
  return _result;
}

/**
 * Test chart conditions.
 */
bool TestChartConditions() {
  bool _result = true;
  Chart *_chart = new Chart();
  assertTrueOrReturnFalse(
      (new Condition(CHART_COND_ASK_BAR_PEAK, _chart)).Test() == _chart.Condition(CHART_COND_ASK_BAR_PEAK),
      "Wrong condition: CHART_COND_ASK_BAR_PEAK!");
  return _result;
}

/**
 * Test date time conditions.
 */
bool TestDateTimeConditions() {
  bool _result = true;
  DateTime *_dt = new DateTime();
  assertTrueOrReturnFalse((new Condition(DATETIME_COND_NEW_HOUR, _dt)).Test() == _dt.Condition(DATETIME_COND_NEW_HOUR),
                          "Wrong condition: DATETIME_COND_NEW_HOUR (dynamic)!");
  assertTrueOrReturnFalse((new Condition(DATETIME_COND_NEW_HOUR)).Test() == DateTime::Condition(DATETIME_COND_NEW_HOUR),
                          "Wrong condition: DATETIME_COND_NEW_HOUR (static)!");
  return _result;
}

/**
 * Test indicator conditions.
 */
bool TestIndicatorConditions() {
  bool _result = true;
  Indi_Demo *_demo = new Indi_Demo();
  /* @fixme
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_IS_MAX, _demo)).Test() == _demo.Condition(INDI_COND_ENTRY_IS_MAX),
      "Wrong condition: INDI_COND_ENTRY_IS_MAX!");
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_IS_MIN, _demo)).Test() == _demo.Condition(INDI_COND_ENTRY_IS_MIN),
      "Wrong condition: INDI_COND_ENTRY_IS_MIN!");
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_GT_AVG, _demo)).Test() == _demo.Condition(INDI_COND_ENTRY_GT_AVG),
      "Wrong condition: INDI_COND_ENTRY_GT_AVG!");
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_GT_MED, _demo)).Test() == _demo.Condition(INDI_COND_ENTRY_GT_MED),
      "Wrong condition: INDI_COND_ENTRY_GT_MED!");
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_LT_AVG, _demo)).Test() == _demo.Condition(INDI_COND_ENTRY_LT_AVG),
      "Wrong condition: INDI_COND_ENTRY_LT_AVG!");
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_LT_MED, _demo)).Test() == _demo.Condition(INDI_COND_ENTRY_LT_MED),
      "Wrong condition: INDI_COND_ENTRY_LT_MED!");
  */
  return _result;
}

/**
 * Test market conditions.
 */
bool TestMarketConditions() {
  bool _result = true;
  Market *_market = new Market();
  assertTrueOrReturnFalse(
      (new Condition(MARKET_COND_IN_PEAK_HOURS, _market)).Test() == _market.Condition(MARKET_COND_IN_PEAK_HOURS),
      "Wrong condition: MARKET_COND_IN_PEAK_HOURS!");
  return _result;
}

/**
 * Test math conditions.
 */
bool TestMathConditions() {
  bool _result = true;
  // @todo
  return _result;
}

/**
 * Test order conditions.
 */
bool TestOrderConditions() {
  bool _result = true;
  // @todo
  return _result;
}

/**
 * Test trade conditions.
 */
bool TestTradeConditions() {
  bool _result = true;
  Trade *_trade = new Trade();
  assertTrueOrReturnFalse(
      (new Condition(TRADE_COND_ALLOWED_NOT, _trade)).Test() == _trade.Condition(TRADE_COND_ALLOWED_NOT),
      "Wrong condition: TRADE_COND_ALLOWED_NOT!");
  return _result;
}