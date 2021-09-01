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
#include "../BufferStruct.mqh"
#include "../Indicator.mqh"
#include "../Util.h"
#include "../ValueStorage.h"
#include "../ValueStorage.price.h"
#include "../ValueStorage.spread.h"
#include "../ValueStorage.tick_volume.h"
#include "../ValueStorage.time.h"
#include "../ValueStorage.volume.h"

// Structs.
struct ADXWParams : IndicatorParams {
  unsigned int period;
  // Struct constructor.
  void ADXWParams(int _period = 14, int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_ADXW;
    max_modes = 3;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\ADXW");
    period = _period;
    shift = _shift;
    tf = _tf;
  };
  void ADXWParams(ADXWParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_ADXW : public Indicator {
 protected:
  ADXWParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_ADXW(ADXWParams &_params) : params(_params.period), Indicator((IndicatorParams)_params) { params = _params; };
  Indi_ADXW(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_ADXW, _tf) { params.tf = _tf; };

  /**
   * Built-in version of ADX Wilder.
   */
  static double iADXWilder(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, int _mode = 0, int _shift = 0,
                           Indicator *_obj = NULL) {
#ifdef __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iADXWilder(_symbol, _tf, _ma_period)) == INVALID_HANDLE) {
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
#else
    ValueStorage<datetime> *_time = TimeValueStorage::GetInstance(_symbol, _tf);
    ValueStorage<long> *_tick_volume = TickVolumeValueStorage::GetInstance(_symbol, _tf);
    ValueStorage<long> *_volume = VolumeValueStorage::GetInstance(_symbol, _tf);
    ValueStorage<long> *_spread = SpreadValueStorage::GetInstance(_symbol, _tf);
    ValueStorage<double> *_price_open = PriceValueStorage::GetInstance(_symbol, _tf, PRICE_OPEN);
    ValueStorage<double> *_price_high = PriceValueStorage::GetInstance(_symbol, _tf, PRICE_HIGH);
    ValueStorage<double> *_price_low = PriceValueStorage::GetInstance(_symbol, _tf, PRICE_LOW);
    ValueStorage<double> *_price_close = PriceValueStorage::GetInstance(_symbol, _tf, PRICE_CLOSE);
    IndicatorCalculateCache<double> *_cache;

    string _key = Util::MakeKey(_symbol, (int)_tf, _ma_period);
    if (!Objects<IndicatorCalculateCache<double>>::TryGet(_key, _cache)) {
      _cache = Objects<IndicatorCalculateCache<double>>::Set(_key, new IndicatorCalculateCache<double>());
    }

    return iADXWilderOnArray(_time, _price_open, _price_high, _price_low, _price_close, _tick_volume, _volume, _spread,
                             0, _ma_period, _mode, _shift, _cache);

#endif
  }

  /**
   * Calculates MA on the array of values.
   */
  static double iADXWilderOnArray(ValueStorage<datetime> &time, ValueStorage<double> &price_open,
                                  ValueStorage<double> &price_high, ValueStorage<double> &price_low,
                                  ValueStorage<double> &price_close, ValueStorage<long> &tick_volume,
                                  ValueStorage<long> &volume, ValueStorage<long> &spread, int total, int period,
                                  int mode, int shift, IndicatorCalculateCache<double> *cache,
                                  bool recalculate = false) {
    cache.SetPriceBuffer(price_open, price_high, price_low, price_close);

    if (!cache.HasBuffers()) {
      cache.AddBuffer<NativeValueStorage<double>>(3 + 7);
    }

    if (recalculate) {
      cache.SetPrevCalculated(0);
    }

    cache.SetPrevCalculated(Indi_ADXW::Calculate(
        cache.GetTotal(), cache.GetPrevCalculated(), time, cache.GetPriceBuffer(PRICE_OPEN),
        cache.GetPriceBuffer(PRICE_HIGH), cache.GetPriceBuffer(PRICE_LOW), cache.GetPriceBuffer(PRICE_CLOSE),
        tick_volume, volume, spread, (ValueStorage<double> *)cache.GetBuffer(0),
        (ValueStorage<double> *)cache.GetBuffer(1), (ValueStorage<double> *)cache.GetBuffer(2),
        (ValueStorage<double> *)cache.GetBuffer(3), (ValueStorage<double> *)cache.GetBuffer(4),
        (ValueStorage<double> *)cache.GetBuffer(5), (ValueStorage<double> *)cache.GetBuffer(6),
        (ValueStorage<double> *)cache.GetBuffer(7), (ValueStorage<double> *)cache.GetBuffer(8),
        (ValueStorage<double> *)cache.GetBuffer(9), period));

    // Returns value from the first calculation buffer.
    // Returns first value for as-series array or last value for non-as-series array.
    return cache.GetTailValue(mode, shift);
  }

  static int Calculate(const int rates_total, const int prev_calculated, ValueStorage<datetime> &time,
                       ValueStorage<double> &open, ValueStorage<double> &high, ValueStorage<double> &low,
                       ValueStorage<double> &close, ValueStorage<long> &tick_volume, ValueStorage<long> &volume,
                       ValueStorage<long> &spread, ValueStorage<double> &ExtADXWBuffer,
                       ValueStorage<double> &ExtPDIBuffer, ValueStorage<double> &ExtNDIBuffer,
                       ValueStorage<double> &ExtPDSBuffer, ValueStorage<double> &ExtNDSBuffer,
                       ValueStorage<double> &ExtPDBuffer, ValueStorage<double> &ExtNDBuffer,
                       ValueStorage<double> &ExtTRBuffer, ValueStorage<double> &ExtATRBuffer,
                       ValueStorage<double> &ExtDXBuffer, int ExtADXWPeriod) {
    //--- checking for bars count
    if (rates_total < ExtADXWPeriod) return (0);
    //--- detect start position
    int start;
    if (prev_calculated > 1)
      start = prev_calculated - 1;
    else {
      start = 1;
      for (int i = 0; i < ExtADXWPeriod; i++) {
        ExtADXWBuffer[i] = 0;
        ExtPDIBuffer[i] = 0;
        ExtNDIBuffer[i] = 0;
        ExtPDSBuffer[i] = 0;
        ExtNDSBuffer[i] = 0;
        ExtPDBuffer[i] = 0;
        ExtNDBuffer[i] = 0;
        ExtTRBuffer[i] = 0;
        ExtATRBuffer[i] = 0;
        ExtDXBuffer[i] = 0;
      }
    }
    //--- main cycle
    for (int i = start; i < rates_total && !IsStopped(); i++) {
      //--- get some data
      double high_price = high[i].Get();
      double prev_high = high[i - 1].Get();
      double low_price = low[i].Get();
      double prev_low = low[i - 1].Get();
      double prev_close = close[i - 1].Get();
      //--- fill main positive and main negative buffers
      double tmp_pos = high_price - prev_high;
      double tmp_neg = prev_low - low_price;
      if (tmp_pos < 0.0) tmp_pos = 0.0;
      if (tmp_neg < 0.0) tmp_neg = 0.0;
      if (tmp_neg == tmp_pos) {
        tmp_neg = 0.0;
        tmp_pos = 0.0;
      } else {
        if (tmp_pos < tmp_neg)
          tmp_pos = 0.0;
        else
          tmp_neg = 0.0;
      }
      ExtPDBuffer[i] = tmp_pos;
      ExtNDBuffer[i] = tmp_neg;
      //--- define TR
      double tr = MathMax(MathMax(MathAbs(high_price - low_price), MathAbs(high_price - prev_close)),
                          MathAbs(low_price - prev_close));
      ExtTRBuffer[i] = tr;  // write down TR to TR buffer
      //--- fill smoothed positive and negative buffers and TR buffer
      if (i < ExtADXWPeriod) {
        ExtATRBuffer[i] = 0.0;
        ExtPDIBuffer[i] = 0.0;
        ExtNDIBuffer[i] = 0.0;
      } else {
        ExtATRBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtATRBuffer[i - 1].Get(), ExtTRBuffer);
        ExtPDSBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtPDSBuffer[i - 1].Get(), ExtPDBuffer);
        ExtNDSBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtNDSBuffer[i - 1].Get(), ExtNDBuffer);
      }
      //--- calculate PDI and NDI buffers
      if (ExtATRBuffer[i] != 0.0) {
        ExtPDIBuffer[i] = 100.0 * ExtPDSBuffer[i].Get() / ExtATRBuffer[i].Get();
        ExtNDIBuffer[i] = 100.0 * ExtNDSBuffer[i].Get() / ExtATRBuffer[i].Get();
      } else {
        ExtPDIBuffer[i] = 0.0;
        ExtNDIBuffer[i] = 0.0;
      }
      //--- Calculate DX buffer
      double dTmp = ExtPDIBuffer[i] + ExtNDIBuffer[i];
      if (dTmp != 0.0)
        dTmp = 100.0 * MathAbs((ExtPDIBuffer[i] - ExtNDIBuffer[i]) / dTmp);
      else
        dTmp = 0.0;
      ExtDXBuffer[i] = dTmp;
      //--- fill ADXW buffer as smoothed DX buffer
      ExtADXWBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtADXWBuffer[i - 1].Get(), ExtDXBuffer);
    }
    //--- OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  /**
   * Smoothed Moving Average.
   */
  static double SmoothedMA(const int position, const int period, const double prev_value, ValueStorage<double> &price) {
    double result = 0.0;
    //--- check period
    if (period > 0 && period <= (position + 1)) {
      if (position == period - 1) {
        for (int i = 0; i < period; i++) result += price[position - i].Get();

        result /= period;
      }

      result = (prev_value * (period - 1) + price[position].Get()) / period;
    }

    return (result);
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_ADXW::iADXWilder(GetSymbol(), GetTf(), GetPeriod(), _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         _mode, _shift);
        break;
        /*
              case IDATA_INDICATOR:
                _value = Indi_ADXW::iADXWilderOnIndicator(GetDataSource(), GetDataSourceMode(),
           Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), GetPeriod()); break;
        */
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }

    Print(_value);

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
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_DOUBLE, true);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE));
      if (_entry.IsValid()) {
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
    _param.double_value = GetEntry(_shift)[_mode];
    return _param;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return params.period; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }
};
