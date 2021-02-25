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
#include "Indi_Price.mqh"
#include "Special/Indi_Math.mqh"

// Structs.
struct RSParams : IndicatorParams {
  ENUM_APPLIED_VOLUME applied_volume;
  // Struct constructor.
  void RSParams(ENUM_APPLIED_VOLUME _applied_volume = VOLUME_TICK, int _shift = 0,
                ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    applied_volume = _applied_volume;
    itype = INDI_RS;
    max_modes = 2;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetDataSourceType(IDATA_MATH);
    shift = _shift;
    tf = _tf;
    tfi = Chart::TfToIndex(_tf);
  };
  void RSParams(RSParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_RS : public Indicator {
 protected:
  RSParams params;
  Ref<Indi_Price> iprice;
  DictStruct<int, Ref<Indi_Math>> imath;

 public:
  /**
   * Class constructor.
   */
  Indi_RS(RSParams &_params) : params(_params), Indicator((IndicatorParams)_params) { Init(); };
  Indi_RS(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_RS, _tf) {
    params.tf = _tf;
    Init();
  };

  void Init() {
    if (params.GetDataSourceType() == IDATA_MATH) {
      PriceIndiParams _iprice_params();
      iprice = new Indi_Price(_iprice_params);

      MathParams _imath0_params(MATH_OP_SUB, PRICE_CLOSE, 0, PRICE_CLOSE, 1);
      _imath0_params.SetDataSourceType(IDATA_INDICATOR);
      _imath0_params.SetIndicatorData(iprice.Ptr(), false);
      Ref<Indi_Math> _imath0 = new Indi_Math(_imath0_params);

      MathParams _imath1_params(MATH_OP_SUB, PRICE_CLOSE, 1, PRICE_CLOSE, 0);
      _imath1_params.SetDataSourceType(IDATA_INDICATOR);
      _imath1_params.SetIndicatorData(iprice.Ptr(), false);
      Ref<Indi_Math> _imath1 = new Indi_Math(_imath1_params);

      imath.Set(0, _imath0);
      imath.Set(1, _imath1);
    }
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_MATH:
        _value = imath[_mode].Ptr().GetValue();

        Print("RS[", _mode, "] = ", _value);
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
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, true);
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
   * Get applied volume.
   */
  ENUM_APPLIED_VOLUME GetAppliedVolume() { return params.applied_volume; }

  /* Setters */

  /**
   * Set applied volume.
   */
  void SetAppliedVolume(ENUM_APPLIED_VOLUME _applied_volume) {
    istate.is_changed = true;
    params.applied_volume = _applied_volume;
  }
};
