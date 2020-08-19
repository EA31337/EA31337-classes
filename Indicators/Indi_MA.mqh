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
#include "../Dict.mqh"
#include "../DictObject.mqh"
#include "../Indicator.mqh"
#include "../Refs.mqh"
#include "../String.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iMA(string _symbol, int _tf, int _ma_period, int _ma_shift, int _ma_method, int _ap, int _shift) {
  return Indi_MA::iMA(_symbol, (ENUM_TIMEFRAMES)_tf, _ma_period, _ma_shift, (ENUM_MA_METHOD)_ma_method,
                      (ENUM_APPLIED_PRICE)_ap, _shift);
}
double iMAOnArray(double &_arr[], int _total, int _period, int _ma_shift, int _ma_method, int _shift,
                  string cache_name = "") {
  return Indi_MA::iMAOnArray(_arr, _total, _period, _ma_shift, _ma_method, _shift, cache_name);
}
#endif

// Structs.
struct MAParams : IndicatorParams {
  unsigned int period;
  unsigned int ma_shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  void MAParams(unsigned int _period, int _ma_shift, ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _ap)
      : period(_period), ma_shift(_ma_shift), ma_method(_ma_method), applied_price(_ap) {
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
                    ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _applied_price, int _shift = 0,
                    Indicator *_obj = NULL) {
    ResetLastError();
#ifdef __MQL4__
    return ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    ResetLastError();
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

    for (int i = 0; i < (int)_ma_period + (int)_ma_shift; ++i) indi_values[i] = _indi.GetValueDouble(i);

    return iMAOnArray(indi_values, 0, _ma_period, _ma_shift, _ma_method, _shift);
  }

  /**
   * Calculates MA on the array of values.
   */
  static double iMAOnArray(double &price[], int total, int period, int ma_shift, int ma_method, int shift,
                           string cache_name = "") {
#ifdef __MQL4__
    return ::iMAOnArray(price, total, period, ma_shift, ma_method, shift);
#else

    if (cache_name != "") {
      String cache_key;
      // Do not add shifts here! It would invalidate cache for each call and break the whole algorithm.
      cache_key.Add(cache_name);
      cache_key.Add(period);
      cache_key.Add(ma_method);

      // Note that OnCalculateProxy() method sets incoming price array as not series. It will be reverted back by
      // SetPrevCalculated(). It is done in such way to not force user to remember to set
      Ref<IndicatorCalculateCache> cache = Indicator::OnCalculateProxy(cache_key.ToString(), price, total);

      int prev_calculated =
          Indi_MA::Calculate(total, cache.Ptr().prev_calculated, 0, price, cache.Ptr().buffer1, ma_method, period);

      // Note that SetPrevCalculated() reverts back price array to previous "as series" state.
      cache.Ptr().SetPrevCalculated(price, prev_calculated);

      // Returns value from first calculation buffer (cache's buffer1).
      return cache.Ptr().GetValue(1, shift + ma_shift);
    }

    // @todo: Change algorithm to not assume that array is set as series?
    double buf[], arr[];
    int pos, i;
    double sum, lsum;
    if (total == 0) total = ArraySize(price);
    if (total > 0 && total < period) return (0);
    if (shift > total - period - ma_shift) return (0);
    switch (ma_method) {
      case MODE_SMA: {
        total = ArrayCopy(arr, price, 0, shift + ma_shift, period);
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
          if (pos == total - 2) buf[pos + 1] = price[pos + 1];
          buf[pos] = price[pos] * pr + buf[pos + 1] * (1 - pr);
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
              sum += price[k];
              buf[k] = 0;
            }
          } else
            sum = buf[pos + 1] * (period - 1) + price[pos];
          buf[pos] = sum / period;
          pos--;
        }
        return (buf[shift + ma_shift]);
      }
      case MODE_LWMA: {
        if (ArrayResize(buf, total) < 0) return (0);
        sum = 0.0;
        lsum = 0.0;
        double _price;
        int weight = 0;
        pos = total - 1;
        for (i = 1; i <= period; i++, pos--) {
          _price = price[pos];
          sum += _price * i;
          lsum += _price;
          weight += i;
        }
        pos++;
        i = pos + period;
        while (pos >= 0) {
          buf[pos] = sum / weight;
          if (pos == 0) break;
          pos--;
          i--;
          _price = price[pos];
          sum = sum - lsum + _price * period;
          lsum -= price[i];
          lsum += _price;
        }
        return (buf[shift + ma_shift]);
      }
      default:
        return (0);
    }
    return (0);
