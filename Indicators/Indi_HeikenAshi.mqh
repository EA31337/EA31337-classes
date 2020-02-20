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
struct HeikenAshiEntry : IndicatorEntry {
  double value[FINAL_HA_MODE_ENTRY];
  string ToString(int _mode = EMPTY) {
    return StringFormat("%g,%g,%g,%g",
      value[HA_OPEN], value[HA_HIGH], value[HA_LOW], value[HA_CLOSE]);
  }
  bool IsValid() {
    double _min_value = fmin(fmin(value[HA_OPEN], value[HA_HIGH]), value[HA_CLOSE]);
    double _max_value = fmax(fmax(value[HA_OPEN], value[HA_HIGH]), value[HA_CLOSE]);
    return _min_value > 0 && _max_value != EMPTY_VALUE;
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
    : Indicator(_iparams, _cparams) { Init(); }
  Indi_HeikenAshi(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : Indicator(INDI_HEIKENASHI, _tf) { Init(); }

  /**
   * Initialize parameters.
   */
  void Init() {
    iparams.SetDataType(TYPE_DOUBLE);
    iparams.SetMaxModes(FINAL_HA_MODE_ENTRY);
  }

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
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
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
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  HeikenAshiEntry GetEntry(int _shift = 0) {
    HeikenAshiEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value[HA_OPEN] = GetValue(HA_OPEN, _shift);
    _entry.value[HA_HIGH] = GetValue(HA_HIGH, _shift);
    _entry.value[HA_LOW] = GetValue(HA_LOW, _shift);
    _entry.value[HA_CLOSE] = GetValue(HA_CLOSE, _shift);
    if (_entry.IsValid()) { _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID); }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value[_mode];
    return _param;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0, int _mode = EMPTY) {
    return GetEntry(_shift).ToString(_mode);
  }

};
