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
#include "../Indicator.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iBWMFI(string _symbol, int _tf, int _shift) {
  ResetLastError();
  return Indi_BWMFI::iBWMFI(_symbol, (ENUM_TIMEFRAMES)_tf, _shift);
}
#endif

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
  IndiBWIndiMFIParams(int _shift = 0) : IndicatorParams(INDI_BWMFI, FINAL_BWMFI_BUFFER_ENTRY, TYPE_DOUBLE) {
    SetDataValueRange(IDATA_RANGE_MIXED);
    shift = _shift;
    SetCustomIndicatorName("Examples\\MarketFacilitationIndex");
  };
  IndiBWIndiMFIParams(IndiBWIndiMFIParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Market Facilitation Index by Bill Williams indicator.
 */
class Indi_BWMFI : public Indicator<IndiBWIndiMFIParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_BWMFI(IndiBWIndiMFIParams &_p, IndicatorBase *_indi_src = NULL)
      : Indicator<IndiBWIndiMFIParams>(_p, _indi_src) {}
  Indi_BWMFI(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_BWMFI, _tf, _shift) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ibwmfi
   * - https://www.mql5.com/en/docs/indicators/ibwmfi
   */
  static double iBWMFI(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                       ENUM_BWMFI_BUFFER _mode = BWMFI_BUFFER, IndicatorBase *_obj = NULL) {
#ifdef __MQL4__
    return ::iBWMFI(_symbol, _tf, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iBWMFI(_symbol, _tf, VOLUME_TICK)) == INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = BWMFI_BUFFER, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_BWMFI::iBWMFI(GetSymbol(), GetTf(), _ishift, (ENUM_BWMFI_BUFFER)_mode, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ VOLUME_TICK /*]*/,
                         _mode, _ishift);
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
  virtual void GetEntryAlter(IndicatorDataEntry &_entry, int _shift = -1) {
    Indicator<IndiBWIndiMFIParams>::GetEntryAlter(_entry);
#ifdef __MQL4__
    // @see: https://en.wikipedia.org/wiki/Market_facilitation_index
    bool _vol_up = GetVolume(_shift) > GetVolume(_shift);
    bool _val_up = GetValue<double>(BWMFI_BUFFER, _shift) > GetValue<double>(BWMFI_BUFFER, _shift);
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
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return _entry[(int)BWMFI_BUFFER] > 0 && _entry[(int)BWMFI_HISTCOLOR] >= 0 && !_entry.HasValue<double>(DBL_MAX) &&
           !_entry.HasValue<double>(EMPTY_VALUE);
  }
};
