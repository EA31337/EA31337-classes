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

/*
 * Class to provide functions that return parameters of the current account.
 */
class Account {
public:

    /**
     * Returns the current account name.
     */
    static string AccountName() {
        #ifdef __MQL4__
        return AccountName();
        #else
        return AccountInfoString(ACCOUNT_NAME);
        #endif
    }

    /**
     * Returns the connected server name.
     */
    static string AccountServer() {
        #ifdef __MQL4__
        return AccountServer();
        #else
        return AccountInfoString(ACCOUNT_SERVER);
        #endif
    }

    /**
     * Returns currency name of the current account.
     */
    static string AccountCurrency() {
        #ifdef __MQL4__
        return AccountCurrency();
        #else
        return AccountInfoString(ACCOUNT_CURRENCY);
        #endif
    }

    /**
     * Returns the brokerage company name where the current account was registered.
     */
    static string AccountCompany() {
        #ifdef __MQL4__
        return AccountCompany();
        #else
        return AccountInfoString(ACCOUNT_COMPANY);
        #endif
    }

    /**
     * Returns balance value of the current account.
     */
    static double AccountBalance() {
        #ifdef __MQL4__
        return AccountBalance();
        #else
        return AccountInfoDouble(ACCOUNT_BALANCE);
        #endif
    }

    /**
     * Returns credit value of the current account.
     */
    static double AccountCredit() {
        #ifdef __MQL4__
        return AccountCredit();
        #else
        return AccountInfoDouble(ACCOUNT_CREDIT);
        #endif
    }

    /**
     * Returns profit value of the current account.
     */
    static double AccountProfit() {
        #ifdef __MQL4__
        return AccountProfit();
        #else
        return AccountInfoDouble(ACCOUNT_PROFIT);
        #endif
    }

    /**
     * Returns equity value of the current account.
     */
    static double AccountEquity() {
        #ifdef __MQL4__
        return AccountEquity();
        #else
        return AccountInfoDouble(ACCOUNT_EQUITY);
        #endif
    }

    /**
     * Returns margin value of the current account.
     */
    static double AccountMargin() {
        #ifdef __MQL4__
        return AccountMargin();
        #else
        return AccountInfoDouble(ACCOUNT_MARGIN);
        #endif
    }

    /**
     * Returns free margin value of the current account.
     */
    static double AccountFreeMargin() {
        #ifdef __MQL4__
        return AccountFreeMargin();
        #else
        return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
        #endif
    }

    /**
     * Returns leverage of the current account.
     */
    static long AccountLeverage() {
        #ifdef __MQL4__
        return AccountLeverage();
        #else
        return AccountInfoInteger(ACCOUNT_LEVERAGE);
        #endif
    }

    /**
     * Returns the current account number.
     */
    static long AccountNumber() {
        #ifdef __MQL4__
        return AccountNumber();
        #else
        return AccountInfoInteger(ACCOUNT_LOGIN);
        #endif
    }

    /**
     * Returns the calculation mode for the Stop Out level.
     */
    static long AccountStopoutMode() {
        #ifdef __MQL4__
        return AccountStopoutMode();
        #else
        return AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
        #endif
    }

    /**
     * Returns the value of the Stop Out level.
     */
    static int AccountStopoutLevel() {
        #ifdef __MQL4__
        return AccountStopoutLevel();
        #else
        // Not implemented.
        #endif
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
        return AccountFreeMarginMode();
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
        return AccountFreeMarginCheck(symbol, cmd, volume);
        #else
        // Not implemented.
        #endif
    }

    /**
     * Check account free margin.
     * @return
     * Returns True, when free margin is sufficient, False when insufficient or on error.
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

};
