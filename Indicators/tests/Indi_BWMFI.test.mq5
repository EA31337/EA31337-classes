//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

// Includes.
#include "../../Test.mqh"
#include "../Indi_BWMFI.mqh"

/**
 * @file
 * Test functionality of Indi_BWMFI indicator class.
 */

Indi_BWMFI indi(PERIOD_CURRENT, 1);

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  assertTrueOrFail(indi.IsValid(), "Error on IsValid!");
  // assertTrueOrFail(indi.IsValidEntry(), "Error on IsValidEntry!");
  return (_result && _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
  static MqlTick _tick_last;
  MqlTick _tick_new = SymbolInfoStatic::GetTick(_Symbol);
  if (_tick_new.time % 60 < _tick_last.time % 60) {
    // Process ticks each minute.
    if (_tick_new.time % 3600 < _tick_last.time % 3600) {
      // Print indicator values every hour.
      Print(indi.ToString());
      if (indi.Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
        assertTrueOrExit(indi.GetEntry().IsValid(), "Invalid entry!");
      }
    }
  }
  _tick_last = _tick_new;
}
