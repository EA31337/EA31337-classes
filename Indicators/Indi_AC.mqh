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
#include "../BufferStruct.mqh"
#include "../Indicator.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iAC(string _symbol, int _tf, int _shift) {
  ResetLastError();
  return Indi_AC::iAC(_symbol, (ENUM_TIMEFRAMES)_tf, _shift);
}
#endif

// Structs.
struct IndiACParams : IndicatorParams {
  // Struct constructor.
  IndiACParams(int _shift = 0) : IndicatorParams(INDI_AC, 1, TYPE_DOUBLE) {
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\Accelerator");
    shift = _shift;
    switch (idstype) {
      case IDATA_ICUSTOM:
        SetMaxModes(2);
        break;
    }
  };
  IndiACParams(IndiACParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_AC : public Indicator<IndiACParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_AC(IndiACParams &_p, IndicatorBase *_indi_src = NULL) : Indicator(_p, _indi_src){};
  Indi_AC(int _shift = 0) : Indicator(INDI_AC, _shift){};

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM; }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/iac
   * - https://www.mql5.com/en/docs/indicators/iac
   */
  static double iAC(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                    IndicatorBase *_obj = NULL) {
#ifdef __MQL4__
    return ::iAC(_symbol, _tf, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iAC(_symbol, _tf), 0, _shift);
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) override {
    IndicatorDataEntryValue _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_AC::iAC(GetSymbol(), GetTf(), _ishift, THIS_PTR);
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
  static Indi_AC *GetCached(IndicatorBase *_indi) {
    Indi_AC *_ptr;
    // There will be only one Indi_AC per IndicatorCandle instance.
    string _key = Util::MakeKey(_indi PTR_DEREF GetCandle() PTR_DEREF GetId());
    if (!Objects<Indi_AC>::TryGet(_key, _ptr)) {
      _ptr = Objects<Indi_AC>::Set(_key, new Indi_AC());
      // Assigning the same candle indicator for AC as in _indi.
      _ptr.SetDataSource(_indi PTR_DEREF GetCandle());
    }
    return _ptr;
  }
};
