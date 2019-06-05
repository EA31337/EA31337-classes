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
 * Implements ZigZag indicator.
 */
class Indi_ZigZag : public Indicator {

  // Structs.
  struct ZigZag_Params {
    double foo;
  };

  // Struct variables.
  ZigZag_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_ZigZag(ZigZag_Params &_params) {
      this.params = _params;
    }

    /**
     * Returns value for ZigZag indicator.
     */
    static double iZigZag(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      int _depth,
      int _deviation,
      int _backstep,
      int _shift = 0
      ) {
      #ifdef __MQL4__
      return ::iCustom(_symbol, _tf, "ZigZag", _depth, _deviation, _backstep, 0, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iCustom(_symbol, _tf, "Examples\\ZigZag", _depth, _deviation, _backstep);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iZigZag(int _depth, int _deviation, int _backstep, int _shift = 0) {
      double _value = iZigZag(GetSymbol(), GetTf(), _depth, _deviation, _backstep, _shift);
      CheckLastError();
      return _value;
    }

};
