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

// Class dependencies.
class Orders;

// Includes.
#include "Log.mqh"
#include "Market.mqh"
#include "Orders.mqh"
#ifdef __MQL5__
#include <Trade/AccountInfo.mqh>
#endif

/*
 * Class to provide functions that return parameters of the current account.
 */
class Account {

protected:

  // Enums.
  enum ENUM_ACC_STAT_VALUE {
    ACC_BALANCE               = 0,
    ACC_CREDIT                = 1,
    ACC_EQUITY                = 2,
    ACC_PROFIT                = 3,
    ACC_MARGIN_USED           = 4,
    ACC_MARGIN_FREE           = 5,
    FINAL_ENUM_ACC_STAT_VALUE = 6
  };
  enum ENUM_ACC_STAT_PERIOD {
    ACC_DAILY                  = 0,
    ACC_WEEKLY                 = 1,
    ACC_MONTHLY                = 2,
    FINAL_ENUM_ACC_STAT_PERIOD = 3
  };
  enum ENUM_ACC_STAT_TYPE {
    ACC_VALUE_MIN            = 0,
    ACC_VALUE_MAX            = 1,
    ACC_VALUE_AVG            = 2,
    FINAL_ENUM_ACC_STAT_TYPE = 3
  };
  enum ENUM_ACC_STAT_INDEX {
    ACC_VALUE_CURR             = 0,
    ACC_VALUE_PREV             = 1,
    FINAL_ENUM_ACC_STAT_INDEX = 2
  };

  // Struct.
  /*
  struct AccountEntry {
    double balance;
    double credit;
    double equity;
    double profit;
    double used_margin;
    double free_margin;
  };
  */

  // Variables.
  double init_balance, start_balance, start_credit;
  // Store daily, weekly and monthly account statistics.
  double acc_stats[FINAL_ENUM_ACC_STAT_VALUE][FINAL_ENUM_ACC_STAT_PERIOD][FINAL_ENUM_ACC_STAT_TYPE][FINAL_ENUM_ACC_STAT_INDEX];

  // Class variables.
  Log *logger;
  Market *market;
  Orders *orders;
  #ifdef __MQL5__
  CAccountInfo account_info;
  #endif

public:

  // Defines.
  #define ACC_OP_BALANCE 6 // Undocumented balance history statement entry.
  #define ACC_OP_CREDIT  7 // Undocumented credit history statement entry.

  /**
   * Class constructor.
   */
  void Account(Market *_market = NULL, Orders *_orders = NULL, Log *_log = NULL) :
    init_balance(CalcInitDeposit()),
    start_balance(AccountBalance()),
    start_credit(AccountBalance()),
    logger(_log != NULL ? _log : new Log),
    market(_market != NULL ? _market : new Market),
    orders(_orders != NULL ? _orders : new Orders)
  {
  }

  /**
   * Class deconstructor.
   */
  void ~Account() {
    // Remove class variables.
    delete logger;
    delete market;
    delete orders;
  }

  /* MT account methods */

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
  double GetBalance() {
    return UpdateStats(ACC_BALANCE, AccountBalance());
  }

  /**
   * Returns credit value of the current account.
   */
  static double AccountCredit() {
    return AccountInfoDouble(ACCOUNT_CREDIT);
  }
  double GetCredit() {
    return UpdateStats(ACC_CREDIT, AccountCredit());
  }

  /**
   * Returns profit value of the current account.
   */
  static double AccountProfit() {
    return AccountInfoDouble(ACCOUNT_PROFIT);
  }
  double GetProfit() {
    return UpdateStats(ACC_PROFIT, AccountProfit());
  }

  /**
   * Returns equity value of the current account.
   */
  static double AccountEquity() {
    return AccountInfoDouble(ACCOUNT_EQUITY);
  }
  double GetEquity() {
    return UpdateStats(ACC_EQUITY, AccountEquity());
  }

  /**
   * Returns margin value of the current account.
   */
  static double AccountMargin() {
    return AccountInfoDouble(ACCOUNT_MARGIN);
  }
  double GetMarginUsed() {
    return UpdateStats(ACC_MARGIN_USED, AccountMargin());
  }

