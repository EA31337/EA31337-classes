//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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

/**
 * Exchange class.
 */
#ifndef EXCHANGE_H
#define EXCHANGE_H

// Includes.
#include "Account/Account.h"
#include "../Storage/Dict/DictObject.h"
#include "../SymbolInfo.mqh"
#include "../Trade.mqh"
#include "Exchange.struct.h"

class Exchange : public Dynamic {
 protected:
  DictStruct<string, Ref<AccountBase>> accounts;
  DictStruct<string, Ref<SymbolInfo>> symbols;
  DictStruct<string, Ref<Trade>> trades;
  ExchangeParams eparams;

 public:
  /**
   * Class constructor without parameters.
   */
  Exchange(){};

  /**
   * Class constructor with parameters.
   */
  Exchange(ExchangeParams &_eparams) : eparams(_eparams){};

  /**
   * Class deconstructor.
   */
  ~Exchange() {}

  /* Adders */

  /**
   * Adds account instance to the list.
   */
  void AccountAdd(AccountBase *_account, string _name) {
    Ref<AccountBase> _ref = _account;
    accounts.Set(_name, _ref);
  }

  /**
   * Adds symbol instance to the list.
   */
  void SymbolAdd(SymbolInfo *_sinfo, string _name) {
    Ref<SymbolInfo> _ref = _sinfo;
    symbols.Set(_name, _ref);
  }

  /**
   * Adds trade instance to the list.
   */
  void TradeAdd(Trade *_trade, string _name) {
    Ref<Trade> _ref = _trade;
    trades.Set(_name, _ref);
  }

  /* Removers */

  /**
   * Removes account instance from the list.
   */
  void AccountRemove(string _name) { accounts.Unset(_name); }

  /**
   * Removes symbol instance from the list.
   */
  void SymbolRemove(string _name) { symbols.Unset(_name); }

  /**
   * Removes trade instance from the list.
   */
  void TradeRemove(string _name) { trades.Unset(_name); }
};
#endif  // EXCHANGE_H
