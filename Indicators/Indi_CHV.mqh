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
#include "../Storage/ValueStorage.all.h"
#include "../Util.h"
#include "Indi_MA.mqh"

// Enums.
enum ENUM_CHV_SMOOTH_METHOD { CHV_SMOOTH_METHOD_SMA = 0, CHV_SMOOTH_METHOD_EMA = 1 };

// Structs.
struct IndiCHVParams : IndicatorParams {
  unsigned int smooth_period;
  unsigned int chv_period;
  ENUM_CHV_SMOOTH_METHOD smooth_method;
  // Struct constructor.
  IndiCHVParams(int _smooth_period = 10, int _chv_period = 10,
                ENUM_CHV_SMOOTH_METHOD _smooth_method = CHV_SMOOTH_METHOD_EMA, int _shift = 0)
      : IndicatorParams(INDI_CHAIKIN_V, 1, TYPE_DOUBLE) {
    chv_period = _chv_period;
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\CHV");
    shift = _shift;
    smooth_method = _smooth_method;
    smooth_period = _smooth_period;
  };
  IndiCHVParams(IndiCHVParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_CHV : public Indicator<IndiCHVParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_CHV(IndiCHVParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiCHVParams>(_p, _indi_src){};
  Indi_CHV(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_CHAIKIN_V, _tf, _shift){};

  /**
   * Built-in version of Chaikin Volatility.
   */
  static double iCHV(string _symbol, ENUM_TIMEFRAMES _tf, int _smooth_period, int _chv_period,
                     ENUM_CHV_SMOOTH_METHOD _smooth_method, int _mode = 0, int _shift = 0, IndicatorBase *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(
        _symbol, _tf, Util::MakeKey("Indi_CHV", _smooth_period, _chv_period, _smooth_method));
    return iCHVOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _smooth_period, _chv_period, _smooth_method, _mode,
                       _shift, _cache);
  }

  /**
   * Calculates Chaikin Volatility on the array of values.
   */
  static double iCHVOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _smooth_period, int _chv_period,
                            ENUM_CHV_SMOOTH_METHOD _smooth_method, int _mode, int _shift,
                            IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(3);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_CHV::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0),
                                                 _cache.GetBuffer<double>(1), _cache.GetBuffer<double>(2),
                                                 _smooth_period, _chv_period, _smooth_method));

    // Returns value from the first calculation buffer.
    // Returns first value for as-series array or last value for non-as-series array.
    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnInit() method for Chaikin Volatility indicator.
   */
  static void CalculateInit(int InpSmoothPeriod, int InpCHVPeriod, ENUM_CHV_SMOOTH_METHOD InpSmoothType,
                            int &ExtSmoothPeriod, int &ExtCHVPeriod) {
    if (InpSmoothPeriod <= 0) {
      ExtSmoothPeriod = 10;
      PrintFormat(
          "Incorrect value for input variable InpSmoothPeriod=%d. Indicator will use value=%d for calculations.",
          InpSmoothPeriod, ExtSmoothPeriod);
    } else
      ExtSmoothPeriod = InpSmoothPeriod;
    if (InpCHVPeriod <= 0) {
      ExtCHVPeriod = 10;
      PrintFormat("Incorrect value for input variable InpCHVPeriod=%d. Indicator will use value=%d for calculations.",
                  InpCHVPeriod, ExtCHVPeriod);
    } else
      ExtCHVPeriod = InpCHVPeriod;
  }

  /**
   * OnCalculate() method for Chaikin Volatility indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtCHVBuffer,
                       ValueStorage<double> &ExtHLBuffer, ValueStorage<double> &ExtSHLBuffer, int InpSmoothPeriod,
                       int InpCHVPeriod, ENUM_CHV_SMOOTH_METHOD InpSmoothType) {
    int ExtSmoothPeriod, ExtCHVPeriod;

    CalculateInit(InpSmoothPeriod, InpCHVPeriod, InpSmoothType, ExtSmoothPeriod, ExtCHVPeriod);

    int i, pos, pos_chv;
    // Check for rates total.
    pos_chv = ExtCHVPeriod + ExtSmoothPeriod - 2;
    if (rates_total < pos_chv) return (0);
    // Start working.
    pos = (prev_calculated < 1) ? 0 : prev_calculated - 1;
    // Fill H-L(i) buffer.
    for (i = pos; i < rates_total && !IsStopped(); i++) ExtHLBuffer[i] = high[i] - low[i];
    // Calculate smoothed H-L(i) buffer.
    if (pos < ExtSmoothPeriod - 1) {
      pos = ExtSmoothPeriod - 1;
      for (i = 0; i < pos; i++) ExtSHLBuffer[i] = 0.0;
    }
    if (InpSmoothType == CHV_SMOOTH_METHOD_SMA)
      Indi_MA::SimpleMAOnBuffer(rates_total, prev_calculated, 0, ExtSmoothPeriod, ExtHLBuffer, ExtSHLBuffer);
    else
      Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, 0, ExtSmoothPeriod, ExtHLBuffer, ExtSHLBuffer);
    // Correct calc position.
    if (pos < pos_chv) pos = pos_chv;
    // Calculate CHV buffer.
    for (i = pos; i < rates_total && !IsStopped(); i++) {
      if (ExtSHLBuffer[i - ExtCHVPeriod] != 0.0)
        ExtCHVBuffer[i] =
            100.0 * (ExtSHLBuffer[i] - ExtSHLBuffer[i - ExtCHVPeriod]) / ExtSHLBuffer[i - ExtCHVPeriod].Get();
      else
        ExtCHVBuffer[i] = 0.0;
    }
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_CHV::iCHV(GetSymbol(), GetTf(), /*[*/ GetSmoothPeriod(), GetCHVPeriod(), GetSmoothMethod() /*]*/,
                                _mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetSmoothPeriod(),
                         GetCHVPeriod(), GetSmoothMethod() /*]*/, _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get smooth period.
   */
  unsigned int GetSmoothPeriod() { return iparams.smooth_period; }

  /**
   * Get Chaikin period.
   */
  unsigned int GetCHVPeriod() { return iparams.chv_period; }

  /**
   * Get smooth method.
   */
  ENUM_CHV_SMOOTH_METHOD GetSmoothMethod() { return iparams.smooth_method; }

  /* Setters */

  /**
   * Get smooth period.
   */
  void SetSmoothPeriod(unsigned int _smooth_period) {
    istate.is_changed = true;
    iparams.smooth_period = _smooth_period;
  }

  /**
   * Get Chaikin period.
   */
  void SetCHVPeriod(unsigned int _chv_period) {
    istate.is_changed = true;
    iparams.chv_period = _chv_period;
  }

  /**
   * Set smooth method.
   */
  void SetSmoothMethod(ENUM_CHV_SMOOTH_METHOD _smooth_method) {
    istate.is_changed = true;
    iparams.smooth_method = _smooth_method;
  }
};
