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
struct RVIParams : IndicatorParams {
  unsigned int period;
  // Struct constructor.
  void RVIParams(unsigned int _period) : period(_period) {
    itype = INDI_RVI;
    max_modes = FINAL_SIGNAL_LINE_ENTRY;
    SetDataType(TYPE_DOUBLE);
  };
};

/**
 * Implements the Relative Vigor Index indicator.
 */
class Indi_RVI : public Indicator {
 protected:
  RVIParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_RVI(const RVIParams &_params) : params(_params.period), Indicator((IndicatorParams)_params) {}
  Indi_RVI(const RVIParams &_params, ENUM_TIMEFRAMES _tf) : params(_params.period), Indicator(INDI_RVI, _tf) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/irvi
   * - https://www.mql5.com/en/docs/indicators/irvi
   */
  static double iRVI(
      string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _period = 10,
      ENUM_SIGNAL_LINE _mode = LINE_MAIN,  // (MT4/MT5): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_SIGNAL/SIGNAL_LINE
      int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iRVI(_symbol, _tf, _period, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iRVI(_symbol, _tf, _period)) == INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_SIGNAL_LINE _mode = LINE_MAIN, int _shift = 0) {
    ResetLastError();
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
    double _value = Indi_RVI::iRVI(GetSymbol(), GetTf(), GetPeriod(), _mode, _shift, GetPointer(this));
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    IndicatorDataEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value.SetValue(params.dtype, GetValue(LINE_MAIN, _shift), LINE_MAIN);
    _entry.value.SetValue(params.dtype, GetValue(LINE_SIGNAL, _shift), LINE_SIGNAL);
    _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID,
      !_entry.value.HasValue(params.dtype, WRONG_VALUE)
      && !_entry.value.HasValue(params.dtype, EMPTY_VALUE)
      && _entry.value.GetMinDbl(params.dtype) >= 0
    );
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
   * Set the averaging period for the RVI calculation.
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
