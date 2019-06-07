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
 * Implements the Relative Vigor Index indicator.
 */
class Indi_RVI : public Indicator {

  // Structs.
  struct RVI_Params {
    uint period;
    uint shift;
  };

  // Struct variables.
  RVI_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_RVI(const RVI_Params &_params) {
      this.params = _params;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/irvi
     * - https://www.mql5.com/en/docs/indicators/irvi
     */
    static double iRVI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        int _mode,                     // (MT4/MT5): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_SIGNAL/SIGNAL_LINE
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iRVI(_symbol, _tf, _period, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = :: iRVI(_symbol, _tf, _period);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iRVI(ENUM_SIGNAL_LINE _mode, int _shift) {
      double _value = iRVI(GetSymbol(), GetTf(), GetPeriod(), _mode, _shift);
      CheckLastError();
      return _value;
    }
    double GetValue(ENUM_SIGNAL_LINE _mode) {
      double _value = iRVI(GetSymbol(), GetTf(), GetPeriod(), _mode, GetShift());
      CheckLastError();
      return _value;
    }

    /* Getters */

    /**
     * Get period value.
     */
    uint GetPeriod() {
      return this.params.period;
    }

    /**
     * Get shift value.
     */
    uint GetShift() {
      return this.params.shift;
    }

    /* Setters */

    /**
     * Set the averaging period for the RVI calculation.
     */
    void SetPeriod(uint _period) {
      this.params.period = _period;
    }

    /**
     * Set shift value.
     */
    void SetShift(int _shift) {
      this.params.shift = _shift;
    }

};
