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
 * Test functionality of Condition class.
 */

// Forward declaration.
struct DataParamEntry;

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
  Condition *_cond = new Condition(ACCOUNT_COND_BAL_IN_LOSS);
  assertTrueOrReturnFalse(_cond.Test() == _acc.CheckCondition(ACCOUNT_COND_BAL_IN_LOSS),
                          "Wrong condition: ACCOUNT_COND_BAL_IN_LOSS!");
  delete _cond;
  delete _acc;
  return _result;
}

/**
 * Test chart conditions.
 */
bool TestChartConditions() {
  bool _result = true;
  Chart *_chart = new Chart();
  Condition *_cond = new Condition(CHART_COND_ASK_BAR_PEAK, _chart);
  assertTrueOrReturnFalse(_cond.Test() == _chart.CheckCondition(CHART_COND_ASK_BAR_PEAK),
                          "Wrong condition: CHART_COND_ASK_BAR_PEAK!");
  delete _cond;
  delete _chart;
  return _result;
}

/**
 * Test date time conditions.
 */
bool TestDateTimeConditions() {
  bool _result = true;
  DateTime *_dt = new DateTime();
  Condition *_cond1 = new Condition(DATETIME_COND_NEW_HOUR, _dt);
  assertTrueOrReturnFalse(_cond1.Test() == _dt.CheckCondition(DATETIME_COND_NEW_HOUR),
                          "Wrong condition: DATETIME_COND_NEW_HOUR (dynamic)!");
  delete _cond1;
  Condition *_cond2 = new Condition(DATETIME_COND_NEW_HOUR);
  assertTrueOrReturnFalse(_cond2.Test() == DateTime::CheckCondition(DATETIME_COND_NEW_HOUR),
                          "Wrong condition: DATETIME_COND_NEW_HOUR (static)!");
  delete _cond2;
  delete _dt;
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
      (new Condition(INDI_COND_ENTRY_IS_MAX, _demo)).Test() == _demo.CheckCondition(INDI_COND_ENTRY_IS_MAX),
      "Wrong condition: INDI_COND_ENTRY_IS_MAX!");
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_IS_MIN, _demo)).Test() == _demo.CheckCondition(INDI_COND_ENTRY_IS_MIN),
      "Wrong condition: INDI_COND_ENTRY_IS_MIN!");
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_GT_AVG, _demo)).Test() == _demo.CheckCondition(INDI_COND_ENTRY_GT_AVG),
      "Wrong condition: INDI_COND_ENTRY_GT_AVG!");
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_GT_MED, _demo)).Test() == _demo.CheckCondition(INDI_COND_ENTRY_GT_MED),
      "Wrong condition: INDI_COND_ENTRY_GT_MED!");
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_LT_AVG, _demo)).Test() == _demo.CheckCondition(INDI_COND_ENTRY_LT_AVG),
      "Wrong condition: INDI_COND_ENTRY_LT_AVG!");
  assertTrueOrReturnFalse(
      (new Condition(INDI_COND_ENTRY_LT_MED, _demo)).Test() == _demo.CheckCondition(INDI_COND_ENTRY_LT_MED),
      "Wrong condition: INDI_COND_ENTRY_LT_MED!");
  */
  delete _demo;
  return _result;
}

/**
 * Test market conditions.
 */
bool TestMarketConditions() {
  bool _result = true;
  Market *_market = new Market();
  Condition *_cond = new Condition(MARKET_COND_IN_PEAK_HOURS, _market);
  assertTrueOrReturnFalse(_cond.Test() == _market.CheckCondition(MARKET_COND_IN_PEAK_HOURS),
                          "Wrong condition: MARKET_COND_IN_PEAK_HOURS!");
  delete _cond;
  delete _market;
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
  Condition *_cond = new Condition(TRADE_COND_ALLOWED_NOT, _trade);
  assertTrueOrReturnFalse(_cond.Test() == _trade.CheckCondition(TRADE_COND_ALLOWED_NOT),
                          "Wrong condition: TRADE_COND_ALLOWED_NOT!");
  delete _cond;
  delete _trade;
  return _result;
}
