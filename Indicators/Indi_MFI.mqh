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
double iMFI(string _symbol, int _tf, int _period, int _shift) {
  ResetLastError();
  return Indi_MFI::iMFI(_symbol, (ENUM_TIMEFRAMES)_tf, _period, _shift);
}
#endif

// Structs.
struct IndiMFIParams : IndicatorParams {
  unsigned int ma_period;
  ENUM_APPLIED_VOLUME applied_volume;  // Ignored in MT4.
  // Struct constructors.
  IndiMFIParams(unsigned int _ma_period = 14, ENUM_APPLIED_VOLUME _av = VOLUME_TICK, int _shift = 0)
      : ma_period(_ma_period), applied_volume(_av), IndicatorParams(INDI_MFI) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\MFI");
  };
  IndiMFIParams(IndiMFIParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Money Flow Index indicator.
 */
class Indi_MFI : public Indicator<IndiMFIParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_MFI(IndiMFIParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE, _indi_src_mode),
                  _indi_src) {}
  Indi_MFI(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(IndiMFIParams(),
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
   * Calculates the Money Flow Index indicator and returns its value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/imfi
   * - https://www.mql5.com/en/docs/indicators/imfi
   */
  static double iMFI(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, int _shift = 0,
                     IndicatorData *_obj = NULL) {
#ifdef __MQL4__
    return ::iMFI(_symbol, _tf, _period, _shift);
#else  // __MQL5__
    return Indi_MFI::iMFI(_symbol, _tf, _period, VOLUME_TICK, _shift, _obj);
#endif
  }
  static double iMFI(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period,
                     ENUM_APPLIED_VOLUME _applied_volume,  // Not used in MT4.
                     int _shift = 0, Indi_MFI *_obj = NULL) {
#ifdef __MQL4__
    return ::iMFI(_symbol, _tf, _period, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iMFI(_symbol, _tf, _period, VOLUME_TICK), 0, _shift);
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
#ifdef __MQL4__
        _value = Indi_MFI::iMFI(GetSymbol(), GetTf(), GetPeriod(), _ishift);
#else  // __MQL5__
        _value = Indi_MFI::iMFI(GetSymbol(), GetTf(), GetPeriod(), GetAppliedVolume(), _ishift, THIS_PTR);
#endif
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod(),
                         VOLUME_TICK /*]*/, 0, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period value.
   *
   * Period (amount of bars) for calculation of the indicator.
   */
  unsigned int GetPeriod() { return iparams.ma_period; }

  /**
   * Get applied volume type.
   *
   * Note: Ignored in MT4.
   */
  ENUM_APPLIED_VOLUME GetAppliedVolume() { return iparams.applied_volume; }

  /* Setters */

  /**
   * Set period value.
   *
   * Period (amount of bars) for calculation of the indicator.
   */
  void SetPeriod(unsigned int _ma_period) {
    istate.is_changed = true;
    iparams.ma_period = _ma_period;
  }

  /**
   * Set applied volume type.
   *
   * Note: Ignored in MT4.
   *
   * @docs
   * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_volume_enum
   */
  void SetAppliedVolume(ENUM_APPLIED_VOLUME _applied_volume) {
    istate.is_changed = true;
    iparams.applied_volume = _applied_volume;
  }
};