  /**
   * Returns free margin value of the current account.
   */
  static double AccountFreeMargin() {
    return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
  }
  double GetMarginFree() {
    return UpdateStats(ACC_MARGIN_FREE, AccountFreeMargin());
  }

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
   *
   * Depending on the set ACCOUNT_MARGIN_SO_MODE,
   * is expressed in percents or in the deposit currency.
   */
  static double AccountStopoutLevel() {
    return AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
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

  /* Other account methods */

  /**
   * Get account real balance (including credit).
   */
  static double AccountRealBalance() {
    return AccountBalance() + AccountCredit();
  }
  double GetRealBalance() {
    return GetBalance() + GetCredit();
  }

  /**
   * Get account available margin.
   */
  static double AccountAvailMargin() {
    return fmin(AccountFreeMargin(), AccountRealBalance());
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

  /* State checkers */

  /**
   * Indicates if an Expert Advisor is allowed to trade on the account.
   */
  bool IsExpertEnabled() {
    return (bool) AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
  }

  /**
   * Check if the Expert Advisor runs on a demo account.
   */
  bool IsDemo() {
    #ifdef __MQL4__
    return ::IsDemo();
    #else // __MQL5__
    return AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO;
    #endif
  }

  /* Setters */

  double UpdateStats(ENUM_ACC_STAT_VALUE _type, double _value) {
    static datetime _last_check = TimeCurrent();
    bool _stats_rotate = false;
    for (uint _pindex = 0; _pindex < FINAL_ENUM_ACC_STAT_PERIOD; _pindex++) {
      acc_stats[_type][_pindex][ACC_VALUE_MIN][ACC_VALUE_CURR] = fmin(acc_stats[_type][_pindex][ACC_VALUE_MIN][ACC_VALUE_CURR], _value);
      acc_stats[_type][_pindex][ACC_VALUE_MAX][ACC_VALUE_CURR] = fmin(acc_stats[_type][_pindex][ACC_VALUE_MAX][ACC_VALUE_CURR], _value);
      acc_stats[_type][_pindex][ACC_VALUE_AVG][ACC_VALUE_CURR] = (acc_stats[_type][_pindex][ACC_VALUE_AVG][ACC_VALUE_CURR] + _value) / 2;
      switch (_pindex) {
        case ACC_DAILY:   _stats_rotate = _last_check < market.iTime(PERIOD_D1); break;
        case ACC_WEEKLY:  _stats_rotate = _last_check < market.iTime(PERIOD_W1); break;
        case ACC_MONTHLY: _stats_rotate = _last_check < market.iTime(PERIOD_MN1); break;
      }
      if (_stats_rotate) {
        acc_stats[_type][_pindex][ACC_VALUE_MIN][ACC_VALUE_PREV] = acc_stats[_type][_pindex][ACC_VALUE_MIN][ACC_VALUE_CURR];
        acc_stats[_type][_pindex][ACC_VALUE_MAX][ACC_VALUE_PREV] = acc_stats[_type][_pindex][ACC_VALUE_MAX][ACC_VALUE_CURR];
        acc_stats[_type][_pindex][ACC_VALUE_AVG][ACC_VALUE_PREV] = acc_stats[_type][_pindex][ACC_VALUE_AVG][ACC_VALUE_CURR];
        acc_stats[_type][_pindex][ACC_VALUE_MIN][ACC_VALUE_CURR] = _value;
        acc_stats[_type][_pindex][ACC_VALUE_MAX][ACC_VALUE_CURR] = _value;
        acc_stats[_type][_pindex][ACC_VALUE_AVG][ACC_VALUE_CURR] = _value;
        _last_check = TimeCurrent();
      }
    }
    return _value;
  }

  /* Class getters */

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

  /* Calculation methods */

  /**
   * Get account stopout level in range: 0.0 - 1.0 where 1.0 is 100%.
   *
   * Note:
   *  - if(AccountEquity()/AccountMargin()*100 < AccountStopoutLevel()) { BrokerClosesOrders(); }
   */
  static double GetAccountStopoutLevel(bool verbose = true) {
    int mode = AccountStopoutMode();
    double level = AccountStopoutLevel();
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
   * Returns free margin that remains after the specified order has been opened at the current price on the current account.
   *
   * @return
   * Free margin that remains after the specified order has been opened at the current price on the current account.
   * If the free margin is insufficient, an error 134 (ERR_NOT_ENOUGH_MONEY) will be generated.
   */
  double AccountFreeMarginCheck(string _symbol, ENUM_ORDER_TYPE _cmd, double _volume) {
    // Notes:
    // AccountFreeMarginCheck =  FreeMargin - Margin1Lot * Lot;
    // FreeMargin = Equity - Margin;
    // Equity = Balance + Profit;
    // FreeMargin =  Balance + Profit - Margin;
    // AccountFreeMarginCheck = Balance + Profit - Margin - Margin1Lot * Lot;
    #ifdef __MQL4__
    return ::AccountFreeMarginCheck(_symbol, _cmd, _volume);
    #else
    // @see: CAccountInfo::FreeMarginCheck
    // return(FreeMargin()-MarginCheck(symbol,trade_operation,volume,price));
    double _open_price = _cmd == ORDER_TYPE_BUY ? SymbolInfoDouble(_symbol, SYMBOL_ASK) : SymbolInfoDouble(_symbol, SYMBOL_BID);
    return account_info.FreeMarginCheck(_symbol, _cmd, _volume, _open_price);
    #endif
  }
  double AccountFreeMarginCheck(ENUM_ORDER_TYPE _cmd, double _volume) {
    return AccountFreeMarginCheck(market.GetSymbol(), _cmd, _volume);
  }

  /**
   * Check account free margin.
   *
   * @return
   *   Returns true, when free margin is sufficient, false when insufficient or on error.
   */
  bool CheckFreeMargin(ENUM_ORDER_TYPE _cmd, double size_of_lot) {
    bool _res = true;
    double margin = AccountFreeMarginCheck(_cmd, size_of_lot);
    if (GetLastError() == 134 /* NOT_ENOUGH_MONEY */) _res = false;
    return (_res);
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

  /**
   * Calculate total profit.
   */
  double GetTotalProfit() {
  /* @todo
    double total_profit = 0;
    for (int id = 0; id < ArrayRange(stats, 0); id++) {
      total_profit += stats[id][TOTAL_NET_PROFIT];
    }
    return total_profit;
  */
    return 0;
  }

  /**
   * Returns min/max/avg daily/weekly/monthly account balance/equity/margin.
   */
  double GetStatValue(ENUM_ACC_STAT_VALUE _value_type, ENUM_ACC_STAT_PERIOD _period, ENUM_ACC_STAT_TYPE _stat_type, ENUM_ACC_STAT_INDEX _shift = ACC_VALUE_CURR) {
    return acc_stats[_value_type][_period][_stat_type][_shift];
  }

  /* Class access methods */

  /**
   * Returns access to Market class.
   */
  Market *Market() {
    return market;
  }

  /**
   * Returns access to Orders class.
   */
  Orders *Orders() {
    return orders;
  }

};
