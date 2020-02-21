//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

// Prevents processing this includes file for the second time.
#ifndef ACCOUNT_MQH
#define ACCOUNT_MQH

// Forward class declaration.
class Account;

// Includes.
#include "Array.mqh"
#include "Chart.mqh"
#include "Convert.mqh"
#include "Orders.mqh"
#include "SymbolInfo.mqh"

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
  ACC_VALUE_CURR            = 0,
  ACC_VALUE_PREV            = 1,
  FINAL_ENUM_ACC_STAT_INDEX = 2
};

#ifndef __MQLBUILD__
// Used in AccountInfoInteger().
enum ENUM_ACCOUNT_INFO_INTEGER {
  ACCOUNT_CURRENCY_DIGITS, // Decimal places required for an accurate display of trading results (int).
  ACCOUNT_FIFO_CLOSE, // Whether positions can only be closed by FIFO rule.
  ACCOUNT_LEVERAGE, // Account leverage (long).
  ACCOUNT_LIMIT_ORDERS, // Maximum allowed number of active pending orders (int).
  ACCOUNT_LOGIN, // Account number (long).
  ACCOUNT_MARGIN_MODE, // Margin calculation mode (ENUM_ACCOUNT_MARGIN_MODE).
  ACCOUNT_MARGIN_SO_MODE, // Mode for setting the minimal allowed margin (ENUM_ACCOUNT_STOPOUT_MODE).
  ACCOUNT_TRADE_ALLOWED, // Allowed trade for the current account (bool).
  ACCOUNT_TRADE_EXPERT, // Allowed trade for an Expert Advisor (bool).
  ACCOUNT_TRADE_MODE, // Account trade mode (ENUM_ACCOUNT_TRADE_MODE).
};
// https://www.mql5.com/en/docs/constants/environment_state/accountinformation
// Used in AccountInfoDouble().
enum ENUM_ACCOUNT_INFO_DOUBLE {
  ACCOUNT_ASSETS, // The current assets of an account (double).
  ACCOUNT_BALANCE, // Account balance in the deposit currency (double).
  ACCOUNT_COMMISSION_BLOCKED, // The current blocked commission amount on an account (double).
  ACCOUNT_CREDIT, //Account credit in the deposit currency (double).
  ACCOUNT_EQUITY, // Account equity in the deposit currency (double).
  ACCOUNT_LIABILITIES, // The current liabilities on an account (double).
  ACCOUNT_MARGIN, // Account margin used in the deposit currency (double).
  ACCOUNT_MARGIN_FREE, // Free margin of an account in the deposit currency (double).
  ACCOUNT_MARGIN_INITIAL, // Initial margin. The amount reserved on an account to cover the margin of all pending orders (double).
  ACCOUNT_MARGIN_LEVEL, // Account margin level in percents (double).
  ACCOUNT_MARGIN_MAINTENANCE, // Maintenance margin. The minimum equity reserved on an account to cover the minimum amount of all open positions (double).
  ACCOUNT_MARGIN_SO_CALL, // Margin call level. Depending on the set ACCOUNT_MARGIN_SO_MODE is expressed in percents or in the deposit currency (double).
  ACCOUNT_MARGIN_SO_SO, // Margin stop out level. Depending on the set ACCOUNT_MARGIN_SO_MODE is expressed in percents or in the deposit currency (double).
  ACCOUNT_PROFIT, // Current profit of an account in the deposit currency (double).
};
// https://www.mql5.com/en/docs/constants/environment_state/accountinformation
// Used in AccountInfoString().
enum ENUM_ACCOUNT_INFO_STRING {
  ACCOUNT_COMPANY, // Name of a company that serves the account (string).
  ACCOUNT_CURRENCY, // Account currency (string).
  ACCOUNT_NAME, // Client name (string).
  ACCOUNT_SERVER // Trade server name (string).
};
// https://www.mql5.com/en/docs/constants/environment_state/accountinformation
enum ENUM_ACCOUNT_TRADE_MODE {
  ACCOUNT_TRADE_MODE_DEMO, // Demo account.
  ACCOUNT_TRADE_MODE_CONTEST, // Contest account.
  ACCOUNT_TRADE_MODE_REAL, // Real account.
};
// https://www.mql5.com/en/docs/constants/environment_state/accountinformation
enum ENUM_ACCOUNT_STOPOUT_MODE {
  ACCOUNT_STOPOUT_MODE_PERCENT, // Account stop out mode in percents.
  ACCOUNT_STOPOUT_MODE_MONEY, // Account stop out mode in money.
};
// https://www.mql5.com/en/docs/constants/environment_state/accountinformation
enum ENUM_ACCOUNT_MARGIN_MODE {
  ACCOUNT_MARGIN_MODE_RETAIL_NETTING, // Used for the OTC markets to interpret positions in the "netting" mode.
  ACCOUNT_MARGIN_MODE_EXCHANGE, // Margin is calculated based on the discounts specified in symbol settings.
  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING, // Used for the exchange markets where individual positions are possible (hedging, multiple positions can exist for one symbol).
};
#endif

