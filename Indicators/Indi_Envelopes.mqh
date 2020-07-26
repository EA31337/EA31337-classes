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
#include "Indi_MA.mqh"
#include "Indi_PriceFeeder.mqh"

// Defines macros (for MQL4 backward compability).
//#define iEnvelopes4(symbol, tf, period, ma_method, ma_shift, ap, deviation, mode, shift) \
//        Indi_Envelopes::iEnvelopes(symbol, tf, period, ma_method, ma_shift, ap, deviation, mode, shift);
#define iEnvelopesOnArray(array, total, ma_period, ma_method, ma_shift, deviation, mode, shift) \
        Indi_Envelopes::iEnvelopesOnArray(array, total, ma_period, ma_method, ma_shift, deviation, mode, shift)

// Structs.
struct EnvelopesParams : IndicatorParams {
  unsigned int ma_period;
  unsigned int ma_shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  double deviation;
  // Struct constructor.
  void EnvelopesParams(unsigned int _ma_period, unsigned int _ma_shift, ENUM_MA_METHOD _ma_method,
                       ENUM_APPLIED_PRICE _ap, double _deviation)
      : ma_period(_ma_period), ma_shift(_ma_shift), ma_method(_ma_method), applied_price(_ap), deviation(_deviation) {
    itype = INDI_ENVELOPES;
    #ifdef __MQL5__
      // There is no LINE_MAIN in MQL5 for Envelopes.
      max_modes = 2;
    #else
      max_modes = 3;
    #endif
    SetDataValueType(TYPE_DOUBLE);
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
  static double iEnvelopes(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _ma_period, ENUM_MA_METHOD _ma_method,
                           int _ma_shift, ENUM_APPLIED_PRICE _applied_price, double _deviation,
                           int _mode,  // (MT4 _mode): 0 - MODE_MAIN,  1 - MODE_UPPER, 2 - MODE_LOWER; (MT5 _mode): 0 -
                                       // UPPER_LINE, 1 - LOWER_LINE
                           int _shift = 0, Indicator *_obj = NULL) {
    ResetLastError();
#ifdef __MQL4__
    return ::iEnvelopes(_symbol, _tf, _ma_period, _ma_method, _ma_shift, _applied_price, _deviation, _mode, _shift);
#else  // __MQL5__
    switch (_mode) {
      case LINE_UPPER:
        _mode = 0;
        break;
      case LINE_LOWER:
        _mode = 1;
        break;
    }
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iEnvelopes(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _deviation)) ==
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

  static double iEnvelopesOnIndicator(
      Indicator *_indi, string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _ma_period,
      ENUM_MA_METHOD _ma_method,  // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
      int _ma_shift,
      ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH,
                                          // PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
      double _deviation,
      int _mode,  // (MT4 _mode): 0 - MODE_MAIN,  1 - MODE_UPPER, 2 - MODE_LOWER; (MT5 _mode): 0 -
                  // UPPER_LINE, 1 - LOWER_LINE
      int _shift = 0) {
    double _indi_value_buffer[];
    int i;

    ArrayResize(_indi_value_buffer, _ma_period);

    for (i = _shift; i < (int)_shift + (int)_ma_period; i++) {
      double o = _indi.GetValueDouble(i, INDI_PRICE_MODE_OPEN);
      double h = _indi.GetValueDouble(i, INDI_PRICE_MODE_HIGH);
      double c = _indi.GetValueDouble(i, INDI_PRICE_MODE_CLOSE);
      double l = _indi.GetValueDouble(i, INDI_PRICE_MODE_LOW);

      _indi_value_buffer[i - _shift] = Chart::GetAppliedPrice(_applied_price, o, h, c, l);
    }

    Indi_PriceFeeder indi_price_feeder(_indi_value_buffer);
    MAParams ma_params(_ma_period, _ma_shift, _ma_method, /*unused*/ _applied_price);
    ma_params.SetIndicatorData(&indi_price_feeder, false);
    ma_params.SetIndicatorMode(0);
    Indi_MA indi_ma(ma_params);

    switch (_mode) {
      case LINE_UPPER:
        return (1.0 + _deviation / 100) *
               Indi_MA::iMAOnIndicator(&indi_price_feeder, _symbol, _tf, _ma_period, _ma_shift, _ma_method, _shift);
      case LINE_LOWER:
        return (1.0 - _deviation / 100) *
               Indi_MA::iMAOnIndicator(&indi_price_feeder, _symbol, _tf, _ma_period, _ma_shift, _ma_method, _shift);
    }

    return DBL_MIN;
  }

  /*
  double iEnvelopesOnArray(double &array[], int total, int ma_period, ENUM_MA_METHOD ma_method, int ma_shift,
                           double deviation, int mode, int shift, int applied_price) {
    Indi_PriceFeeder indi_price_feeder(array);
    return Indi_Envelopes::iEnvelopesOnIndicator(&indi_price_feeder, NULL, NULL, ma_period, ma_method, ma_shift,
                                                 (ENUM_APPLIED_PRICE)applied_price, deviation, mode, shift);
  }
  */
  double iEnvelopesOnArray(double &array[], int total, int ma_period, ENUM_MA_METHOD ma_method, int ma_shift,
                           double deviation, int mode, int shift) {
    Indi_PriceFeeder indi_price_feeder(array);
    return Indi_Envelopes::iEnvelopesOnIndicator(&indi_price_feeder, NULL, NULL, ma_period, ma_method, ma_shift,
                                                 (ENUM_APPLIED_PRICE) -1, deviation, mode, shift);
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_LO_UP_LINE _mode, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_Envelopes::iEnvelopes(GetSymbol(), GetTf(), GetMAPeriod(), GetMAMethod(), GetMAShift(),
                                            GetAppliedPrice(), GetDeviation(), _mode, _shift, GetPointer(this));
        break;
      case IDATA_INDICATOR:
        _value =
            Indi_Envelopes::iEnvelopesOnIndicator(params.indi_data, GetSymbol(), GetTf(), GetMAPeriod(), GetMAMethod(),
                                                  GetMAShift(), GetAppliedPrice(), GetDeviation(), _mode, _shift);
        break;
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
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);

      #ifndef __MQL5__
        // There is no LINE_MAIN in MQL5 for Envelopes.
        _entry.value.SetValue(params.idvtype, GetValue((ENUM_LO_UP_LINE)LINE_MAIN, _shift), LINE_MAIN);
      #endif
      _entry.value.SetValue(params.idvtype, GetValue(LINE_UPPER, _shift), LINE_UPPER);
      _entry.value.SetValue(params.idvtype, GetValue(LINE_LOWER, _shift), LINE_LOWER);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.value.HasValue(params.idvtype, (double)NULL) &&
                                                   !_entry.value.HasValue(params.idvtype, EMPTY_VALUE) &&
                                                   _entry.value.GetMinDbl(params.idvtype) > 0);
      if (_entry.IsValid()) idata.Add(_entry, _bar_time);
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
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.idvtype, _mode);
    return _param;
  }

  /* Getters */

  /**
   * Get MA period value.
   */
  unsigned int GetMAPeriod() { return params.ma_period; }

  /**
   * Set MA method.
   */
  ENUM_MA_METHOD GetMAMethod() { return params.ma_method; }

  /**
   * Get MA shift value.
   */
  unsigned int GetMAShift() { return params.ma_shift; }

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
  void SetMAPeriod(unsigned int _ma_period) {
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
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }

  /**
   * Set deviation value.
   */
  void SetDeviation(double _deviation) {
    istate.is_changed = true;
    params.deviation = _deviation;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idvtype); }
};
