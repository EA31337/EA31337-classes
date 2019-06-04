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
#include "Indicator.mqh"

/**
 * Class to deal with indicators.
 */
class Indi_ADX : public Indicator {

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
    void Indi_ADX(IndicatorParams &_params, ENUM_TIMEFRAMES _tf = NULL, string _symbol = NULL) {
      params = _params;
    }
    void Indi_ADX()
    {
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
        int _mode,                         // (MT4 _mode): 0 - MODE_MAIN, 1 - MODE_PLUSDI, 2 - MODE_MINUSDI
        int _shift = 0                     // (MT5 _mode): 0 - MAIN_LINE, 1 - PLUSDI_LINE, 2 - MINUSDI_LINE
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

};
