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
struct BearsPowerEntry : IndicatorEntry {
  double value;
  string ToString() {
    return StringFormat("%g", value);
  }
  bool IsValid() { return value != WRONG_VALUE && value != EMPTY_VALUE; }
};
struct BearsPower_Params {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price; // (MT5): not used
  // Constructor.
  void BearsPower_Params(unsigned int _period, ENUM_APPLIED_PRICE _ap)
    : period(_period), applied_price(_ap) {}
};

/**
 * Implements the Bears Power indicator.
 */
class Indi_BearsPower : public Indicator {

 public:

  BearsPower_Params params;

  /**
   * Class constructor.
   */
  Indi_BearsPower(BearsPower_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.period, _params.applied_price), Indicator(_iparams, _cparams) {};
  Indi_BearsPower(BearsPower_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.period, _params.applied_price), Indicator(INDI_BEARS, _tf) {};

  /**
    * Returns the indicator value.
    *
    * @docs
    * - https://docs.mql4.com/indicators/ibearspower
    * - https://www.mql5.com/en/docs/indicators/ibearspower
    */
  static double iBearsPower(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    unsigned int _period,
    ENUM_APPLIED_PRICE _applied_price, // (MT5): not used
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
#ifdef __MQL4__
    return ::iBearsPower(_symbol, _tf, _period, _applied_price, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
    double _res[];
      if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iBearsPower(_symbol, _tf, _period)) == INVALID_HANDLE) {
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
    double _value = iBearsPower(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
    * Returns the indicator's struct value.
    */
  BearsPowerEntry GetEntry(int _shift = 0) {
    BearsPowerEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value = GetValue(_shift);
    return _entry;
  }

    /* Getters */

    /**
     * Get period value.
     */
    unsigned int GetPeriod() {
      return params.period;
    }

    /**
     * Get applied price value.
     *
     * Note: Not used in MT5.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return params.applied_price;
    }

    /* Setters */

    /**
     * Set period value.
     */
    void SetPeriod(unsigned int _period) {
      new_params = true;
      params.period = _period;
    }

    /**
     * Set applied price value.
     *
     * Note: Not used in MT5.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      new_params = true;
      params.applied_price = _applied_price;
    }

};
