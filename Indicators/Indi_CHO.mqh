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
#include "../Indicator/Indicator.h"
#include "../Storage/ValueStorage.all.h"
#include "../Util.h"
#include "Indi_MA.mqh"

// Structs.
struct IndiCHOParams : IndicatorParams {
  unsigned int fast_ma;
  unsigned int slow_ma;
  ENUM_MA_METHOD smooth_method;
  ENUM_APPLIED_VOLUME input_volume;
  // Struct constructor.
  IndiCHOParams(int _fast_ma = 3, int _slow_ma = 10, ENUM_MA_METHOD _smooth_method = MODE_EMA,
                ENUM_APPLIED_VOLUME _input_volume = VOLUME_TICK, int _shift = 0)
      : IndicatorParams(INDI_CHAIKIN) {
    fast_ma = _fast_ma;
    input_volume = _input_volume;
    SetCustomIndicatorName("Examples\\CHO");
    shift = _shift;
    slow_ma = _slow_ma;
    smooth_method = _smooth_method;
  };
  IndiCHOParams(IndiCHOParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_CHO : public Indicator<IndiCHOParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_CHO(IndiCHOParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_CHO(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(IndiCHOParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_CANDLE | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * Built-in version of Chaikin Oscillator.
   */
  static double iChaikin(string _symbol, ENUM_TIMEFRAMES _tf, int _fast_ma_period, int _slow_ma_period,
                         ENUM_MA_METHOD _ma_method, ENUM_APPLIED_VOLUME _av, int _mode = 0, int _shift = 0,
                         IndicatorData *_obj = NULL) {
#ifdef __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iChaikin(_symbol, _tf, _fast_ma_period, _slow_ma_period, _ma_method, _av),
                                      _mode, _shift);
#else
    if (_obj == nullptr) {
      Print(
          "Indi_CHO::iChaikin() can work without supplying pointer to IndicatorData only in MQL5. In this platform the "
          "pointer is required.");
      DebugBreak();
      return 0;
    }
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(
        _obj, Util::MakeKey(_fast_ma_period, _slow_ma_period, (int)_ma_method, (int)_av));
    return iChaikinOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _fast_ma_period, _slow_ma_period, _ma_method, _av,
                           _mode, _shift, _cache);
#endif
  }

  /**
   * Calculates Chaikin Oscillator on the array of values.
   */
  static double iChaikinOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _fast_ma_period, int _slow_ma_period,
                                ENUM_MA_METHOD _ma_method, ENUM_APPLIED_VOLUME _av, int _mode, int _shift,
                                IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(4);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_CHO::Calculate(
        INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0), _cache.GetBuffer<double>(1),
        _cache.GetBuffer<double>(2), _cache.GetBuffer<double>(3), _fast_ma_period, _slow_ma_period, _ma_method, _av));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * On-indicator version of Chaikin Oscillator.
   */
  static double iChaikinOnIndicator(IndicatorData *_indi, int _fast_ma_period, int _slow_ma_period,
                                    ENUM_MA_METHOD _ma_method, ENUM_APPLIED_VOLUME _av, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(
        _indi, Util::MakeKey(_fast_ma_period, _slow_ma_period, (int)_ma_method, (int)_av));
    return iChaikinOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _fast_ma_period, _slow_ma_period, _ma_method, _av,
                           _mode, _shift, _cache);
  }

  /**
   * OnCalculate() method for Chaikin Oscillator indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtCHOBuffer,
                       ValueStorage<double> &ExtFastEMABuffer, ValueStorage<double> &ExtSlowEMABuffer,
                       ValueStorage<double> &ExtADBuffer, int InpFastMA, int InpSlowMA, ENUM_MA_METHOD InpSmoothMethod,
                       ENUM_APPLIED_VOLUME InpVolumeType) {
    if (rates_total < InpSlowMA) return (0);
    // Preliminary calculations.
    int i, start;
    if (prev_calculated < 2)
      start = 0;
    else
      start = prev_calculated - 2;
    // Calculate AD buffer.
    if (InpVolumeType == VOLUME_TICK) {
      for (i = start; i < rates_total && !IsStopped(); i++) {
        ExtADBuffer[i] = AD(high[i].Get(), low[i].Get(), close[i].Get(), tick_volume[i].Get());
        if (i > 0) ExtADBuffer[i] += ExtADBuffer[i - 1];
      }
    } else {
      for (i = start; i < rates_total && !IsStopped(); i++) {
        ExtADBuffer[i] = AD(high[i].Get(), low[i].Get(), close[i].Get(), volume[i].Get());
        if (i > 0) ExtADBuffer[i] += ExtADBuffer[i - 1];
      }
    }
    // Calculate EMA on array ExtADBuffer.
    AverageOnArray(InpSmoothMethod, rates_total, prev_calculated, 0, InpFastMA, ExtADBuffer, ExtFastEMABuffer);
    AverageOnArray(InpSmoothMethod, rates_total, prev_calculated, 0, InpSlowMA, ExtADBuffer, ExtSlowEMABuffer);
    // Calculate chaikin oscillator.
    for (i = start; i < rates_total && !IsStopped(); i++) ExtCHOBuffer[i] = ExtFastEMABuffer[i] - ExtSlowEMABuffer[i];
    // Return value of prev_calculated for next call.
    return (rates_total);
  }

  static double AD(double high, double low, double close, long volume) {
    double res = 0.0;
    double sum = (close - low) - (high - close);
    if (sum != 0.0) {
      if (high != low) res = (sum / (high - low)) * volume;
    }
    return (res);
  }

  static void AverageOnArray(const int mode, const int rates_total, const int prev_calculated, const int begin,
                             const int period, ValueStorage<double> &source, ValueStorage<double> &destination) {
    switch (mode) {
      case MODE_EMA:
        Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, begin, period, source, destination);
        break;
      case MODE_SMMA:
        Indi_MA::SmoothedMAOnBuffer(rates_total, prev_calculated, begin, period, source, destination);
        break;
      case MODE_LWMA:
        Indi_MA::LinearWeightedMAOnBuffer(rates_total, prev_calculated, begin, period, source, destination);
        break;
      default:
        Indi_MA::SimpleMAOnBuffer(rates_total, prev_calculated, begin, period, source, destination);
    }
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
      case IDATA_ONCALCULATE:
        _value = Indi_CHO::iChaikin(GetSymbol(), GetTf(), /*[*/ GetSlowMA(), GetFastMA(), GetSmoothMethod(),
                                    GetInputVolume() /*]*/, _mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetFastMA(),
                         GetSlowMA(), GetSmoothMethod(), GetInputVolume() /*]*/, 0, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_CHO::iChaikinOnIndicator(GetDataSource(), /*[*/ GetFastMA(), GetSlowMA(), GetSmoothMethod(),
                                               GetInputVolume() /*]*/, _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get fast moving average.
   */
  unsigned int GetFastMA() { return iparams.fast_ma; }

  /**
   * Get slow moving average.
   */
  unsigned int GetSlowMA() { return iparams.slow_ma; }

  /**
   * Get smooth method.
   */
  ENUM_MA_METHOD GetSmoothMethod() { return iparams.smooth_method; }

  /**
   * Get input volume.
   */
  ENUM_APPLIED_VOLUME GetInputVolume() { return iparams.input_volume; }

  /* Setters */

  /**
   * Set fast moving average.
   */
  void SetFastMA(unsigned int _fast_ma) {
    istate.is_changed = true;
    iparams.fast_ma = _fast_ma;
  }

  /**
   * Set slow moving average.
   */
  void SetSlowMA(unsigned int _slow_ma) {
    istate.is_changed = true;
    iparams.slow_ma = _slow_ma;
  }

  /**
   * Set smooth method.
   */
  void SetSmoothMethod(ENUM_MA_METHOD _smooth_method) {
    istate.is_changed = true;
    iparams.smooth_method = _smooth_method;
  }

  /**
   * Set input volume.
   */
  void SetInputVolume(ENUM_APPLIED_VOLUME _input_volume) {
    istate.is_changed = true;
    iparams.input_volume = _input_volume;
  }
};
