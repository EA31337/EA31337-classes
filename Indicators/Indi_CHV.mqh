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
#include "Indi_MA.mqh"

// Enums.
enum ENUM_CHV_SMOOTH_METHOD { CHV_SMOOTH_METHOD_SMA = 0, CHV_SMOOTH_METHOD_EMA = 1 };

// Structs.
struct CHVParams : IndicatorParams {
  unsigned int smooth_period;
  unsigned int chv_period;
  ENUM_CHV_SMOOTH_METHOD smooth_method;
  // Struct constructor.
  void CHVParams(int _smooth_period = 10, int _chv_period = 10,
                 ENUM_CHV_SMOOTH_METHOD _smooth_method = CHV_SMOOTH_METHOD_EMA, int _shift = 0) {
    chv_period = _chv_period;
    itype = INDI_CHAIKIN_V;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\CHV");
    shift = _shift;
    smooth_method = _smooth_method;
    smooth_period = _smooth_period;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_CHV : public Indicator<CHVParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_CHV(CHVParams &_params) : Indicator<CHVParams>(_params){};
  Indi_CHV(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_CHAIKIN_V, _tf){};

  /**
   * Built-in version of Chaikin Volatility.
   */
  static double iCHV(string _symbol, ENUM_TIMEFRAMES _tf, int _smooth_period, int _chv_period,
                     ENUM_CHV_SMOOTH_METHOD _smooth_method, int _mode = 0, int _shift = 0,
                     Indicator<CHVParams> *_obj = NULL) {
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
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_CHV::iCHV(GetSymbol(), GetTf(), /*[*/ GetSmoothPeriod(), GetCHVPeriod(), GetSmoothMethod() /*]*/,
                                _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetSmoothPeriod(),
                         GetCHVPeriod(), GetSmoothMethod() /*]*/, _mode, _shift);
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
    IndicatorDataEntry _entry(iparams.GetMaxModes());
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)iparams.GetMaxModes(); _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE));
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(iparams.GetDataValueType()));
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
