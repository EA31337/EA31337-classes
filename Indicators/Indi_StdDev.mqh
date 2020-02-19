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
struct StdDevEntry : IndicatorEntry {
  double value;
  string ToString() {
    return StringFormat("%g", value);
  }
};
struct StdDev_Params {
  unsigned int ma_period;
  unsigned int ma_shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  // Constructor.
  void StdDev_Params(unsigned int _ma_period, unsigned int _ma_shift, ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _ap)
    : ma_period(_ma_period), ma_shift(_ma_shift), ma_method(_ma_method), applied_price(_ap) {};
};

/**
 * Implements the Standard Deviation indicator.
 */
class Indi_StdDev : public Indicator {

 protected:

  StdDev_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_StdDev(StdDev_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.ma_period, _params.ma_shift, _params.ma_method, _params.applied_price),
      Indicator(_iparams, _cparams) {};
  Indi_StdDev(StdDev_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.ma_period, _params.ma_shift, _params.ma_method, _params.applied_price),
      Indicator(INDI_STDDEV, _tf) {};

  /**
    * Calculates the Standard Deviation indicator and returns its value.
    *
    * @docs
    * - https://docs.mql4.com/indicators/istddev
    * - https://www.mql5.com/en/docs/indicators/istddev
    */
  static double iStdDev (
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    unsigned int _ma_period,
    unsigned int _ma_shift,
    ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
    ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
#ifdef __MQL4__
    return ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price)) == INVALID_HANDLE) {
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
    double _value = Indi_StdDev::iStdDev(GetSymbol(), GetTf(), GetMAPeriod(), GetMAShift(), GetMAMethod(), GetAppliedPrice(), _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  StdDevEntry GetEntry(int _shift = 0) {
    StdDevEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value = GetValue(_shift);
    return _entry;
  }

    /* Getters */

    /**
     * Get period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    unsigned int GetMAPeriod() {
      return params.ma_period;
    }

    /**
     * Get MA shift value.
     *
     * Indicators line offset relate to the chart by timeframe.
     */
    unsigned int GetMAShift() {
      return params.ma_shift;
    }

    /**
     * Set MA method (smoothing type).
     */
    ENUM_MA_METHOD GetMAMethod() {
      return params.ma_method;
    }

    /**
     * Get applied price value.
     *
     * The desired price base for calculations.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return params.applied_price;
    }

    /* Setters */

    /**
     * Set period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetMAPeriod(unsigned int _ma_period) {
      new_params = true;
      params.ma_period = _ma_period;
    }

    /**
     * Set MA shift value.
     */
    void SetMAShift(int _ma_shift) {
      new_params = true;
      params.ma_shift = _ma_shift;
    }

    /**
     * Set MA method.
     *
     * Indicators line offset relate to the chart by timeframe.
     */
    void SetMAMethod(ENUM_MA_METHOD _ma_method) {
      new_params = true;
      params.ma_method = _ma_method;
    }

    /**
     * Set applied price value.
     *
     * The desired price base for calculations.
     * @docs
     * - https://docs.mql4.com/constants/indicatorconstants/prices#enum_applied_price_enum
     * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      new_params = true;
      params.applied_price = _applied_price;
    }

};
