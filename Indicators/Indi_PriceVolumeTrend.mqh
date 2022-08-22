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
#include "../Indicator/Indicator.h"
#include "../Storage/ValueStorage.all.h"

// Structs.
struct IndiPriceVolumeTrendParams : IndicatorParams {
  ENUM_APPLIED_VOLUME applied_volume;
  // Struct constructor.
  IndiPriceVolumeTrendParams(ENUM_APPLIED_VOLUME _applied_volume = VOLUME_TICK, int _shift = 0)
      : IndicatorParams(INDI_PRICE_VOLUME_TREND) {
    applied_volume = _applied_volume;
    SetCustomIndicatorName("Examples\\PVT");
    shift = _shift;
  };
  IndiPriceVolumeTrendParams(IndiPriceVolumeTrendParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Price Volume Trend indicator.
 */
class Indi_PriceVolumeTrend : public Indicator<IndiPriceVolumeTrendParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_PriceVolumeTrend(IndiPriceVolumeTrendParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                        IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_PriceVolumeTrend(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                        IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(IndiPriceVolumeTrendParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_CANDLE | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * OnCalculate-based version of Price Volume Trend as there is no built-in one.
   */
  static double iPVT(IndicatorData *_indi, ENUM_APPLIED_VOLUME _av, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey((int)_av));
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
   * On-indicator version of Price Volume Trend.
   */
  static double iPVTOnIndicator(IndicatorData *_indi, ENUM_APPLIED_VOLUME _av, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey((int)_av));
    return iPVTOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _av, _mode, _shift, _cache);
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
      case IDATA_ONCALCULATE:
        _value = iPVT(THIS_PTR, GetAppliedVolume(), _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(),
                         /*[*/ GetAppliedVolume() /*]*/, 0, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = iPVT(THIS_PTR, GetAppliedVolume(), _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
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
