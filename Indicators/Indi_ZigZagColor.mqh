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
struct ZigZagColorParams : IndicatorParams {
  unsigned int depth;
  unsigned int deviation;
  unsigned int backstep;

  // Struct constructor.
  void ZigZagColorParams(unsigned int _depth = 12, unsigned int _deviation = 5, unsigned int _backstep = 3,
                         int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    backstep = _backstep;
    depth = _depth;
    deviation = _deviation;
    itype = INDI_ZIGZAG_COLOR;
    max_modes = 3;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\ZigZagColor");
    SetDataSourceType(IDATA_ICUSTOM);
    shift = _shift;
    tf = _tf;
  };
  void ZigZagColorParams(ZigZagColorParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Volume Rate of Change indicator.
 */
class Indi_ZigZagColor : public Indicator {
 protected:
  ZigZagColorParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_ZigZagColor(ZigZagColorParams &_params)
      : params(_params.depth, _params.deviation, _params.backstep), Indicator((IndicatorParams)_params) {
    params = _params;
  };
  Indi_ZigZagColor(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_VROC, _tf) { params.tf = _tf; };

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), params.GetCustomIndicatorName(),
                         /*[*/ GetDepth(), GetDeviation(), GetBackstep() /*]*/, _mode, _shift);
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
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _entry.values[0].Get<double>() != EMPTY_VALUE);
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
   * Get depth.
   */
  unsigned int GetDepth() { return params.depth; }

  /**
   * Get deviation.
   */
  unsigned int GetDeviation() { return params.deviation; }

  /**
   * Get backstep.
   */
  unsigned int GetBackstep() { return params.backstep; }

  /* Setters */

  /**
   * Set depth.
   */
  void SetDepth(unsigned int _depth) {
    istate.is_changed = true;
    params.depth = _depth;
  }

  /**
   * Set deviation.
   */
  void SetDeviation(unsigned int _deviation) {
    istate.is_changed = true;
    params.deviation = _deviation;
  }

  /**
   * Set backstep.
   */
  void SetBackstep(unsigned int _backstep) {
    istate.is_changed = true;
    params.backstep = _backstep;
  }
};
