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

// Properties.
#property strict

// Includes.
#include "../Indicator.mqh"

/**
 * Implements the Envelopes indicator.
 */
class Indi_Envelopes : public Indicator {

  // Structs.
  struct Envelopes_Params {
    uint ma_period;
    uint ma_shift;
    ENUM_MA_METHOD ma_method;
    ENUM_APPLIED_PRICE applied_price;
    double deviation;
    // Constructor.
    void Envelopes_Params(uint _ma_period, uint _ma_shift, ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _ap, double _deviation)
      : ma_period(_ma_period), ma_shift(_ma_shift), ma_method(_ma_method), applied_price(_ap), deviation(_deviation) {};
  } params;

  public:

    /**
     * Class constructor.
     */
    void Indi_Envelopes(Envelopes_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
      : params(_params.ma_period, _params.ma_shift, _params.ma_method, _params.applied_price, _params.deviation),
        Indicator(_iparams, _cparams) {};

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ienvelopes
     * - https://www.mql5.com/en/docs/indicators/ienvelopes
     */
    static double iEnvelopes(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      uint _ma_period,
      ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
      int _ma_shift,
      ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
      double _deviation,
      int _mode,                         // (MT4 _mode): 0 - MODE_MAIN,  1 - MODE_UPPER, 2 - MODE_LOWER
      int _shift = 0                     // (MT5 _mode): 0 - UPPER_LINE, 1 - LOWER_LINE
      )
    {
      #ifdef __MQL4__
      return ::iEnvelopes(_symbol, _tf, _ma_period, _ma_method, _ma_shift, _applied_price, _deviation, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iEnvelopes(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _deviation);
      // if(handle==INVALID_HANDLE)?
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(int _mode, uint _shift = 0) {
      double _value = this.iEnvelopes(GetSymbol(), GetTf(), GetMAPeriod(), GetMAMethod(), GetMAShift(), GetAppliedPrice(), GetDeviation(), _mode, _shift);
      CheckLastError();
      return _value;
    }

    /* Getters */

    /**
     * Get MA period value.
     */
    uint GetMAPeriod() {
      return this.params.ma_period;
    }

    /**
     * Set MA method.
     */
    ENUM_MA_METHOD GetMAMethod() {
      return this.params.ma_method;
    }

    /**
     * Get MA shift value.
     */
    uint GetMAShift() {
      return this.params.ma_shift;
    }

    /**
     * Get applied price value.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return this.params.applied_price;
    }

    /**
     * Get deviation value.
     */
    double GetDeviation() {
      return this.params.deviation;
    }

    /* Setters */

    /**
     * Set MA period value.
     */
    void SetMAPeriod(uint _ma_period) {
      this.params.ma_period = _ma_period;
    }

    /**
     * Set MA method.
     */
    void SetMAMethod(ENUM_MA_METHOD _ma_method) {
      this.params.ma_method = _ma_method;
    }

    /**
     * Set MA shift value.
     */
    void SetMAShift(int _ma_shift) {
      this.params.ma_shift = _ma_shift;
    }

    /**
     * Set applied price value.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      this.params.applied_price = _applied_price;
    }

    /**
     * Set deviation value.
     */
    void SetDeviation(double _deviation) {
      this.params.deviation = _deviation;
    }

};
