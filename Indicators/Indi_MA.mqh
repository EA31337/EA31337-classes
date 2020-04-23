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

// Prevents processing this includes file for the second time.
#ifndef INDI_MA_MQH
#define INDI_MA_MQH

// Includes.
#include "../Indicator.mqh"

// Structs.
struct MAParams : IndicatorParams {
  unsigned int period;
  unsigned int shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  void MAParams(unsigned int _period, int _shift, ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _ap)
      : period(_period), shift(_shift), ma_method(_ma_method), applied_price(_ap) {
    itype = INDI_MA;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
  };
};

/**
 * Implements the Moving Average indicator.
 */
class Indi_MA : public Indicator {
 protected:
  MAParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_MA(MAParams &_p) : params(_p.period, _p.shift, _p.ma_method, _p.applied_price), Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_MA(MAParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.period, _p.shift, _p.ma_method, _p.applied_price), Indicator(INDI_MA, _tf) {
    params = _p;
  }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ima
   * - https://www.mql5.com/en/docs/indicators/ima
   */
  static double iMA(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _ma_period, unsigned int _ma_shift,
                    ENUM_MA_METHOD _ma_method,          // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
                    ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW,
                                                        // PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
                    int _shift = 0, Indicator *_obj = NULL) {
    ResetLastError();
#ifdef __MQL4__
    return ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price)) == INVALID_HANDLE) {
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
   * Calculates MA on another indicator.
   *
   * We are operating on given indicator's data. To select which buffer we use,
   * we need to set "indi_mode" parameter for current indicator. It defaults to
   * 0 (the first value). For example: if Price indicator has four values
   * (OHCL), we can use this indicator to operate over Price indicator, and set
   * indi_mode to e.g., PRICE_LOW or PRICE_CLOSE.
   */
  static double iMAOnIndicator(Indicator *_indi, string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _ma_period,
                               unsigned int _ma_shift,
                               ENUM_MA_METHOD _ma_method,  // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
                               int _shift = 0, Indicator *_obj = NULL) {
    double result = 0;
    double indi_values[];
    ArrayResize(indi_values, _ma_period + _ma_shift);

    for (int i = 0; i < (int)_ma_period + (int)_ma_shift; ++i)
      indi_values[i] = _indi.GetValueDouble(i);
      
    return iMAOnArray(indi_values, 0, _ma_period, _ma_shift, _ma_method, _shift);
  }

  /**
   * Calculates MA on the array of values.
   */
  static double iMAOnArray(double &array[], int total, int period, int ma_shift, int ma_method, int shift) {
#ifdef __MQL4__
    return iMAOnArray(array, total, period, ma_shift, ma_method, shift);
#else
    double buf[], arr[];
    int pos, i;
    double sum, lsum;
    if (total == 0) total = ArraySize(array);
    if (total > 0 && total < period) return (0);
    if (shift > total - period - ma_shift) return (0);
    switch (ma_method) {
      case MODE_SMA: {
        total = ArrayCopy(arr, array, 0, shift + ma_shift, period);
        if (ArrayResize(buf, total) < 0) return (0);
        sum = 0;
        pos = total - 1;
        for (i = 1; i < period; i++, pos--) sum += arr[pos];
        while (pos >= 0) {
          sum += arr[pos];
          buf[pos] = sum / period;
          sum -= arr[pos + period - 1];
          pos--;
        }
        return (buf[0]);
      }
      case MODE_EMA: {
        if (ArrayResize(buf, total) < 0) return (0);
        double pr = 2.0 / (period + 1);
        pos = total - 2;
        while (pos >= 0) {
          if (pos == total - 2) buf[pos + 1] = array[pos + 1];
          buf[pos] = array[pos] * pr + buf[pos + 1] * (1 - pr);
          pos--;
        }
        return (buf[shift + ma_shift]);
      }
      case MODE_SMMA: {
        if (ArrayResize(buf, total) < 0) return (0);
        sum = 0;
        int k;
        pos = total - period;
        while (pos >= 0) {
          if (pos == total - period) {
            for (i = 0, k = pos; i < period; i++, k++) {
              sum += array[k];
              buf[k] = 0;
            }
          } else
            sum = buf[pos + 1] * (period - 1) + array[pos];
          buf[pos] = sum / period;
          pos--;
        }
        return (buf[shift + ma_shift]);
      }
      case MODE_LWMA: {
        if (ArrayResize(buf, total) < 0) return (0);
        sum = 0.0;
        lsum = 0.0;
        double price;
        int weight = 0;
        pos = total - 1;
        for (i = 1; i <= period; i++, pos--) {
          price = array[pos];
          sum += price * i;
          lsum += price;
          weight += i;
        }
        pos++;
        i = pos + period;
        while (pos >= 0) {
          buf[pos] = sum / weight;
          if (pos == 0) break;
          pos--;
          i--;
          price = array[pos];
          sum = sum - lsum + price * period;
          lsum -= array[i];
          lsum += price;
        }
        return (buf[shift + ma_shift]);
      }
      default:
        return (0);
    }
    return (0);
#endif
  }

  static double SimpleMA(const int position, const int period, const double &price[]) {
    double result = 0.0;
    for (int i = 0; i < period; i++) {
      result += price[i];
    }
    result /= period;
    return result;
  }
  
  static double SmoothedMA(const double prev_price, const double new_price, const int period) {
   double result = 0.0;
   
   if (prev_price == 0.0) {
     // Previous 
     return 0; //SimpleMA(0, period, price);
   }
   else
       result = 0; //(prev_value * (period - 1) + price[position]) / period;
       
   return result;
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
        _value = Indi_MA::iMA(GetSymbol(), GetTf(), GetPeriod(), GetShift(), GetMAMethod(), GetAppliedPrice(), _shift,
                              GetPointer(this));
        break;
      case IDATA_ICUSTOM:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        // @todo:
        // - https://docs.mql4.com/indicators/icustom
        // - https://www.mql5.com/en/docs/indicators/icustom
        break;
      case IDATA_INDICATOR:
        // Calculating MA value from specified indicator.
        _value = Indi_MA::iMAOnIndicator(params.indi_data, GetSymbol(), GetTf(), GetPeriod(), GetShift(), GetMAMethod(),
                                         _shift, GetPointer(this));
        if (iparams.is_draw) {
          draw.DrawLineTo(StringFormat("%s_%d", GetName(), params.indi_mode), GetBarTime(_shift), _value);
        }
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
   * Get period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get MA shift value.
   *
   * Indicators line offset relate to the chart by timeframe.
   */
  unsigned int GetShift() { return params.shift; }

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
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Set MA shift value.
   */
  void SetShift(int _shift) {
    istate.is_changed = true;
    params.shift = _shift;
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

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idvtype); }
};
#endif  // INDI_MA_MQH
