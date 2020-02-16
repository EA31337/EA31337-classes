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
struct MACD_Params {
  unsigned int ema_fast_period;
  unsigned int ema_slow_period;
  unsigned int signal_period;
  ENUM_APPLIED_PRICE applied_price;
  // Constructor.
  void MACD_Params(unsigned int _efp, unsigned int _esp, unsigned int _sp, ENUM_APPLIED_PRICE _ap)
    : ema_fast_period(_efp), ema_slow_period(_esp), signal_period(_sp), applied_price(_ap) {};
};

/**
 * Implements the Moving Averages Convergence/Divergence indicator.
 */
class Indi_MACD : public Indicator {

public:

    MACD_Params params;

    /**
     * Class constructor.
     */
    Indi_MACD(MACD_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
      : params(_params.ema_fast_period, _params.ema_slow_period, _params.signal_period, _params.applied_price),
        Indicator(_iparams, _cparams) {};

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
      unsigned int _ema_fast_period,
      unsigned int _ema_slow_period,
      unsigned int _signal_period,
      ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
      ENUM_SIGNAL_LINE _mode = LINE_MAIN, // (MT4/MT5 _mode): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_SIGNAL/SIGNAL_LINE
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
  double GetValue(ENUM_SIGNAL_LINE _mode = LINE_MAIN, int _shift = 0) {
    double _value = iMACD(GetSymbol(), GetTf(), GetEmaFastPeriod(), GetEmaSlowPeriod(), GetSignalPeriod(), GetAppliedPrice(), _mode, _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

    /* Getters */

    /**
     * Get fast EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    unsigned int GetEmaFastPeriod() {
      return this.params.ema_fast_period;
    }

    /**
     * Get slow EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    unsigned int GetEmaSlowPeriod() {
      return this.params.ema_slow_period;
    }

    /**
     * Get signal period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    unsigned int GetSignalPeriod() {
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

    /* Setters */

    /**
     * Set fast EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetEmaFastPeriod(unsigned int _ema_fast_period) {
      new_params = true;
      this.params.ema_fast_period = _ema_fast_period;
    }

    /**
     * Set slow EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetEmaSlowPeriod(unsigned int _ema_slow_period) {
      new_params = true;
      this.params.ema_slow_period = _ema_slow_period;
    }

    /**
     * Set signal period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetSignalPeriod(unsigned int _signal_period) {
      new_params = true;
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
      new_params = true;
      this.params.applied_price = _applied_price;
    }

};
