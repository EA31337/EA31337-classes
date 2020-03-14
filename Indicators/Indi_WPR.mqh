//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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

// Structs.
struct WPRParams : IndicatorParams {
  unsigned int period;
  // Struct constructor.
  void WPRParams(unsigned int _period) : period(_period) {
    itype = INDI_WPR;
    max_modes = 1;
    SetDataType(TYPE_DOUBLE);
  };
};

/**
 * Implements the Larry Williams' Percent Range.
 */
class Indi_WPR : public Indicator {
 protected:
  WPRParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_WPR(WPRParams &_params) : params(_params.period), Indicator((IndicatorParams)_params) {}
  Indi_WPR(WPRParams &_params, ENUM_TIMEFRAMES _tf) : params(_params.period), Indicator(INDI_WPR, _tf) {}

  /**
   * Calculates the Larry Williams' Percent Range and returns its value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/iwpr
   * - https://www.mql5.com/en/docs/indicators/iwpr
   */
  static double iWPR(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _period = 14,
                     int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iWPR(_symbol, _tf, _period, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iWPR(_symbol, _tf, _period)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (GetLastError() > 0) {
      return EMPTY_VALUE;
    } else if (_bars_calc <= 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, 0, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
    double _value = Indi_WPR::iWPR(GetSymbol(), GetTf(), GetPeriod(), _shift, GetPointer(this));
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
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.value.SetValue(params.dtype, GetValue(_shift));
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.value.HasValue(params.dtype, (double) NULL) && !_entry.value.HasValue(params.dtype, EMPTY_VALUE));
      idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.dtype, _mode);
    return _param;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return params.period; }

  /* Setters */

  /**
   * Set period (bars count) for the indicator calculation.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.dtype); }
};
