//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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

// Structs.
struct CHOParams : IndicatorParams {
  unsigned int fast_ma;
  unsigned int slow_ma;
  ENUM_MA_METHOD smooth_method;
  ENUM_APPLIED_VOLUME input_volume;
  // Struct constructor.
  void CHOParams(int _fast_ma = 3, int _slow_ma = 10, ENUM_MA_METHOD _smooth_method = MODE_EMA,
                 ENUM_APPLIED_VOLUME _input_volume = VOLUME_TICK, int _shift = 0,
                 ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    fast_ma = _fast_ma;
    input_volume = _input_volume;
    itype = INDI_CHAIKIN;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\CHO");
    SetDataSourceType(IDATA_ICUSTOM);
    shift = _shift;
    slow_ma = _slow_ma;
    smooth_method = _smooth_method;
    tf = _tf;
  };
  void CHOParams(CHOParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_CHO : public Indicator {
 protected:
  CHOParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_CHO(CHOParams &_params)
      : params(_params.fast_ma, _params.slow_ma, _params.smooth_method, _params.input_volume),
        Indicator((IndicatorParams)_params) {
    params = _params;
  };
  Indi_CHO(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_CHAIKIN, _tf) { params.tf = _tf; };

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.GetCustomIndicatorName(), /*[*/ GetFastMA(),
                         GetSlowMA(), GetSmoothMethod(), GetInputVolume() /*]*/, 0, _shift);
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
      _entry.values[0] = GetValue(_shift);
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
   * Get fast moving average.
   */
  unsigned int GetFastMA() { return params.fast_ma; }

  /**
   * Get slow moving average.
   */
  unsigned int GetSlowMA() { return params.slow_ma; }

  /**
   * Get smooth method.
   */
  ENUM_MA_METHOD GetSmoothMethod() { return params.smooth_method; }

  /**
   * Get input volume.
   */
  ENUM_APPLIED_VOLUME GetInputVolume() { return params.input_volume; }

  /* Setters */

  /**
   * Set fast moving average.
   */
  void SetFastMA(unsigned int _fast_ma) {
    istate.is_changed = true;
    params.fast_ma = _fast_ma;
  }

  /**
   * Set slow moving average.
   */
  void SetSlowMA(unsigned int _slow_ma) {
    istate.is_changed = true;
    params.slow_ma = _slow_ma;
  }

  /**
   * Set smooth method.
   */
  void SetSmoothMethod(ENUM_MA_METHOD _smooth_method) {
    istate.is_changed = true;
    params.smooth_method = _smooth_method;
  }

  /**
   * Set input volume.
   */
  void SetInputVolume(ENUM_APPLIED_VOLUME _input_volume) {
    istate.is_changed = true;
    params.input_volume = _input_volume;
  }
};
