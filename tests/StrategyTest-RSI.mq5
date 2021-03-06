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

// Includes.
#include "../Indicators/Indi_RSI.mqh"
#include "../Strategy.mqh"
#include "../Test.mqh"

// Define strategy classes.
class Stg_RSI : public Strategy {
 public:
  // Class constructor.
  void Stg_RSI(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "") : Strategy(_sparams, _tparams, chart_params_defaults, _name) {}

  static Stg_RSI *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    ChartParams _cparams(_tf);
    RSIParams _indi_params(12, PRICE_OPEN, 0);
    StgParams _stg_params;
    TradeParams _tparams(_magic_no, _log_level);
    _stg_params.SetIndicator(new Indi_RSI(_indi_params));
    Strategy *_strat = new Stg_RSI(_stg_params, _tparams, _cparams, "RSI");
    return _strat;
  }

  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_RSI *_indi = GetIndicator();
    return (_cmd == ORDER_TYPE_BUY && _indi[_shift][0] <= 20) || (_cmd == ORDER_TYPE_SELL && _indi[_shift][0] >= 80);
  }

  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level, int _shift) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
  }

  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_RSI *_indi = GetIndicator();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    return _direction > 0 ? (float)_indi.GetPrice(PRICE_HIGH, _indi.GetHighest<double>(_indi.GetPeriod() * 2))
                          : (float)_indi.GetPrice(PRICE_LOW, _indi.GetLowest<double>(_indi.GetPeriod() * 2));
  }
};

// Global variables.
Strategy *stg_rsi;

/**
 * Implements OnInit().
 */
int OnInit() {
  // Initialize strategy.
  stg_rsi = Stg_RSI::Init(PERIOD_CURRENT, 1234);
  stg_rsi.SetName("Stg_RSI");

  assertTrueOrFail(stg_rsi.GetName() == "Stg_RSI", "Invalid Strategy name!");
  assertTrueOrFail(stg_rsi.IsValid(), "Fail on IsValid()!");
  // assertTrueOrFail(stg_rsi.GetMagicNo() == 1234, "Invalid magic number!");

  // Test whether strategy is enabled and not suspended.
  assertTrueOrFail(stg_rsi.IsEnabled(), "Fail on IsEnabled()!");
  assertFalseOrFail(stg_rsi.IsSuspended(), "Fail on IsSuspended()!");

  // Output.
  Print(stg_rsi.ToString());

  // Check for errors.
  long _last_error = GetLastError();
  if (_last_error > 0) {
    assertTrueOrFail(_last_error == ERR_NO_ERROR, StringFormat("Error occured! Code: %d", _last_error));
  }
  return INIT_SUCCEEDED;
}

/**
 * Implements OnTick().
 */
void OnTick() {
  if (stg_rsi.TickFilter(SymbolInfo::GetTick(_Symbol), 1)) {
    StrategySignal _signal = stg_rsi.ProcessSignals();
    if (_signal.CheckSignals(STRAT_SIGNAL_BUY_OPEN)) {
      assertTrueOrExit(_signal.GetOpenDirection() == 1, "Wrong order open direction!");
      stg_rsi.ExecuteAction(STRAT_ACTION_TRADE_EXE, TRADE_ACTION_ORDER_OPEN, ORDER_TYPE_BUY);
    } else if (_signal.CheckSignals(STRAT_SIGNAL_SELL_OPEN)) {
      assertTrueOrExit(_signal.GetOpenDirection() == -1, "Wrong order open direction!");
      stg_rsi.ExecuteAction(STRAT_ACTION_TRADE_EXE, TRADE_ACTION_ORDER_OPEN, ORDER_TYPE_SELL);
    } else {
      stg_rsi.ProcessOrders();
      stg_rsi.ProcessTasks();
    }
    long _last_error = GetLastError();
    if (_last_error > 0) {
      assertTrueOrExit(_last_error == ERR_NO_ERROR, StringFormat("Error occured! Code: %d", _last_error));
    }
  }
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) { delete stg_rsi; }
