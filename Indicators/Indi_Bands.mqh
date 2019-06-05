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
 * Class to deal with indicators.
 */
class Indi_Bands : public Indicator {

  // Structs.
  struct IndicatorParams {
    double foo;
  };

  // Struct variables.
  IndicatorParams params;

  public:

    /**
     * Class constructor.
     */
    void Indi_Bands(IndicatorParams &_params, ENUM_TIMEFRAMES _tf = NULL, string _symbol = NULL) {
      this.params = _params;
    }
    void Indi_Bands()
    {
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
        ENUM_APPLIED_PRICE _applied_price,   // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _mode,                           // (MT4 _mode): 0 - MODE_MAIN, 1 - MODE_UPPER, 2 - MODE_LOWER
        int _shift = 0                       // (MT5 _mode): 0 - BASE_LINE, 1 - UPPER_BAND, 2 - LOWER_BAND
        ) {
      #ifdef __MQL4__
      return ::iBands(_symbol, _tf, _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iBands(_symbol, _tf, _period, _bands_shift, _deviation, _applied_price);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iBands(uint _period, double _deviation, int _bands_shift, ENUM_APPLIED_PRICE _applied_price, int _mode, int _shift = 0) {
      double _value = iBands(GetSymbol(), GetTf(), _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
      CheckLastError();
      return _value;
    }

};
