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
struct BullsPower_Params {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price; // (MT5): not used
  // Constructor.
  void BullsPower_Params(unsigned int _period, ENUM_APPLIED_PRICE _ap)
    : period(_period), applied_price(_ap) {}
};

/**
 * Implements the Bulls Power indicator.
 */
class Indi_BullsPower : public Indicator {

protected:

  // Struct variables.
  BullsPower_Params params;

  public:

    /**
     * Class constructor.
     */
    Indi_BullsPower(BullsPower_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
      : params(_params.period, _params.applied_price), Indicator(_iparams, _cparams) {};


    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ibullspower
     * - https://www.mql5.com/en/docs/indicators/ibullspower
     */
    static double iBullsPower(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      unsigned int _period,
      ENUM_APPLIED_PRICE _applied_price,
      int _shift = 0
      )
    {
      #ifdef __MQL4__
      return ::iBullsPower(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iBullsPower(_symbol, _tf, _period);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(int _shift = 0) {
      double _value = iBullsPower(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift);
      is_ready = _LastError == ERR_NO_ERROR;
      new_params = false;
      return _value;
    }

    /* Getters */

    /**
     * Get period value.
     */
    unsigned int GetPeriod() {
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
    void SetPeriod(unsigned int _period) {
      new_params = true;
      this.params.period = _period;
    }

    /**
     * Set applied price value.
     *
     * Note: Not used in MT5.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      new_params = true;
      this.params.applied_price = _applied_price;
    }

};
