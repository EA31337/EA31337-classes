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
double iOBV(string _symbol, int _tf, int _av, int _shift) {
  ResetLastError();
  return Indi_OBV::iOBV(_symbol, (ENUM_TIMEFRAMES)_tf, (ENUM_APPLIED_VOLUME)_av, _shift);
}
#endif

// Structs.
struct IndiOBVParams : IndicatorParams {
  ENUM_APPLIED_PRICE applied_price;    // MT4 only.
  ENUM_APPLIED_VOLUME applied_volume;  // MT5 only.
  // Struct constructors.
  IndiOBVParams(int _shift = 0) : IndicatorParams(INDI_OBV, 1, TYPE_DOUBLE) {
    shift = _shift;
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\OBV");
    applied_price = PRICE_CLOSE;
    applied_volume = VOLUME_TICK;
  }
  IndiOBVParams(ENUM_APPLIED_VOLUME _av, int _shift = 0)
      : applied_volume(_av), IndicatorParams(INDI_OBV, 1, TYPE_DOUBLE) {
    max_modes = 1;
    shift = _shift;
  };
  IndiOBVParams(ENUM_APPLIED_PRICE _ap, int _shift = 0)
      : applied_price(_ap), IndicatorParams(INDI_OBV, 1, TYPE_DOUBLE) {
    max_modes = 1;
    shift = _shift;
  };
  IndiOBVParams(IndiOBVParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the On Balance Volume indicator.
 */
class Indi_OBV : public Indicator<IndiOBVParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_OBV(IndiOBVParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiOBVParams>(_p, _indi_src) {}
  Indi_OBV(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_OBV, _tf, _shift) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/iobv
   * - https://www.mql5.com/en/docs/indicators/iobv
   */
  static double iOBV(string _symbol, ENUM_TIMEFRAMES _tf,
#ifdef __MQL4__
                     ENUM_APPLIED_PRICE _applied = PRICE_CLOSE,  // MT4 only.
#else
                     ENUM_APPLIED_VOLUME _applied = VOLUME_TICK,  // MT5 only.
#endif
                     int _shift = 0, IndicatorBase *_obj = NULL) {
#ifdef __MQL4__
    return ::iOBV(_symbol, _tf, _applied, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iOBV(_symbol, _tf, _applied)) == INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, 0, _shift, 1, _res) < 0) {
      return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
#ifdef __MQL4__
        _value = Indi_OBV::iOBV(GetSymbol(), GetTf(), GetAppliedPrice(), _ishift);
#else  // __MQL5__
        _value = Indi_OBV::iOBV(GetSymbol(), GetTf(), GetAppliedVolume(), _ishift, THIS_PTR);
#endif
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ VOLUME_TICK /*]*/,
                         0, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get applied price value (MT4 only).
   *
   * The desired price base for calculations.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return iparams.applied_price; }

  /**
   * Get applied volume type (MT5 only).
   */
  ENUM_APPLIED_VOLUME GetAppliedVolume() { return iparams.applied_volume; }

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
    iparams.applied_price = _applied_price;
  }

  /**
   * Set applied volume type (MT5 only).
   *
   * @docs
   * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_volume_enum
   */
  void SetAppliedVolume(ENUM_APPLIED_VOLUME _applied_volume) {
    istate.is_changed = true;
    iparams.applied_volume = _applied_volume;
  }
};
