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
  HA_LOW = 0,
  HA_HIGH = 1,
  HA_OPEN = 2,
  HA_CLOSE = 3,
#else
  HA_OPEN = 0,
  HA_HIGH = 1,
  HA_LOW = 2,
  HA_CLOSE = 3,
#endif
  FINAL_HA_MODE_ENTRY
};

// Structs.
struct HeikenAshiParams : IndicatorParams {
  // Struct constructor.
  void HeikenAshiParams(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_HEIKENASHI;
    max_modes = FINAL_HA_MODE_ENTRY;
    SetDataType(TYPE_DOUBLE);
    tf = _tf;
    tfi = Chart::TfToIndex(_tf);
  };
};

/**
 * Implements the Heiken-Ashi indicator.
 */
class Indi_HeikenAshi : public Indicator {
 protected:
  HeikenAshiParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_HeikenAshi(IndicatorParams &_params) : Indicator((IndicatorParams)_params) {}
  Indi_HeikenAshi(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_HEIKENASHI, _tf) {}

  /**
   * Returns value for iHeikenAshi indicator.
   */
  static double iHeikenAshi(string _symbol, ENUM_TIMEFRAMES _tf, ENUM_HA_MODE _mode, int _shift = 0,
                            Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, "Heiken Ashi", _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iCustom(_symbol, _tf, "Examples\\Heiken_Ashi")) == INVALID_HANDLE) {
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
  double GetValue(ENUM_HA_MODE _mode, int _shift = 0) {
    ResetLastError();
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
    double _value = Indi_HeikenAshi::iHeikenAshi(GetSymbol(), GetTf(), _mode, _shift, GetPointer(this));
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
    _entry.value.SetValue(params.dtype, GetValue(HA_OPEN, _shift), HA_OPEN);
    _entry.value.SetValue(params.dtype, GetValue(HA_HIGH, _shift), HA_HIGH);
    _entry.value.SetValue(params.dtype, GetValue(HA_LOW, _shift), HA_LOW);
    _entry.value.SetValue(params.dtype, GetValue(HA_CLOSE, _shift), HA_CLOSE);
    _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID,
      !_entry.value.HasValue(params.dtype, WRONG_VALUE)
      && !_entry.value.HasValue(params.dtype, EMPTY_VALUE)
      && _entry.value.GetMinDbl(params.dtype) > 0
      && _entry.value.GetValueDbl(params.dtype, HA_LOW) < _entry.value.GetValueDbl(params.dtype, HA_HIGH)
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

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.dtype); }
};
