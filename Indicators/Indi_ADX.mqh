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
#include "../Indicator/Indicator.h"
#include "Price/Indi_Price.h"

// Structs.
struct IndiADXParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  IndiADXParams(unsigned int _period = 14, ENUM_APPLIED_PRICE _ap = PRICE_TYPICAL, int _shift = 0)
      : period(_period), applied_price(_ap), IndicatorParams(INDI_ADX) {
    SetShift(_shift);
    if (custom_indi_name == "") {
      SetCustomIndicatorName("Examples\\ADX");
    }
  };
};

/**
 * Implements the Average Directional Movement Index indicator.
 */
class Indi_ADX : public Indicator<IndiADXParams> {
 protected:
  /* Protected methods */

  void Init() {}

 public:
  /**
   * Class constructor.
   */
  Indi_ADX(IndiADXParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_INDI_ADX_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE,
                                                   _indi_src_mode),
                  _indi_src) {
    Init();
  }

  Indi_ADX(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(IndiADXParams(),
                  IndicatorDataParams::GetInstance(FINAL_INDI_ADX_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE,
                                                   _indi_src_mode),
                  _indi_src) {
    Init();
  }
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM; }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return Indicator<IndiADXParams>::IsValidEntry(_entry) && _entry.IsWithinRange(0.0, 100.0);
  }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/iadx
   * - https://www.mql5.com/en/docs/indicators/iadx
   */
  static double iADX(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period,
                     ENUM_APPLIED_PRICE _applied_price,  // (MT5): not used
                     int _mode = LINE_MAIN_ADX,          // (MT4/MT5): 0 - MODE_MAIN/MAIN_LINE, 1 -
                                                         // MODE_PLUSDI/PLUSDI_LINE, 2 - MODE_MINUSDI/MINUSDI_LINE
                     int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iADX(_symbol, _tf, _period, _applied_price, _mode, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iADX(_symbol, _tf, _period), _mode, _shift);
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = LINE_MAIN_ADX, int _abs_shift = 0) {
    double _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_ADX::iADX(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _mode, ToRelShift(_abs_shift),
                                THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         _mode, ToRelShift(_abs_shift));
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
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
   *
   * Note: Not used in MT5.
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
   *
   * Note: Not used in MT5.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iADX(string _symbol, int _tf, int _period, int _ap, int _mode, int _shift) {
  ResetLastError();
  return Indi_ADX::iADX(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_APPLIED_PRICE)_ap, (ENUM_INDI_ADX_LINE)_mode,
                        _shift);
}
#endif
