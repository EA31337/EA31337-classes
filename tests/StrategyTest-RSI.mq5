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

#define __debug__
#define __debug_verbose__

// Includes.
#include "../ChartMt.h"
#include "../Indicator/tests/classes/IndicatorTfDummy.h"
#include "../Indicator/tests/classes/IndicatorTickReal.h"
#include "../Indicators/Indi_RSI.mqh"
#include "../Strategy.mqh"
#include "../Test.mqh"

// Define strategy classes.
class Stg_RSI : public Strategy {
 public:
  // Class constructor.
  void Stg_RSI(StgParams &_sparams, TradeParams &_tparams, IndicatorBase *_indi_source, string _name = "")
      : Strategy(_sparams, _tparams, _indi_source, _name) {}

  static Stg_RSI *Init(IndicatorBase *_indi_source) {
    IndiRSIParams _indi_params(12, PRICE_OPEN, 0);
    StgParams _stg_params;
    TradeParams _tparams;
    Strategy *_strat = new Stg_RSI(_stg_params, _tparams, _indi_source, "RSI");
    IndicatorBase *_indi_rsi = new Indi_RSI(_indi_params);
    _strat.SetIndicator(_indi_rsi);
    _indi_rsi PTR_DEREF SetDataSource(_indi_source);
    return _strat;
  }

  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_RSI *_indi = GetIndicator();
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift);
    _result &=
        (_cmd == ORDER_TYPE_BUY && _indi[_shift][0] <= 20) || (_cmd == ORDER_TYPE_SELL && _indi[_shift][0] >= 80);
    return _result;
  }

  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level, int _shift) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
  }

  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_RSI *_indi = GetIndicator();
    IndiRSIParams _iparams = _indi.GetParams();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    return _direction > 0 ? (float)_indi.GetPrice(PRICE_HIGH, _indi.GetHighest<double>(_iparams.GetPeriod() * 2))
                          : (float)_indi.GetPrice(PRICE_LOW, _indi.GetLowest<double>(_iparams.GetPeriod() * 2));
  }

  virtual void OnPeriod(unsigned int _periods = DATETIME_NONE) {
    if ((_periods & DATETIME_HOUR) != 0) {
      // New hour started.
    }
  }
};

// Global variables.
Ref<Strategy> stg_rsi;
Ref<Trade> trade;
Ref<IndicatorTickReal> _ticks;
Ref<IndicatorTfDummy> _candles;

/**
 * Implements OnInit().
 */
int OnInit() {
  // Initialize ticker and candle indicators.
  _ticks = new IndicatorTickReal(_Symbol);
  _candles = new IndicatorTfDummy(PERIOD_M1);
  _candles.Ptr().SetDataSource(_ticks.Ptr());

  // Initialize strategy instance.
  stg_rsi = Stg_RSI::Init(_candles.Ptr());
  stg_rsi REF_DEREF SetName("Stg_RSI");
  stg_rsi REF_DEREF Set<long>(STRAT_PARAM_ID, 1234);

  // Initialize trade instance.
  TradeParams _tparams;
  trade = new Trade(_tparams, _candles.Ptr());

  assertTrueOrFail(stg_rsi REF_DEREF GetName() == "Stg_RSI", "Invalid Strategy name!");
  assertTrueOrFail(stg_rsi REF_DEREF IsValid(), "Fail on IsValid()!");
  // assertTrueOrFail(stg_rsi REF_DEREF GetMagicNo() == 1234, "Invalid magic number!");

  // Test whether strategy is enabled and not suspended.
  assertTrueOrFail(stg_rsi REF_DEREF IsEnabled(), "Fail on IsEnabled()!");
  assertFalseOrFail(stg_rsi REF_DEREF IsSuspended(), "Fail on IsSuspended()!");

  // Output.
  Print(stg_rsi REF_DEREF ToString());

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
  // Strategy will tick all attached indicators.
  stg_rsi REF_DEREF Tick();

  static MqlTick _tick_last;
  MqlTick _tick_new = SymbolInfoStatic::GetTick(_Symbol);
  if (_tick_new.time % 60 < _tick_last.time % 60) {
    if (stg_rsi REF_DEREF SignalOpen(ORDER_TYPE_BUY)) {
      MqlTradeRequest _request = trade REF_DEREF GetTradeOpenRequest(
          ORDER_TYPE_BUY, 0, stg_rsi REF_DEREF Get<long>(STRAT_PARAM_ID), stg_rsi REF_DEREF GetName());
      trade REF_DEREF RequestSend(_request);
    } else if (stg_rsi REF_DEREF SignalOpen(ORDER_TYPE_SELL)) {
      MqlTradeRequest _request = trade REF_DEREF GetTradeOpenRequest(
          ORDER_TYPE_SELL, 0, stg_rsi REF_DEREF Get<long>(STRAT_PARAM_ID), stg_rsi REF_DEREF GetName());
      trade REF_DEREF RequestSend(_request);
    }
    if (trade REF_DEREF Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
      if (stg_rsi REF_DEREF SignalClose(ORDER_TYPE_BUY)) {
        // Close signal for buy order.
        trade REF_DEREF OrdersCloseViaProp2<ENUM_ORDER_PROPERTY_INTEGER, long>(
            ORDER_MAGIC, stg_rsi REF_DEREF Get<long>(STRAT_PARAM_ID), ORDER_TYPE, ORDER_TYPE_BUY, MATH_COND_EQ,
            ORDER_REASON_CLOSED_BY_SIGNAL, stg_rsi REF_DEREF GetOrderCloseComment());
      }
      if (stg_rsi REF_DEREF SignalClose(ORDER_TYPE_SELL)) {
        trade REF_DEREF OrdersCloseViaProp2<ENUM_ORDER_PROPERTY_INTEGER, long>(
            ORDER_MAGIC, stg_rsi REF_DEREF Get<long>(STRAT_PARAM_ID), ORDER_TYPE, ORDER_TYPE_SELL, MATH_COND_EQ,
            ORDER_REASON_CLOSED_BY_SIGNAL, stg_rsi REF_DEREF GetOrderCloseComment());
      }
    }
    if (_tick_new.time % 3600 < _tick_last.time % 3600) {
      stg_rsi REF_DEREF ProcessTasks();
      trade REF_DEREF UpdateStates();
      // Print strategy values every hour.
      Print(stg_rsi REF_DEREF ToString());
    }
    long _last_error = GetLastError();
    if (_last_error > 0) {
      assertTrueOrExit(_last_error == ERR_NO_ERROR, StringFormat("Error occured! Code: %d", _last_error));
    }
  }
  _tick_last = _tick_new;
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {}
