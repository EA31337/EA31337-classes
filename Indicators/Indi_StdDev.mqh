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
 * Implements the Standard Deviation indicator.
 */
class Indi_StdDev : public Indicator {

  // Structs.
  struct StdDev_Params {
    double foo;
  };

  // Struct variables.
  StdDev_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_StdDev(StdDev_Params &_params) {
      this.params = _params;
    }

    /**
     * Calculates the Standard Deviation indicator and returns its value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/istddev
     * - https://www.mql5.com/en/docs/indicators/istddev
     */
    static double iStdDev (
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _ma_period,
        uint _ma_shift,
        ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iStdDev (
        uint _ma_period,
        uint _ma_shift,
        ENUM_MA_METHOD _ma_method,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
     double _value = iStdDev(GetSymbol(), GetTf(), _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
     CheckLastError();
     return _value;
    }

};
