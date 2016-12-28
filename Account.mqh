//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

// Includes.
#include "Market.mqh"
#include "Orders.mqh"

/*
 * Class to provide functions that return parameters of the current account.
 */
class Account {
public:

    /* MT Account methods */

    /**
     * Returns the current account name.
     */
    static string AccountName() {
      return AccountInfoString(ACCOUNT_NAME);
    }

    /**
     * Returns the connected server name.
     */
    static string AccountServer() {
      return AccountInfoString(ACCOUNT_SERVER);
    }

    /**
     * Returns currency name of the current account.
     */
    static string AccountCurrency() {
      return AccountInfoString(ACCOUNT_CURRENCY);
    }

    /**
     * Returns the brokerage company name where the current account was registered.
     */
    static string AccountCompany() {
      return AccountInfoString(ACCOUNT_COMPANY);
    }

    /* Double getters */

    /**
     * Returns balance value of the current account.
     */
    static double AccountBalance() {
      return AccountInfoDouble(ACCOUNT_BALANCE);
    }

    /**
     * Returns credit value of the current account.
     */
    static double AccountCredit() {
      return AccountInfoDouble(ACCOUNT_CREDIT);
    }

    /**
     * Returns profit value of the current account.
     */
    static double AccountProfit() {
      return AccountInfoDouble(ACCOUNT_PROFIT);
    }

    /**
     * Returns equity value of the current account.
     */
    static double AccountEquity() {
      return AccountInfoDouble(ACCOUNT_EQUITY);
    }

    /**
     * Returns margin value of the current account.
     */
    static double AccountMargin() {
      return AccountInfoDouble(ACCOUNT_MARGIN);
    }

    /**
     * Returns free margin value of the current account.
     */
    static double AccountFreeMargin() {
      return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    }

    /* Integer getters */

    /**
     * Returns the current account number.
     */
    static long AccountNumber() {
      return AccountInfoInteger(ACCOUNT_LOGIN);
    }

    /**
     * Returns leverage of the current account.
     */
    static long AccountLeverage() {
      return AccountInfoInteger(ACCOUNT_LEVERAGE);
    }

    /**
     * Returns the calculation mode for the Stop Out level.
     */
    static int AccountStopoutMode() {
      return (int) AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
    }

    /**
     * Returns the value of the Stop Out level.
     */
    static int AccountStopoutLevel() {
      #ifdef __MQL4__
      return ::AccountStopoutLevel();
      #else
      // Not implemented.
      // @todo
      // ENUM_ACCOUNT_STOPOUT_MODE stop_out_mode=(ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
      // ((stop_out_mode==ACCOUNT_STOPOUT_MODE_PERCENT)?"percentage":" money")
      #endif
    }

    /**
     * Get account real balance (including credit).
     */
    static double AccountRealBalance() {
      return AccountBalance() + AccountCredit();
    }

    /**
     * Get a maximum allowed number of active pending orders set by broker.
     *
     * @return
     *   Returns the limit orders (0 for unlimited).
     */
    static uint AccountLimitOrders() {
      return (uint) AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
    }

    /**
     * Get account available margin.
     */
    static double AccountAvailMargin() {
      return fmin(AccountFreeMargin(), AccountRealBalance());
    }

    /**
     * Get account stopout level in range: 0.0 - 1.0 where 1.0 is 100%.
     *
     * Note:
     *  - if(AccountEquity()/AccountMargin()*100 < AccountStopoutLevel()) { BrokerClosesOrders(); }
     */
    static double GetAccountStopoutLevel(bool verbose = True) {
      int mode = AccountStopoutMode();
      int level = AccountStopoutLevel();
      if (mode == 0 && level > 0) {
         // Calculation of percentage ratio between margin and equity.
         return (double) level / 100;
      } else if (mode == 1) {
        // Comparison of the free margin level to the absolute value.
        return 1.0;
      } else {
       if (verbose) PrintFormat("%s(): Not supported mode (%d).", __FUNCTION__, mode);
      }
      return 1.0;
    }

    /**
     * Returns the calculation mode of free margin allowed to open orders on the current account.
     */
    static double AccountFreeMarginMode() {
        #ifdef __MQL4__
        /*
         *  The calculation mode can take the following values:
         *  0 - floating profit/loss is not used for calculation;
         *  1 - both floating profit and loss on opened orders on the current account are used for free margin calculation;
         *  2 - only profit value is used for calculation, the current loss on opened orders is not considered;
         *  3 - only loss value is used for calculation, the current loss on opened orders is not considered.
         */
        return ::AccountFreeMarginMode();
        #else
        // Not implemented.
        #endif
    }

    /**
     * Returns free margin that remains after the specified order has been opened at the current price on the current account.
     * @return
     * Free margin that remains after the specified order has been opened at the current price on the current account.
     * If the free margin is insufficient, an error 134 (ERR_NOT_ENOUGH_MONEY) will be generated.
     */
    static double AccountFreeMarginCheck(string symbol, int cmd, double volume) {
        #ifdef __MQL4__
        return ::AccountFreeMarginCheck(symbol, cmd, volume);
        #else
        // Not implemented.
        #endif
    }

    /**
     * Check account free margin.
     *
     * @return
     *   Returns True, when free margin is sufficient, False when insufficient or on error.
     */
    static bool CheckFreeMargin(int op_type, double size_of_lot) {
        #ifdef __MQL4__
        bool margin_ok = True;
        double margin = AccountFreeMarginCheck(Symbol(), op_type, size_of_lot);
        if (GetLastError() == 134 /* NOT_ENOUGH_MONEY */) margin_ok = False;
        return (margin_ok);
        #else
        // @todo
        #endif
    }

    /**
     * Calculate size of the lot based on the free margin.
     */
    static double CalcLotSize(double risk_margin = 1, double risk_ratio = 1.0, string symbol = NULL) {
      return AccountAvailMargin() / Market::GetMarginRequired(symbol) * risk_margin/100 * risk_ratio;
    }

  /**
   * Calculate available lot size given the risk margin.
   */
  static uint CalcMaxLotSize(double risk_margin = 1.0, string symbol = NULL) {
    double _avail_margin = AccountAvailMargin();
    double _opened_lots = Orders::GetOpenLots(symbol);
    // @todo
    return 0;
  }

  /**
   * Get current account drawdown in percent.
   */
  static double GetDrawdownInPct() {
    // @todo: To test.
    return 100 / (AccountRealBalance()) * AccountEquity();
  }

  /**
   * Get current account risk margin level.
   *
   * The risk is calculated based on the stop loss sum of opened orders.
   *
   * @return
   *   Returns value from 0.0 (no risk) and 1.0 (100% risk).
   *   The risk higher than 1.0 means that the risk is extremely high.
   */
  static double GetRiskMarginLevel(int cmd = EMPTY) {
    return 1 / AccountAvailMargin() * Convert::ValueToMoney(Orders::TotalSL(cmd));
  }

};
