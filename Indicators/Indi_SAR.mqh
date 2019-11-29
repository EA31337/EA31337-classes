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
struct SAR_Params {
  double step;
  double max;
  // Constructor.
  void SAR_Params(double _step = 0.02, double _max = 0.2)
    : step(_step), max(_max) {};
};

/**
 * Implements the Parabolic Stop and Reverse system indicator.
 */
class Indi_SAR : public Indicator {

public:

    SAR_Params params;

    /**
     * Class constructor.
     */
    Indi_SAR(SAR_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
      : params(_params.step, _params.max), Indicator(_iparams, _cparams) {};

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/isar
     * - https://www.mql5.com/en/docs/indicators/isar
     */
    static double iSAR(
      string _symbol = NULL,
      ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
      double _step = 0.02,
      double _max = 0.2,
      uint _shift = 0
      )
    {
      #ifdef __MQL4__
      return ::iSAR(_symbol ,_tf, _step, _max, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iSAR(_symbol , _tf, _step, _max);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(uint _shift = 0) {
      double _value = iSAR(GetSymbol(), GetTf(), GetStep(), GetMax(), _shift);
      CheckLastError();
      return _value;
    }

    /* Getters */

    /**
     * Get step of price increment.
     */
    double GetStep() {
      return this.params.step;
    }

    /**
     * Get the maximum step.
     */
    double GetMax() {
      return this.params.max;
    }

    /* Setters */

    /**
     * Set step of price increment (usually 0.02).
     */
    void SetStep(double _step) {
      this.params.step = _step;
    }

    /**
     * Set the maximum step (usually 0.2).
     */
    void SetMax(double _max) {
      this.params.max = _max;
    }

};
