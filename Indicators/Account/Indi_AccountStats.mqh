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
#include "../../Account/AccountBase.h"
#include "../../BufferStruct.mqh"
#include "../../Indicator.mqh"
#include "../../Platform.h"
#include "../../Storage/Objects.h"

// Structs.
struct Indi_AccountStats_Params : IndicatorParams {
  // Applied price.
  ENUM_APPLIED_PRICE ap;

  // Account to use.
  Ref<AccountBase> account;

  // Struct constructor.
  Indi_AccountStats_Params(AccountBase *_account = nullptr, int _shift = 0)
      : IndicatorParams(INDI_ACCOUNT_STATS), account(_account) {
    SetShift(_shift);
  };
  Indi_AccountStats_Params(Indi_AccountStats_Params &_params) { THIS_REF = _params; };

  // Getters.
  AccountBase *GetAccount() { return account.Ptr(); }
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return ap; }

  // Setters.
  void SetAccount(AccountBase *_account) { account = _account; }
  void SetAppliedPrice(ENUM_APPLIED_PRICE _ap) { ap = _ap; }
};

/**
 * Price Indicator.
 */
class Indi_AccountStats : public Indicator<Indi_AccountStats_Params> {
  Ref<ValueStorage<datetime>> buffer_date_time;
  Ref<ValueStorage<double>> buffer_balance;
  Ref<ValueStorage<double>> buffer_credit;
  Ref<ValueStorage<double>> buffer_equity;
  Ref<ValueStorage<double>> buffer_profit;
  Ref<ValueStorage<double>> buffer_margin_used;
  Ref<ValueStorage<double>> buffer_margin_free;
  Ref<ValueStorage<double>> buffer_margin_avail;

 public:
  /**
   * Class constructor.
   */
  Indi_AccountStats(Indi_AccountStats_Params &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                    IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(INDI_VS_TYPE_ACCOUNT_STATS_BUFFERS_COUNT, TYPE_DOUBLE, _idstype,
                                                   IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {
    InitAccountStats();
  };
  Indi_AccountStats(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                    int _indi_src_mode = 0)
      : Indicator(Indi_AccountStats_Params(),
                  IndicatorDataParams::GetInstance(INDI_VS_TYPE_ACCOUNT_STATS_BUFFERS_COUNT, TYPE_DOUBLE, _idstype,
                                                   IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {
    InitAccountStats();
  };
  void InitAccountStats() {
    buffer_date_time = new NativeValueStorage<datetime>();
    buffer_balance = new NativeValueStorage<double>();
    buffer_credit = new NativeValueStorage<double>();
    buffer_equity = new NativeValueStorage<double>();
    buffer_profit = new NativeValueStorage<double>();
    buffer_margin_used = new NativeValueStorage<double>();
    buffer_margin_free = new NativeValueStorage<double>();
    buffer_margin_avail = new NativeValueStorage<double>();
  }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  virtual unsigned int GetSuitableDataSourceTypes() {
    // We require that candle indicator is attached.
    return INDI_SUITABLE_DS_TYPE_CANDLE;
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN; }

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  virtual bool HasValidEntry(int _shift = 0) { return GetBarTime(_shift) != 0; }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();

    // Converting mode into value storage type.
    ENUM_INDI_VS_TYPE _vs_type = (ENUM_INDI_VS_TYPE)(INDI_VS_TYPE_ACCOUNT_STATS_INDEX_FIRST + _mode);

    // Retrieving data from specific value storage.
    switch (_vs_type) {
      case INDI_VS_TYPE_ACCOUNT_STATS_DATE_TIME:
        return ((ValueStorage<datetime> *)GetSpecificValueStorage(_vs_type))PTR_DEREF FetchSeries(_ishift);
      case INDI_VS_TYPE_ACCOUNT_STATS_BALANCE:
      case INDI_VS_TYPE_ACCOUNT_STATS_CREDIT:
      case INDI_VS_TYPE_ACCOUNT_STATS_EQUITY:
      case INDI_VS_TYPE_ACCOUNT_STATS_PROFIT:
      case INDI_VS_TYPE_ACCOUNT_STATS_MARGIN_USED:
      case INDI_VS_TYPE_ACCOUNT_STATS_MARGIN_FREE:
      case INDI_VS_TYPE_ACCOUNT_STATS_MARGIN_AVAIL:
        return ((ValueStorage<double> *)GetSpecificValueStorage(_vs_type))PTR_DEREF FetchSeries(_ishift);
      default:
        Alert("Error: Indi_AccountStats: Invalid mode passed to GetEntryValue()!");
        DebugBreak();
        return EMPTY_VALUE;
    }
  }

  /**
   * Returns value storage of given kind.
   */
  IValueStorage *GetSpecificValueStorage(ENUM_INDI_VS_TYPE _type) override {
    // Returning Price indicator which provides applied price in the only buffer #0.
    switch (_type) {
      case INDI_VS_TYPE_ACCOUNT_STATS_DATE_TIME:
        return buffer_date_time.Ptr();
      case INDI_VS_TYPE_ACCOUNT_STATS_BALANCE:
        return buffer_balance.Ptr();
      case INDI_VS_TYPE_ACCOUNT_STATS_CREDIT:
        return buffer_credit.Ptr();
      case INDI_VS_TYPE_ACCOUNT_STATS_EQUITY:
        return buffer_equity.Ptr();
      case INDI_VS_TYPE_ACCOUNT_STATS_PROFIT:
        return buffer_profit.Ptr();
      case INDI_VS_TYPE_ACCOUNT_STATS_MARGIN_USED:
        return buffer_margin_used.Ptr();
      case INDI_VS_TYPE_ACCOUNT_STATS_MARGIN_FREE:
        return buffer_margin_free.Ptr();
      case INDI_VS_TYPE_ACCOUNT_STATS_MARGIN_AVAIL:
        return buffer_margin_avail.Ptr();
      default:
        // Trying in parent class.
        return Indicator<Indi_AccountStats_Params>::GetSpecificValueStorage(_type);
    }
  }

  /**
   * Checks whether indicator support given value storage type.
   */
  bool HasSpecificValueStorage(ENUM_INDI_VS_TYPE _type) override {
    switch (_type) {
      case INDI_VS_TYPE_ACCOUNT_STATS_DATE_TIME:
      case INDI_VS_TYPE_ACCOUNT_STATS_BALANCE:
      case INDI_VS_TYPE_ACCOUNT_STATS_CREDIT:
      case INDI_VS_TYPE_ACCOUNT_STATS_EQUITY:
      case INDI_VS_TYPE_ACCOUNT_STATS_PROFIT:
      case INDI_VS_TYPE_ACCOUNT_STATS_MARGIN_USED:
      case INDI_VS_TYPE_ACCOUNT_STATS_MARGIN_FREE:
      case INDI_VS_TYPE_ACCOUNT_STATS_MARGIN_AVAIL:
        return true;
      default:
        // Trying in parent class.
        return Indicator<Indi_AccountStats_Params>::HasSpecificValueStorage(_type);
    }
  }

  /**
   * Called when data source emits new entry (historic or future one).
   */
  virtual void OnDataSourceEntry(IndicatorDataEntry &entry,
                                 ENUM_INDI_EMITTED_ENTRY_TYPE type = INDI_EMITTED_ENTRY_TYPE_PARENT) {
    Indicator<Indi_AccountStats_Params>::OnDataSourceEntry(entry, type);

    if (type != INDI_EMITTED_ENTRY_TYPE_CANDLE) {
      return;
    }

    // Adding new account stats entry.

    Print("New candle: ", entry.ToString<double>());
  }
};
