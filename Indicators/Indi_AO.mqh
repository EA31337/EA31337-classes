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
#include "../Indicator.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iAO(string _symbol, int _tf, int _shift) { return Indi_AO::iAO(_symbol, (ENUM_TIMEFRAMES)_tf, _shift); }
#endif

// Structs.
struct AOParams : IndicatorParams {
  // Struct constructor.
  void AOParams(int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_AO;
#ifdef __MQL4__
    max_modes = 1;
#else
    max_modes = 2;
#endif
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\Awesome_Oscillator");
    shift = _shift;
    tf = _tf;
  };
  void AOParams(AOParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Awesome oscillator.
 */
class Indi_AO : public Indicator {
 protected:
  AOParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_AO(AOParams &_p) : Indicator((IndicatorParams)_p) { params = _p; };
  Indi_AO(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : params(_tf), Indicator(INDI_AO, _tf){};

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/iao
   * - https://www.mql5.com/en/docs/indicators/iao
   */
  static double iAO(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0, int _mode = 0,
                    Indicator *_obj = NULL) {
#ifdef __MQL4__
    // Note: In MQL4 _mode is not supported.
    return ::iAO(_symbol, _tf, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iAO(_symbol, _tf)) == INVALID_HANDLE) {
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
#endif
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
        _value = Indi_AO::iAO(Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), _shift, _mode, GetPointer(this));
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), params.GetCustomIndicatorName(), _mode, _shift);
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
    GetEntry(_shift).values[_mode].Get(_param.double_value);
    return _param;
  }
};
