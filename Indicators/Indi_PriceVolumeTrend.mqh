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
struct PriceVolumeTrendParams : IndicatorParams {
  ENUM_APPLIED_VOLUME applied_volume;
  // Struct constructor.
  void PriceVolumeTrendParams(ENUM_APPLIED_VOLUME _applied_volume = VOLUME_TICK, int _shift = 0)
      : IndicatorParams(INDI_PRICE_VOLUME_TREND, 1) {
    applied_volume = _applied_volume;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\PVT");
    shift = _shift;
  };
};

/**
 * Implements the Price Volume Trend indicator.
 */
class Indi_PriceVolumeTrend : public Indicator<PriceVolumeTrendParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_PriceVolumeTrend(PriceVolumeTrendParams &_p, IndicatorBase *_indi_src = NULL)
      : Indicator<PriceVolumeTrendParams>(_p, _indi_src){};
  Indi_PriceVolumeTrend(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_PRICE_VOLUME_TREND, _tf){};

  /**
   * Built-in version of Price Volume Trend.
   */
  static double iPVT(string _symbol, ENUM_TIMEFRAMES _tf, ENUM_APPLIED_VOLUME _av, int _mode = 0, int _shift = 0,
                     IndicatorBase *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, Util::MakeKey("Indi_PriceVolumeTrend", (int)_av));
    return iPVTOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _av, _mode, _shift, _cache);
  }

  /**
   * Calculates Price Volume Trend on the array of values.
   */
  static double iPVTOnArray(INDICATOR_CALCULATE_PARAMS_LONG, ENUM_APPLIED_VOLUME _av, int _mode, int _shift,
                            IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(
        Indi_PriceVolumeTrend::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0), _av));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for Price Volume Trend indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtPVTBuffer,
                       ENUM_APPLIED_VOLUME InpVolumeType) {
    if (rates_total < 2) return (0);
    int pos = prev_calculated - 1;
    // Correct position, when it's first iteration.
    if (pos < 0) {
      pos = 1;
      ExtPVTBuffer[0] = 0.0;
    }
    // Main cycle.
    if (InpVolumeType == VOLUME_TICK)
      CalculatePVT(pos, rates_total, close, tick_volume, ExtPVTBuffer);
    else
      CalculatePVT(pos, rates_total, close, volume, ExtPVTBuffer);
    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  static void CalculatePVT(const int pos, const int rates_total, ValueStorage<double> &close,
                           ValueStorage<long> &volume, ValueStorage<double> &ExtPVTBuffer) {
    for (int i = pos; i < rates_total && !IsStopped(); i++) {
      double prev_close = close[i - 1].Get();
      // Calculate PVT value.
      if (prev_close != 0)
        ExtPVTBuffer[i] = ((close[i] - prev_close) / prev_close) * volume[i].Get() + ExtPVTBuffer[i - 1].Get();
      else
        ExtPVTBuffer[i] = ExtPVTBuffer[i - 1];
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
        _value =
            Indi_PriceVolumeTrend::iPVT(GetSymbol(), GetTf(), /*[*/ GetAppliedVolume() /*]*/, _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(),
                         /*[*/ GetAppliedVolume() /*]*/, 0, _shift);
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
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE));
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
  void SetPeriod(ENUM_APPLIED_VOLUME _applied_volume) {
    istate.is_changed = true;
    iparams.applied_volume = _applied_volume;
  }
};
