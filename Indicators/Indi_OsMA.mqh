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
#include "../Indicator/Indicator.h"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iOsMA(string _symbol, int _tf, int _ema_fp, int _ema_sp, int _signal_period, int _ap, int _shift) {
  ResetLastError();
  return Indi_OsMA::iOsMA(_symbol, (ENUM_TIMEFRAMES)_tf, _ema_fp, _ema_sp, _signal_period, (ENUM_APPLIED_PRICE)_ap,
                          _shift);
}
#endif

// Structs.
struct IndiOsMAParams : IndicatorParams {
  int ema_fast_period;
  int ema_slow_period;
  int signal_period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  IndiOsMAParams(int _efp = 12, int _esp = 26, int _sp = 9, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0)
      : ema_fast_period(_efp),
        ema_slow_period(_esp),
        signal_period(_sp),
        applied_price(_ap),
        IndicatorParams(INDI_OSMA) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\OsMA");
  };
  IndiOsMAParams(IndiOsMAParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Moving Average of Oscillator indicator.
 */
class Indi_OsMA : public Indicator<IndiOsMAParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_OsMA(IndiOsMAParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {}
  Indi_OsMA(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(IndiOsMAParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {}
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM; }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/iosma
   * - https://www.mql5.com/en/docs/indicators/iosma
   */
  static double iOsMA(string _symbol, ENUM_TIMEFRAMES _tf, int _ema_fast_period, int _ema_slow_period,
                      int _signal_period, ENUM_APPLIED_PRICE _applied_price, int _shift = 0,
                      IndicatorData *_obj = NULL) {
#ifdef __MQL4__
    return ::iOsMA(_symbol, _tf, _ema_fast_period, _ema_slow_period, _signal_period, _applied_price, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iOsMA(_symbol, _tf, _ema_fast_period, _ema_slow_period, _signal_period, _applied_price)) ==
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
    if (CopyBuffer(_handle, 0, _shift, 1, _res) < 0) {
      return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    double _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_OsMA::iOsMA(GetSymbol(), GetTf(), GetEmaFastPeriod(), GetEmaSlowPeriod(), GetSignalPeriod(),
                                  GetAppliedPrice(), _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value =
            iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetEmaFastPeriod(),
                    GetEmaSlowPeriod(), GetSignalPeriod(), GetAppliedPrice() /*]*/, 0, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get fast EMA period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  int GetEmaFastPeriod() { return iparams.ema_fast_period; }

  /**
   * Get slow EMA period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  int GetEmaSlowPeriod() { return iparams.ema_slow_period; }

  /**
   * Get signal period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  int GetSignalPeriod() { return iparams.signal_period; }

  /**
   * Get applied price value.
   *
   * The desired price base for calculations.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /* Setters */

  /**
   * Set fast EMA period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  void SetEmaFastPeriod(int _ema_fast_period) {
    istate.is_changed = true;
    iparams.ema_fast_period = _ema_fast_period;
  }

  /**
   * Set slow EMA period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  void SetEmaSlowPeriod(int _ema_slow_period) {
    istate.is_changed = true;
    iparams.ema_slow_period = _ema_slow_period;
  }

  /**
   * Set signal period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  void SetSignalPeriod(int _signal_period) {
    istate.is_changed = true;
    iparams.signal_period = _signal_period;
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
    iparams.applied_price = _applied_price;
  }
};
