//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
 * Test functionality of Trade class.
 */

// Includes.
#include "../Test.mqh"
#include "../Trade.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  // Initial market tests.
  assertTrueOrFail(SymbolInfo::GetAsk(_Symbol) > 0, "Invalid Ask price!");

  // Test 1.
  TradeParams tparams1(new Account, new Chart(PERIOD_M1, _Symbol), new Log);
  Trade *trade1 = new Trade(tparams1);

  // Test market.
  assertTrueOrFail(trade1.TradeAllowed(), "Trade not allowed!");
  assertTrueOrFail(trade1.Chart().GetTf() == PERIOD_M1,
                   StringFormat("Fail on GetTf() => [%s]!", EnumToString(trade1.Chart().GetTf())));
  assertTrueOrFail(trade1.Chart().GetOpen() > 0, "Fail on GetOpen()!");
  assertTrueOrFail(trade1.Market().GetSymbol() == _Symbol, "Fail on GetSymbol()!");
  // assertTrueOrFail(trade1.IsTradeAllowed(), "Fail on IsTradeAllowed()!"); // @fixme
  Print("Trade1 Account: ", trade1.Account().ToString());
  Print("Trade1 Chart: ", trade1.Chart().ToString());
  // Clean up.
  delete trade1;

  // Test 2.
  TradeParams tparams2(new Account, new Chart(PERIOD_M5, _Symbol), new Log);
  Trade *trade2 = new Trade(tparams2);

  // Test market.
  assertTrueOrFail(trade2.Chart().GetTf() == PERIOD_M5,
                   StringFormat("Fail on GetTf() => [%s]!", EnumToString(trade2.Chart().GetTf())));
  assertTrueOrFail(trade2.Chart().GetOpen() > 0, "Fail on GetOpen()!");
  assertTrueOrFail(trade2.Market().GetSymbol() == _Symbol, "Fail on GetSymbol()!");
  // assertTrueOrFail(trade2.IsTradeAllowed(), "Fail on IsTradeAllowed()!"); // @fixme
  // @todo
  Print("Trade2 Account: ", trade2.Account().ToString());
  Print("Trade2 Chart: ", trade2.Chart().ToString());
  // Clean up.
  delete trade2;

  return (INIT_SUCCEEDED);
}
