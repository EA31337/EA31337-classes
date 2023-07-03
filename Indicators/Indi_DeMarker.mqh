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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Indicator/Indicator.h"

// Structs.
struct IndiDeMarkerParams : IndicatorParams {
  unsigned int period;
  // Struct constructors.
  IndiDeMarkerParams(unsigned int _period = 14, int _shift = 0) : period(_period), IndicatorParams(INDI_DEMARKER) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\DeMarker");
  };
  IndiDeMarkerParams(IndiDeMarkerParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the DeMarker indicator.
 */
class Indi_DeMarker : public Indicator<IndiDeMarkerParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_DeMarker(IndiDeMarkerParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE, _indi_src_mode),
                  _indi_src) {}
  Indi_DeMarker(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                int _indi_src_mode = 0)
      : Indicator(IndiDeMarkerParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE, _indi_src_mode),
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
   * - https://docs.mql4.com/indicators/idemarker
   * - https://www.mql5.com/en/docs/indicators/idemarker
   */
  static double iDeMarker(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, int _shift = 0,
                          IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iDeMarker(_symbol, _tf, _period, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iDeMarker(_symbol, _tf, _period), 0, _shift);
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
        _value = _value = Indi_DeMarker::iDeMarker(GetSymbol(), GetTf(), GetPeriod(), ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         0, ToRelShift(_abs_shift));
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

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }
};

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iDeMarker(string _symbol, int _tf, int _period, int _shift) {
  ResetLastError();
  return Indi_DeMarker::iDeMarker(_symbol, (ENUM_TIMEFRAMES)_tf, _period, _shift);
}
#endif
