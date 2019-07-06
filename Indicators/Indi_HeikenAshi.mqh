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

enum ENUM_HA_MODE {
#ifdef __MQL4__
  HA_LOW   = 0,
  HA_HIGH  = 1,
  HA_OPEN  = 2,
  HA_CLOSE = 3
#else
  HA_OPEN  = 0,
  HA_HIGH  = 1,
  HA_LOW   = 2,
  HA_CLOSE = 3
#endif
};

/**
 * Implements the Heiken-Ashi indicator.
 */
class Indi_HeikenAshi : public Indicator {

  public:

    /**
     * Class constructor.
     */
    void Indi_HeikenAshi(IndicatorParams &_iparams, Chart *_chart = NULL)
      : Indicator(_iparams, _chart) {};

    /**
     * Returns value for iHeikenAshi indicator.
     */
    static double iHeikenAshi(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      ENUM_HA_MODE _mode,
      int _shift = 0
      ) {
      #ifdef __MQL4__
      return ::iCustom(_symbol, _tf, "Heiken Ashi", _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iCustom(_symbol, _tf, "Examples\\Heiken_Ashi");
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(ENUM_HA_MODE _mode, uint _shift = 0) {
     double _value = this.iHeikenAshi(GetSymbol(), GetTf(), _mode, _shift);
     CheckLastError();
     return _value;
    }

};
