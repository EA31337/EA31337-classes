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
struct MassIndexParams : IndicatorParams {
  unsigned int period;
  unsigned int second_period;
  unsigned int sum_period;
  // Struct constructor.
  void MassIndexParams(unsigned int _period = 9, unsigned int _second_period = 9, unsigned int _sum_period = 25,
                       int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_MASS_INDEX;
    max_modes = 1;
    period = _period;
    second_period = _second_period;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\MI");
    SetDataSourceType(IDATA_ICUSTOM);
    shift = _shift;
    sum_period = _sum_period;
    tf = _tf;
  };
  void MassIndexParams(MassIndexParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_MassIndex : public Indicator {
 protected:
  MassIndexParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_MassIndex(MassIndexParams &_params)
      : params(_params.period, _params.second_period, _params.sum_period), Indicator((IndicatorParams)_params) {
    params = _params;
  };
  Indi_MassIndex(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_MASS_INDEX, _tf) { params.tf = _tf; };

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                         params.GetCustomIndicatorName(), /*[*/ GetPeriod(), GetSecondPeriod(), GetSumPeriod() /*]*/, 0,
                         _shift);
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
   * Get period.
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get second period.
   */
  unsigned int GetSecondPeriod() { return params.second_period; }

  /**
   * Get sum period.
   */
  unsigned int GetSumPeriod() { return params.sum_period; }

  /* Setters */

  /**
   * Set period.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Set second period.
   */
  void SetSecondPeriod(unsigned int _second_period) {
    istate.is_changed = true;
    params.second_period = _second_period;
  }

  /**
   * Set sum period.
   */
  void SetSumPeriod(unsigned int _sum_period) {
    istate.is_changed = true;
    params.sum_period = _sum_period;
  }
};
