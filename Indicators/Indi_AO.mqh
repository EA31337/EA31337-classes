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
double iAO(string _symbol, int _tf, int _shift) {
  ResetLastError();
  return Indi_AO::iAO(_symbol, (ENUM_TIMEFRAMES)_tf, _shift);
}
#endif

// Structs.
struct IndiAOParams : IndicatorParams {
  // Struct constructor.
  IndiAOParams(int _shift = 0) : IndicatorParams(INDI_AO) {
    SetCustomIndicatorName("Examples\\Awesome_Oscillator");
    shift = _shift;
  };
  IndiAOParams(IndiAOParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Awesome oscillator.
 */
class Indi_AO : public Indicator<IndiAOParams> {
 protected:
  /* Protected methods */

  /**
   * Initialize.
   */
  void Init() {
#ifdef __MQL4__
    Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), 1);
#else
    Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), 2);
#endif
  }

 public:
  /**
   * Class constructor.
   */
  Indi_AO(IndiAOParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
          int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {
    Init();
  };
  Indi_AO(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
          int _indi_src_mode = 0)
      : Indicator(IndiAOParams(),
                  IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {
    Init();
  };
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

 public:
  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM; }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/iao
   * - https://www.mql5.com/en/docs/indicators/iao
   */
  static double iAO(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0, int _mode = 0,
                    IndicatorData *_obj = NULL) {
#ifdef __MQL4__
    // Note: In MQL4 _mode is not supported.
    return ::iAO(_symbol, _tf, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iAO(_symbol, _tf), _mode, _shift);
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift + iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_AO::iAO(GetSymbol(), GetTf(), _ishift, _mode, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Returns reusable indicator with the same candle indicator as given indicator's one.
   */
  static Indi_AO *GetCached(IndicatorData *_indi) {
    Indi_AO *_ptr;
    // There will be only one Indi_AO per IndicatorCandle instance.
    string _key = Util::MakeKey(_indi PTR_DEREF GetCandle() PTR_DEREF GetId());
    if (!Objects<Indi_AO>::TryGet(_key, _ptr)) {
      _ptr = Objects<Indi_AO>::Set(_key, new Indi_AO());
      // Assigning the same candle indicator for AO as in _indi.
      _ptr.SetDataSource(_indi PTR_DEREF GetCandle());
    }
    return _ptr;
  }
  /**
   * Checks if indicator entry values are valid.
   */
  bool IsValidEntry(IndicatorDataEntry &_entry) override { return _entry.values[0].Get<double>() != EMPTY_VALUE; }
};
