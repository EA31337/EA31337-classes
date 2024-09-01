//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
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
struct IndiFractalsParams : IndicatorParams {
  // Struct constructors.
  IndiFractalsParams(int _shift = 0) : IndicatorParams(INDI_FRACTALS) {
    SetCustomIndicatorName("Examples\\Fractals");
    shift = _shift;
  };
  IndiFractalsParams(IndiFractalsParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Fractals indicator.
 */
class Indi_Fractals : public Indicator<IndiFractalsParams> {
 protected:
  /* Protected methods */

  /**
   * Initialize.
   */
  void Init() { Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), FINAL_LO_UP_LINE_ENTRY); }

 public:
  /**
   * Class constructor.
   */
  Indi_Fractals(IndiFractalsParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_LO_UP_LINE_ENTRY, TYPE_DOUBLE, _idstype,
                                                   IDATA_RANGE_PRICE_ON_SIGNAL, _indi_src_mode),
                  _indi_src) {
    Init();
  }
  Indi_Fractals(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                int _indi_src_mode = 0)
      : Indicator(IndiFractalsParams(),
                  IndicatorDataParams::GetInstance(FINAL_LO_UP_LINE_ENTRY, TYPE_DOUBLE, _idstype,
                                                   IDATA_RANGE_PRICE_ON_SIGNAL, _indi_src_mode),
                  _indi_src) {}

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

 public:
  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM; }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ifractals
   * - https://www.mql5.com/en/docs/indicators/ifractals
   */
  static double iFractals(string _symbol, ENUM_TIMEFRAMES _tf,
                          ENUM_LO_UP_LINE _mode,  // (MT4 _mode): 1 - MODE_UPPER, 2 - MODE_LOWER
                          int _shift = 0,         // (MT5 _mode): 0 - UPPER_LINE, 1 - LOWER_LINE
                          IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iFractals(_symbol, _tf, _mode, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iFractals(_symbol, _tf), _mode, _shift);
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
        _value =
            Indi_Fractals::iFractals(GetSymbol(), GetTf(), (ENUM_LO_UP_LINE)_mode, ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode,
                         ToRelShift(_abs_shift));
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Alters indicator's struct value.
   */
  void GetEntryAlter(IndicatorDataEntry &_entry, int _rel_shift) override {
    Indicator<IndiFractalsParams>::GetEntryAlter(_entry, _rel_shift);
#ifdef __MQL4__
    // In MT4 line identifiers starts from 1, so populating also at 0.
    _entry.values[0] = _entry.values[LINE_UPPER];
#endif
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    double _wrong_value = DBL_MAX;
#ifdef __MQL4__
    // In MT4, the empty value for iFractals is 0, not EMPTY_VALUE=DBL_MAX as in MT5.
    // So the wrong value is the opposite.
    _wrong_value = EMPTY_VALUE;
#endif
    return !_entry.HasValue(_wrong_value);
  }
};

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iFractals(string _symbol, int _tf, int _mode, int _shift) {
  ResetLastError();
  return Indi_Fractals::iFractals(_symbol, (ENUM_TIMEFRAMES)_tf, (ENUM_LO_UP_LINE)_mode, _shift);
}
#endif
