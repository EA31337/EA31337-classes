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
struct ACEntry : IndicatorEntry {
  double value;
  //void ACEntry(double _value) : value(_value) {}
  string ToString(int _mode = EMPTY) {
    return StringFormat("%g", value);
  }
  bool IsValid() { return value != WRONG_VALUE && value != EMPTY_VALUE; }
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_AC : public Indicator {

 public:

  /**
   * Class constructor.
   */
  Indi_AC(IndicatorParams &_iparams, ChartParams &_cparams)
    : Indicator(_iparams, _cparams) {};
  Indi_AC(IndicatorParams &_iparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : Indicator(_iparams, _tf) {};
  Indi_AC(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : Indicator(INDI_AC, _tf) {};

  /**
    * Returns the indicator value.
    *
    * @docs
    * - https://docs.mql4.com/indicators/iac
    * - https://www.mql5.com/en/docs/indicators/iac
    */
  static double iAC(
      string _symbol = NULL,
      ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
      int _shift = 0,
      Indicator *_obj = NULL
      ) {
#ifdef __MQL4__
    return ::iAC(_symbol, _tf, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iAC(_symbol, _tf)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      }
      else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (_bars_calc < 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, 0, -_shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    double _value = Indi_AC::iAC(GetSymbol(), GetTf(), _shift, GetPointer(this));
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  ACEntry GetEntry(int _shift = 0) {
    ACEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value = GetValue(_shift);
    if (_entry.IsValid()) { _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID); }
    return _entry;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0, int _mode = EMPTY) {
    return GetEntry(_shift).ToString(_mode);
  }

};
