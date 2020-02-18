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

// Indicator line identifiers used in ADX indicator.
enum ENUM_ADX_LINE {
#ifdef __MQL4__
  LINE_MAIN_ADX =  MODE_MAIN,   // Base indicator line.
  LINE_PLUSDI   = MODE_PLUSDI,  // +DI indicator line.
  LINE_MINUSDI  = MODE_MINUSDI, // -DI indicator line.
#else
  LINE_MAIN_ADX = MAIN_LINE,    // Base indicator line.
  LINE_PLUSDI   = PLUSDI_LINE,  // +DI indicator line.
  LINE_MINUSDI  = MINUSDI_LINE, // -DI indicator line.
#endif
  FINAL_ADX_LINE_ENTRY,
};

// Structs.   
struct ADX_Params {
 unsigned int period;
 ENUM_APPLIED_PRICE applied_price;
 // Constructor.
 void ADX_Params(unsigned int _period, ENUM_APPLIED_PRICE _applied_price)
   : period(_period), applied_price(_applied_price) {};
};

/**
 * Implements the Average Directional Movement Index indicator.
 */
class Indi_ADX : public Indicator {

 public:

  ADX_Params params;

  /**
   * Class constructor.
   */
  Indi_ADX(ADX_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.period, _params.applied_price), Indicator(_iparams, _cparams) {};
  Indi_ADX(ADX_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.period, _params.applied_price), Indicator(INDI_ADX, _tf) {};

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
        unsigned int _period,
        ENUM_APPLIED_PRICE _applied_price,   // (MT5): not used
        ENUM_ADX_LINE _mode = LINE_MAIN_ADX, // (MT4/MT5): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_PLUSDI/PLUSDI_LINE, 2 - MODE_MINUSDI/MINUSDI_LINE
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iADX(_symbol, _tf, _period, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iADX(_symbol, _tf, _period);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(ENUM_ADX_LINE _mode = LINE_MAIN_ADX, int _shift = 0) {
      double _value = iADX(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _mode, _shift);
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
