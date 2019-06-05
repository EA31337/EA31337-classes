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
 * Implements the Bollinger Bands® indicator.
 */
class Indi_Bands : public Indicator {

  // Structs.
  struct Bands_Params {
    uint period;
    double deviation;
    uint bands_shift;
    ENUM_APPLIED_PRICE applied_price;
    ENUM_BANDS_LINE mode;
    uint shift;
  };

  // Struct variables.
  Bands_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_Bands(Bands_Params &_params) {
      this.params = _params;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ibands
     * - https://www.mql5.com/en/docs/indicators/ibands
     */
    static double iBands(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        double _deviation,
        int _bands_shift,
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _mode,                         // (MT4/MT5): 0 - MODE_MAIN/BASE_LINE, 1 - MODE_UPPER/UPPER_BAND, 2 - MODE_LOWER/LOWER_BAND
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iBands(_symbol, _tf, _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iBands(_symbol, _tf, _period, _bands_shift, _deviation, _applied_price);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iBands(int _shift = 0) {
      double _value = this.iBands(GetSymbol(), GetTf(), GetPeriod(), GetDeviation(), GetBandsShift(), GetAppliedPrice(), GetMode(), _shift);
      CheckLastError();
      return _value;
    }
    double GetValue() {
      double _value = this.iBands(GetSymbol(), GetTf(), GetPeriod(), GetDeviation(), GetBandsShift(), GetAppliedPrice(), GetMode(), GetShift());
      CheckLastError();
      return _value;
    }

    /* Getters */

    /**
     * Get period value.
     */
    uint GetPeriod() {
      return this.params.period;
    }

    /**
     * Get deviation value.
     */
    double GetDeviation() {
      return this.params.deviation;
    }

    /**
     * Get bands shift value.
     */
    uint GetBandsShift() {
      return this.params.bands_shift;
    }

    /**
     * Get applied price value.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return this.params.applied_price;
    }

    /**
     * Get mode.
     */
    ENUM_BANDS_LINE GetMode() {
      return this.params.mode;
    }

    /**
     * Get shift value.
     */
    uint GetShift() {
      return this.params.shift;
    }

    /* Setters */

    /**
     * Set period value.
     */
    void SetPeriod(uint _period) {
      this.params.period = _period;
    }

    /**
     * Set deviation value.
     */
    void SetDeviation(double _deviation) {
      this.params.deviation = _deviation;
    }

    /**
     * Set bands shift value.
     */
    void SetBandsShift(int _bands_shift) {
      this.params.bands_shift = _bands_shift;
    }

    /**
     * Set applied price value.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      this.params.applied_price = _applied_price;
    }

    /**
     * Set mode.
     */
    void SetMode(ENUM_BANDS_LINE _mode) {
      this.params.mode = _mode;
    }

    /**
     * Set shift value.
     */
    void SetShift(int _shift) {
      this.params.shift = _shift;
    }

};
