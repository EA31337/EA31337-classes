//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
 * Test functionality of Exchange class.
 */

// Includes.
#include "../../Platform/Platform.h"
#include "../../Test.mqh"
#include "../Exchange.h"

// Test classes.
class AccountDummy : public AccountBase {};  // <AccountForexState, AccountForexEntry>
class ExchangeDummy : public Exchange {};
class SymbolDummy : public SymbolInfo {};
class TradeDummy : public Trade {
 public:
  TradeDummy(IndicatorBase *_indi_candle) : Trade(_indi_candle) {}
};

// Global variables.
ExchangeDummy ex_dummy;

// Test dummy Exchange.
bool TestExchange01() {
  bool _result = true;
  // Initialize a dummy Exchange instance.
  Ref<ExchangeDummy> exchange = new ExchangeDummy();

  // Attach instances of dummy accounts.
  Ref<AccountDummy> account01 = new AccountDummy();
  Ref<AccountDummy> account02 = new AccountDummy();
  exchange REF_DEREF AccountAdd(account01.Ptr(), "Account01");
  exchange REF_DEREF AccountAdd(account02.Ptr(), "Account02");

  // Attach instances of dummy symbols.
  Ref<SymbolDummy> symbol01 = new SymbolDummy();
  Ref<SymbolDummy> symbol02 = new SymbolDummy();
  exchange REF_DEREF SymbolAdd(symbol01.Ptr(), "Symbol01");
  exchange REF_DEREF SymbolAdd(symbol02.Ptr(), "Symbol02");

  // Attach instances of dummy trades.
  Ref<TradeDummy> trade01 = new TradeDummy(Platform::FetchDefaultCandleIndicator(_Symbol, PERIOD_CURRENT));
  Ref<TradeDummy> trade02 = new TradeDummy(Platform::FetchDefaultCandleIndicator(_Symbol, PERIOD_CURRENT));

  exchange REF_DEREF TradeAdd(trade01.Ptr(), "Trade01");
  exchange REF_DEREF TradeAdd(trade02.Ptr(), "Trade02");
  return _result;
}

/**
 * Implements OnInit().
 */
int OnInit() {
  Platform::Init();
  bool _result = true;
  assertTrueOrFail(TestExchange01(), "Fail!");
  return _result && GetLastError() == 0 ? INIT_SUCCEEDED : INIT_FAILED;
}
