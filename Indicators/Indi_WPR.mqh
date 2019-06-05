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
 * Implements the Larry Williams' Percent Range.
 */
class Indi_WPR : public Indicator {

  // Structs.
  struct WPR_Params {
    double foo;
  };

  // Struct variables.
  WPR_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_WPR(WPR_Params &_params) {
      this.params = _params;
    }

    /**
     * Calculates the Larry Williams' Percent Range and returns its value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iwpr
     * - https://www.mql5.com/en/docs/indicators/iwpr
     */
    static double iWPR(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iWPR(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iWPR(_symbol, _tf, _period);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iWPR(
        uint _period,
        int _shift = 0) {
      return  iWPR(GetSymbol(), GetTf(), _period, _shift);
    }

};
