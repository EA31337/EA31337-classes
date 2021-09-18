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

// Prevents processing this includes file for the second time.
#ifndef INDI_MA_MQH
#define INDI_MA_MQH

// Includes.
#include "../Dict.mqh"
#include "../DictObject.mqh"
#include "../Indicator.mqh"
#include "../Refs.mqh"
#include "../Singleton.h"
#include "../String.mqh"
#include "../ValueStorage.h"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iMA(string _symbol, int _tf, int _ma_period, int _ma_shift, int _ma_method, int _ap, int _shift) {
  return Indi_MA::iMA(_symbol, (ENUM_TIMEFRAMES)_tf, _ma_period, _ma_shift, (ENUM_MA_METHOD)_ma_method,
                      (ENUM_APPLIED_PRICE)_ap, _shift);
}
double iMAOnArray(double &_arr[], int _total, int _period, int _ma_shift, int _ma_method, int _shift,
                  IndicatorCalculateCache<double> *_cache = NULL) {
  return Indi_MA::iMAOnArray(_arr, _total, _period, _ma_shift, _ma_method, _shift, _cache);
}
#endif

// Structs.
struct MAParams : IndicatorParams {
  unsigned int period;
  unsigned int ma_shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_array;
  // Struct constructors.
  void MAParams(unsigned int _period = 13, int _ma_shift = 10, ENUM_MA_METHOD _ma_method = MODE_SMA,
                ENUM_APPLIED_PRICE _ap = PRICE_OPEN, int _shift = 0)
      : period(_period), ma_shift(_ma_shift), ma_method(_ma_method), applied_array(_ap) {
    itype = INDI_MA;
    max_modes = 1;
    shift = _shift;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_PRICE);
    SetCustomIndicatorName("Examples\\Moving Average");
  };
  void MAParams(MAParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
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
  Indi_MA(MAParams &_p) : params(_p.period, _p.shift, _p.ma_method, _p.applied_array), Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_MA(MAParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.period, _p.shift, _p.ma_method, _p.applied_array), Indicator(INDI_MA, _tf) {
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
                    ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _applied_array, int _shift = 0,
                    Indicator *_obj = NULL) {
    ResetLastError();
#ifdef __MQL4__
    return ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_array, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_array)) == INVALID_HANDLE) {
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
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Calculates MA on another indicator.
   */
  static double iMAOnIndicator(IndicatorCalculateCache<double> *cache, Indicator *indi, int indi_mode, string symbol,
                               ENUM_TIMEFRAMES tf, unsigned int ma_period, unsigned int ma_shift,
                               ENUM_MA_METHOD ma_method,  // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
                               int shift = 0) {
    return iMAOnArray(indi.GetValueStorage(indi_mode), 0, ma_period, ma_shift, ma_method, shift, cache);
  }

  /**
   * Calculates MA on the array of values. Cache is optional.
   */
  static double iMAOnArray(double &price[], int total, int ma_period, int ma_shift, int ma_method, int shift,
                           IndicatorCalculateCache<double> *cache = NULL) {
#ifdef __MQL4__
    return ::iMAOnArray(price, total, ma_period, ma_shift, ma_method, shift);
#else
    // We're reusing the same native array for each consecutive calculation.
    NativeValueStorage<double> *_array_storage = Singleton<NativeValueStorage<double>>::Get();
    _array_storage.SetData(price);

    return iMAOnArray((ValueStorage<double> *)_array_storage, total, ma_period, ma_shift, ma_method, shift, cache);
#endif
  }

  /**
   * Calculates MA on the array of values.
   */
  static double iMAOnArray(ValueStorage<double> &price, int total, int ma_period, int ma_shift, int ma_method,
                           int shift, IndicatorCalculateCache<double> *_cache = NULL, bool recalculate = false) {
    if (_cache != NULL) {
      _cache.SetPriceBuffer(price);

      if (!_cache.HasBuffers()) {
        _cache.AddBuffer<NativeValueStorage<double>>();
      }

      if (recalculate) {
        _cache.SetPrevCalculated(0);
      }

      _cache.SetPrevCalculated(
          Indi_MA::Calculate(INDICATOR_CALCULATE_GET_PARAMS_SHORT, _cache.GetBuffer<double>(0), ma_method, ma_period));

      // Returns value from the first calculation buffer.
      // Returns first value for as-series array or last value for non-as-series array.
      return _cache.GetTailValue<double>(0, shift + ma_shift);
    }

    double buf[], arr[], _result, pr, _array;
    int pos, i, k, weight;
    double sum, lsum;
    if (total == 0) total = ArraySize(price);
    if (total > 0 && total < ma_period) return (0);
    if (shift > total - ma_period - ma_shift) return (0);
    bool _was_series = ArrayGetAsSeries(price);
    ArraySetAsSeries(price, true);
    switch (ma_method) {
      case MODE_SMA:
        total = ArrayCopy(arr, price, 0, shift + ma_shift, ma_period);
        if (ArrayResize(buf, total) < 0) return (0);
        sum = 0;
        pos = total - 1;
        for (i = 1; i < ma_period; i++, pos--) sum += arr[pos];
        while (pos >= 0) {
          sum += arr[pos];
          buf[pos] = sum / ma_period;
          sum -= arr[pos + ma_period - 1];
          pos--;
        }
        _result = buf[0];
        break;
      case MODE_EMA:
        if (ArrayResize(buf, total) < 0) return (0);
        pr = 2.0 / (ma_period + 1);
        pos = total - 2;
        while (pos >= 0) {
          if (pos == total - 2) buf[pos + 1] = price[pos + 1].Get();
          buf[pos] = price[pos] * pr + buf[pos + 1] * (1 - pr);
          pos--;
        }
        _result = buf[0];
        break;
      case MODE_SMMA:
        if (ArrayResize(buf, total) < 0) return (0);
        sum = 0;
        pos = total - ma_period;
        while (pos >= 0) {
          if (pos == total - ma_period) {
            for (i = 0, k = pos; i < ma_period; i++, k++) {
              sum += price[k].Get();
              buf[k] = 0;
            }
          } else
            sum = buf[pos + 1] * (ma_period - 1) + price[pos].Get();
          buf[pos] = sum / ma_period;
          pos--;
        }
        _result = buf[0];
        break;
      case MODE_LWMA:
        if (ArrayResize(buf, total) < 0) return (0);
        sum = 0.0;
        lsum = 0.0;
        weight = 0;
        pos = total - 1;
        for (i = 1; i <= ma_period; i++, pos--) {
          _array = price[pos].Get();
          sum += _array * i;
          lsum += _array;
          weight += i;
        }
        pos++;
        i = pos + ma_period;
        while (pos >= 0) {
          buf[pos] = sum / weight;
          if (pos == 0) break;
          pos--;
          i--;
          _array = price[pos].Get();
          sum = sum - lsum + _array * ma_period;
          lsum -= price[i].Get();
          lsum += _array;
        }
        _result = buf[0];
        break;
      default:
        _result = 0;
    }
    ArraySetAsSeries(price, _was_series);
    return _result;
  }

  /**
   * Calculates Simple Moving Average (SMA). The same as in "Example Moving Average" indicator.
   */
  static void CalculateSimpleMA(int rates_total, int prev_calculated, int begin, ValueStorage<double> &price,
                                ValueStorage<double> &ExtLineBuffer, int InpMAPeriod) {
    int i, start;
    //--- first calculation or number of bars was changed
    if (prev_calculated == 0) {
      start = InpMAPeriod + begin;
      //--- set empty value for first start bars
      for (i = 0; i < start - 1; i++) ExtLineBuffer[i] = 0.0;
      //--- calculate first visible value
      double first_value = 0;
      for (i = begin; i < start; i++) first_value += price[i].Get();
      first_value /= InpMAPeriod;
      ExtLineBuffer[start - 1] = first_value;
    } else
      start = prev_calculated - 1;
    //--- main loop
    for (i = start; i < rates_total && !IsStopped(); i++) {
      ExtLineBuffer[i] = ExtLineBuffer[i - 1] + (price[i] - price[i - InpMAPeriod]) / InpMAPeriod;
    }

    // DebugBreak();
  }

  /**
   * Calculates Exponential Moving Average (EMA). The same as in "Example Moving Average" indicator.
   */
  static void CalculateEMA(int rates_total, int prev_calculated, int begin, ValueStorage<double> &price,
                           ValueStorage<double> &ExtLineBuffer, int InpMAPeriod) {
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
  static void CalculateLWMA(int rates_total, int prev_calculated, int begin, ValueStorage<double> &price,
                            ValueStorage<double> &ExtLineBuffer, int InpMAPeriod) {
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
        firstValue += k * price[i].Get();
      }
      firstValue /= (double)weightsum;
      ExtLineBuffer[limit - 1] = firstValue;
    } else
      limit = prev_calculated - 1;
    //--- main loop
    for (i = limit; i < rates_total && !IsStopped(); i++) {
      sum = 0;
      for (int j = 0; j < InpMAPeriod; j++) sum += (InpMAPeriod - j) * price[i - j].Get();
      ExtLineBuffer[i] = sum / weightsum;
    }
    //---
  }

  /**
   * Calculates Smoothed Moving Average (SMMA). The same as in "Example Moving Average" indicator.
   */
  static void CalculateSmoothedMA(int rates_total, int prev_calculated, int begin, ValueStorage<double> &price,
                                  ValueStorage<double> &ExtLineBuffer, int InpMAPeriod) {
    int i, limit;
    //--- first calculation or number of bars was changed
    if (prev_calculated == 0) {
      limit = InpMAPeriod + begin;
      //--- set empty value for first limit bars
      for (i = 0; i < limit - 1; i++) ExtLineBuffer[i] = 0.0;
      //--- calculate first visible value
      double firstValue = 0;
      for (i = begin; i < limit; i++) firstValue += price[i].Get();
      firstValue /= InpMAPeriod;
      ExtLineBuffer[limit - 1] = firstValue;
    } else
      limit = prev_calculated - 1;
    //--- main loop
    for (i = limit; i < rates_total && !IsStopped(); i++)
      ExtLineBuffer[i] = (ExtLineBuffer[i - 1] * (InpMAPeriod - 1) + price[i].Get()) / InpMAPeriod;
    //---
  }

  static int ExponentialMAOnBuffer(const int rates_total, const int prev_calculated, const int begin, const int period,
                                   ValueStorage<double> &price, ValueStorage<double> &buffer) {
    if (period <= 1 || period > (rates_total - begin)) return (0);

    bool as_series_array = ArrayGetAsSeries(price);
    bool as_series_buffer = ArrayGetAsSeries(buffer);

    ArraySetAsSeries(price, false);
    ArraySetAsSeries(buffer, false);

    int start_position, i;
    double smooth_factor = 2.0 / (1.0 + period);

    if (prev_calculated == 0)  // first calculation or number of bars was changed
    {
      //--- set empty value for first bars
      for (i = 0; i < begin; i++) buffer[i] = 0.0;
      //--- calculate first visible value
      start_position = period + begin;
      buffer[begin] = price[begin];

      for (i = begin + 1; i < start_position; i++)
        buffer[i] = price[i] * smooth_factor + buffer[i - 1] * (1.0 - smooth_factor);
    } else
      start_position = prev_calculated - 1;

    for (i = start_position; i < rates_total; i++)
      buffer[i] = price[i] * smooth_factor + buffer[i - 1] * (1.0 - smooth_factor);

    ArraySetAsSeries(price, as_series_array);
    ArraySetAsSeries(buffer, as_series_buffer);

    return (rates_total);
  }

  static int SimpleMAOnBuffer(const int rates_total, const int prev_calculated, const int begin, const int period,
                              ValueStorage<double> &price, ValueStorage<double> &buffer) {
    int i;
    //--- check period
    if (period <= 1 || period > (rates_total - begin)) return (0);
    //--- save as_series flags
    bool as_series_price = ArrayGetAsSeries(price);
    bool as_series_buffer = ArrayGetAsSeries(buffer);

    ArraySetAsSeries(price, false);
    ArraySetAsSeries(buffer, false);
    //--- calculate start position
    int start_position;

    if (prev_calculated == 0)  // first calculation or number of bars was changed
    {
      //--- set empty value for first bars
      start_position = period + begin;

      for (i = 0; i < start_position - 1; i++) buffer[i] = 0.0;
      //--- calculate first visible value
      double first_value = 0;

      for (i = begin; i < start_position; i++) first_value += price[i].Get();

      buffer[start_position - 1] = first_value / period;
    } else
      start_position = prev_calculated - 1;
    //--- main loop
    for (i = start_position; i < rates_total; i++) buffer[i] = buffer[i - 1] + (price[i] - price[i - period]) / period;
    //--- restore as_series flags
    ArraySetAsSeries(price, as_series_price);
    ArraySetAsSeries(buffer, as_series_buffer);
    //---
    return (rates_total);
  }

  static int LinearWeightedMAOnBuffer(const int rates_total, const int prev_calculated, const int begin,
                                      const int period, ValueStorage<double> &price, ValueStorage<double> &buffer) {
    //--- check period
    if (period <= 1 || period > (rates_total - begin)) return (0);
    //--- save as_series flags
    bool as_series_price = ArrayGetAsSeries(price);
    bool as_series_buffer = ArrayGetAsSeries(buffer);

    ArraySetAsSeries(price, false);
    ArraySetAsSeries(buffer, false);
    //--- calculate start position
    int i, start_position;

    if (prev_calculated <= period + begin + 2)  // first calculation or number of bars was changed
    {
      //--- set empty value for first bars
      start_position = period + begin;

      for (i = 0; i < start_position; i++) buffer[i] = 0.0;
    } else
      start_position = prev_calculated - 2;
    //--- calculate first visible value
    double sum = 0.0, lsum = 0.0;
    int l, weight = 0;

    for (i = start_position - period, l = 1; i < start_position; i++, l++) {
      sum += price[i] * l;
      lsum += price[i].Get();
      weight += l;
    }
    buffer[start_position - 1] = sum / weight;
    //--- main loop
    for (i = start_position; i < rates_total; i++) {
      sum = sum - lsum + price[i] * period;
      lsum = lsum - price[i - period].Get() + price[i].Get();
      buffer[i] = sum / weight;
    }
    //--- restore as_series flags
    ArraySetAsSeries(price, as_series_price);
    ArraySetAsSeries(buffer, as_series_buffer);
    //---
    return (rates_total);
  }

  static int LinearWeightedMAOnBuffer(const int rates_total, const int prev_calculated, const int begin,
                                      const int period, ValueStorage<double> &price, ValueStorage<double> &buffer,
                                      int &weight_sum) {
    int i, k;

    //--- check period
    if (period <= 1 || period > (rates_total - begin)) return (0);
    //--- save as_series flags
    bool as_series_price = ArrayGetAsSeries(price);
    bool as_series_buffer = ArrayGetAsSeries(buffer);

    ArraySetAsSeries(price, false);
    ArraySetAsSeries(buffer, false);
    //--- calculate start position
    int start_position;

    if (prev_calculated == 0)  // first calculation or number of bars was changed
    {
      //--- set empty value for first bars
      start_position = period + begin;

      for (i = 0; i < start_position; i++) buffer[i] = 0.0;
      //--- calculate first visible value
      double first_value = 0;
      int wsum = 0;

      for (i = begin, k = 1; i < start_position; i++, k++) {
        first_value += k * price[i].Get();
        wsum += k;
      }

      buffer[start_position - 1] = first_value / wsum;
      weight_sum = wsum;
    } else
      start_position = prev_calculated - 1;
    //--- main loop
    for (i = start_position; i < rates_total; i++) {
      double sum = 0;

      for (int j = 0; j < period; j++) sum += (period - j) * price[i - j].Get();

      buffer[i] = sum / weight_sum;
    }
    //--- restore as_series flags
    ArraySetAsSeries(price, as_series_price);
    ArraySetAsSeries(buffer, as_series_buffer);
    //---
    return (rates_total);
  }

  static int SmoothedMAOnBuffer(const int rates_total, const int prev_calculated, const int begin, const int period,
                                ValueStorage<double> &price, ValueStorage<double> &buffer) {
    int i;
    //--- check period
    if (period <= 1 || period > (rates_total - begin)) return (0);
    //--- save as_series flags
    bool as_series_price = ArrayGetAsSeries(price);
    bool as_series_buffer = ArrayGetAsSeries(buffer);

    ArraySetAsSeries(price, false);
    ArraySetAsSeries(buffer, false);
    //--- calculate start position
    int start_position;

    if (prev_calculated == 0)  // first calculation or number of bars was changed
    {
      //--- set empty value for first bars
      start_position = period + begin;

      for (i = 0; i < start_position - 1; i++) buffer[i] = 0.0;
      //--- calculate first visible value
      double first_value = 0;

      for (i = begin; i < start_position; i++) first_value += price[i].Get();

      buffer[start_position - 1] = first_value / period;
    } else
      start_position = prev_calculated - 1;
    //--- main loop
    for (i = start_position; i < rates_total; i++) buffer[i] = (buffer[i - 1] * (period - 1) + price[i].Get()) / period;
    //--- restore as_series flags
    ArraySetAsSeries(price, as_series_price);
    ArraySetAsSeries(buffer, as_series_buffer);
    //---
    return (rates_total);
  }

  /**
   * Calculates Moving Average. The same as in "Example Moving Average" indicator.
   */
  static int Calculate(const int rates_total, const int prev_calculated, const int begin, ValueStorage<double> &price,
                       ValueStorage<double> &ExtLineBuffer, int InpMAMethod, int InpMAPeriod) {
    //--- check for bars count
    if (rates_total < InpMAPeriod - 1 + begin)
      return (0);  // not enough bars for calculation
                   //--- first calculation or number of bars was changed
    if (prev_calculated == 0) ArrayInitialize(ExtLineBuffer, (double)0);

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
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_MA::iMA(Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), GetPeriod(),
                              GetMAShift(), GetMAMethod(), GetAppliedPrice(), _shift, GetPointer(this));
        break;
      case IDATA_ICUSTOM:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                         params.custom_indi_name, /* [ */ GetPeriod(), GetMAShift(), GetMAMethod(),
                         GetAppliedPrice() /* ] */, 0, _shift);
        break;
      case IDATA_INDICATOR:
        // Calculating MA value from specified indicator.
        _value = Indi_MA::iMAOnIndicator(GetCache(), GetDataSource(), GetDataSourceMode(),
                                         Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                                         GetPeriod(), GetMAShift(), GetMAMethod(), _shift);
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
    IndicatorDataEntry _entry = idata.GetByKey(_bar_time);
    if (!_entry.IsValid() && !_entry.CheckFlag(INDI_ENTRY_FLAG_INSUFFICIENT_DATA)) {
      _entry.Resize(params.max_modes);
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) &&
                                                   !_entry.HasValue<double>(EMPTY_VALUE) &&
                                                   !_entry.HasValue<double>(DBL_MAX));
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(params.GetDataValueType()));
        idata.Add(_entry, _bar_time);
      } else {
        _entry.AddFlags(INDI_ENTRY_FLAG_INSUFFICIENT_DATA);
      }
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
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_array; }

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
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_array) {
    istate.is_changed = true;
    params.applied_array = _applied_array;
  }
};
#endif  // INDI_MA_MQH
