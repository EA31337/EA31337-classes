//+------------------------------------------------------------------+
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

// Prevents processing the same indicator file twice.
#ifndef INDI_CUSTOM_MQH
#define INDI_CUSTOM_MQH

// Defines
#ifndef INDI_CUSTOM_PATH
#ifdef __MQL4__
#define INDI_CUSTOM_PATH "RSI"
#else
#define INDI_CUSTOM_PATH "Examples\\RSI"
#endif
#endif

// Includes.
#include "../../Indicator/Indicator.h"

// Structs.

// Defines struct to store indicator parameter values.
struct IndiCustomParams : public IndicatorParams {
  DataParamEntry iargs[];
  // Struct constructors.
  IndiCustomParams(string _filepath = INDI_CUSTOM_PATH, int _shift = 0) : IndicatorParams(INDI_CUSTOM) {
    custom_indi_name = _filepath;
  }
  IndiCustomParams(IndiCustomParams &_params) { THIS_REF = _params; }
  // Getters.
  DataParamEntry GetParam(int _index) const { return iargs[_index - 1]; }
  int GetParamsSize() const { return ArraySize(iargs); }
  // Setters.
  void AddParam(DataParamEntry &_entry) {
    int _size = GetParamsSize();
    ArrayResize(iargs, _size + 1);
    iargs[_size] = _entry;
  }
  void SetParam(DataParamEntry &_entry, int _index) {
    if (_index >= GetParamsSize()) {
      ArrayResize(iargs, _index + 1);
    }
    iargs[_index + 1] = _entry;
  }
  void SetParams(DataParamEntry &_entries[]) {
    for (int i = 0; i < ArraySize(_entries); i++) {
      iargs[i] = _entries[i];
    }
  }
};

/**
 * Implements indicator class.
 */
class Indi_Custom : public Indicator<IndiCustomParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Custom(IndiCustomParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_ICUSTOM, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_UNKNOWN, _indi_src_mode),
                  _indi_src) {}
  Indi_Custom(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_ICUSTOM, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0)
      : Indicator(IndiCustomParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src){};

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ICUSTOM; }

  /**
   * Returns the indicator's value.
   */
  IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_ICUSTOM:
        switch (iparams.GetParamsSize()) {
          case 0:
            _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.custom_indi_name, _mode, _ishift);
            break;
          case 1:
            _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.custom_indi_name,
                             iparams.GetParam(1).ToValue<double>(), _mode, _ishift);
            break;
          case 2:
            _value =
                iCustom(istate.handle, GetSymbol(), GetTf(), iparams.custom_indi_name,
                        iparams.GetParam(1).ToValue<double>(), iparams.GetParam(2).ToValue<double>(), _mode, _ishift);
            break;
        }
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        _value = EMPTY_VALUE;
        break;
    }
    return _value;
  }
};

#endif  // INDI_CUSTOM_MQH
