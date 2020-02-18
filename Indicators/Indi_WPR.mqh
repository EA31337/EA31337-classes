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
struct WPREntry : IndicatorEntry {
  double value;
  string ToString() {
    return StringFormat("%g", value);
  }
};
struct WPR_Params {
  unsigned int period;
  // Constructor.
  void WPR_Params(unsigned int _period) : period(_period) {};
};

/**
 * Implements the Larry Williams' Percent Range.
 */
class Indi_WPR : public Indicator {

 protected:

  WPR_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_WPR(WPR_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.period), Indicator(_iparams, _cparams) {};
  Indi_WPR(WPR_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.period), Indicator(INDI_WPR, _tf) {};

  /**
    * Calculates the Larry Williams' Percent Range and returns its value.
    *
    * @docs
    * - https://docs.mql4.com/indicators/iwpr
    * - https://www.mql5.com/en/docs/indicators/iwpr
    */
  static double iWPR(
    string _symbol = NULL,
    ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
    unsigned int _period = 14,
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
#ifdef __MQL4__
    return ::iWPR(_symbol, _tf, _period, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
  double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iWPR(_symbol, _tf, _period)) == INVALID_HANDLE) {
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
    double _value = Indi_WPR::iWPR(GetSymbol(), GetTf(), GetPeriod(), _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  WPREntry GetEntry(int _shift = 0) {
    WPREntry _entry;
    _entry.value = GetValue(_shift);
    return _entry;
  }

    /* Getters */

    /**
     * Get period value.
     */
    unsigned int GetPeriod() {
      return this.params.period;
    }

    /* Setters */

    /**
     * Set period (bars count) for the indicator calculation.
     */
    void SetPeriod(unsigned int _period) {
      new_params = true;
      this.params.period = _period;
    }

};
