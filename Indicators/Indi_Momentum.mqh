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
 * Implements the Momentum indicator.
 */
class Indi_Momentum : public Indicator {

  // Structs.
  struct Momentum_Params {
    uint period;
    ENUM_APPLIED_PRICE applied_price;
    uint shift;
  };

  // Struct variables.
  Momentum_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_Momentum(Momentum_Params &_params) {
      this.params = _params;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/imomentum
     * - https://www.mql5.com/en/docs/indicators/imomentum
     */
    static double iMomentum(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iMomentum(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iMomentum(_symbol, _tf, _period, _applied_price);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iMomentum(int _shift = 0) {
      double _value = iMomentum(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift);
      CheckLastError();
      return _value;
    }
    double GetValue() {
      double _value = iMomentum(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), GetShift());
      CheckLastError();
      return _value;
    }

    /* Getters */

    /**
     * Get period value.
     *
     * Averaging period (bars count) for the calculation of the price change.
     */
    uint GetPeriod() {
      return this.params.period;
    }

    /**
     * Get applied price value.
     *
     * The desired price base for calculations.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return this.params.applied_price;
    }

    /**
     * Get shift value.
     *
     * Index of the value taken from the indicator buffer.
     * Shift relative to the current bar the given amount of periods ago.
     */
    uint GetShift() {
      return this.params.shift || 0;
    }

    /* Setters */

    /**
     * Set period value.
     *
     * Averaging period (bars count) for the calculation of the price change.
     */
    void SetPeriod(uint _period) {
      this.params.period = _period;
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

    /**
     * Set shift value.
     *
     * Index of the value taken from the indicator buffer.
     * Shift relative to the current bar the given amount of periods ago.
     */
    void SetShift(int _shift) {
      this.params.shift = _shift;
    }

};
