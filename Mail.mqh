//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Includes.
#include "Account.mqh"
#include "Convert.mqh"
#include "Order.mqh"

// Prevents processing this includes file for the second time.
#ifndef MAIL_MQH
#define MAIL_MQH

/**
 * Implements Mail class.
 */
class Mail {
 private:
  string string_dlm;  // String delimiter;
  string string_nl;   // String new line separator.
  string subject_execute_order;
  string subject_prefix;

 public:
  /**
   * Constructor.
   */
  Mail(string _subject_prefix = "Trading Info: ") {
    this.string_dlm = " ";
    this.string_nl = "<br>\n";
    this.subject_execute_order = __FILE__;
    this.subject_prefix = _subject_prefix;
  }

  /* Getters */

  /**
   * Gets subject prefix.
   */
  string GetMailSubjectPrefix() { return this.subject_prefix; }

  /**
   * Gets subject on execute order.
   */
  string GetMailSubjectExecuteOrder() { return this.subject_execute_order; }

  /**
   * Get content of e-mail for executing order.
   *
   * Note: Order needs to be selected before calling this function.
   */
  string GetMailBodyExecuteOrder() {
    string _body = "Trade Information" + string_nl;
    _body += string_nl + StringFormat("Event: %s", "Trade Opened");
    _body += string_nl + StringFormat("Currency Pair: %s", _Symbol);
    _body += string_nl + StringFormat("Time: %s", DateTimeStatic::TimeToStr(TIME_DATE | TIME_MINUTES | TIME_SECONDS));
    _body += string_nl + StringFormat("Order Type: %s", Order::OrderTypeToString((ENUM_ORDER_TYPE)Order::OrderType()));
    _body += string_nl + StringFormat("Price: %s", DoubleToStr(Order::OrderOpenPrice(), Digits));
    _body += string_nl + StringFormat("Lot size: %g", Order::OrderLots());
    _body += string_nl + StringFormat("Comment: %s", Order::OrderComment());
    _body += string_nl + StringFormat("Account Balance: %s", Convert::ValueWithCurrency(Account::AccountBalance()));
    _body += string_nl + StringFormat("Account Equity: %s", Convert::ValueWithCurrency(Account::AccountEquity()));
    if (Account::AccountCredit() > 0) {
      _body += string_nl + StringFormat("Account Credit: %s", Convert::ValueWithCurrency(Account::AccountCredit()));
    }
    return _body;
  }

  /**
   * Gets string delimiter.
   */
  string GetStringDlm() { return this.string_dlm; }

  /**
   * Gets string new line separator.
   */
  string GetStringNl() { return this.string_nl; }

  /**
   * Get subject of e-mail for executing order.
   *
   * Note: Order needs to be selected before calling this function.
   */
  string GetSubjectExecuteOrder() { return GetMailSubjectPrefix() + this.string_dlm + GetMailSubjectExecuteOrder(); }

  /* Setters */

  /**
   * Sets subject prefix.
   */
  void SetSubjectPrefix(string _subject_prefix) { this.subject_prefix = _subject_prefix; }

  /**
   * Sets subject on execute order.
   */
  void SetSubjectExecuteOrder(string _subject_execute_order) { this.subject_execute_order = _subject_execute_order; }

  /**
   * Sets string delimiter.
   */
  void SetStringDlm(string _dlm) { this.string_dlm = _dlm; }

  /**
   * Sets string new line separator.
   */
  void SetStringNl(string _nl) { this.string_nl = _nl; }

  /* Mailing methods */

  /**
   * Send e-mail about the order.
   *
   * Note: Order needs to be selected before calling this function.
   */
  bool SendMailExecuteOrder() { return SendMail(GetMailSubjectExecuteOrder(), GetMailBodyExecuteOrder()); }
};
#endif
