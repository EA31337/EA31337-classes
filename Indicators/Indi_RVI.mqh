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
double iRVI(string _symbol, int _tf, int _period, int _mode, int _shift) {
  ResetLastError();
  return Indi_RVI::iRVI(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_SIGNAL_LINE)_mode, _shift);
}
#endif

// Structs.
struct IndiRVIParams : IndicatorParams {
  unsigned int period;
  // Struct constructors.
  IndiRVIParams(unsigned int _period = 10, int _shift = 0)
      : period(_period), IndicatorParams(INDI_RVI, FINAL_SIGNAL_LINE_ENTRY, TYPE_DOUBLE) {
    shift = _shift;
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\RVI");
  };
  IndiRVIParams(IndiRVIParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Relative Vigor Index indicator.
 */
class Indi_RVI : public Indicator<IndiRVIParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_RVI(const IndiRVIParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiRVIParams>(_p, _indi_src) {}
  Indi_RVI(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_RVI, _tf, _shift) {}

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
      int _shift = 0, IndicatorBase *_obj = NULL) {
#ifdef __MQL4__
    return ::iRVI(_symbol, _tf, _period, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iRVI(_symbol, _tf, _period)) == INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = LINE_MAIN, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_RVI::iRVI(GetSymbol(), GetTf(), GetPeriod(), (ENUM_SIGNAL_LINE)_mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE);
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /* Setters */

  /**
   * Set the averaging period for the RVI calculation.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }
};