// Class structs.
// Struct for making a snapshot of user account values.
struct AccountSnapshot {
  datetime dtime;
  double balance;
  double credit;
  double equity;
  double profit;
  double margin_used;
  double margin_free;
  double margin_avail;
};

/**
 * Class to provide functions that return parameters of the current account.
 */
class Account {

  protected:

  // Struct variables.
  AccountSnapshot snapshots[];

  // Variables.
  double init_balance, start_balance, start_credit;
  // Store daily, weekly and monthly account statistics.
  double acc_stats[FINAL_ENUM_ACC_STAT_VALUE][FINAL_ENUM_ACC_STAT_PERIOD][FINAL_ENUM_ACC_STAT_TYPE][FINAL_ENUM_ACC_STAT_INDEX];

  // Class variables.
  Orders *trades;
  Orders *history;
  Orders *dummy;

  public:

  // Defines.
  #define ACC_OP_BALANCE 6 // Undocumented balance history statement entry.
  #define ACC_OP_CREDIT  7 // Undocumented credit history statement entry.

  /**
   * Class constructor.
   */
  Account() :
    init_balance(CalcInitDeposit()),
    start_balance(GetBalance()),
    start_credit(GetCredit()),
    trades(new Orders(ORDERS_POOL_TRADES)),
    history(new Orders(ORDERS_POOL_HISTORY)),
    dummy(new Orders(ORDERS_POOL_DUMMY))
  {}

  /**
   * Class deconstructor.
   */
  ~Account() {
    delete trades;
    delete history;
    delete dummy;
  }

  /* MT account methods */

  /**
   * Returns the current account name.
   */
  static string AccountName() {
    return AccountInfoString(ACCOUNT_NAME);
  }
  string GetAccountName() {
    return AccountName();
  }

  /**
   * Returns the connected server name.
   */
  static string AccountServer() {
    return AccountInfoString(ACCOUNT_SERVER);
  }
  string GetServerName() {
    return AccountServer();
  }

  /**
   * Returns currency name of the current account.
   */
  static string AccountCurrency() {
    return AccountInfoString(ACCOUNT_CURRENCY);
  }
  string GetCurrency() {
    return AccountCurrency();
  }

