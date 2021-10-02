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
#include "../BufferStruct.mqh"
#include "../Indicator.mqh"
#include "../Storage/ValueStorage.all.h"

// Structs.
struct VolumesParams : IndicatorParams {
  ENUM_APPLIED_VOLUME applied_volume;
  // Struct constructor.
  void VolumesParams(ENUM_APPLIED_VOLUME _applied_volume = VOLUME_TICK, int _shift = 0) {
    applied_volume = _applied_volume;
    itype = INDI_VOLUMES;
    max_modes = 2;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\Volumes");
    SetDataSourceType(IDATA_BUILTIN);
    shift = _shift;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_Volumes : public Indicator<VolumesParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Volumes(VolumesParams &_params) : Indicator<VolumesParams>(_params){};
  Indi_Volumes(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_VOLUMES, _tf){};

  /**
   * Built-in version of Volumes.
   */
  static double iVolumes(string _symbol, ENUM_TIMEFRAMES _tf, ENUM_APPLIED_VOLUME _av, int _mode = 0, int _shift = 0,
                         IndicatorBase *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, Util::MakeKey("Indi_Volumes", (int)_av));
    return iVolumesOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _av, _mode, _shift, _cache);
  }

  /**
   * Calculates AMVolumes on the array of values.
   */
  static double iVolumesOnArray(INDICATOR_CALCULATE_PARAMS_LONG, ENUM_APPLIED_VOLUME _av, int _mode, int _shift,
                                IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1 + 1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_Volumes::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0),
                                                     _cache.GetBuffer<double>(1), _av));

    for (int i = 0; i < _cache.NumBuffers(); ++i) {
      Print("(Mode #", _mode, ", Buffer #", i, " = ", _cache.GetTailValue<double>(i, _shift));
    }

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for Volumes indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtVolumesBuffer,
                       ValueStorage<double> &ExtColorsBuffer, ENUM_APPLIED_VOLUME InpVolumeType) {
    if (rates_total < 2) return (0);

    // Starting work.
    int pos = prev_calculated - 1;
    // Correct position.
    if (pos < 1) {
      ExtVolumesBuffer[0] = 0;
      pos = 1;
    }

    // Main cycle.
    if (InpVolumeType == VOLUME_TICK)
      CalculateVolume(pos, rates_total, tick_volume, ExtVolumesBuffer, ExtColorsBuffer);
    else
      CalculateVolume(pos, rates_total, volume, ExtVolumesBuffer, ExtColorsBuffer);
    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  static void CalculateVolume(const int pos, const int rates_total, ValueStorage<long> &volume,
                              ValueStorage<double> &ExtVolumesBuffer, ValueStorage<double> &ExtColorsBuffer) {
    ExtVolumesBuffer[0] = (double)volume[0].Get();
    ExtColorsBuffer[0] = 0.0;
    for (int i = pos; i < rates_total && !IsStopped(); i++) {
      double curr_volume = (double)volume[i].Get();
      double prev_volume = (double)volume[i - 1].Get();
      // Calculate indicator.
      ExtVolumesBuffer[i] = curr_volume;
      ExtColorsBuffer[i] = (curr_volume > prev_volume) ? 0.0 : 1.0;

      Print("Volume: ", ExtVolumesBuffer[i].Get(), ", ", ExtColorsBuffer[i].Get());
    }
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_Volumes::iVolumes(GetSymbol(), GetTf(), /*[*/ GetAppliedVolume() /*]*/, _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(),
                         /*[*/ GetAppliedVolume() /*]*/, _mode, _shift);
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
    IndicatorDataEntry _entry(iparams.GetMaxModes());
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)iparams.GetMaxModes(); _mode++) {
        double _v = GetValue(_mode, _shift);
        _entry.values[_mode] = _v;
        Print("Volumes[", _mode, "] = ", _v);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(EMPTY_VALUE));
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(iparams.GetDataValueType()));
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
  ENUM_APPLIED_VOLUME GetAppliedVolume() { return iparams.applied_volume; }

  /* Setters */

  /**
   * Set applied volume.
   */
  void SetAppliedVolume(ENUM_APPLIED_VOLUME _applied_volume) {
    istate.is_changed = true;
    iparams.applied_volume = _applied_volume;
  }
};
