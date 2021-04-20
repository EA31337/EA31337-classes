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
#include "../BufferStruct.mqh"
#include "../Indicator.mqh"

// Structs.
struct VIDYAParams : IndicatorParams {
  unsigned int cmo_period;
  unsigned int ma_period;
  unsigned int vidya_shift;

  // Struct constructor.
  void VIDYAParams(unsigned int _cmo_period = 9, unsigned int _ma_period = 14, unsigned int _vidya_shift = 0,
                   int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    cmo_period = _cmo_period;
    itype = INDI_VIDYA;
    ma_period = _ma_period;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\VIDYA");
    SetDataSourceType(IDATA_ICUSTOM);
    shift = _shift;
    tf = _tf;
    vidya_shift = _vidya_shift;
  };
  void VIDYAParams(VIDYAParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Variable Index Dynamic Average indicator.
 */
class Indi_VIDYA : public Indicator {
 protected:
  VIDYAParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_VIDYA(VIDYAParams &_params) : Indicator((IndicatorParams)_params) { params = _params; };
  Indi_VIDYA(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_VIDYA, _tf) { params.tf = _tf; };

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.GetCustomIndicatorName(), /*[*/
                         GetCMOPeriod(), GetMAPeriod(),
                         GetVIDYAShift()
                         /*]*/,
                         0, _shift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
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
      _entry.values[0] = GetValue(_shift);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE));
      if (_entry.IsValid()) {
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift)[_mode];
    return _param;
  }

  /* Getters */

  /**
   * Get CMO period.
   */
  unsigned int GetCMOPeriod() { return params.cmo_period; }

  /**
   * Get MA period.
   */
  unsigned int GetMAPeriod() { return params.ma_period; }

  /**
   * Get VIDYA shift.
   */
  unsigned int GetVIDYAShift() { return params.vidya_shift; }

  /* Setters */

  /**
   * Set CMO period.
   */
  void SetCMOPeriod(unsigned int _cmo_period) {
    istate.is_changed = true;
    params.cmo_period = _cmo_period;
  }

  /**
   * Set MA period.
   */
  void SetMAPeriod(unsigned int _ma_period) {
    istate.is_changed = true;
    params.ma_period = _ma_period;
  }

  /**
   * Set VIDYA shift.
   */
  void SetVIDYAShift(unsigned int _vidya_shift) {
    istate.is_changed = true;
    params.vidya_shift = _vidya_shift;
  }
};
