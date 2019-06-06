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

// Indicator line identifiers used in ADX indicator.
enum ENUM_ADX_LINE {
  LINE_MAIN_ADX = #ifdef __MQL4__ MODE_MAIN    #else MAIN_LINE    #endif, // Base indicator line.
  LINE_PLUSDI   = #ifdef __MQL4__ MODE_PLUSDI  #else PLUSDI_LINE  #endif, // +DI indicator line.
  LINE_MINUSDI  = #ifdef __MQL4__ MODE_MINUSDI #else MINUSDI_LINE #endif, // -DI indicator line.
  FINAL_ADX_LINE_ENTRY,
};

/**
 * Implements the Average Directional Movement Index indicator.
 */
class Indi_ADX : public Indicator {

  // Structs.
  struct ADX_Params {
    uint period;
    ENUM_APPLIED_PRICE applied_price;
    ENUM_ADX_LINE mode;
    uint shift;
  };

  // Struct variables.
  ADX_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_ADX(ADX_Params &_params) {
      this.params = _params;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iadx
     * - https://www.mql5.com/en/docs/indicators/iadx
     */
    static double iADX(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price, // (MT5): not used
        uint _mode,                        // (MT4/MT5): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_PLUSDI/PLUSDI_LINE, 2 - MODE_MINUSDI/MINUSDI_LINE
        uint _shift = 0                    // (MT5): not used
        ) {
      #ifdef __MQL4__
      return ::iADX(_symbol, _tf, _period, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iADX(_symbol, _tf, _period);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iADX(uint _period, ENUM_APPLIED_PRICE _applied_price, int _mode, int _shift = 0) {
      double _value = iADX(GetSymbol(), GetTf(), _period, _applied_price, _mode, _shift);
      CheckLastError();
      return _value;
    }
    double GetValue() {
      double _value = iADX(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), GetMode(), GetShift());
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

    /**
     * Get mode value.
     */
    ENUM_ADX_LINE GetMode() {
      return this.params.mode;
    }

    /**
     * Get shift value.
     *
     * Note: Not used in MT5.
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
     * Set applied price value.
     *
     * Note: Not used in MT5.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      this.params.applied_price = _applied_price;
    }

    /**
     * Set mode value.
     */
    void SetMode(ENUM_ADX_LINE _mode) {
      this.params.mode = _mode;
    }

    /**
     * Set shift value.
     *
     * Note: Not used in MT5.
     */
    void SetShift(int _shift) {
      this.params.shift = _shift;
    }

};
