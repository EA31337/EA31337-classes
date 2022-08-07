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
#include "Indi_MA.mqh"
#include "Indi_PriceFeeder.mqh"
#include "Price/Indi_Price.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iCCI(string _symbol, int _tf, int _period, int _ap, int _shift) {
  ResetLastError();
  return Indi_CCI::iCCI(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_APPLIED_PRICE)_ap, _shift);
}
double iCCIOnArray(double &_arr[], int _total, int _period, int _shift) {
  ResetLastError();
  return Indi_CCI::iCCIOnArray(_arr, _total, _period, _shift);
}
#endif

// Structs.
struct IndiCCIParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  IndiCCIParams(unsigned int _period = 14, ENUM_APPLIED_PRICE _applied_price = PRICE_OPEN, int _shift = 0)
      : period(_period), applied_price(_applied_price), IndicatorParams(INDI_CCI) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\CCI");
  };
  IndiCCIParams(IndiCCIParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Commodity Channel Index indicator.
 */
class Indi_CCI : public Indicator<IndiCCIParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_CCI(IndiCCIParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {}
  Indi_CCI(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(IndiCCIParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {}
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_AP | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override {
    return IDATA_BUILTIN | IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR;
  }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/icci
   * - https://www.mql5.com/en/docs/indicators/icci
   */
  static double iCCI(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, ENUM_APPLIED_PRICE _applied_price,
                     int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL4__
    return ::iCCI(_symbol, _tf, _period, _applied_price, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iCCI(_symbol, _tf, _period, _applied_price), 0, _shift);
#endif
  }

  static double iCCIOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period,
                                int _mode, int _shift = 0) {
    _indi.ValidateDataSourceMode(_mode);

    double _indi_value_buffer[];
    IndicatorDataEntry _entry(_indi.GetModeCount());

    ArrayResize(_indi_value_buffer, _period);

    for (int i = _shift; i < (int)_shift + (int)_period; i++) {
      // Getting value from single, selected buffer.
      _indi_value_buffer[i - _shift] = _indi[i].GetValue<double>(_mode);
    }

    double d;
    double d_mul = 0.015 / _period;

    double sp, d_buf, m_buf, cci;

    sp = Indi_MA::SimpleMA(0, _period, _indi_value_buffer);
    d = 0.0;

    for (int j = 0; j < (int)_period; ++j) {
      d += MathAbs(_indi_value_buffer[j] - sp);
    }

    d_buf = d * d_mul;
    m_buf = _indi_value_buffer[0] - sp;

    if (d_buf != 0.0)
      cci = m_buf / d_buf;
    else
      cci = 0.0;

    return cci;
  }

  /**
   * CCI on array.
   */
  static double iCCIOnArray(double &array[], int total, int period, int shift) {
#ifdef __MQL4__
    return ::iCCIOnArray(array, total, period, shift);
#else
    Indi_PriceFeeder indi_price_feeder(array);
    return iCCIOnIndicator(&indi_price_feeder, NULL, NULL, period, /*unused*/ PRICE_OPEN, shift);
#endif
  }

  /**
   * Returns the indicator's value.
   *
   * For IDATA_ICUSTOM mode, use those externs:
   *
   * extern unsigned int period;
   * extern ENUM_APPLIED_PRICE applied_price; // Required only for MQL4.
   *
   * Also, remember to use iparams.SetCustomIndicatorName(name) method to choose
   * indicator name, e.g.,: iparams.SetCustomIndicatorName("Examples\\CCI");
   *
   * Note that in MQL5 Applied Price must be passed as the last parameter
   * (before mode and shift).
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    double _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        // @fixit Somehow shift isn't used neither in MT4 nor MT5.
        _value = Indi_CCI::iCCI(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _ishift /* + iparams.shift*/,
                                THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        // @fixit Somehow shift isn't used neither in MT4 nor MT5.
        _value =
            Indi_CCI::iCCIOnIndicator(GetDataSource(), GetSymbol(), GetTf(), GetPeriod(), _ishift /* + iparams.shift*/);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.custom_indi_name, /* [ */ GetPeriod(),
                         GetAppliedPrice() /* ] */, 0, _ishift);
        break;
      case IDATA_INDICATOR:
        ValidateSelectedDataSource();

        // @fixit Somehow shift isn't used neither in MT4 nor MT5.
        _value =
            Indi_CCI::iCCIOnIndicator(GetDataSource(), GetSymbol(), GetTf(), GetPeriod(), _ishift /* + iparams.shift*/);
        break;
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return iparams.period; }

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
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};
