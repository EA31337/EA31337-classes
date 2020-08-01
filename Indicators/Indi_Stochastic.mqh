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
double iStochastic(string _symbol, int _tf, int _kperiod, int _dperiod, int _slowing, int _ma_method, int _pf,
                   int _mode, int _shift) {
  return Indi_Stochastic::iStochastic(_symbol, (ENUM_TIMEFRAMES)_tf, _kperiod, _dperiod, _slowing,
                                      (ENUM_MA_METHOD)_ma_method, (ENUM_STO_PRICE)_pf, _mode, _shift);
}
#endif

// Structs.
struct StochParams : IndicatorParams {
  int kperiod;
  int dperiod;
  int slowing;
  ENUM_MA_METHOD ma_method;
  ENUM_STO_PRICE price_field;
  // Struct constructor.
  void StochParams(int _kperiod, int _dperiod, int _slowing, ENUM_MA_METHOD _ma_method, ENUM_STO_PRICE _pf)
      : kperiod(_kperiod), dperiod(_dperiod), slowing(_slowing), ma_method(_ma_method), price_field(_pf) {
    itype = INDI_STOCHASTIC;
    max_modes = FINAL_SIGNAL_LINE_ENTRY;
    SetDataValueType(TYPE_DOUBLE);
  };
};

/**
 * Implements the Stochastic Oscillator.
 */
class Indi_Stochastic : public Indicator {
 protected:
  StochParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Stochastic(StochParams &_p)
      : params(_p.kperiod, _p.dperiod, _p.slowing, _p.ma_method, _p.price_field), Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_Stochastic(StochParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.kperiod, _p.dperiod, _p.slowing, _p.ma_method, _p.price_field), Indicator(INDI_STOCHASTIC, _tf) {
    params = _p;
  }

  /**
   * Calculates the Stochastic Oscillator and returns its value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/istochastic
   * - https://www.mql5.com/en/docs/indicators/istochastic
   */
  static double iStochastic(
      string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _kperiod, unsigned int _dperiod, unsigned int _slowing,
      ENUM_MA_METHOD _ma_method,    // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
      ENUM_STO_PRICE _price_field,  // (MT4 _price_field):      0      - Low/High,       1        - Close/Close
                                    // (MT5 _price_field): STO_LOWHIGH - Low/High, STO_CLOSECLOSE - Close/Close
      int _mode,                    // (MT4): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_SIGNAL/SIGNAL_LINE
      int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iStochastic(_symbol, _tf, _kperiod, _dperiod, _slowing, _ma_method, _price_field, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iStochastic(_symbol, _tf, _kperiod, _dperiod, _slowing, _ma_method, _price_field)) ==
          INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_SIGNAL_LINE _mode = LINE_MAIN, int _shift = 0) {
    ResetLastError();
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
    double _value = Indi_Stochastic::iStochastic(GetSymbol(), GetTf(), GetKPeriod(), GetDPeriod(), GetSlowing(),
                                                 GetMAMethod(), GetPriceField(), _mode, _shift, GetPointer(this));
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
      _entry.value.SetValue(params.idvtype, GetValue(LINE_MAIN, _shift), LINE_MAIN);
      _entry.value.SetValue(params.idvtype, GetValue(LINE_SIGNAL, _shift), LINE_SIGNAL);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.value.HasValue(params.idvtype, (double)NULL) &&
                                                   !_entry.value.HasValue(params.idvtype, EMPTY_VALUE) &&
                                                   _entry.value.GetMinDbl(params.idvtype) >= 0);
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
   * Get period of the %K line.
   */
  int GetKPeriod() { return params.kperiod; }

  /**
   * Get period of the %D line.
   */
  int GetDPeriod() { return params.dperiod; }

  /**
   * Get slowing value.
   */
  int GetSlowing() { return params.slowing; }

  /**
   * Set MA method.
   */
  ENUM_MA_METHOD GetMAMethod() { return params.ma_method; }

  /**
   * Get price field parameter.
   */
  ENUM_STO_PRICE GetPriceField() { return params.price_field; }

  /* Setters */

  /**
   * Set period of the %K line.
   */
  void SetKPeriod(int _kperiod) {
    istate.is_changed = true;
    params.kperiod = _kperiod;
  }

  /**
   * Set period of the %D line.
   */
  void SetDPeriod(int _dperiod) {
    istate.is_changed = true;
    params.dperiod = _dperiod;
  }

  /**
   * Set slowing value.
   */
  void SetSlowing(int _slowing) {
    istate.is_changed = true;
    params.slowing = _slowing;
  }

  /**
   * Set MA method.
   */
  void SetMAMethod(ENUM_MA_METHOD _ma_method) {
    istate.is_changed = true;
    params.ma_method = _ma_method;
  }

  /**
   * Set price field parameter.
   */
  void SetPriceField(ENUM_STO_PRICE _price_field) {
    istate.is_changed = true;
    params.price_field = _price_field;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idvtype); }
};