  /**
   * Returns the brokerage company name where the current account was registered.
   */
  static string AccountCompany() {
    return AccountInfoString(ACCOUNT_COMPANY);
  }
  string GetCompanyName() {
    return AccountCompany();
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
  long GetLogin() {
    return AccountNumber();
  }

  /**
   * Returns leverage of the current account.
   */
  static long AccountLeverage() {
    return AccountInfoInteger(ACCOUNT_LEVERAGE);
  }
  long GetLeverage() {
    return AccountLeverage();
  }

  /**
   * Returns the calculation mode for the Stop Out level.
   */
  static int AccountStopoutMode() {
    return (int) AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
  }
  int GetStopoutMode() {
    return AccountStopoutMode();
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
  double GetStopoutLevel() {
    return AccountStopoutLevel();
  }

  /**
   * Get a maximum allowed number of active pending orders set by broker.
   *
   * @return
   *   Returns the limit orders (0 for unlimited).
   */
  static long AccountLimitOrders() {
    return AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
  }
  long GetLimitOrders(uint _max = 999) {
    long _limit = AccountLimitOrders();
    return _limit > 0 ? _limit : _max;
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
  double GetMarginAvail() {
    return AccountAvailMargin();
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
  double GetAccountFreeMarginMode() {
    return AccountFreeMarginMode();
  }

  /* State checkers */

  /**
   * Indicates if an Expert Advisor is allowed to trade on the account.
   */
  static bool IsExpertEnabled() {
    return (bool) AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
  }

  /**
   * Check the permission to trade for the current account.
   */
  static bool IsTradeAllowed() {
    return (bool) AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
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

  /**
   * Returns type of account (Demo or Live).
   */
  string GetType() {
    return GetServerName() != "" ? (IsDemo() ? "Demo" : "Live") : "Off-line";
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
        case ACC_DAILY:   _stats_rotate = _last_check < Chart::iTime(_Symbol, PERIOD_D1); break;
        case ACC_WEEKLY:  _stats_rotate = _last_check < Chart::iTime(_Symbol, PERIOD_W1); break;
        case ACC_MONTHLY: _stats_rotate = _last_check < Chart::iTime(_Symbol, PERIOD_MN1); break;
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
  double GetInitBalance() {
    return init_balance;
  }

  /**
   * Get account start balance.
   */
  double GetStartBalance() {
    return start_balance;
  }

  /**
   * Get account init credit.
   */
  double GetStartCredit() {
    return start_credit;
  }

  /* Calculation methods */

  /**
   * Get account stopout level in range: 0.0 - 1.0 where 1.0 is 100%.
   *
   * Note:
   *  - if(AccountEquity()/AccountMargin()*100 < AccountStopoutLevel()) { BrokerClosesOrders(); }
   */
  static double GetAccountStopoutLevel() {
    int mode = AccountStopoutMode();
    double level = AccountStopoutLevel();
    if (mode == 0 && level > 0) {
       // Calculation of percentage ratio between margin and equity.
       return (double) level / 100;
    } else if (mode == 1) {
      // Comparison of the free margin level to the absolute value.
      return 1.0;
    } else {
      // @todo: Add logging.
      //if (verbose) PrintFormat("%s(): Not supported mode (%d).", __FUNCTION__, mode);
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
  static double AccountFreeMarginCheck(string _symbol, ENUM_ORDER_TYPE _cmd, double _volume) {
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
    double _margin;
    return (::OrderCalcMargin(_cmd, _symbol, _volume,
      SymbolInfo::SymbolInfoDouble(_symbol, (_cmd == ORDER_TYPE_BUY) ? SYMBOL_ASK : SYMBOL_BID), _margin) ?
      AccountInfoDouble(ACCOUNT_MARGIN_FREE) - _margin : -1);
    #endif
  }
  double GetAccountFreeMarginCheck(ENUM_ORDER_TYPE _cmd, double _volume) {
    return AccountFreeMarginCheck(_Symbol, _cmd, _volume);
  }

  /**
   * Get current account drawdown in percent.
   */
  static double GetDrawdownInPct() {
    return (100 / AccountRealBalance()) * (AccountRealBalance() - AccountEquity());
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
    double _avail_margin = AccountAvailMargin() * Convert::ValueToMoney(trades.TotalSL(_cmd));
    return _avail_margin > 0 ? 1 / _avail_margin : 0;
  }

  /**
   * Calculates initial deposit based on the current balance and previous orders.
   */
  static double CalcInitDeposit() {
    double deposit = AccountInfoDouble(ACCOUNT_BALANCE);
    for (int i = Account::OrdersHistoryTotal() - 1; i >= 0; i--) {
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
   * Returns the number of closed orders in the account history loaded into the terminal.
   */
  static int OrdersHistoryTotal() {
    #ifdef __MQL4__
      return ::OrdersHistoryTotal();
    #else
       ::HistorySelect(0, TimeCurrent());
       return ::HistoryOrdersTotal();
    #endif
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
    // @fixme
    return acc_stats[_value_type][_period][_stat_type][_shift];
  }

  /* State checkers */

  /**
   * Check account free margin.
   *
   * @return
   *   Returns true, when free margin is sufficient, false when insufficient or on error.
   */
  bool IsFreeMargin(ENUM_ORDER_TYPE _cmd, double size_of_lot, string _symbol = NULL) {
    bool _res = true;
    double margin = AccountFreeMarginCheck(_symbol, _cmd, size_of_lot);
    if (GetLastError() == 134 /* NOT_ENOUGH_MONEY */) _res = false;
    return (_res);
  }

  /* Printers */

  /**
   * Returns text info about the account.
   */
  string ToString() {
    return StringFormat(
      "Type: %s, Server/Company/Name: %s/%s/%s, Currency: %s, Balance: %g, Credit: %g, Equity: %g, Profit: %g, Margin Used/Free/Avail: %g/%g/%g, Orders limit: %g: Leverage: 1:%d, StopOut Level: %d (Mode: %d)",
      GetType(), GetServerName(),GetCompanyName(), GetAccountName(),  GetCurrency(), GetBalance(), GetCredit(), GetEquity(),
      GetProfit(), GetMarginUsed(), GetMarginFree(), GetMarginAvail(), GetLimitOrders(), GetLeverage(), GetStopoutLevel(), GetStopoutMode()
      );
  }

  /**
   * Returns info about the account in CSV format.
   */
  string ToCSV() {
    return StringFormat(
      "%g,%g,%g,%g,%g,%g",
      GetRealBalance(), GetEquity(), GetProfit(), GetMarginUsed(), GetMarginFree(), GetMarginAvail()
      );
  }

  /* Snapshots */

  /**
   * Create a market snapshot.
   */
  bool MakeSnapshot() {
    uint _size = Array::ArraySize(snapshots);
    if (ArrayResize(snapshots, _size + 1, 100)) {
      snapshots[_size].dtime = TimeCurrent();
      snapshots[_size].balance = GetBalance();
      snapshots[_size].credit = GetCredit();
      snapshots[_size].equity = GetEquity();
      snapshots[_size].profit = GetProfit();
      snapshots[_size].margin_used = GetMarginUsed();
      snapshots[_size].margin_free = GetMarginFree();
      snapshots[_size].margin_avail = GetMarginAvail();
      return true;
    } else {
      return false;
    }
  }

  /* Class access methods */

  /**
   * Returns Orders class to access the current trades.
   */
  Orders *Trades() {
    return trades;
  }
  Orders *History() {
    return history;
  }
  Orders *Dummy() {
    return dummy;
  }

};
#endif // ACCOUNT_MQH
