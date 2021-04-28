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

// Structs.
struct CustomMovingAverageParams : IndicatorParams {
  unsigned int smooth_period;
  unsigned int smooth_shift;
  ENUM_MA_METHOD smooth_method;
  // Struct constructor.
  void CustomMovingAverageParams(int _smooth_period = 13, int _smooth_shift = 0,
                                 ENUM_MA_METHOD _smooth_method = MODE_SMMA, int _shift = 0,
                                 ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_CUSTOM_MOVING_AVG;
    max_modes = 3;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\Custom Moving Average");
    SetDataSourceType(IDATA_ICUSTOM);
    shift = _shift;
    smooth_method = _smooth_method;
    smooth_period = _smooth_period;
    smooth_shift = _smooth_shift;
    tf = _tf;
    tfi = Chart::TfToIndex(_tf);
  };
  void CustomMovingAverageParams(CustomMovingAverageParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Custom Moving Average indicator.
 */
class Indi_CustomMovingAverage : public Indicator {
 protected:
  CustomMovingAverageParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_CustomMovingAverage(CustomMovingAverageParams &_params) : Indicator((IndicatorParams)_params) {
    params = _params;
  };
  Indi_CustomMovingAverage(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_CUSTOM_MOVING_AVG, _tf) {
    params.tf = _tf;
  };

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.GetCustomIndicatorName(), /*[*/ GetSmoothPeriod(),
                         GetSmoothShift(), GetSmoothMethod() /*]*/, 0, _shift);
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
   * Get smooth period.
   */
  unsigned int GetSmoothPeriod() { return params.smooth_period; }

  /**
   * Get smooth shift.
   */
  unsigned int GetSmoothShift() { return params.smooth_shift; }

  /**
   * Get smooth method.
   */
  ENUM_MA_METHOD GetSmoothMethod() { return params.smooth_method; }

  /* Setters */

  /**
   * Set smooth period.
   */
  void SetSmoothPeriod(unsigned int _smooth_period) {
    istate.is_changed = true;
    params.smooth_period = _smooth_period;
  }

  /**
   * Set smooth shift.
   */
  void SetSmoothShift(unsigned int _smooth_shift) {
    istate.is_changed = true;
    params.smooth_shift = _smooth_shift;
  }

  /**
   * Set smooth method.
   */
  void SetSmoothMethod(ENUM_MA_METHOD _smooth_method) {
    istate.is_changed = true;
    params.smooth_method = _smooth_method;
  }
};
