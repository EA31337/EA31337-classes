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

/**
 * @file
 * Test functionality of Exchange class.
 */

// Includes.
#include "../../Test.mqh"
#include "../Exchange.h"

// Test classes.
class AccountDummy : public AccountBase {};  // <AccountForexState, AccountForexEntry>
class ExchangeDummy : public Exchange {};
class SymbolDummy : public SymbolInfo {};
class TradeDummy : public Trade {};

// Global variables.
ExchangeDummy ex_dummy;

// Test dummy Exchange.
bool TestExchange01() {
  bool _result = true;
  // Initialize a dummy Exchange instance.
  ExchangeDummy exchange;
  // Attach instances of dummy accounts.
  AccountDummy account01;
  AccountDummy account02;
  exchange.AccountAdd(account01, "Account01");
  exchange.AccountAdd(account02, "Account02");
  // Attach instances of dummy symbols.
  SymbolDummy symbol01;
  SymbolDummy symbol02;
  exchange.SymbolAdd(symbol01, "Symbol01");
  exchange.SymbolAdd(symbol02, "Symbol02");
  // Attach instances of dummy trades.
  TradeDummy trade01;
  TradeDummy trade02;
  exchange.TradeAdd(trade01, "Trade01");
  exchange.TradeAdd(trade02, "Trade02");
  return _result;
}

/**
 * Implements OnInit().
 */
int OnInit() {
  bool _result = true;
  assertTrueOrFail(TestExchange01(), "Fail!");
  return _result && GetLastError() == 0 ? INIT_SUCCEEDED : INIT_FAILED;
}
