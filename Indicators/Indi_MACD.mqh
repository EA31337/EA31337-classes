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
 * Implements the Moving Averages Convergence/Divergence indicator.
 */
class Indi_MACD : public Indicator {

  // Structs.
  struct MACD_Params {
    uint ema_fast_period;
    uint ema_slow_period;
    uint signal_period;
    ENUM_APPLIED_PRICE applied_price;
    ENUM_SIGNAL_LINE mode;
    uint shift;
  };

  // Struct variables.
  MACD_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_MACD(MACD_Params &_params) {
      this.params = _params;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/imacd
     * - https://www.mql5.com/en/docs/indicators/imacd
     */
    static double iMACD(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _ema_fast_period,
        uint _ema_slow_period,
        uint _signal_period,
        ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _mode,                          // (MT4/MT5 _mode): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_SIGNAL/SIGNAL_LINE
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iMACD(_symbol, _tf, _ema_fast_period, _ema_slow_period, _signal_period, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iMACD(_symbol, _tf, _ema_fast_period, _ema_slow_period, _signal_period, _applied_price);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iMACD(int _mode, int _shift = 0) {
      double _value = iMACD(GetSymbol(), GetTf(), GetEmaFastPeriod(), GetEmaSlowPeriod(), GetSignalPeriod(), GetAppliedPrice(), _mode, _shift);
      CheckLastError();
      return _value;
    }
    double GetValue(int _mode, int _shift = 0) {
      double _value = iMACD(GetSymbol(), GetTf(), GetEmaFastPeriod(), GetEmaSlowPeriod(), GetSignalPeriod(), GetAppliedPrice(), GetMode(), GetShift());
      CheckLastError();
      return _value;
    }

    /* Getters */

    /**
     * Get fast EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    uint GetEmaFastPeriod() {
      return this.params.ema_fast_period;
    }

    /**
     * Get slow EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    uint GetEmaSlowPeriod() {
      return this.params.ema_slow_period;
    }

    /**
     * Get signal period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    uint GetSignalPeriod() {
      return this.params.signal_period;
    }

    /**
     * Get applied price value.
     *
     * The desired price base for calculations.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return this.params.applied_price;
    }

    /**
     * Get line index mode.
     */
    ENUM_SIGNAL_LINE GetMode() {
      return this.params.mode;
    }

    /**
     * Get shift value.
     *
     * Index of the value taken from the indicator buffer.
     * Shift relative to the current bar the given amount of periods ago.
     */
    uint GetShift() {
      return this.params.shift;
    }

    /* Setters */

    /**
     * Set fast EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetEmaFastPeriod(uint _ema_fast_period) {
      this.params.ema_fast_period = _ema_fast_period;
    }

    /**
     * Set slow EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetEmaSlowPeriod(uint _ema_slow_period) {
      this.params.ema_slow_period = _ema_slow_period;
    }

    /**
     * Set signal period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetSignalPeriod(uint _signal_period) {
      this.params.signal_period = _signal_period;
    }

    /**
     * Set applied price value.
     *
     * The desired price base for calculations.
     * @docs
     * - https://docs.mql4.com/constants/indicatorconstants/prices#enum_applied_price_enum
     * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      this.params.applied_price = _applied_price;
    }

    /**
     * Set line index mode.
     */
    void SetMode(ENUM_SIGNAL_LINE _mode) {
      this.params.mode = _mode;
    }

    /**
     * Set shift value.
     *
     * Index of the value taken from the indicator buffer.
     * Shift relative to the current bar the given amount of periods ago.
     */
    void SetShift(int _shift) {
      this.params.shift = _shift;
    }

};
