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
double iATR(string _symbol, int _tf, int _period, int _shift) {
  ResetLastError();
  return Indi_ATR::iATR(_symbol, (ENUM_TIMEFRAMES)_tf, _period, _shift);
}
#endif

// Structs.
struct IndiATRParams : IndicatorParams {
  unsigned int period;
  // Struct constructors.
  IndiATRParams(unsigned int _period = 14, int _shift = 0) : period(_period), IndicatorParams(INDI_ATR) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\ATR");
  };
  IndiATRParams(IndiATRParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Average True Range indicator.
 *
 * Note: It doesn't give independent signals. It is used to define volatility (trend strength).
 */
class Indi_ATR : public Indicator<IndiATRParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ATR(IndiATRParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {}
  Indi_ATR(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(IndiATRParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
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
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/iatr
   * - https://www.mql5.com/en/docs/indicators/iatr
   */
  static double iATR(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, int _shift = 0,
                     IndicatorData *_obj = NULL) {
#ifdef __MQL4__
    return ::iATR(_symbol, _tf, _period, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iATR(_symbol, _tf, _period), 0, _shift);
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
        _value = Indi_ATR::iATR(GetSymbol(), GetTf(), GetPeriod(), _ishift, THIS_PTR);
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
  static Indi_ATR *GetCached(IndicatorData *_indi, int _period) {
    Indi_ATR *_ptr;
    // There will be only one Indi_ATR per IndicatorCandle instance.
    string _key = Util::MakeKey(_indi PTR_DEREF GetCandle() PTR_DEREF GetId());
    if (!Objects<Indi_ATR>::TryGet(_key, _ptr)) {
      IndiATRParams _params(_period);
      _ptr = Objects<Indi_ATR>::Set(_key, new Indi_ATR(_params));
      // Assigning the same candle indicator for ATR as in _indi.
      _ptr.SetDataSource(_indi PTR_DEREF GetCandle());
    }
    return _ptr;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }
};
