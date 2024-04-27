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
 * Test functionality of AccountMt class.
 */

// Includes.
#include "../../Test.mqh"
#include "../AccountMt.h"

/**
 * Implements OnInit().
 */
int OnInit() {
  // Initialize class.
  AccountMt *acc = new AccountMt();

  // Defines variables.
  double _balance = AccountMt::AccountInfoDouble(ACCOUNT_BALANCE);
  double _credit = AccountMt::AccountInfoDouble(ACCOUNT_CREDIT);
  double _equity = AccountMt::AccountInfoDouble(ACCOUNT_EQUITY);

  // Dummy calls.
  acc.GetAccountName();
  acc.GetCompanyName();
  acc.GetLogin();
  acc.GetServerName();

  // assertTrueOrFail(acc.GetCurrency() == "USD", "Invalid currency: " + acc.GetCurrency()); // @fixme

  assertTrueOrFail(acc.GetBalance() == _balance, "Invalid balance!");  // 10000
  assertTrueOrFail(acc.GetCredit() == _credit, "Invalid credit!");     // 0
  assertTrueOrFail(acc.GetEquity() == _equity, "Invalid equity!");     // 10000
  assertTrueOrFail(acc.GetProfit() == 0, "Invalid profit!");           // 0

  assertTrueOrFail(acc.GetMarginUsed() == 0, "Invalid margin used!");               // 0
  assertTrueOrFail(acc.GetMarginFree() == _balance, "Invalid margin free!");        // 10000
  assertTrueOrFail(acc.GetStopoutMode() == 0, "Invalid stopout mode!");             // 0
  assertTrueOrFail(acc.GetLimitOrders() > 0, "Invalid limit orders!");              // 999
  assertTrueOrFail(acc.GetTotalBalance() == _balance, "Invalid real balance!");     // 10000
  assertTrueOrFail(acc.GetMarginAvail() == _balance, "Invalid margin available!");  // 10000
#ifdef __MQL4__
  // @fixme
  // assertTrueOrFail(acc.GetAccountFreeMarginMode() == 1.0, "Invalid account free margin mode!");  // 1.0
  // assertTrueOrFail(acc.GetLeverage() == 100, "Invalid leverage!");                               // 100
#endif
  assertTrueOrFail(acc.IsExpertEnabled() == (bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT),
                   "Invalid value for IsExpertEnabled()!");
  assertTrueOrFail(acc.IsTradeAllowed(), "Invalid value for IsTradeAllowed()!");  // true
  assertTrueOrFail(acc.IsDemo() == AccountMt::IsDemo(), "Invalid value for IsDemo()!");
  assertTrueOrFail(acc.GetType() == AccountMt::GetType(), "Invalid value for GetType()!");
  assertTrueOrFail(acc.GetInitBalance() == _balance, "Invalid init balance!");  // 10000
  assertTrueOrFail(acc.GetStartCredit() == _credit, "Invalid start credit!");   // 0
  // @fixme
  // assertTrueOrFail(acc.GetAccountStopoutLevel() == 0.3, "Invalid account stopout level!");  // 0.3

  Print(acc.GetAccountFreeMarginCheck(ORDER_TYPE_BUY, SymbolInfoStatic::GetVolumeMin(_Symbol)));
  Print(acc.GetAccountFreeMarginCheck(ORDER_TYPE_SELL, SymbolInfoStatic::GetVolumeMin(_Symbol)));
  Print(acc.IsFreeMargin(ORDER_TYPE_BUY, SymbolInfoStatic::GetVolumeMin(_Symbol)));
  Print(acc.IsFreeMargin(ORDER_TYPE_SELL, SymbolInfoStatic::GetVolumeMin(_Symbol)));

  assertTrueOrFail(acc.GetDrawdownInPct() == 0.0, "Invalid drawdown value!");  // 0
  // assertTrueOrFail(acc.GetRiskMarginLevel() == 0.0, "Invalid risk margin level!");             // 0
  assertTrueOrFail(acc.CalcInitDeposit() == _balance, "Invalid calculated initial deposit!");  // 10000

  // Print account details.
  Print(acc.ToString());
  Print(acc.ToCSV());

  // Clean up.
  delete acc;

  return (INIT_SUCCEEDED);
}
