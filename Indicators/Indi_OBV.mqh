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
struct OBVEntry : IndicatorEntry {
  double value;
  string ToString(int _mode = EMPTY) {
    return StringFormat("%g", value);
  }
  bool IsValid() { return value != WRONG_VALUE && value != EMPTY_VALUE; }
};
struct OBVParams : IndicatorParams {
  ENUM_APPLIED_PRICE applied_price; // MT4 only.
  ENUM_APPLIED_VOLUME applied_volume; // MT5 only.
  // Struct constructor.
  void OBVParams(ENUM_APPLIED_VOLUME _av = EMPTY)
    : applied_volume(_av) {
    dtype = TYPE_DOUBLE;
    itype = INDI_OBV;
    max_modes = 1;
  };
  void OBVParams(ENUM_APPLIED_PRICE _ap = EMPTY)
    : applied_price(_ap) {
    dtype = TYPE_DOUBLE;
    itype = INDI_OBV;
    max_modes = 1;
  };
};

/**
 * Implements the On Balance Volume indicator.
 */
class Indi_OBV : public Indicator {

 protected:

  OBVParams params;

 public:

  /**
   * Class constructor.
   */
  Indi_OBV(OBVParams &_params)
#ifdef __MQL4__
    : params(_params.applied_price),
#else
    : params(_params.applied_volume),
#endif
      Indicator((IndicatorParams) _params) { }
  Indi_OBV(OBVParams &_params, ENUM_TIMEFRAMES _tf)
#ifdef __MQL4__
    : params(_params.applied_price),
#else
    : params(_params.applied_volume),
#endif
      Indicator(INDI_OBV, _tf) { }

  /**
    * Returns the indicator value.
    *
    * @docs
    * - https://docs.mql4.com/indicators/iobv
    * - https://www.mql5.com/en/docs/indicators/iobv
    */
  static double iOBV(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    ENUM_APPLIED_PRICE _applied_price, // MT4 only.
    int _shift = 0,
    Indicator *_obj = NULL
    ) {
#ifdef __MQL4__
    return ::iOBV(_symbol, _tf, _applied_price, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iOBV(_symbol, _tf, VOLUME_TICK)) == INVALID_HANDLE) {
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
  static double iOBV(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    ENUM_APPLIED_VOLUME _applied_volume, // MT5 only.
    int _shift = 0,
    Indicator *_obj = NULL
    ) {
#ifdef __MQL4__
    return ::iOBV(_symbol, _tf, PRICE_CLOSE, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iOBV(_symbol, _tf, _applied_volume)) == INVALID_HANDLE) {
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
  double iOBV(int _shift = 0) {
#ifdef __MQL4__
    double _value = iOBV(GetSymbol(), GetTf(), GetAppliedPrice(), _shift);
#else // __MQL5__
    double _value = iOBV(GetSymbol(), GetTf(), GetAppliedVolume(), _shift);
#endif
    CheckLastError();
    return _value;
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
#ifdef __MQL4__
    double _value = Indi_OBV::iOBV(GetSymbol(), GetTf(), GetAppliedPrice(), _shift);
#else // __MQL5__
    double _value = Indi_OBV::iOBV(GetSymbol(), GetTf(), GetAppliedVolume(), _shift);
#endif
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  OBVEntry GetEntry(int _shift = 0) {
    OBVEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value = GetValue(_shift);
    if (_entry.IsValid()) { _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID); }
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
     * Get applied price value (MT4 only).
     *
     * The desired price base for calculations.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return params.applied_price;
    }

    /**
     * Get applied volume type (MT5 only).
     */
    ENUM_APPLIED_VOLUME GetAppliedVolume() {
      return params.applied_volume;
    }

    /* Setters */

    /**
     * Set applied price value (MT4 only).
     *
     * The desired price base for calculations.
     * @docs
     * - https://docs.mql4.com/constants/indicatorconstants/prices#enum_applied_price_enum
     * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      istate.is_changed = true;
      params.applied_price = _applied_price;
    }

    /**
     * Set applied volume type (MT5 only).
     *
     * @docs
     * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_volume_enum
     */
    void SetAppliedVolume(ENUM_APPLIED_VOLUME _applied_volume) {
      istate.is_changed = true;
      params.applied_volume = _applied_volume;
    }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0, int _mode = EMPTY) {
    return GetEntry(_shift).ToString(_mode);
  }

};
