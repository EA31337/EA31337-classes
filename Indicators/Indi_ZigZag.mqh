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

// Includes.
#include "../Indicator.mqh"

// Structs.
struct ZigZag_Params {
  int depth;
  int deviation;
  int backstep;
  // Constructor.
  void ZigZag_Params(int _depth, int _deviation, int _backstep)
    : depth(_depth), deviation(_deviation), backstep(_backstep) {};
};

/**
 * Implements ZigZag indicator.
 */
class Indi_ZigZag : public Indicator {

public:

    ZigZag_Params params;

    /**
     * Class constructor.
     */
    Indi_ZigZag(ZigZag_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
      : params(_params.depth, _params.deviation, _params.backstep),
        Indicator(_iparams, _cparams) {};

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
      )
    {
      #ifdef __MQL4__
      return ::iCustom(_symbol, _tf, "ZigZag", _depth, _deviation, _backstep, 0, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iCustom(_symbol, _tf, "Examples\\ZigZag", _depth, _deviation, _backstep);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(int _shift = 0) {
      double _value = iZigZag(GetSymbol(), GetTf(), GetDepth(), GetDeviation(), GetBackstep(), _shift);
      CheckLastError();
      return _value;
    }

    /* Getters */

    /**
     * Get depth.
     */
    int GetDepth() {
      return this.params.depth;
    }

    /**
     * Get deviation.
     */
    int GetDeviation() {
      return this.params.deviation;
    }

    /**
     * Get backstep.
     */
    int GetBackstep() {
      return this.params.backstep;
    }

    /* Setters */

    /**
     * Set depth.
     */
    void SetDepth(int _depth) {
      this.params.depth = _depth;
    }

    /**
     * Set deviation.
     */
    void SetDeviation(int _deviation) {
      this.params.deviation = _deviation;
    }

    /**
     * Set backstep.
     */
    void SetBackstep(int _backstep) {
      this.params.backstep = _backstep;
    }

};
