//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
  return Indi_SAR::iSAR(_symbol, (ENUM_TIMEFRAMES)_tf, _step, _max, _shift);
}
#endif

// Structs.
struct SARParams : IndicatorParams {
  double step;
  double max;
  // Struct constructors.
  void SARParams(double _step = 0.02, double _max = 0.2) : step(_step), max(_max) {
    itype = INDI_SAR;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
  };
  void SARParams(SARParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    _params.tf = _tf;
  };
};

/**
 * Implements the Parabolic Stop and Reverse system indicator.
 */
class Indi_SAR : public Indicator {
 protected:
  SARParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_SAR(SARParams &_p) : params(_p.step, _p.max), Indicator((IndicatorParams)_p) { params = _p; }
  Indi_SAR(SARParams &_p, ENUM_TIMEFRAMES _tf) : params(_p.step, _p.max), Indicator(INDI_SAR, _tf) { params = _p; }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/isar
   * - https://www.mql5.com/en/docs/indicators/isar
   */
  static double iSAR(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, double _step = 0.02,
                     double _max = 0.2, int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iSAR(_symbol, _tf, _step, _max, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iSAR(_symbol, _tf, _step, _max)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (GetLastError() > 0) {
      return EMPTY_VALUE;
    } else if (_bars_calc <= 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, 0, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
    double _value = Indi_SAR::iSAR(GetSymbol(), GetTf(), GetStep(), GetMax(), _shift, GetPointer(this));
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.value.SetValue(params.idvtype, GetValue(_shift));
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.value.HasValue(params.idvtype, (double)NULL) &&
                                                   !_entry.value.HasValue(params.idvtype, EMPTY_VALUE));

      if (_entry.IsValid()) idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.idvtype, _mode);
    return _param;
  }

  /* Getters */

  /**
   * Get step of price increment.
   */
  double GetStep() { return params.step; }

  /**
   * Get the maximum step.
   */
  double GetMax() { return params.max; }

  /* Setters */

  /**
   * Set step of price increment (usually 0.02).
   */
  void SetStep(double _step) {
    istate.is_changed = true;
    params.step = _step;
  }

  /**
   * Set the maximum step (usually 0.2).
   */
  void SetMax(double _max) {
    istate.is_changed = true;
    params.max = _max;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idvtype); }
};
