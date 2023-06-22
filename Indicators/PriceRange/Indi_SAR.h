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

// Includes.
#include "../../Indicator/Indicator.h"

// Structs.
struct IndiSARParams : IndicatorParams {
  double step;
  double max;
  // Struct constructors.
  IndiSARParams(double _step = 0.02, double _max = 0.2, int _shift = 0)
      : step(_step), max(_max), IndicatorParams(INDI_SAR) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\ParabolicSAR");
  };
  IndiSARParams(IndiSARParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Parabolic Stop and Reverse system indicator.
 */
class Indi_SAR : public Indicator<IndiSARParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_SAR(IndiSARParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {}
  Indi_SAR(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(IndiSARParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
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
   * - https://docs.mql4.com/indicators/isar
   * - https://www.mql5.com/en/docs/indicators/isar
   */
  static double iSAR(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, double _step = 0.02,
                     double _max = 0.2, int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iSAR(_symbol, _tf, _step, _max, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iSAR(_symbol, _tf, _step, _max), 0, _shift);
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
        _value = Indi_SAR::iSAR(GetSymbol(), GetTf(), GetStep(), GetMax(), ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetStep(),
                         GetMax() /*]*/, _mode, ToRelShift(_abs_shift));
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get step of price increment.
   */
  double GetStep() { return iparams.step; }

  /**
   * Get the maximum step.
   */
  double GetMax() { return iparams.max; }

  /* Setters */

  /**
   * Set step of price increment (usually 0.02).
   */
  void SetStep(double _step) {
    istate.is_changed = true;
    iparams.step = _step;
  }

  /**
   * Set the maximum step (usually 0.2).
   */
  void SetMax(double _max) {
    istate.is_changed = true;
    iparams.max = _max;
  }
};

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iSAR(string _symbol, int _tf, double _step, double _max, int _shift) {
  ResetLastError();
  return Indi_SAR::iSAR(_symbol, (ENUM_TIMEFRAMES)_tf, _step, _max, _shift);
}
#endif
