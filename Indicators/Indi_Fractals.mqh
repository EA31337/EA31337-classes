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
 * Implements the Fractals indicator.
 */
class Indi_Fractals : public Indicator {

  public:

    /**
     * Class constructor.
     */
    void Indi_Fractals(IndicatorParams &_iparams, ChartParams &_cparams)
      : Indicator(_iparams, _cparams) {};

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ifractals
     * - https://www.mql5.com/en/docs/indicators/ifractals
     */
    static double iFractals(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        ENUM_LO_UP_LINE _mode,     // (MT4 _mode): 1 - MODE_UPPER, 2 - MODE_LOWER
        int _shift = 0             // (MT5 _mode): 0 - UPPER_LINE, 1 - LOWER_LINE
        ) {
      #ifdef __MQL4__
      return ::iFractals(_symbol, _tf, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iFractals(_symbol, _tf);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(ENUM_LO_UP_LINE _mode, uint _shift = 0) {
      double _value = this.iFractals(GetSymbol(), GetTf(), _mode, _shift);
      CheckLastError();
      return _value;
    }

};
