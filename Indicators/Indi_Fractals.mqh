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
struct Fractals_Entry {
  double value[FINAL_LO_UP_LINE_ENTRY];
  string ToString() {
    return StringFormat("%g,%g", value[LINE_UPPER], value[LINE_LOWER]);
  }
};

/**
 * Implements the Fractals indicator.
 */
class Indi_Fractals : public Indicator {

 public:

  /**
   * Class constructor.
   */
  Indi_Fractals(IndicatorParams &_iparams, ChartParams &_cparams)
    : Indicator(_iparams, _cparams) {};
  Indi_Fractals(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : Indicator(INDI_FRACTALS, _tf) {};

  /**
    * Returns the indicator value.
    *
    * @docs
    * - https://docs.mql4.com/indicators/ifractals
    * - https://www.mql5.com/en/docs/indicators/ifractals
    */
  static double iFractals(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      ENUM_LO_UP_LINE _mode,     // (MT4 _mode): 1 - MODE_UPPER, 2 - MODE_LOWER
      int _shift = 0,            // (MT5 _mode): 0 - UPPER_LINE, 1 - LOWER_LINE
      Indicator *_obj = NULL
      ) {
    #ifdef __MQL4__
    return ::iFractals(_symbol, _tf, _mode, _shift);
    #else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
  double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iFractals(_symbol, _tf)) == INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, _mode, -_shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
      #endif
    }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_LO_UP_LINE _mode, int _shift = 0) {
    double _value = Indi_Fractals::iFractals(GetSymbol(), GetTf(), _mode, _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  Fractals_Entry GetEntry(int _shift = 0) {
    Fractals_Entry _entry;
    _entry.value[LINE_UPPER] = GetValue(LINE_UPPER, _shift);
    _entry.value[LINE_LOWER] = GetValue(LINE_LOWER, _shift);
    return _entry;
  }

};
