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
#include "../ValueStorage.h"

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
    SetDataSourceType(IDATA_ICUSTOM);
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
   * Calculates MA on the array of values.
   */
  static double iADXWilderOnArray(ValueStorage<datetime> &time, ValueStorage<double> &price_open,
                                  ValueStorage<double> &price_high, ValueStorage<double> &price_low,
                                  ValueStorage<double> &price_close, ValueStorage<long> &tick_volume,
                                  ValueStorage<long> &volume, ValueStorage<int> &spread, int total, int period,
                                  int shift, IndicatorCalculateCache<double> *cache, bool recalculate = false) {
    cache.SetPriceBuffer(price_open, price_high, price_low, price_close);

    if (!cache.IsInitialized()) {
      cache.AddBuffer<NativeValueStorage<double>>(3 + 7);
    }

    if (recalculate) {
      cache.SetPrevCalculated(0);
    }

    cache.SetPrevCalculated(Indi_ADXW::Calculate(
        cache.GetTotal(), cache.GetPrevCalculated(), time, cache.GetPriceBuffer(PRICE_OPEN),
        cache.GetPriceBuffer(PRICE_HIGH), cache.GetPriceBuffer(PRICE_LOW), cache.GetPriceBuffer(PRICE_CLOSE),
        tick_volume, volume, spread, cache.GetBuffer(0), cache.GetBuffer(1), cache.GetBuffer(2), cache.GetBuffer(3),
        cache.GetBuffer(4), cache.GetBuffer(5), cache.GetBuffer(6), cache.GetBuffer(7), cache.GetBuffer(8),
        cache.GetBuffer(9), period));

    // Returns value from the first calculation buffer.
    // Returns first value for as-series array or last value for non-as-series array.
    return cache.GetTailValue(0, shift + ma_shift);
  }

  int Calculate(const int rates_total, const int prev_calculated, ValueStorage<datetime> &time,
                ValueStorage<double> &open, ValueStorage<double> &high, ValueStorage<double> &low,
                ValueStorage<double> &close, ValueStorage<long> &tick_volume, ValueStorage<long> &volume,
                ValueStorage<int> &spread) {
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
      double high_price = high[i];
      double prev_high = high[i - 1];
      double low_price = low[i];
      double prev_low = low[i - 1];
      double prev_close = close[i - 1];
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
        ExtATRBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtATRBuffer[i - 1], ExtTRBuffer);
        ExtPDSBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtPDSBuffer[i - 1], ExtPDBuffer);
        ExtNDSBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtNDSBuffer[i - 1], ExtNDBuffer);
      }
      //--- calculate PDI and NDI buffers
      if (ExtATRBuffer[i] != 0.0) {
        ExtPDIBuffer[i] = 100.0 * ExtPDSBuffer[i] / ExtATRBuffer[i];
        ExtNDIBuffer[i] = 100.0 * ExtNDSBuffer[i] / ExtATRBuffer[i];
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
      ExtADXWBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtADXWBuffer[i - 1], ExtDXBuffer);
    }
    //--- OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                         params.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/, _mode, _shift);
        break;
      case IDATA_INDICATOR:
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
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
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
