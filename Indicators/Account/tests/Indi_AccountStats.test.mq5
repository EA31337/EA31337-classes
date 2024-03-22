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

// Includes.
#include "../../../Account/AccountMt.h"
#include "../../../Platform.h"
#include "../../../Test.mqh"
#include "../Indi_AccountStats.mqh"

/**
 * @file
 * Test functionality of Indi_AccountStats indicator class.
 */

Ref<Indi_AccountStats> indi_account_mt;

int OnInit() {
  Ref<AccountMt> account_mt = new AccountMt();
  Indi_AccountStats_Params indi_params(account_mt.Ptr());
  indi_account_mt = new Indi_AccountStats(indi_params);

  Platform::Init();

  Platform::AddWithDefaultBindings(indi_account_mt.Ptr());

  bool _result = true;
  assertTrueOrFail(indi_account_mt REF_DEREF IsValid(), "Error on IsValid!");
  return (_result && _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED);
}

void OnTick() {
  Platform::Tick();
  if (Platform::IsNewHour()) {
    IndicatorDataEntry _entry = indi_account_mt REF_DEREF GetEntry();
    bool _is_ready = indi_account_mt REF_DEREF Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY));
    bool _is_valid = _entry.IsValid();
    Print(indi_account_mt REF_DEREF ToString(), _is_ready ? "" : " (Not yet ready)");
    if (_is_ready && !_is_valid) {
      Print(indi_account_mt REF_DEREF ToString(), " (Invalid entry!)");
      assertTrueOrExit(_entry.IsValid(), "Invalid entry!");
    }
  }
}