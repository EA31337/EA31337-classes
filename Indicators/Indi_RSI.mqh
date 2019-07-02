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
 * Implements the Relative Strength Index indicator.
 */
class Indi_RSI : public Indicator {

  // Structs.
  struct RSI_Params {
    uint period;
    ENUM_APPLIED_PRICE applied_price;
    // Struct methods.
    void Set(uint _period, ENUM_APPLIED_PRICE _ap) { period = _period; applied_price = _ap; }
  };

  // Struct variables.
  RSI_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_RSI(const RSI_Params &_params)
    {
      this.params = _params;
    }
    void Indi_RSI(
      const RSI_Params &_params,
      const IndicatorParams &_iparams,
      Chart *_chart
      ) :
        Indicator(_iparams, _chart)
    {
      this.params = _params;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/irsi
     * - https://www.mql5.com/en/docs/indicators/irsi
     */
    static double iRSI(
      string _symbol = NULL,
      ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
      uint _period = 14,
      ENUM_APPLIED_PRICE _applied_price = PRICE_CLOSE, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
      uint _shift = 0
      )
    {
      #ifdef __MQL4__
      return ::iRSI(_symbol , _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iRSI(_symbol, _tf, _period, _applied_price);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(uint _shift = 0) {
      double _value = this.iRSI(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift);
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
     * Get applied price value.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return this.params.applied_price;
    }

    /* Setters */

    /**
     * Set period value.
     */
    void SetPeriod(uint _period) {
      this.params.period = _period;
    }

    /**
     * Set applied price value.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      this.params.applied_price = _applied_price;
    }

};
