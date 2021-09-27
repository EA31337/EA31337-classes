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

// Structs.
struct VROCParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_VOLUME applied_volume;
  // Struct constructor.
  void VROCParams(unsigned int _period = 25, ENUM_APPLIED_VOLUME _applied_volume = VOLUME_TICK, int _shift = 0) {
    applied_volume = _applied_volume;
    itype = INDI_VROC;
    max_modes = 1;
    period = _period;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\VROC");
    shift = _shift;
  };
};

/**
 * Implements the Volume Rate of Change indicator.
 */
class Indi_VROC : public Indicator {
 protected:
  VROCParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_VROC(VROCParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator((IndicatorParams)_params, _tf) {
    params = _params;
  };
  Indi_VROC(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_VROC, _tf){};

  /**
   * Built-in version of VROC.
   */
  static double iVROC(string _symbol, ENUM_TIMEFRAMES _tf, int _period, ENUM_APPLIED_VOLUME _av, int _mode = 0,
                      int _shift = 0, Indicator *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, Util::MakeKey("Indi_VROC", _period, (int)_av));
    return iVROCOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _period, _av, _mode, _shift, _cache);
  }

  /**
   * Calculates AMVROC on the array of values.
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
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_VROC::iVROC(GetSymbol(), GetTf(), /*[*/ GetPeriod(), GetAppliedVolume() /*]*/, _mode, _shift,
                                  THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.GetCustomIndicatorName(),
                         /*[*/ GetPeriod(), GetAppliedVolume() /*]*/, _mode, _shift);
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
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE));
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(params.GetDataValueType()));
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
   * Get period volume.
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get applied volume.
   */
  ENUM_APPLIED_VOLUME GetAppliedVolume() { return params.applied_volume; }

  /* Setters */

  /**
   * Set period.
   */
  void SetPeriod(ENUM_APPLIED_VOLUME _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Set applied volume.
   */
  void SetAppliedVolume(ENUM_APPLIED_VOLUME _applied_volume) {
    istate.is_changed = true;
    params.applied_volume = _applied_volume;
  }
};
