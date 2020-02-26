//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
struct MACDEntry : IndicatorEntry {
  double value[FINAL_SIGNAL_LINE_ENTRY];
  string ToString(int _mode = EMPTY) {
    return StringFormat("%g,%g",
      value[LINE_MAIN], value[LINE_SIGNAL]);
  }
  bool IsValid() {
    double _min_value = fmin(value[LINE_MAIN], value[LINE_SIGNAL]);
    double _max_value = fmax(value[LINE_MAIN], value[LINE_SIGNAL]);
    return _min_value > 0 && _max_value != EMPTY_VALUE;
  }
};
struct MACDParams : IndicatorParams {
  unsigned int ema_fast_period;
  unsigned int ema_slow_period;
  unsigned int signal_period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  void MACDParams(unsigned int _efp, unsigned int _esp, unsigned int _sp, ENUM_APPLIED_PRICE _ap)
    : ema_fast_period(_efp), ema_slow_period(_esp), signal_period(_sp), applied_price(_ap) {
    dtype = TYPE_DOUBLE;
    itype = INDI_MACD;
    max_modes = FINAL_SIGNAL_LINE_ENTRY;
  };
};

/**
 * Implements the Moving Averages Convergence/Divergence indicator.
 */
class Indi_MACD : public Indicator {

 protected:

  MACDParams params;

 public:

  /**
   * Class constructor.
   */
  Indi_MACD(MACDParams &_params)
    : params(_params.ema_fast_period, _params.ema_slow_period, _params.signal_period, _params.applied_price),
      Indicator((IndicatorParams) _params) { }
  Indi_MACD(MACDParams &_params, ENUM_TIMEFRAMES _tf)
    : params(_params.ema_fast_period, _params.ema_slow_period, _params.signal_period, _params.applied_price),
      Indicator(INDI_MACD, _tf) { }

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
    int _shift = 0,
    Indicator *_obj = NULL
  ) {
#ifdef __MQL4__
    return ::iMACD(_symbol, _tf, _ema_fast_period, _ema_slow_period, _signal_period, _applied_price, _mode, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
  double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iMACD(_symbol, _tf, _ema_fast_period, _ema_slow_period, _signal_period, _applied_price)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      }
      else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (GetLastError() > 0) {
      return EMPTY_VALUE;
    }
    else if (_bars_calc <= 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, _mode, -_shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
    }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_SIGNAL_LINE _mode = LINE_MAIN, int _shift = 0) {
    ResetLastError();
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
    double _value = Indi_MACD::iMACD(GetSymbol(), GetTf(), GetEmaFastPeriod(), GetEmaSlowPeriod(), GetSignalPeriod(), GetAppliedPrice(), _mode, _shift, GetPointer(this));
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  MACDEntry GetEntry(int _shift = 0) {
    MACDEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value[LINE_MAIN] = GetValue(LINE_MAIN, _shift);
    _entry.value[LINE_SIGNAL] = GetValue(LINE_SIGNAL, _shift);
    if (_entry.IsValid()) { _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID); }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value[_mode];
    return _param;
  }

    /* Getters */

    /**
     * Get fast EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    unsigned int GetEmaFastPeriod() {
      return params.ema_fast_period;
    }

    /**
     * Get slow EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    unsigned int GetEmaSlowPeriod() {
      return params.ema_slow_period;
    }

    /**
     * Get signal period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    unsigned int GetSignalPeriod() {
      return params.signal_period;
    }

    /**
     * Get applied price value.
     *
     * The desired price base for calculations.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return params.applied_price;
    }

    /* Setters */

    /**
     * Set fast EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetEmaFastPeriod(unsigned int _ema_fast_period) {
      istate.is_changed = true;
      params.ema_fast_period = _ema_fast_period;
    }

    /**
     * Set slow EMA period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetEmaSlowPeriod(unsigned int _ema_slow_period) {
      istate.is_changed = true;
      params.ema_slow_period = _ema_slow_period;
    }

    /**
     * Set signal period value.
     *
     * Averaging period for the calculation of the moving average.
     */
    void SetSignalPeriod(unsigned int _signal_period) {
      istate.is_changed = true;
      params.signal_period = _signal_period;
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
      istate.is_changed = true;
      params.applied_price = _applied_price;
    }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0, int _mode = EMPTY) {
    return GetEntry(_shift).ToString(_mode);
  }

};
