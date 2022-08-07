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
struct IndiVROCParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_VOLUME applied_volume;
  // Struct constructor.
  IndiVROCParams(unsigned int _period = 25, ENUM_APPLIED_VOLUME _applied_volume = VOLUME_TICK, int _shift = 0)
      : IndicatorParams(INDI_VROC) {
    applied_volume = _applied_volume;
    period = _period;
    SetCustomIndicatorName("Examples\\VROC");
    shift = _shift;
  };
  IndiVROCParams(IndiVROCParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Volume Rate of Change indicator.
 */
class Indi_VROC : public Indicator<IndiVROCParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_VROC(IndiVROCParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_VROC(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(IndiVROCParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_CUSTOM; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiVROCParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // VROC uses volume only.
    return _ds PTR_DEREF HasSpecificValueStorage(INDI_VS_TYPE_VOLUME);
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * OnCalculate-based version of VROC as there is no built-in one.
   */
  static double iVROC(IndicatorData *_indi, int _period, ENUM_APPLIED_VOLUME _av, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey(_period, (int)_av));
    return iVROCOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _period, _av, _mode, _shift, _cache);
  }

  /**
   * Calculates VROC on the array of values.
   */
  static double iVROCOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _period, ENUM_APPLIED_VOLUME _av, int _mode,
                             int _shift, IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(
        Indi_VROC::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0), _period, _av));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for VROC indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtVROCBuffer, int InpPeriodVROC,
                       ENUM_APPLIED_VOLUME InpVolumeType) {
    int ExtPeriodVROC;

    if (InpPeriodVROC <= 1) {
      ExtPeriodVROC = 25;
      PrintFormat("Incorrect value for input variable InpPeriodVROC=%d. Indicator will use value=%d for calculations.",
                  InpPeriodVROC, ExtPeriodVROC);
    } else
      ExtPeriodVROC = InpPeriodVROC;

    if (rates_total < ExtPeriodVROC) return (0);
    int pos = prev_calculated - 1;
    if (pos < ExtPeriodVROC - 1) {
      pos = ExtPeriodVROC - 1;
      for (int i = 0; i < pos; i++) ExtVROCBuffer[i] = 0.0;
    }
    // Main cycle by volume type.
    if (InpVolumeType == VOLUME_TICK)
      CalculateVROC(pos, rates_total, tick_volume, ExtVROCBuffer, ExtPeriodVROC);
    else
      CalculateVROC(pos, rates_total, volume, ExtVROCBuffer, ExtPeriodVROC);
    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  static void CalculateVROC(const int pos, const int rates_total, ValueStorage<long> &volume,
                            ValueStorage<double> &ExtVROCBuffer, int ExtPeriodVROC) {
    for (int i = pos; i < rates_total && !IsStopped(); i++) {
      double prev_volume = (double)(volume[i - (ExtPeriodVROC - 1)].Get());
      double curr_volume = (double)volume[i].Get();
      // Calculate VROC.
      if (prev_volume != 0.0)
        ExtVROCBuffer[i] = 100.0 * (curr_volume - prev_volume) / prev_volume;
      else
        ExtVROCBuffer[i] = ExtVROCBuffer[i - 1];
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
        _value = iVROC(THIS_PTR, GetPeriod(), GetAppliedVolume(), _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(),
                         /*[*/ GetPeriod(), GetAppliedVolume() /*]*/, _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = iVROC(THIS_PTR, GetPeriod(), GetAppliedVolume(), _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period volume.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get applied volume.
   */
  ENUM_APPLIED_VOLUME GetAppliedVolume() { return iparams.applied_volume; }

  /* Setters */

  /**
   * Set period.
   */
  void SetPeriod(ENUM_APPLIED_VOLUME _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set applied volume.
   */
  void SetAppliedVolume(ENUM_APPLIED_VOLUME _applied_volume) {
    istate.is_changed = true;
    iparams.applied_volume = _applied_volume;
  }
};
