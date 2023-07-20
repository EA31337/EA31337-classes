//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

/**
 * @file
 * Force Index Indicator
 *
 * The Force Index indicator is an oscillator that measures the force behind a price movement.
 * It uses the following three market data options:
 * 1. Direction of price change.
 * 2. Magnitude of price change.
 * 3. Trading volume.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Indicator/Indicator.h"
#include "../Indicators/Price/Indi_MA.h"

// Structs.
struct IndiForceParams : IndicatorParams {
  unsigned int period;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  IndiForceParams(unsigned int _period = 13, ENUM_MA_METHOD _ma_method = MODE_SMA, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE,
                  int _shift = 0)
      : period(_period), ma_method(_ma_method), applied_price(_ap), IndicatorParams(INDI_FORCE) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\Force_Index");
  };
  IndiForceParams(IndiForceParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Force Index indicator.
 */
class Indi_Force : public Indicator<IndiForceParams> {
 protected:
 public:
  /**
   * Class constructor.
   */
  Indi_Force(IndiForceParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {}
  Indi_Force(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(IndiForceParams(),
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
   * - https://docs.mql4.com/indicators/iforce
   * - https://www.mql5.com/en/docs/indicators/iforce
   */
  static double iForce(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, ENUM_MA_METHOD _ma_method,
                       ENUM_APPLIED_PRICE _applied_price, int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iForce(_symbol, _tf, _period, _ma_method, _applied_price, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iForce(_symbol, _tf, _period, _ma_method, VOLUME_TICK), 0, _shift);
#endif
#else  // Non-MQL.
    // @todo: Use Platform class.
    RUNTIME_ERROR(
        "Not implemented. Please use an On-Indicator mode and attach "
        "indicator via Platform::Add/AddWithDefaultBindings().");
    return DBL_MAX;
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) {
    double _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_Force::iForce(GetSymbol(), GetTf(), GetPeriod(), GetMAMethod(), GetAppliedPrice(),
                                    ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod(),
                         GetMAMethod(), GetAppliedPrice(), VOLUME_TICK /*]*/, 0, ToRelShift(_abs_shift));
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get MA method.
   */
  ENUM_MA_METHOD GetMAMethod() { return iparams.ma_method; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set MA method.
   */
  void SetMAMethod(ENUM_MA_METHOD _ma_method) {
    istate.is_changed = true;
    iparams.ma_method = _ma_method;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iForce(string _symbol, int _tf, int _period, int _ma_method, int _ap, int _shift) {
  ResetLastError();
  return Indi_Force::iForce(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_MA_METHOD)_ma_method, (ENUM_APPLIED_PRICE)_ap,
                            _shift);
}
#endif
