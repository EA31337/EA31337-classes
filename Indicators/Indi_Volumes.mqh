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
struct IndiVolumesParams : IndicatorParams {
  ENUM_APPLIED_VOLUME applied_volume;
  // Struct constructor.
  IndiVolumesParams(ENUM_APPLIED_VOLUME _applied_volume = VOLUME_TICK, int _shift = 0) : IndicatorParams(INDI_VOLUMES) {
    applied_volume = _applied_volume;
    SetCustomIndicatorName("Examples\\Volumes");
    shift = _shift;
  };
  IndiVolumesParams(IndiVolumesParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Volumes indicator.
 */
class Indi_Volumes : public Indicator<IndiVolumesParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Volumes(IndiVolumesParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
               int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_Volumes(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
               int _indi_src_mode = 0)
      : Indicator(IndiVolumesParams(),
                  IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_CUSTOM | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiVolumesParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // Volume uses volume only.
    return _ds PTR_DEREF HasSpecificValueStorage(INDI_VS_TYPE_VOLUME);
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * OnCalculate-based version of Volumes as there is no built-in one.
   */
  static double iVolumes(IndicatorData *_indi, ENUM_APPLIED_VOLUME _av, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey((int)_av));
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
        _value = Indi_Volumes::iVolumes(THIS_PTR, GetAppliedVolume(), _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(),
                         /*[*/ GetAppliedVolume() /*]*/, _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_Volumes::iVolumes(THIS_PTR, GetAppliedVolume(), _mode, _ishift);
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
  void SetAppliedVolume(ENUM_APPLIED_VOLUME _applied_volume) {
    istate.is_changed = true;
    iparams.applied_volume = _applied_volume;
  }
};
