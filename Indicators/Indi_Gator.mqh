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
 * Implements the Gator oscillator.
 */
class Indi_Gator : public Indicator {

  // Structs.
  struct Gator_Params {
    double foo;
  };

  // Struct variables.
  Gator_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_Gator(Gator_Params &_params) {
      this.params = _params;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/igator
     * - https://www.mql5.com/en/docs/indicators/igator
     */
    static double iGator(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _jaw_period,
        uint _jaw_shift,
        uint _teeth_period,
        uint _teeth_shift,
        uint _lips_period,
        uint _lips_shift,
        ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _mode,                         // (MT4 _mode): 1 - MODE_UPPER,      2 - MODE_LOWER
        int _shift = 0                     // (MT5 _mode): 0 - UPPER_HISTOGRAM, 2 - LOWER_HISTOGRAM
        ) {
      #ifdef __MQL4__
      return ::iGator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iGator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iGator(
        uint _jaw_period,
        uint _jaw_shift,
        uint _teeth_period,
        uint _teeth_shift,
        uint _lips_period,
        uint _lips_shift,
        ENUM_MA_METHOD _ma_method,
        ENUM_APPLIED_PRICE _applied_price,
        int _mode,
        int _shift = 0) {
      double _value = iGator(GetSymbol(), GetTf(), _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price, _mode, _shift);
      CheckLastError();
      return _value;
    }

};
