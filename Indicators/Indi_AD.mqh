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
#include "../Indicator/Indicator.h"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iAD(string _symbol, int _tf, int _shift) {
  ResetLastError();
  return Indi_AD::iAD(_symbol, (ENUM_TIMEFRAMES)_tf, _shift);
}
#endif

// Structs.
struct IndiADParams : IndicatorParams {
  // Struct constructor.
  IndiADParams(int _shift = 0) : IndicatorParams(INDI_AD) {
    SetCustomIndicatorName("Examples\\AD");
    shift = _shift;
  };
  IndiADParams(IndiADParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Accumulation/Distribution indicator.
 */
class Indi_AD : public Indicator<IndiADParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_AD(IndiADParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
          int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_INDI_ADX_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED,
                                                   _indi_src_mode),
                  _indi_src){};

  Indi_AD(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
          int _indi_src_mode = 0)
      : Indicator(IndiADParams(),
                  IndicatorDataParams::GetInstance(FINAL_INDI_ADX_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED,
                                                   _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM; }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) { return true; }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/iad
   * - https://www.mql5.com/en/docs/indicators/iad
   */
  static double iAD(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                    IndicatorData *_obj = NULL) {
#ifdef __MQL4__
    Print("We'll now retrieve value from ::iAD(", _symbol, ", ", EnumToString(_tf), ", ", _shift, ")...");
    double _value = ::iAD(_symbol, _tf, _shift);
    Print("value = \"", _value, "\", LastError: ", _LastError);
    return _value;
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iAD(_symbol, _tf, VOLUME_TICK), 0, _shift);
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_AD::iAD(GetSymbol(), GetTf(), _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }
};
