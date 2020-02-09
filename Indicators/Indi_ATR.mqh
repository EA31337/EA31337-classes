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
struct ATR_Params {
  uint period;
  // Constructor
  void ATR_Params(uint _period)
   : period(_period) {};
};

/**
 * Implements the Average True Range indicator.
 */
class Indi_ATR : public Indicator {

public:

    ATR_Params params;

    /**
     * Class constructor.
     */
    Indi_ATR(ATR_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
      : params(_params.period), Indicator(_iparams, _cparams) {};

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iatr
     * - https://www.mql5.com/en/docs/indicators/iatr
     */
    static double iATR(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      uint _period,
      int _shift = 0
      )
    {
      #ifdef __MQL4__
      return ::iATR(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iATR(_symbol, _tf, _period);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(int _shift = 0) {
      double _value = iATR(GetSymbol(), GetTf(), GetPeriod(), _shift);
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

    /* Setters */

    /**
     * Set period value.
     */
    void SetPeriod(uint _period) {
      this.params.period = _period;
    }

};
