//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Exchange/SymbolInfo/SymbolInfo.h"
#include "../Serializer/Serializer.h"
#include "../Storage/Dict/DictObject.h"
#include "../Storage/State.struct.h"
#include "../Task/TaskManager.h"
#include "../Task/Taskable.h"
#include "../Trade.mqh"
#include "Account/AccountForex.h"
#include "Exchange.enum.h"
#include "Exchange.struct.h"

class Exchange : public Taskable<DataParamEntry> {
 protected:
  DictStruct<int, Ref<AccountBase>> accounts;
  DictStruct<string, Ref<SymbolInfo>> symbols;
  DictStruct<string, Ref<Trade>> trades;
  ExchangeParams eparams;
  State estate;

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
  void AccountAdd(AccountBase *_account, int _id = 0) {
    Ref<AccountBase> _ref = _account;
    accounts.Set(_id, _ref);
  }

  /**
   * Adds account instance to the list.
   */
  void AccountAdd(AccountParams &_aparams) {
    AccountBase *_account = new AccountForex(/*_aparams*/);
    AccountAdd(_account);
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

  /* Getters */

  /**
   * Gets DictStruct reference to accounts.
   */
  DictStruct<int, Ref<AccountBase>> *GetAccounts() { return GetPointer(accounts); }

  /**
   * Gets DictStruct reference to symbols.
   */
  DictStruct<string, Ref<SymbolInfo>> *GetSymbols() { return GetPointer(symbols); }

  /* Removers */

  /**
   * Removes account instance from the list.
   */
  void AccountRemove(int _id) { accounts.Unset(_id); }

  /**
   * Removes symbol instance from the list.
   */
  void SymbolRemove(string _name) { symbols.Unset(_name); }

  /**
   * Removes trade instance from the list.
   */
  void TradeRemove(string _name) { trades.Unset(_name); }

  /* Taskable methods */

  /**
   * Checks a condition.
   */
  bool Check(const TaskConditionEntry &_entry) {
    bool _result = true;
    switch (_entry.GetId()) {
      default:
        _result = false;
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _result;
  }

  /**
   * Gets a data param entry.
   */
  DataParamEntry Get(const TaskGetterEntry &_entry) {
    DataParamEntry _result;
    switch (_entry.GetId()) {
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _result;
  }

  /**
   * Runs an action.
   */
  bool Run(const TaskActionEntry &_entry) {
    bool _result = true;
    switch (_entry.GetId()) {
      case EXCHANGE_ACTION_ADD_ACCOUNT:
        if (!_entry.HasArgs()) {
          AccountAdd(new AccountForex());
        } else {
          AccountParams _aparams(_entry.GetArg(0).ToString());
          Ref<AccountBase> _account1_ref = new AccountForex(_aparams);
          accounts.Set(_aparams.Get<int>(ACCOUNT_PARAM_LOGIN), _account1_ref);
        }
        break;
      default:
        _result = false;
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _result;
  }

  /**
   * Sets an entry value.
   */
  bool Set(const TaskSetterEntry &_entry, const DataParamEntry &_entry_value) {
    bool _result = true;
    switch (_entry.GetId()) {
      default:
        _result = false;
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _result;
  }

  /* Serializers */

  /**
   * Returns serialized representation of the object instance.
   */
  SerializerNodeType Serialize(Serializer &_s) {
    _s.PassStruct(THIS_REF, "eparams", eparams);
    _s.PassStruct(THIS_REF, "accounts", accounts);
    //_s.PassStruct(THIS_REF, "symbols", symbols);
    //_s.PassStruct(THIS_REF, "trades", trades);
    return SerializerNodeObject;
  }

  /**
   * Returns textual representation of the object instance.
   */
  string ToString() { return SerializerConverter::FromObject(THIS_REF).ToString<SerializerJson>(); }
};
