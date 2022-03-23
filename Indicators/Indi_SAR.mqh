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
#include "../Indicator.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iSAR(string _symbol, int _tf, double _step, double _max, int _shift) {
  ResetLastError();
  return Indi_SAR::iSAR(_symbol, (ENUM_TIMEFRAMES)_tf, _step, _max, _shift);
}
#endif

// Structs.
struct IndiSARParams : IndicatorParams {
  double step;
  double max;
  // Struct constructors.
  IndiSARParams(double _step = 0.02, double _max = 0.2, int _shift = 0)
      : step(_step), max(_max), IndicatorParams(INDI_SAR, 1, TYPE_DOUBLE) {
    shift = _shift;
    SetDataValueRange(IDATA_RANGE_PRICE);  // @fixit It draws single dot for each bar!
    SetCustomIndicatorName("Examples\\ParabolicSAR");
  };
  IndiSARParams(IndiSARParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Parabolic Stop and Reverse system indicator.
 */
class Indi_SAR : public Indicator<IndiSARParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_SAR(IndiSARParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiSARParams>(_p, _indi_src) {}
  Indi_SAR(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_SAR, _tf, _shift) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/isar
   * - https://www.mql5.com/en/docs/indicators/isar
   */
  static double iSAR(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, double _step = 0.02,
                     double _max = 0.2, int _shift = 0, IndicatorBase *_obj = NULL) {
#ifdef __MQL4__
    return ::iSAR(_symbol, _tf, _step, _max, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iSAR(_symbol, _tf, _step, _max)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    if (Terminal::IsVisualMode()) {
      // To avoid error 4806 (ERR_INDICATOR_DATA_NOT_FOUND),
      // we check the number of calculated data only in visual mode.
      int _bars_calc = BarsCalculated(_handle);
      if (GetLastError() > 0) {
        return EMPTY_VALUE;
      } else if (_bars_calc <= 2) {
        SetUserError(ERR_USER_INVALID_BUFF_NUM);
        return EMPTY_VALUE;
      }
    }
    if (CopyBuffer(_handle, 0, _shift, 1, _res) < 0) {
      return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_SAR::iSAR(GetSymbol(), GetTf(), GetStep(), GetMax(), _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetStep(),
                         GetMax() /*]*/, _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get step of price increment.
   */
  double GetStep() { return iparams.step; }

  /**
   * Get the maximum step.
   */
  double GetMax() { return iparams.max; }

  /* Setters */

  /**
   * Set step of price increment (usually 0.02).
   */
  void SetStep(double _step) {
    istate.is_changed = true;
    iparams.step = _step;
  }

  /**
   * Set the maximum step (usually 0.2).
   */
  void SetMax(double _max) {
    istate.is_changed = true;
    iparams.max = _max;
  }
};
