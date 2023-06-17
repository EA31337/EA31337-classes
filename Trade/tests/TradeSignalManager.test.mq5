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
 * Test functionality of TradeSignalManager class.
 */

// Includes.
#include "../../Test.mqh"
#include "../TradeSignalManager.h"

// Test signals for expired signals.
bool TestSignalsExpired() {
  bool _result = true;
  TradeSignalManagerParams _tsm_params(5);
  TradeSignalManager _tsm(_tsm_params);
  _result &= _tsm.Get<short>(TSM_PROP_FREQ) == 5;
  for (int i = 0; i < 10; i++) {
    TradeSignalEntry _entry(i % 2 == 0 ? SIGNAL_OPEN_BUY_MAIN : SIGNAL_OPEN_SELL_MAIN);
    TradeSignal _signal(_entry);
    _tsm.SignalAdd(_signal);
  }
  _result &= _tsm.GetSignalsActive().Size() == 10;
  Print(_tsm.ToString());
  for (DictObjectIterator<int, TradeSignal> iter = _tsm.GetIterSignalsActive(); iter.IsValid(); ++iter) {
    TradeSignal *_signal = iter.Value();
    // Set signal as processed.
    _signal.Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_EXPIRED), true);
  }
  _tsm.Refresh();
  _result &= _tsm.GetSignalsActive().Size() == 0;
  _result &= _tsm.GetSignalsExpired().Size() == 10;
  _result &= _tsm.GetSignalsProcessed().Size() == 0;
  Print(_tsm.ToString());
  return _result;
}

// Test signals for processing.
bool TestSignalsProcessed() {
  bool _result = true;
  TradeSignalManager _tsm;
  for (int i = 0; i < 10; i++) {
    TradeSignalEntry _entry(i % 2 == 0 ? SIGNAL_OPEN_BUY_MAIN : SIGNAL_OPEN_SELL_MAIN);
    TradeSignal _signal(_entry);
    _tsm.SignalAdd(_signal);
  }
  _result &= _tsm.GetSignalsActive().Size() == 10;
  Print(_tsm.ToString());
  for (DictObjectIterator<int, TradeSignal> iter = _tsm.GetIterSignalsActive(); iter.IsValid(); ++iter) {
    TradeSignal *_signal = iter.Value();
    // Set signal as processed.
    _signal.Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_PROCESSED), true);
  }
  _tsm.Refresh();
  _result &= _tsm.GetSignalsActive().Size() == 0;
  _result &= _tsm.GetSignalsExpired().Size() == 0;
  _result &= _tsm.GetSignalsProcessed().Size() == 10;
  Print(_tsm.ToString());
  return _result;
}

/**
 * Implements OnInit().
 */
int OnInit() {
  bool _result = true;
  assertTrueOrFail(_result &= TestSignalsExpired(), "Fail!");
  assertTrueOrFail(_result &= TestSignalsProcessed(), "Fail!");
  return _result && GetLastError() == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED;
}
