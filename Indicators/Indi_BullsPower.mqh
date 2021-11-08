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
double iBullsPower(string _symbol, int _tf, int _period, int _ap, int _shift) {
  ResetLastError();
  return Indi_BullsPower::iBullsPower(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_APPLIED_PRICE)_ap, _shift);
}
#endif

// Structs.
struct IndiBullsPowerParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;  // (MT5): not used
  // Struct constructor.
  IndiBullsPowerParams(unsigned int _period = 13, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0)
      : period(_period), applied_price(_ap), IndicatorParams(INDI_BULLS, 1, TYPE_DOUBLE) {
    shift = _shift;
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\Bulls");
  };
  IndiBullsPowerParams(IndiBullsPowerParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bulls Power indicator.
 */
class Indi_BullsPower : public Indicator<IndiBullsPowerParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_BullsPower(IndiBullsPowerParams &_p, IndicatorBase *_indi_src = NULL)
      : Indicator<IndiBullsPowerParams>(_p, _indi_src) {}
  Indi_BullsPower(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_BULLS, _tf, _shift) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ibullspower
   * - https://www.mql5.com/en/docs/indicators/ibullspower
   */
  static double iBullsPower(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period,
                            ENUM_APPLIED_PRICE _applied_price,  // (MT5): not used
                            int _shift = 0, IndicatorBase *_obj = NULL) {
#ifdef __MQL4__
    return ::iBullsPower(_symbol, _tf, _period, _applied_price, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iBullsPower(_symbol, _tf, _period)) == INVALID_HANDLE) {
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
        _value = iBullsPower(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /**/ GetPeriod() /**/,
                         _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get applied price value.
   *
   * Note: Not used in MT5.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return iparams.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set applied price value.
   *
   * Note: Not used in MT5.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};
