//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iMACD(string _symbol, int _tf, int _ema_fp, int _ema_sp, int _signal_period, int _ap, int _mode, int _shift) {
  return Indi_MACD::iMACD(_symbol, (ENUM_TIMEFRAMES)_tf, _ema_fp, _ema_sp, _signal_period, (ENUM_APPLIED_PRICE)_ap,
                          (ENUM_SIGNAL_LINE)_mode, _shift);
}
#endif

// Structs.
struct MACDParams : IndicatorParams {
  unsigned int ema_fast_period;
  unsigned int ema_slow_period;
  unsigned int signal_period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  void MACDParams(unsigned int _efp = 12, unsigned int _esp = 26, unsigned int _sp = 9,
                  ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0)
      : ema_fast_period(_efp), ema_slow_period(_esp), signal_period(_sp), applied_price(_ap) {
    itype = INDI_MACD;
    max_modes = FINAL_SIGNAL_LINE_ENTRY;
    shift = _shift;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_RANGE);
    SetCustomIndicatorName("Examples\\MACD");
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
  Indi_MACD(MACDParams &_p, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator((IndicatorParams)_p, _tf) { params = _p; }
  Indi_MACD(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_MACD, _tf) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/imacd
   * - https://www.mql5.com/en/docs/indicators/imacd
   */
  static double iMACD(
      string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _ema_fast_period, unsigned int _ema_slow_period,
      unsigned int _signal_period, ENUM_APPLIED_PRICE _applied_price,
      ENUM_SIGNAL_LINE _mode = LINE_MAIN,  // (MT4/MT5 _mode): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_SIGNAL/SIGNAL_LINE
      int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iMACD(_symbol, _tf, _ema_fast_period, _ema_slow_period, _signal_period, _applied_price, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iMACD(_symbol, _tf, _ema_fast_period, _ema_slow_period, _signal_period, _applied_price)) ==
          INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    if (Terminal::IsVisualMode()) {
      // To avoid error 4806 (ERR_INDICATOR_DATA_NOT_FOUND),
      // we check the number of calculated data only in visual mode.
      int _bars_calc = BarsCalculated(_handle);
      if (GetLastError() > 0) {
        return EMPTY_VALUE;
      } else if (_bars_calc <= 2) {
        SetUserError(ERR_USER_INVALID_BUFF_NUM);
        return EMPTY_VALUE;
      }
    }
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
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
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_MACD::iMACD(GetSymbol(), GetTf(), GetEmaFastPeriod(), GetEmaSlowPeriod(), GetSignalPeriod(),
                                  GetAppliedPrice(), _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.GetCustomIndicatorName(), /*[*/ GetEmaFastPeriod(),
                         GetEmaSlowPeriod(), GetSignalPeriod(), GetAppliedPrice() /*]*/, _mode, _shift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue((ENUM_SIGNAL_LINE)_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID,
                     !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE) && _entry.IsGt<double>(0));
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(params.GetDataValueType()));
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    GetEntry(_shift).values[_mode].Get(_param.double_value);
    return _param;
  }

  /* Getters */

  /**
   * Get fast EMA period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  unsigned int GetEmaFastPeriod() { return params.ema_fast_period; }

  /**
   * Get slow EMA period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  unsigned int GetEmaSlowPeriod() { return params.ema_slow_period; }

  /**
   * Get signal period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  unsigned int GetSignalPeriod() { return params.signal_period; }

  /**
   * Get applied price value.
   *
   * The desired price base for calculations.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

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
};
