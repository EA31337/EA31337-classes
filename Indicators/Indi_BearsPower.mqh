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
struct BearsPower_Params {
  uint period;
  ENUM_APPLIED_PRICE applied_price; // (MT5): not used
  // Constructor.
  void BearsPower_Params(uint _period, ENUM_APPLIED_PRICE _ap)
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
    void Indi_BearsPower(BearsPower_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
      : params(_params.period, _params.applied_price), Indicator(_iparams, _cparams) {};

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
      uint _period,
      ENUM_APPLIED_PRICE _applied_price, // (MT5): not used
      int _shift = 0
      )
    {
      #ifdef __MQL4__
      return ::iBearsPower(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iBearsPower(_symbol, _tf, _period);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(uint _shift = 0) {
      double _value = iBearsPower(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift);
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
     *
     * Note: Not used in MT5.
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
     *
     * Note: Not used in MT5.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      this.params.applied_price = _applied_price;
    }

};
