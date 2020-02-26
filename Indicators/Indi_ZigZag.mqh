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
struct ZigZagEntry : IndicatorEntry {
  double value;
  string ToString(int _mode = EMPTY) { return StringFormat("%g", value); }
  bool IsValid() { return value != WRONG_VALUE && value != EMPTY_VALUE; }
};
struct ZigZagParams : IndicatorParams {
  unsigned int depth;
  unsigned int deviation;
  unsigned int backstep;
  // Struct constructor.
  void ZigZagParams(unsigned int _depth, unsigned int _deviation, unsigned int _backstep)
      : depth(_depth), deviation(_deviation), backstep(_backstep) {
    dtype = TYPE_DOUBLE;
    itype = INDI_ZIGZAG;
    max_modes = 1;
  };
};

/**
 * Implements ZigZag indicator.
 */
class Indi_ZigZag : public Indicator {
 protected:
  ZigZagParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_ZigZag(ZigZagParams &_params)
      : params(_params.depth, _params.deviation, _params.backstep), Indicator((IndicatorParams)_params) {}
  Indi_ZigZag(ZigZagParams &_params, ENUM_TIMEFRAMES _tf)
      : params(_params.depth, _params.deviation, _params.backstep), Indicator(INDI_ZIGZAG, _tf) {}

  /**
   * Returns value for ZigZag indicator.
   */
  static double iZigZag(string _symbol, ENUM_TIMEFRAMES _tf, int _depth, int _deviation, int _backstep, int _shift = 0,
                        Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, "ZigZag", _depth, _deviation, _backstep, 0, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iCustom(_symbol, _tf, "Examples\\ZigZag", _depth, _deviation, _backstep)) == INVALID_HANDLE) {
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
    ResetLastError();
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
    double _value =
        Indi_ZigZag::iZigZag(GetSymbol(), GetTf(), GetDepth(), GetDeviation(), GetBackstep(), _shift, GetPointer(this));
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  ZigZagEntry GetEntry(int _shift = 0) {
    ZigZagEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value = GetValue(_shift);
    if (_entry.IsValid()) {
      _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value;
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

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0, int _mode = EMPTY) { return GetEntry(_shift).ToString(_mode); }
};
