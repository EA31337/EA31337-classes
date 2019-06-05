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
class Indi_BWMFI : public Indicator {

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
    void Indi_BWMFI(IndicatorParams &_params, ENUM_TIMEFRAMES _tf = NULL, string _symbol = NULL) {
      this.params = _params;
    }
    void Indi_BWMFI()
    {
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ibwmfi
     * - https://www.mql5.com/en/docs/indicators/ibwmfi
     */
    static double iBWMFI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iBWMFI(_symbol, _tf, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iBWMFI(_symbol, _tf, VOLUME_TICK);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iBWMFI(int _shift = 0) {
      double _value = iBWMFI(GetSymbol(), GetTf(), _shift);
      CheckLastError();
      return _value;
    }

};
