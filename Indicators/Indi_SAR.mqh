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
struct SAREntry : IndicatorEntry {
  double value;
  string ToString() {
    return StringFormat("%g", value);
  }
};
struct SAR_Params {
  double step;
  double max;
  // Constructor.
  void SAR_Params(double _step = 0.02, double _max = 0.2)
    : step(_step), max(_max) {};
};

/**
 * Implements the Parabolic Stop and Reverse system indicator.
 */
class Indi_SAR : public Indicator {

 protected:

  SAR_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_SAR(SAR_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.step, _params.max), Indicator(_iparams, _cparams) {};
  Indi_SAR(SAR_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.step, _params.max), Indicator(INDI_SAR, _tf) {};

  /**
    * Returns the indicator value.
    *
    * @docs
    * - https://docs.mql4.com/indicators/isar
    * - https://www.mql5.com/en/docs/indicators/isar
    */
  static double iSAR(
    string _symbol = NULL,
    ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
    double _step = 0.02,
    double _max = 0.2,
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
#ifdef __MQL4__
    return ::iSAR(_symbol ,_tf, _step, _max, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
  double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iSAR(_symbol , _tf, _step, _max)) == INVALID_HANDLE) {
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
    double _value = Indi_SAR::iSAR(GetSymbol(), GetTf(), GetStep(), GetMax(), _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  SAREntry GetEntry(int _shift = 0) {
    SAREntry _entry;
    _entry.value = GetValue(_shift);
    return _entry;
  }

    /* Getters */

    /**
     * Get step of price increment.
     */
    double GetStep() {
      return this.params.step;
    }

    /**
     * Get the maximum step.
     */
    double GetMax() {
      return this.params.max;
    }

    /* Setters */

    /**
     * Set step of price increment (usually 0.02).
     */
    void SetStep(double _step) {
      new_params = true;
      this.params.step = _step;
    }

    /**
     * Set the maximum step (usually 0.2).
     */
    void SetMax(double _max) {
      new_params = true;
      this.params.max = _max;
    }

};
