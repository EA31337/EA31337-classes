//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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

// Defines macros (for MQL4 backward compability).
#define iMFI4(symbol, tf, period, av, shift) \
        Indi_MFI::iMFI(symbol, tf, period, av, shift);

// Structs.
struct MFIParams : IndicatorParams {
  unsigned int ma_period;
  ENUM_APPLIED_VOLUME applied_volume;  // Ignored in MT4.
  // Struct constructor.
  void MFIParams(unsigned int _ma_period, ENUM_APPLIED_VOLUME _av = NULL) : ma_period(_ma_period), applied_volume(_av) {
    itype = INDI_MFI;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
  };
};

/**
 * Implements the Money Flow Index indicator.
 */
class Indi_MFI : public Indicator {
 protected:
  MFIParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_MFI(MFIParams &_p) : params(_p.ma_period, _p.applied_volume), Indicator((IndicatorParams)_p) { params = _p; }
  Indi_MFI(MFIParams &_p, ENUM_TIMEFRAMES _tf) : params(_p.ma_period, _p.applied_volume), Indicator(INDI_MFI, _tf) {
    params = _p;
  }

  /**
   * Calculates the Money Flow Index indicator and returns its value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/imfi
   * - https://www.mql5.com/en/docs/indicators/imfi
   */
  static double iMFI(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, int _shift = 0,
                     Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iMFI(_symbol, _tf, _period, _shift);
#else  // __MQL5__
    return Indi_MFI::iMFI(_symbol, _tf, _period, VOLUME_TICK, _shift, _obj);
#endif
  }
  static double iMFI(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period,
                     ENUM_APPLIED_VOLUME _applied_volume,  // Not used in MT4.
                     int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iMFI(_symbol, _tf, _period, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iMFI(_symbol, _tf, _period, VOLUME_TICK)) == INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, 0, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
#ifdef __MQL4__
    double _value = Indi_MFI::iMFI(GetSymbol(), GetTf(), GetPeriod(), _shift);
#else  // __MQL5__
    double _value = Indi_MFI::iMFI(GetSymbol(), GetTf(), GetPeriod(), GetAppliedVolume(), _shift, GetPointer(this));
#endif
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
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.value.SetValue(params.idvtype, GetValue(_shift));
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.value.HasValue(params.idvtype, (double)NULL) &&
                                                   !_entry.value.HasValue(params.idvtype, EMPTY_VALUE));
      if (_entry.IsValid()) idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.idvtype, _mode);
    return _param;
  }

  /* Getters */

  /**
   * Get period value.
   *
   * Period (amount of bars) for calculation of the indicator.
   */
  unsigned int GetPeriod() { return params.ma_period; }

  /**
   * Get applied volume type.
   *
   * Note: Ignored in MT4.
   */
  ENUM_APPLIED_VOLUME GetAppliedVolume() { return params.applied_volume; }

  /* Setters */

  /**
   * Set period value.
   *
   * Period (amount of bars) for calculation of the indicator.
   */
  void SetPeriod(unsigned int _ma_period) {
    istate.is_changed = true;
    params.ma_period = _ma_period;
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
    params.applied_volume = _applied_volume;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idvtype); }
};
