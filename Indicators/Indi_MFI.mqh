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
 * Implements the Money Flow Index indicator.
 */
class Indi_MFI : public Indicator {

  // Structs.
  struct MFI_Params {
    double foo;
  };

  // Struct variables.
  MFI_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_MFI(MFI_Params &_params) {
      this.params = _params;
    }

    /**
     * Calculates the Money Flow Index indicator and returns its value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/imfi
     * - https://www.mql5.com/en/docs/indicators/imfi
     */
    static double iMFI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _period,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iMFI(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iMFI(_symbol, _tf, _period, VOLUME_TICK);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iMFI(
        int _period,
        int _shift = 0) {
      double _value = iMFI(GetSymbol(), GetTf(), _period, _shift);
      CheckLastError();
      return _value;
    }

};
