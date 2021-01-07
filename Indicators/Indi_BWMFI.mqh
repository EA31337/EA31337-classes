//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
double iBWMFI(string _symbol, int _tf, int _shift) { return Indi_BWMFI::iBWMFI(_symbol, (ENUM_TIMEFRAMES)_tf, _shift); }
#endif

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
struct BWMFIParams : IndicatorParams {
  // Struct constructors.
  BWMFIParams(int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_BWMFI;
    max_modes = FINAL_BWMFI_BUFFER_ENTRY;
    SetDataValueType(TYPE_DOUBLE);
    shift = _shift;
    tf = _tf;
    tfi = ChartHistory::TfToIndex(_tf);
  };
  BWMFIParams(BWMFIParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Market Facilitation Index by Bill Williams indicator.
 */
class Indi_BWMFI : public Indicator {
 protected:
  BWMFIParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_BWMFI(IndicatorParams &_p) : Indicator((IndicatorParams)_p) {}
  Indi_BWMFI(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_BWMFI, _tf) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ibwmfi
   * - https://www.mql5.com/en/docs/indicators/ibwmfi
   */
  static double iBWMFI(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                       ENUM_BWMFI_BUFFER _mode = BWMFI_BUFFER, Indicator *_obj = NULL) {
#ifdef __MQL4__
    // Adjusting shift for MT4.
    _shift++;
    return ::iBWMFI(_symbol, _tf, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iBWMFI(_symbol, _tf, VOLUME_TICK)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (GetLastError() > 0) {
      return EMPTY_VALUE;
    } else if (_bars_calc <= 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, _mode, _shift + 1, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_BWMFI_BUFFER _mode = BWMFI_BUFFER, int _shift = 0) {
    ResetLastError();
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
    double _value = iBWMFI(GetSymbol(), GetTf(), _shift, _mode, GetPointer(this));
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.values[BWMFI_BUFFER] = GetValue(BWMFI_BUFFER, _shift);
      double _histcolor = EMPTY_VALUE;
#ifdef __MQL4__
      // @see: https://en.wikipedia.org/wiki/Market_facilitation_index
      bool _vol_up = GetVolume(_shift) > GetVolume(_shift + 1);
      bool _val_up = GetValue(BWMFI_BUFFER, _shift) > GetValue(BWMFI_BUFFER, _shift + 1);
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
#else
      _histcolor = GetValue(BWMFI_HISTCOLOR, _shift);
#endif
      _entry.values[BWMFI_HISTCOLOR] = _histcolor;
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _entry.values[BWMFI_BUFFER] != 0 && !_entry.HasValue(EMPTY_VALUE));
      if (_entry.IsValid()) idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    GetEntry(_shift).values[_mode].Get(_param.double_value);
    return _param;
  }
};
