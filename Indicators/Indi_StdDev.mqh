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

/*
 * @file
 * Standard Deviation indicator.
 *
 * It doesn't give independent signals. Is used to define volatility (trend strength).
 */

// Includes.
#include "../Indicator.mqh"
#include "Indi_MA.mqh"
#include "Indi_PriceFeeder.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iStdDev(string _symbol, int _tf, int _ma_period, int _ma_shift, int _ma_method, int _ap, int _shift) {
  return Indi_StdDev::iStdDev(_symbol, (ENUM_TIMEFRAMES)_tf, _ma_period, _ma_shift, (ENUM_MA_METHOD)_ma_method,
                              (ENUM_APPLIED_PRICE)_ap, _shift);
}
double iStdDevOnArray(double &_arr[], int _total, int _ma_period, int _ma_shift, int _ma_method, int _shift) {
  return Indi_StdDev::iStdDevOnArray(_arr, _total, _ma_period, _ma_shift, (ENUM_MA_METHOD)_ma_method, _shift);
}
#endif

// Structs.
struct StdDevParams : IndicatorParams {
  int ma_period;
  int ma_shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  void StdDevParams(int _ma_period, int _ma_shift, ENUM_MA_METHOD _ma_method = MODE_SMA,
                    ENUM_APPLIED_PRICE _ap = PRICE_OPEN)
      : ma_period(_ma_period), ma_shift(_ma_shift), ma_method(_ma_method), applied_price(_ap) {
    itype = INDI_STDDEV;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
  };
  void StdDevParams(StdDevParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Standard Deviation indicator.
 */
class Indi_StdDev : public Indicator {
 protected:
  StdDevParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_StdDev(StdDevParams &_p)
      : params(_p.ma_period, _p.ma_shift, _p.ma_method, _p.applied_price), Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_StdDev(StdDevParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.ma_period, _p.ma_shift, _p.ma_method, _p.applied_price), Indicator(INDI_STDDEV, _tf) {
    params = _p;
  }

  /**
   * Calculates the Standard Deviation indicator and returns its value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/istddev
   * - https://www.mql5.com/en/docs/indicators/istddev
   */
  static double iStdDev(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, int _ma_shift, ENUM_MA_METHOD _ma_method,
                        ENUM_APPLIED_PRICE _applied_price, int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price)) == INVALID_HANDLE) {
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
   * Note that this method operates on current price (set by _applied_price).
   */
  static double iStdDevOnIndicator(Indicator *_indi, string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, int _ma_shift,
                                   ENUM_APPLIED_PRICE _applied_price, int _shift = 0, Indicator *_obj = NULL) {
    double _indi_value_buffer[];
    double _std_dev;
    int i;
    int _mode = _obj != NULL ? _obj.GetParams().indi_mode : 0;

    ArrayResize(_indi_value_buffer, _ma_period);

    for (i = _shift; i < (int)_shift + (int)_ma_period; i++) {
      // Getting current indicator value. Input data may be shifted on
      // the graph, so we need to take that shift into consideration.
      _indi_value_buffer[i - _shift] = _indi[i + _ma_shift][_mode];
    }

    double _ma = Indi_MA::SimpleMA(_shift, _ma_period, _indi_value_buffer);

    // Standard deviation.
    _std_dev = Indi_StdDev::iStdDevOnArray(_indi_value_buffer, _ma, _ma_period);

    return _std_dev;
  }

  static double iStdDevOnArray(const double &price[], double MAprice, int period) {
    double std_dev = 0;
    int i;

    for (i = 0; i < period; ++i) std_dev += MathPow(price[i] - MAprice, 2);

    return MathSqrt(std_dev / period);
  }

  static double iStdDevOnArray(double &array[], int total, int ma_period, int ma_shift, int ma_method, int shift) {
#ifdef __MQL4__
    return ::iStdDevOnArray(array, total, ma_period, ma_shift, ma_method, shift);
#endif
    bool was_series = ArrayGetAsSeries(array);
    if (!was_series) {
      ArraySetAsSeries(array, true);
    }
    int num = shift + ma_shift;
    bool flag = total == 0;
    if (flag) {
      total = ArraySize(array);
    }
    bool flag2 = num < 0 || num >= total;
    double result;
    if (flag2) {
      result = -1.0;
    } else {
      bool flag3 = ma_method != 1 && num + ma_period > total;
      if (flag3) {
        result = -1.0;
      } else {
        double num2 = 0.0;
        double num3 = Indi_MA::iMAOnArray(array, total, ma_period, 0, ma_method, num);
        for (int i = 0; i < ma_period; i++) {
          double num4 = array[num + i];  // true?
          num2 += (num4 - num3) * (num4 - num3);
        }
        double num5 = MathSqrt(num2 / (double)ma_period);
        result = num5;
      }
    }

    if (!was_series) {
      ArraySetAsSeries(array, false);
    }

    return result;
  }

  /**
   * Standard Deviation On Array is just a normal standard deviation over MA with a selected method.
   */
  static double iStdDevOnArray(const double &price[], int period, ENUM_MA_METHOD ma_method = MODE_SMA) {
    Indi_PriceFeeder indi_price_feeder(price);

    MAParams ma_params(period, 0, ma_method, PRICE_OPEN);
    ma_params.SetIndicatorData(&indi_price_feeder, false);
    ma_params.SetIndicatorMode(0);  // Using first and only mode from price feeder.
    Indi_MA indi_ma(ma_params);

    return iStdDevOnIndicator(&indi_ma, NULL, NULL, period, 0, PRICE_OPEN, /*unused*/ 0);
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_StdDev::iStdDev(GetSymbol(), GetTf(), GetMAPeriod(), GetMAShift(), GetMAMethod(),
                                      GetAppliedPrice(), _shift, GetPointer(this));
        break;
      case IDATA_INDICATOR:
        _value = Indi_StdDev::iStdDevOnIndicator(iparams.indi_data, GetSymbol(), GetTf(), GetMAPeriod(), GetMAShift(),
                                                 GetAppliedPrice(), _shift, GetPointer(this));
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
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.values[0].Set(GetValue(_shift));
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue((double)NULL) && !_entry.HasValue(EMPTY_VALUE));

      AddEntry(_entry, _shift);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    GetEntry(_shift).values[_mode].Get(_param.double_value);
    return _param;
  }

  /* Getters */

  /**
   * Get period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  int GetMAPeriod() { return params.ma_period; }

  /**
   * Get MA shift value.
   *
   * Indicators line offset relate to the chart by timeframe.
   */
  unsigned int GetMAShift() { return params.ma_shift; }

  /**
   * Set MA method (smoothing type).
   */
  ENUM_MA_METHOD GetMAMethod() { return params.ma_method; }

  /**
   * Get applied price value.
   *
   * The desired price base for calculations.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

  /* Setters */

  /**
   * Set period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  void SetMAPeriod(int _ma_period) {
    istate.is_changed = true;
    params.ma_period = _ma_period;
  }

  /**
   * Set MA shift value.
   */
  void SetMAShift(int _ma_shift) {
    istate.is_changed = true;
    params.ma_shift = _ma_shift;
  }

  /**
   * Set MA method.
   *
   * Indicators line offset relate to the chart by timeframe.
   */
  void SetMAMethod(ENUM_MA_METHOD _ma_method) {
    istate.is_changed = true;
    params.ma_method = _ma_method;
  }

  /**
   * Set applied price value.
   *
   * The desired price base for calculations.
   * @docs
   * - https://docs.mql4.com/constants/indicatorconstants/prices#enum_applied_price_enum
   * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }
};
