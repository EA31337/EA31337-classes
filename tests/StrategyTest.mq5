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
 * Test functionality of Strategy class.
 */

// Forward declaration.
struct DataParamEntry;

// Includes.
#include "../Indicators/Indi_Demo.mqh"
#include "../Strategy.mqh"
#include "../Test.mqh"

// Define strategy classes.
class Stg1 : public Strategy {
 public:
  // Class constructor.
  void Stg1(StgParams &_params, string _name = "")
      : Strategy(_params, trade_params_defaults, chart_params_defaults, _name) {}
  void OnInit() { trade.tparams.SetMagicNo(1234); }

  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level, int _shift) { return _method % 2 == 0; }

  bool SignalOpenFilterMethod(ENUM_ORDER_TYPE _cmd, int _method = 0) { return true; }

  float SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) { return 1.0; }

  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level, int _shift) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
  }

  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) { return 0; }
};

class Stg2 : public Strategy {
 public:
  // Class constructor.
  void Stg2(StgParams &_params, string _name = "")
      : Strategy(_params, trade_params_defaults, chart_params_defaults, _name) {}
  void OnInit() {
    ddata.Set(1, 1.1);
    fdata.Set(1, 1.1f);
    idata.Set(1, 1);
  }

  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level, int _shift) { return _method % 2 == 0; }

  bool SignalOpenFilterMethod(ENUM_ORDER_TYPE _cmd, int _method = 0) { return true; }

  float SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) { return 0.0; }

  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level, int _shift) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
  }

  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) { return 0; }
};

// Global variables.
Strategy *strat1;
Strategy *strat2;

/**
 * Implements OnInit().
 */
int OnInit() {
  // Initial market tests.
  assertTrueOrFail(SymbolInfoStatic::GetAsk(_Symbol) > 0, "Invalid Ask price!");

  /* Test 1st strategy. */

  // Initialize strategy.
  StgParams stg1_params;
  strat1 = new Stg1(stg1_params, "Stg1");
  assertTrueOrFail(strat1.GetName() == "Stg1", "Invalid Strategy name!");
  assertTrueOrFail(strat1.IsValid(), "Fail on IsValid()!");
  // assertTrueOrFail(strat1.GetMagicNo() == 1234, "Invalid magic number!");

  // Test whether strategy is enabled and not suspended.
  assertTrueOrFail(strat1.IsEnabled(), "Fail on IsEnabled()!");
  assertFalseOrFail(strat1.IsSuspended(), "Fail on IsSuspended()!");

  // Output.
  Print(strat1.ToString());

  /* Test 2nd strategy. */

  // Initialize strategy.
  IndiDemoParams iparams;
  ChartParams cparams(PERIOD_M5);
  StgParams stg2_params;
  stg2_params.Enabled(false);
  stg2_params.Suspended(true);
  strat2 = new Stg2(stg2_params);
  strat2.SetIndicator(new Indi_Demo(iparams));
  strat2.SetName("Stg2");
  assertTrueOrFail(strat2.GetName() == "Stg2", "Invalid Strategy name!");
  assertTrueOrFail(strat2.IsValid(), "Fail on IsValid()!");

  // Test enabling.
  assertFalseOrFail(strat2.IsEnabled(), "Fail on IsEnabled()!");
  assertTrueOrFail(strat2.IsSuspended(), "Fail on IsSuspended()!");
  strat2.Enabled();
  strat2.Suspended(false);
  assertTrueOrFail(strat2.IsEnabled(), "Fail on IsEnabled()!");
  assertFalseOrFail(strat2.IsSuspended(), "Fail on IsSuspended()!");

  // Output.
  Print(strat2.ToString());

  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  delete strat1;
  delete strat2;
}
