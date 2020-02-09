//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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
struct StdDev_Params {
  uint ma_period;
  uint ma_shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  // Constructor.
  void StdDev_Params(uint _ma_period, uint _ma_shift, ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _ap)
    : ma_period(_ma_period), ma_shift(_ma_shift), ma_method(_ma_method), applied_price(_ap) {};
};

/**
 * Implements the Standard Deviation indicator.
 */
class Indi_StdDev : public Indicator {

public:

    StdDev_Params params;

    /**
     * Class constructor.
     */
    Indi_StdDev(StdDev_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
      : params(_params.ma_period, _params.ma_shift, _params.ma_method, _params.applied_price),
        Indicator(_iparams, _cparams) {};

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
      uint _ma_period,
      uint _ma_shift,
      ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
      ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
      int _shift = 0
      )
    {
      #ifdef __MQL4__
      return ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(int _shift = 0) {
     double _value = iStdDev(GetSymbol(), GetTf(), GetMAPeriod(), GetMAShift(), GetMAMethod(), GetAppliedPrice(), _shift);
     CheckLastError();
     return _value;
    }

    /* Getters */

    /**
     * Get period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    uint GetMAPeriod() {
      return this.params.ma_period;
    }

    /**
     * Get MA shift value.
     *
     * Indicators line offset relate to the chart by timeframe.
     */
    uint GetMAShift() {
      return this.params.ma_shift;
    }

    /**
     * Set MA method (smoothing type).
     */
    ENUM_MA_METHOD GetMAMethod() {
      return this.params.ma_method;
    }

    /**
     * Get applied price value.
     *
     * The desired price base for calculations.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return this.params.applied_price;
    }

    /* Setters */

    /**
     * Set period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetMAPeriod(uint _ma_period) {
      this.params.ma_period = _ma_period;
    }

    /**
     * Set MA shift value.
     */
    void SetMAShift(int _ma_shift) {
      this.params.ma_shift = _ma_shift;
    }

    /**
     * Set MA method.
     *
     * Indicators line offset relate to the chart by timeframe.
     */
    void SetMAMethod(ENUM_MA_METHOD _ma_method) {
      this.params.ma_method = _ma_method;
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
      this.params.applied_price = _applied_price;
    }

};