#endif
  }

  /**
   * Calculates Simple Moving Average (SMA). The same as in "Example Moving Average" indicator.
   */
  static void CalculateSimpleMA(int rates_total, int prev_calculated, int begin, const double &price[],
                                double &ExtLineBuffer[], int InpMAPeriod) {
    int i, limit;
    //--- first calculation or number of bars was changed
    if (prev_calculated == 0)  // first calculation
    {
      limit = InpMAPeriod + begin;
      //--- set empty value for first limit bars
      for (i = 0; i < limit - 1; i++) ExtLineBuffer[i] = 0.0;
      //--- calculate first visible value
      double firstValue = 0;
      for (i = begin; i < limit; i++) firstValue += price[i];
      firstValue /= InpMAPeriod;
      ExtLineBuffer[limit - 1] = firstValue;
    } else
      limit = prev_calculated - 1;
    //--- main loop
    for (i = limit; i < rates_total && !IsStopped(); i++)
      ExtLineBuffer[i] = ExtLineBuffer[i - 1] + (price[i] - price[i - InpMAPeriod]) / InpMAPeriod;
    //---
  }

  /**
   * Calculates Exponential Moving Average (EMA). The same as in "Example Moving Average" indicator.
   */
  static void CalculateEMA(int rates_total, int prev_calculated, int begin, const double &price[],
                           double &ExtLineBuffer[], int InpMAPeriod) {
    int i, limit;
    double SmoothFactor = 2.0 / (1.0 + InpMAPeriod);
    //--- first calculation or number of bars was changed
    if (prev_calculated == 0) {
      limit = InpMAPeriod + begin;
      ExtLineBuffer[begin] = price[begin];
      for (i = begin + 1; i < limit; i++)
        ExtLineBuffer[i] = price[i] * SmoothFactor + ExtLineBuffer[i - 1] * (1.0 - SmoothFactor);
    } else
      limit = prev_calculated - 1;
    //--- main loop
    for (i = limit; i < rates_total && !IsStopped(); i++)
      ExtLineBuffer[i] = price[i] * SmoothFactor + ExtLineBuffer[i - 1] * (1.0 - SmoothFactor);
    //---
  }

  /**
   * Calculates Linearly Weighted Moving Average (LWMA). The same as in "Example Moving Average" indicator.
   */
  static void CalculateLWMA(int rates_total, int prev_calculated, int begin, const double &price[],
                            double &ExtLineBuffer[], int InpMAPeriod) {
    int i, limit;
    static int weightsum;
    double sum;
    //--- first calculation or number of bars was changed
    if (prev_calculated == 0) {
      weightsum = 0;
      limit = InpMAPeriod + begin;
      //--- set empty value for first limit bars
      for (i = 0; i < limit; i++) ExtLineBuffer[i] = 0.0;
      //--- calculate first visible value
      double firstValue = 0;
      for (i = begin; i < limit; i++) {
        int k = i - begin + 1;
        weightsum += k;
        firstValue += k * price[i];
      }
      firstValue /= (double)weightsum;
      ExtLineBuffer[limit - 1] = firstValue;
    } else
      limit = prev_calculated - 1;
    //--- main loop
    for (i = limit; i < rates_total && !IsStopped(); i++) {
      sum = 0;
      for (int j = 0; j < InpMAPeriod; j++) sum += (InpMAPeriod - j) * price[i - j];
      ExtLineBuffer[i] = sum / weightsum;
    }
    //---
  }

  /**
   * Calculates Smoothed Moving Average (SMMA). The same as in "Example Moving Average" indicator.
   */
  static void CalculateSmoothedMA(int rates_total, int prev_calculated, int begin, const double &price[],
                                  double &ExtLineBuffer[], int InpMAPeriod) {
    int i, limit;
    //--- first calculation or number of bars was changed
    if (prev_calculated == 0) {
      limit = InpMAPeriod + begin;
      //--- set empty value for first limit bars
      for (i = 0; i < limit - 1; i++) ExtLineBuffer[i] = 0.0;
      //--- calculate first visible value
      double firstValue = 0;
      for (i = begin; i < limit; i++) firstValue += price[i];
      firstValue /= InpMAPeriod;
      ExtLineBuffer[limit - 1] = firstValue;
    } else
      limit = prev_calculated - 1;
    //--- main loop
    for (i = limit; i < rates_total && !IsStopped(); i++)
      ExtLineBuffer[i] = (ExtLineBuffer[i - 1] * (InpMAPeriod - 1) + price[i]) / InpMAPeriod;
    //---
  }

  /**
   * Calculates Moving Average. The same as in "Example Moving Average" indicator.
   */
  static int Calculate(const int rates_total, const int prev_calculated, const int begin, const double &price[],
                       double &ExtLineBuffer[], int InpMAMethod, int InpMAPeriod) {
    //--- check for bars count
    if (rates_total < InpMAPeriod - 1 + begin)
      return (0);  // not enough bars for calculation
                   //--- first calculation or number of bars was changed
    if (prev_calculated == 0) ArrayInitialize(ExtLineBuffer, 0);

    //--- calculation
    switch (InpMAMethod) {
      case MODE_EMA:
        CalculateEMA(rates_total, prev_calculated, begin, price, ExtLineBuffer, InpMAPeriod);
        break;
      case MODE_LWMA:
        CalculateLWMA(rates_total, prev_calculated, begin, price, ExtLineBuffer, InpMAPeriod);
        break;
      case MODE_SMMA:
        CalculateSmoothedMA(rates_total, prev_calculated, begin, price, ExtLineBuffer, InpMAPeriod);
        break;
      case MODE_SMA:
        CalculateSimpleMA(rates_total, prev_calculated, begin, price, ExtLineBuffer, InpMAPeriod);
        break;
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
  }

  static double SimpleMA(const int position, const int period, const double &price[]) {
    double result = 0.0;
    for (int i = 0; i < period; i++) {
      result += price[i];
    }
    result /= period;
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
        _value = Indi_MA::iMA(GetSymbol(), GetTf(), GetPeriod(), GetMAShift(), GetMAMethod(), GetAppliedPrice(), _shift,
                              GetPointer(this));
        break;
      case IDATA_ICUSTOM:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.custom_indi_name, /* [ */ GetPeriod(),
                         GetMAShift(), GetMAMethod(), GetAppliedPrice() /* ] */, 0, _shift);
        break;
      case IDATA_INDICATOR:
        // Calculating MA value from specified indicator.
        _value = Indi_MA::iMAOnIndicator(params.indi_data, GetSymbol(), GetTf(), GetPeriod(), GetMAShift(),
                                         GetMAMethod(), _shift, GetPointer(this));
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
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
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

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idvtype); }
};
#endif  // INDI_MA_MQH
