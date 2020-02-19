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

// Prevents processing this includes file for the second time.
#ifndef INDI_MA_MQH
#define INDI_MA_MQH

// Includes.
#include "../Indicator.mqh"

// Structs.
struct MAEntry : IndicatorEntry {
  double value;
  string ToString() {
    return StringFormat("%g", value);
  }
};
struct MA_Params {
  unsigned int period;
  unsigned int shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  void MA_Params(unsigned int _period, int _shift, ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _ap)
    : period(_period), shift(_shift), ma_method(_ma_method), applied_price(_ap) {};
};

/**
 * Implements the Moving Average indicator.
 */
class Indi_MA : public Indicator {

 protected:

  MA_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_MA(MA_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.period, _params.shift, _params.ma_method, _params.applied_price), Indicator(_iparams, _cparams) {};
  Indi_MA(MA_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.period, _params.shift, _params.ma_method, _params.applied_price), Indicator(INDI_MA, _tf) {};

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ima
   * - https://www.mql5.com/en/docs/indicators/ima
   */
  static double iMA(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    unsigned int _ma_period,
    unsigned int _ma_shift,
    ENUM_MA_METHOD _ma_method,          // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
    ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
    ResetLastError();
#ifdef __MQL4__
    return ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
    double _res[];
      if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price)) == INVALID_HANDLE) {
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
    iparams.ihandle = new_params ? INVALID_HANDLE : iparams.ihandle;
    double _value = Indi_MA::iMA(GetSymbol(), GetTf(), GetPeriod(), GetShift(), GetMAMethod(), GetAppliedPrice(), _shift, GetPointer(this));
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  MAEntry GetEntry(int _shift = 0) {
    MAEntry _entry;
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
    unsigned int GetPeriod() {
      return params.period;
    }

    /**
     * Get MA shift value.
     *
     * Indicators line offset relate to the chart by timeframe.
     */
    unsigned int GetShift() {
      return params.shift;
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
    void SetPeriod(unsigned int _period) {
      new_params = true;
      params.period = _period;
    }

    /**
     * Set MA shift value.
     */
    void SetShift(int _shift) {
      new_params = true;
      params.shift = _shift;
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
#endif // INDI_MA_MQH
