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
#include "Indi_MA.mqh"
#include "Indi_Price.mqh"
#include "Indi_PriceFeeder.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iEnvelopes(string _symbol, int _tf, int _period, int _ma_method, int _ma_shift, int _ap, double _deviation,
                  int _mode, int _shift) {
  return Indi_Envelopes::iEnvelopes(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_MA_METHOD)_ma_method, _ma_shift,
                                    (ENUM_APPLIED_PRICE)_ap, _deviation, _mode, _shift);
}
double iEnvelopesOnArray(double &_arr[], int _total, int _ma_period, int _ma_method, int _ma_shift, double _deviation,
                         int _mode, int _shift) {
  return Indi_Envelopes::iEnvelopesOnArray(_arr, _total, _ma_period, (ENUM_MA_METHOD)_ma_method, _ma_shift, _deviation,
                                           _mode, _shift);
}
#endif

// Structs.
struct EnvelopesParams : IndicatorParams {
  int ma_period;
  int ma_shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  double deviation;
  // Struct constructors.
  void EnvelopesParams(int _ma_period = 13, int _ma_shift = 0, ENUM_MA_METHOD _ma_method = MODE_SMA,
                       ENUM_APPLIED_PRICE _ap = PRICE_OPEN, double _deviation = 2, int _shift = 0)
      : ma_period(_ma_period), ma_shift(_ma_shift), ma_method(_ma_method), applied_price(_ap), deviation(_deviation) {
    itype = INDI_ENVELOPES;
#ifdef __MQL5__
    // There is no LINE_MAIN in MQL5 for Envelopes.
    max_modes = 2;
#else
    max_modes = 3;
#endif
    shift = _shift;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_PRICE);
    SetCustomIndicatorName("Examples\\Envelopes");
  };
  void EnvelopesParams(EnvelopesParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Envelopes indicator.
 */
class Indi_Envelopes : public Indicator {
 protected:
  // Structs.
  EnvelopesParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Envelopes(EnvelopesParams &_p)
      : params(_p.ma_period, _p.ma_shift, _p.ma_method, _p.applied_price, _p.deviation),
        Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_Envelopes(EnvelopesParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.ma_period, _p.ma_shift, _p.ma_method, _p.applied_price, _p.deviation),
        Indicator(INDI_ENVELOPES, _tf) {
    params = _p;
  }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ienvelopes
   * - https://www.mql5.com/en/docs/indicators/ienvelopes
   */
  static double iEnvelopes(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, ENUM_MA_METHOD _ma_method,
                           int _ma_shift, ENUM_APPLIED_PRICE _ap, double _deviation,
                           int _mode,  // (MT4 _mode): 0 - MODE_MAIN,  1 - MODE_UPPER, 2 - MODE_LOWER; (MT5 _mode): 0 -
                                       // UPPER_LINE, 1 - LOWER_LINE
                           int _shift = 0, Indicator *_obj = NULL) {
    ResetLastError();
#ifdef __MQL4__
    return ::iEnvelopes(_symbol, _tf, _ma_period, _ma_method, _ma_shift, _ap, _deviation, _mode, _shift);
#else  // __MQL5__
    switch (_mode) {
      case LINE_UPPER:
        _mode = 0;
        break;
      case LINE_LOWER:
        _mode = 1;
        break;
    }
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iEnvelopes(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _ap, _deviation)) ==
          INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  static double iEnvelopesOnIndicator(Indicator *_indi, string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period,
                                      ENUM_MA_METHOD _ma_method,  // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
                                      int _indi_mode,  // Source indicator's mode index. May be -1 to use first buffer
                                      int _ma_shift, double _deviation,
                                      int _mode,  // (MT4 _mode): 0 - MODE_MAIN,  1 - MODE_UPPER, 2 - MODE_LOWER; (MT5
                                                  // _mode): 0 - UPPER_LINE, 1 - LOWER_LINE
                                      int _shift = 0) {
    _indi.ValidateDataSourceMode(_indi_mode);

    double _indi_value_buffer[];
    double _result;
    int i;

    ArrayResize(_indi_value_buffer, _ma_period);

    for (i = _shift; i < (int)_shift + (int)_ma_period; i++) {
      _indi_value_buffer[i - _shift] = _indi[i].GetValue<double>(_indi_mode);
    }

    Indi_PriceFeeder indi_price_feeder(_indi_value_buffer);
    MAParams ma_params(_ma_period, _ma_shift, _ma_method);
    ma_params.SetDataSource(&indi_price_feeder, false, 0);
    Indi_MA indi_ma(ma_params);

    _result = Indi_MA::iMAOnIndicator(&indi_price_feeder, _symbol, _tf, _ma_period, _ma_shift, _ma_method, _shift);
    switch (_mode) {
      case LINE_UPPER:
        _result *= (1.0 + _deviation / 100);
        break;
      case LINE_LOWER:
        _result *= (1.0 - _deviation / 100);
        break;
#ifdef __MQL4__
      case LINE_MAIN:
        // The LINE_MAIN only exists in MQL4 for Envelopes.
        _result *= 1.0;
        break;
#endif
      default:
        _result = DBL_MIN;
    }

    return _result;
  }

  /*
  double iEnvelopesOnArray(double &array[], int total, int ma_period, ENUM_MA_METHOD ma_method, int ma_shift,
                           double deviation, int mode, int shift, int applied_price) {
    Indi_PriceFeeder indi_price_feeder(array);
    return Indi_Envelopes::iEnvelopesOnIndicator(&indi_price_feeder, NULL, NULL, ma_period, ma_method, ma_shift,
                                                 (ENUM_APPLIED_PRICE)applied_price, deviation, mode, shift);
  }
  */
  static double iEnvelopesOnArray(double &array[], int total, int ma_period, ENUM_MA_METHOD ma_method, int ma_shift,
                                  double deviation, int mode, int shift) {
#ifdef __MQL4__
    return iEnvelopesOnArray(array, total, ma_period, ma_method, ma_shift, deviation, mode, shift);
#else
    Indi_PriceFeeder indi_price_feeder(array);
    return Indi_Envelopes::iEnvelopesOnIndicator(&indi_price_feeder, NULL, NULL, ma_period, ma_method,
                                                 /* indi_mode */ 0, ma_shift, deviation, mode, shift);
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_Envelopes::iEnvelopes(Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                                            GetMAPeriod(), GetMAMethod(), GetMAShift(), GetAppliedPrice(),
                                            GetDeviation(), _mode, _shift, GetPointer(this));
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                         params.GetCustomIndicatorName(), /**/ GetMAPeriod(), GetMAMethod(), GetMAShift(),
                         GetAppliedPrice(), GetDeviation() /**/, _mode, _shift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_Envelopes::iEnvelopesOnIndicator(
            GetDataSource(), Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), GetMAPeriod(),
            GetMAMethod(), GetDataSourceMode(), GetMAShift(), GetDeviation(), _mode, _shift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
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
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.values[LINE_UPPER] = GetValue(LINE_UPPER, _shift);
      _entry.values[LINE_LOWER] = GetValue(LINE_LOWER, _shift);
#ifdef __MQL4__
      // The LINE_MAIN only exists in MQL4 for Envelopes.
      _entry.values[LINE_MAIN] = GetValue((ENUM_LO_UP_LINE)LINE_MAIN, _shift);
#endif
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID,
                     !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE) && _entry.IsGt<double>(0));
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(params.GetDataValueType()));
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
#ifdef __MQL4__
    // Adjusting index, as in MT4, the line identifiers starts from 1, not 0.
    _mode = _mode > 0 ? _mode - 1 : _mode;
