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
#include "Log.mqh"
#include "Market.mqh"
#include "Orders.mqh"

/*
 * Class to provide functions that return parameters of the current account.
 */
class Account {

protected:
  // Variables.
  double init_balance, start_balance, start_credit;
  // Class variables.
  Log *logger;
  Market *market;
  Orders *orders;

public:

  // Defines.
  #define ACC_OP_BALANCE 6
  #define ACC_OP_CREDIT  7

  /**
   * Class constructor.
   */
  void Account(ENUM_LOG_LEVEL _log_level = V_INFO) :
    init_balance(CalcInitDeposit()),
    start_balance(AccountBalance()),
    start_credit(AccountBalance()),
    logger(new Log(_log_level)),
    market(new Market(_Symbol)),
    orders(new Orders(_Symbol))
  {
  }

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
      return NULL;
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
     * Get account init balance.
     */
    double AccountInitBalance() {
      return init_balance;
    }

    /**
     * Get account init credit.
     */
    double AccountStartCredit() {
      return start_credit;
    }

    /**
     * Get account stopout level in range: 0.0 - 1.0 where 1.0 is 100%.
     *
     * Note:
     *  - if(AccountEquity()/AccountMargin()*100 < AccountStopoutLevel()) { BrokerClosesOrders(); }
     */
    static double GetAccountStopoutLevel(bool verbose = true) {
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
      // @todo: Not implemented yet.
      return NULL;
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
      // @todo: Not implemented.
      return NULL;
      #endif
    }

    /**
     * Check account free margin.
     *
     * @return
     *   Returns true, when free margin is sufficient, false when insufficient or on error.
     */
    static bool CheckFreeMargin(int op_type, double size_of_lot) {
      #ifdef __MQL4__
      bool margin_ok = true;
      double margin = AccountFreeMarginCheck(Symbol(), op_type, size_of_lot);
      if (GetLastError() == 134 /* NOT_ENOUGH_MONEY */) margin_ok = false;
      return (margin_ok);
      #else
      // @todo: To be implemented.
      return NULL;
      #endif
    }

  /**
   * Calculate available lot size given the risk margin.
   */
  uint CalcMaxLotSize(double risk_margin = 1.0) {
    double _avail_margin = AccountAvailMargin();
    double _opened_lots = orders.GetOpenLots();
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
  double GetRiskMarginLevel(ENUM_ORDER_TYPE _cmd = NULL) {
    return 1 / AccountAvailMargin() * Convert::ValueToMoney(orders.TotalSL(_cmd));
  }

  /**
   * Calculates initial deposit based on the current balance and previous orders.
   */
  static double CalcInitDeposit() {
    double deposit = AccountInfoDouble(ACCOUNT_BALANCE);
    for (int i = Orders::OrdersHistoryTotal() - 1; i >= 0; i--) {
      if (!Order::OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      int type = Order::OrderType();
      // Initial balance not considered.
      if (i == 0 && type == ACC_OP_BALANCE) break;
      if (type == ORDER_TYPE_BUY || type == ORDER_TYPE_SELL) {
        // Calculate profit.
        double profit = Order::OrderProfit() + Order::OrderCommission() + Order::OrderSwap();
        // Calculate decrease balance.
        deposit -= profit;
      }
      if (type == ACC_OP_BALANCE || type == ACC_OP_CREDIT) {
        deposit -= Order::OrderProfit();
      }
    }
    return deposit;
  }

};
