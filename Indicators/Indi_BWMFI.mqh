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

// Enumerations.
// Indicator line identifiers used in BWMFI indicators.
enum ENUM_BWMFI_BUFFER { BWMFI_BUFFER = 0, BWMFI_HISTCOLOR = 1, FINAL_BWMFI_BUFFER_ENTRY };
// Defines four possible groupings of MFI and volume were termed by Williams.
// @see: https://en.wikipedia.org/wiki/Market_facilitation_index
enum ENUM_MFI_COLOR {
  MFI_HISTCOLOR_GREEN = 0,
  MFI_HISTCOLOR_SQUAT = 1,
  MFI_HISTCOLOR_FAKE = 2,
  MFI_HISTCOLOR_FADE = 3,
  FINAL_MFI_COLOR_ENTRY
};

// Structs.
struct IndiBWIndiMFIParams : IndicatorParams {
  ENUM_APPLIED_VOLUME ap;  // @todo
  // Struct constructors.
  IndiBWIndiMFIParams(int _shift = 0) : IndicatorParams(INDI_BWMFI) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\MarketFacilitationIndex");
  };
  IndiBWIndiMFIParams(IndiBWIndiMFIParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Market Facilitation Index by Bill Williams indicator.
 */
class Indi_BWMFI : public Indicator<IndiBWIndiMFIParams> {
 protected:
  /* Protected methods */

  /**
   * Initialize.
   */
  void Init() { Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), FINAL_BWMFI_BUFFER_ENTRY); }

 public:
  /**
   * Class constructor.
   */
  Indi_BWMFI(IndiBWIndiMFIParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_BWMFI_BUFFER_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED,
                                                   _indi_src_mode),
                  _indi_src) {
    Init();
  }
  Indi_BWMFI(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(IndiBWIndiMFIParams(),
                  IndicatorDataParams::GetInstance(FINAL_BWMFI_BUFFER_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED,
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
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ibwmfi
   * - https://www.mql5.com/en/docs/indicators/ibwmfi
   */
  static double iBWMFI(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                       ENUM_BWMFI_BUFFER _mode = BWMFI_BUFFER, IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iBWMFI(_symbol, _tf, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iBWMFI(_symbol, _tf, VOLUME_TICK), _mode, _shift);
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = BWMFI_BUFFER, int _abs_shift = 0) {
    double _value = EMPTY_VALUE;

    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_BWMFI::iBWMFI(GetSymbol(), GetTf(), ToRelShift(_abs_shift), (ENUM_BWMFI_BUFFER)_mode, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ VOLUME_TICK /*]*/,
                         _mode, ToRelShift(_abs_shift));
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }

  /**
   * Alters indicator's struct value.
   */
  void GetEntryAlter(IndicatorDataEntry &_entry, int _rel_shift) override {
    Indicator<IndiBWIndiMFIParams>::GetEntryAlter(_entry, _rel_shift);
#ifdef __MQL4__
    Print(GetVolume(_rel_shift), ", ", GetVolume(_rel_shift + 1), " | ", GetValue<double>(BWMFI_BUFFER, _rel_shift),
          " > ", GetValue<double>(BWMFI_BUFFER, _rel_shift + 1));
    // @see: https://en.wikipedia.org/wiki/Market_facilitation_index
    bool _vol_up = GetVolume(_rel_shift) > GetVolume(_rel_shift + 1);
    bool _val_up = GetValue<double>(BWMFI_BUFFER, _rel_shift) > GetValue<double>(BWMFI_BUFFER, _rel_shift + 1);
    double _histcolor = EMPTY_VALUE;
    switch (_vol_up) {
      case true:
        switch (_val_up) {
          case true:
            // Green = Volume(+) Index (+).
            _histcolor = MFI_HISTCOLOR_GREEN;
            break;
          case false:
            // Squat (Brown) = Volume(+) Index (-).
            _histcolor = MFI_HISTCOLOR_SQUAT;
            break;
        }
        break;
      case false:
        switch (_val_up) {
          case true:
            // Fale (Pink) = Volume(-) Index (+).
            _histcolor = MFI_HISTCOLOR_FAKE;
            break;
          case false:
            // Fade (Blue) = Volume(-) Index (-).
            _histcolor = MFI_HISTCOLOR_FADE;
            break;
        }
        break;
    }
    _entry.values[BWMFI_HISTCOLOR] = _histcolor;
#endif
  }

  /**
   * Checks if indicator entry is valid.
   *
   * @return
   *   Returns true if entry is valid (has valid values), otherwise false.
   */
  bool IsValidEntry(IndicatorDataEntry &_entry) override {
    return _entry.GetValue<double>((int)BWMFI_BUFFER) > 0 && _entry.GetValue<double>((int)BWMFI_HISTCOLOR) >= 0 &&
           !_entry.HasValue<double>(DBL_MAX);
  }
};

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iBWMFI(string _symbol, int _tf, int _shift) {
  ResetLastError();
  return Indi_BWMFI::iBWMFI(_symbol, (ENUM_TIMEFRAMES)_tf, _shift);
}
#endif
