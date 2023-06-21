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

/*
 * @file
 * Momentum oscillator.
 *
 * It helps identify the strength behind price movement.
 * We can also use to identify when a market is likely to continue in the direction of the main trend.
 * In addition, it can help to identify when the price action is losing steam to prepare for a potential trend reversal.
 */

// Includes.
#include "../Indicator/Indicator.h"
#include "Indi_PriceFeeder.mqh"

#ifndef __MQL4__
// Forward declaration.
class Indi_Momentum;

// Defines global functions (for MQL4 backward compability).
double iMomentum(string _symbol, int _tf, int _period, int _ap, int _shift) {
  ResetLastError();
  return Indi_Momentum::iMomentum(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_APPLIED_PRICE)_ap, _shift);
}
#endif

// Structs.
struct IndiMomentumParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  IndiMomentumParams(unsigned int _period = 12, ENUM_APPLIED_PRICE _ap = PRICE_OPEN, int _shift = 0)
      : period(_period), applied_price(_ap), IndicatorParams(INDI_MOMENTUM) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\Momentum");
  };
  IndiMomentumParams(IndiMomentumParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Momentum indicator.
 */
class Indi_Momentum : public Indicator<IndiMomentumParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Momentum(IndiMomentumParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {}
  Indi_Momentum(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                int _indi_src_mode = 0)
      : Indicator(IndiMomentumParams(),
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
   * - https://docs.mql4.com/indicators/imomentum
   * - https://www.mql5.com/en/docs/indicators/imomentum
   */
  static double iMomentum(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, ENUM_APPLIED_PRICE _ap,
                          int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iMomentum(_symbol, _tf, _period, _ap, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iMomentum(_symbol, _tf, _period, _ap), 0, _shift);
#endif
#else  // Non-MQL.
    // @todo: Use Platform class.
    RUNTIME_ERROR(
        "Not implemented. Please use an On-Indicator mode and attach "
        "indicator via Platform::Add/AddWithDefaultBindings().");
    return DBL_MAX;
#endif
  }

  static double iMomentumOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period,
                                     int _mode, int _shift = 0) {
    INDI_REQUIRE_BARS_OR_RETURN_EMPTY(_indi, _period);

    double _indi_value_buffer[];
    IndicatorDataEntry _entry(_indi.GetModeCount());

    ArrayResize(_indi_value_buffer, _period);

    for (int i = 0; i < (int)_period; i++) {
      // Getting value from single, selected buffer.
      _indi_value_buffer[i] = _indi[i].GetValue<double>(_mode);
    }

    double _last_value = _indi_value_buffer[_period - 1];
    double momentum = _last_value != 0.0 ? (_indi_value_buffer[0] / _last_value) * 100 : 0.0;

    return momentum;
  }

  static double iMomentumOnArray(double &array[], int total, int period, int shift) {
#ifdef __MQL4__
    return ::iMomentumOnArray(array, total, period, shift);
#else
    Indi_PriceFeeder indi_price_feeder(array);
    return iMomentumOnIndicator(&indi_price_feeder, NULL, NULL, period, /*unused*/ PRICE_OPEN, shift);
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) {
    double _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        // @fixit Somehow shift isn't used neither in MT4 nor MT5.
        _value = Indi_Momentum::iMomentum(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(),
                                          iparams.shift + ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        // @fixit Somehow shift isn't used neither in MT4 nor MT5.
        _value = Indi_Momentum::iMomentumOnIndicator(GetDataSource(), GetSymbol(), GetTf(), GetPeriod(),
                                                     iparams.shift + ToRelShift(_abs_shift));
        if (idparams.IsPloting()) {
          // draw.DrawLineTo(StringFormat("%s", GetName()), GetBarTime(iparams.shift + ToRelShift(_abs_shift)), _value,
          // 1);
        }
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         0, ToRelShift(_abs_shift));
        break;
      case IDATA_INDICATOR:
        ValidateSelectedDataSource();

        // @fixit Somehow shift isn't used neither in MT4 nor MT5.
        _value = Indi_Momentum::iMomentumOnIndicator(GetDataSource(), GetSymbol(), GetTf(), GetPeriod(),
                                                     iparams.shift + ToRelShift(_abs_shift));
        if (idparams.IsPloting()) {
          // draw.DrawLineTo(StringFormat("%s", GetName()), GetBarTime(iparams.shift + ToRelShift(_abs_shift)), _value,
          // 1);
        }
        break;
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period value.
   *
   * Averaging period (bars count) for the calculation of the price change.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get applied price value.
   *
   * The desired price base for calculations.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /* Setters */

  /**
   * Set period value.
   *
   * Averaging period (bars count) for the calculation of the price change.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set applied price value.
   *
   * The desired price base for calculations.
   * @docs
   * - https://docs.mql4.com/constants/indicatorconstants/prices#enum_applied_price_enum
   * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _ap) {
    istate.is_changed = true;
    iparams.applied_price = _ap;
  }
};
