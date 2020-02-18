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
struct RVIEntry : IndicatorEntry {
  double value[FINAL_SIGNAL_LINE_ENTRY];
  string ToString() {
    return StringFormat("%g,%g",
      value[LINE_MAIN], value[LINE_SIGNAL]);
  }
};
struct RVI_Params {
  unsigned int period;
  // Constructor.
  void RVI_Params(unsigned int _period)
    : period(_period) {};
};

/**
 * Implements the Relative Vigor Index indicator.
 */
class Indi_RVI : public Indicator {

 protected:

    RVI_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_RVI(const RVI_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.period), Indicator(_iparams, _cparams) {};
  Indi_RVI(const RVI_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.period), Indicator(INDI_RVI, _tf) {};

  /**
    * Returns the indicator value.
    *
    * @docs
    * - https://docs.mql4.com/indicators/irvi
    * - https://www.mql5.com/en/docs/indicators/irvi
    */
  static double iRVI(
    string _symbol = NULL,
    ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
    unsigned int _period = 10,
    ENUM_SIGNAL_LINE _mode = LINE_MAIN,    // (MT4/MT5): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_SIGNAL/SIGNAL_LINE
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
#ifdef __MQL4__
    return ::iRVI(_symbol, _tf, _period, _mode, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iRVI(_symbol, _tf, _period)) == INVALID_HANDLE) {
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
  double GetValue(ENUM_SIGNAL_LINE _mode = LINE_MAIN, int _shift = 0) {
    double _value = Indi_RVI::iRVI(GetSymbol(), GetTf(), GetPeriod(), _mode, _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  RVIEntry GetEntry(int _shift = 0) {
    RVIEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value[LINE_MAIN] = GetValue(LINE_MAIN, _shift);
    _entry.value[LINE_SIGNAL] = GetValue(LINE_SIGNAL, _shift);
    return _entry;
  }

    /* Getters */

    /**
     * Get period value.
     */
    unsigned int GetPeriod() {
      return params.period;
    }

    /* Setters */

    /**
     * Set the averaging period for the RVI calculation.
     */
    void SetPeriod(unsigned int _period) {
      new_params = true;
      params.period = _period;
    }

};
