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

// Enums.
enum ENUM_HA_MODE {
#ifdef __MQL4__
  HA_LOW   = 0,
  HA_HIGH  = 1,
  HA_OPEN  = 2,
  HA_CLOSE = 3,
#else
  HA_OPEN  = 0,
  HA_HIGH  = 1,
  HA_LOW   = 2,
  HA_CLOSE = 3,
#endif
  FINAL_HA_MODE_ENTRY
};

// Structs.
struct HeikenAshi_Entry : IndicatorEntry {
  double value[FINAL_HA_MODE_ENTRY];
  string ToString() {
    return StringFormat("%g,%g,%g,%g",
      value[HA_OPEN], value[HA_HIGH], value[HA_LOW], value[HA_CLOSE]);
  }
};

/**
 * Implements the Heiken-Ashi indicator.
 */
class Indi_HeikenAshi : public Indicator {

 public:

  /**
   * Class constructor.
   */
  Indi_HeikenAshi(IndicatorParams &_iparams, ChartParams &_cparams)
    : Indicator(_iparams, _cparams) {};
  Indi_HeikenAshi(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : Indicator(INDI_HEIKENASHI, _tf) {};

  /**
    * Returns value for iHeikenAshi indicator.
    */
  static double iHeikenAshi(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    ENUM_HA_MODE _mode,
    int _shift = 0,
    Indicator *_obj = NULL
    ) {
    #ifdef __MQL4__
    return ::iCustom(_symbol, _tf, "Heiken Ashi", _mode, _shift);
    #else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
  double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iCustom(_symbol, _tf, "Examples\\Heiken_Ashi")) == INVALID_HANDLE) {
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
  double GetValue(ENUM_HA_MODE _mode, int _shift = 0) {
    double _value = Indi_HeikenAshi::iHeikenAshi(GetSymbol(), GetTf(), _mode, _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  HeikenAshi_Entry GetEntry(int _shift = 0) {
    HeikenAshi_Entry _entry;
    _entry.value[HA_OPEN] = GetValue(HA_OPEN, _shift);
    _entry.value[HA_HIGH] = GetValue(HA_HIGH, _shift);
    _entry.value[HA_LOW] = GetValue(HA_LOW, _shift);
    _entry.value[HA_CLOSE] = GetValue(HA_CLOSE, _shift);
    return _entry;
  }

};