#endif
    GetEntry(_shift).values[_mode].Get(_param.double_value);
    return _param;
  }

  /* Getters */

  /**
   * Get MA period value.
   */
  int GetMAPeriod() { return params.ma_period; }

  /**
   * Set MA method.
   */
  ENUM_MA_METHOD GetMAMethod() { return params.ma_method; }

  /**
   * Get MA shift value.
   */
  int GetMAShift() { return params.ma_shift; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

  /**
   * Get deviation value.
   */
  double GetDeviation() { return params.deviation; }

  /* Setters */

  /**
   * Set MA period value.
   */
  void SetMAPeriod(int _ma_period) {
    istate.is_changed = true;
    params.ma_period = _ma_period;
  }

  /**
   * Set MA method.
   */
  void SetMAMethod(ENUM_MA_METHOD _ma_method) {
    istate.is_changed = true;
    params.ma_method = _ma_method;
  }

  /**
   * Set MA shift value.
   */
  void SetMAShift(int _ma_shift) {
    istate.is_changed = true;
    params.ma_shift = _ma_shift;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _ap) {
    istate.is_changed = true;
    params.applied_price = _ap;
  }

  /**
   * Set deviation value.
   */
  void SetDeviation(double _deviation) {
    istate.is_changed = true;
    params.deviation = _deviation;
  }
};
