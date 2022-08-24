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
#include "Indi_MA.mqh"

// Structs.
struct IndiMassIndexParams : IndicatorParams {
  int period;
  int second_period;
  int sum_period;
  // Struct constructor.
  IndiMassIndexParams(int _period = 9, int _second_period = 9, int _sum_period = 25, int _shift = 0)
      : IndicatorParams(INDI_MASS_INDEX) {
    period = _period;
    second_period = _second_period;
    SetCustomIndicatorName("Examples\\MI");
    shift = _shift;
    sum_period = _sum_period;
  };
  IndiMassIndexParams(IndiMassIndexParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_MassIndex : public Indicator<IndiMassIndexParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_MassIndex(IndiMassIndexParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                 IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_MassIndex(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                 int _indi_src_mode = 0)
      : Indicator(IndiMassIndexParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_CUSTOM; }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiMassIndexParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // MI uses high and low prices only.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW);
  }

  /**
   * OnCalculate-based version of Mass Index as there is no built-in one.
   */
  static double iMI(IndicatorData *_indi, int _period, int _second_period, int _sum_period, int _mode = 0,
                    int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey(_period, _second_period, _sum_period));
    return iMIOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _period, _second_period, _sum_period, _mode, _shift,
                      _cache);
  }

  /**
   * Calculates Mass Index on the array of values.
   */
  static double iMIOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _period, int _second_period, int _sum_period, int _mode,
                           int _shift, IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1 + 3);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_MassIndex::Calculate(
        INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0), _cache.GetBuffer<double>(1),
        _cache.GetBuffer<double>(2), _cache.GetBuffer<double>(3), _period, _second_period, _sum_period));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for Mass Index indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtMIBuffer,
                       ValueStorage<double> &ExtEHLBuffer, ValueStorage<double> &ExtEEHLBuffer,
                       ValueStorage<double> &ExtHLBuffer, int InpPeriodEMA, int InpSecondPeriodEMA, int InpSumPeriod) {
    int ExtPeriodEMA;
    int ExtSecondPeriodEMA;
    int ExtSumPeriod;

    if (InpPeriodEMA <= 0) {
      ExtPeriodEMA = 9;
      PrintFormat("Incorrect value for input variable InpPeriodEMA=%d. Indicator will use value=%d for calculations.",
                  InpPeriodEMA, ExtPeriodEMA);
    } else
      ExtPeriodEMA = InpPeriodEMA;
    if (InpSecondPeriodEMA <= 0) {
      ExtSecondPeriodEMA = 9;
      PrintFormat(
          "Incorrect value for input variable InpSecondPeriodEMA=%d. Indicator will use value=%d for calculations.",
          InpSecondPeriodEMA, ExtSecondPeriodEMA);
    } else
      ExtSecondPeriodEMA = InpSecondPeriodEMA;
    if (InpSumPeriod <= 0) {
      ExtSumPeriod = 25;
      PrintFormat("Incorrect value for input variable PeriodSum=%d. Indicator will use value=%d for calculations.",
                  InpSumPeriod, ExtSumPeriod);
    } else
      ExtSumPeriod = InpSumPeriod;

    int pos_mi = ExtSumPeriod + ExtPeriodEMA + ExtSecondPeriodEMA - 3;
    if (rates_total < pos_mi) return (0);
    int pos = prev_calculated - 1;
    if (pos < 1) {
      // Correct position.
      ExtHLBuffer[0] = high[0] - low[0];
      pos = 1;
    }
    // Main cycle.
    for (int i = pos; i < rates_total && !IsStopped(); i++) {
      // Fill main data buffer.
      ExtHLBuffer[i] = high[i] - low[i];
      // Calculate EMA values.
      ExtEHLBuffer[i] = Indi_MA::ExponentialMA(i, ExtPeriodEMA, ExtEHLBuffer[i - 1].Get(), ExtHLBuffer);
      // Calculate EMA on EMA values.
      ExtEEHLBuffer[i] = Indi_MA::ExponentialMA(i, ExtSecondPeriodEMA, ExtEEHLBuffer[i - 1].Get(), ExtEHLBuffer);
      // Calculate MI values.
      double dtmp = 0.0;
      if (i >= pos_mi) {
        for (int j = 0; j < ExtSumPeriod; j++)
          if (ExtEEHLBuffer[i - j] != 0.0) dtmp += ExtEHLBuffer[i - j] / ExtEEHLBuffer[i - j];
      }
      ExtMIBuffer[i] = dtmp;
    }
    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
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
        _value = Indi_MassIndex::iMI(THIS_PTR, GetPeriod(), GetSecondPeriod(), GetSumPeriod(), _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod(),
                         GetSecondPeriod(), GetSumPeriod() /*]*/, _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_MassIndex::iMI(THIS_PTR, GetPeriod(), GetSecondPeriod(), GetSumPeriod(), _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period.
   */
  int GetPeriod() { return iparams.period; }

  /**
   * Get second period.
   */
  int GetSecondPeriod() { return iparams.second_period; }

  /**
   * Get sum period.
   */
  int GetSumPeriod() { return iparams.sum_period; }

  /* Setters */

  /**
   * Set period.
   */
  void SetPeriod(int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set second period.
   */
  void SetSecondPeriod(int _second_period) {
    istate.is_changed = true;
    iparams.second_period = _second_period;
  }

  /**
   * Set sum period.
   */
  void SetSumPeriod(int _sum_period) {
    istate.is_changed = true;
    iparams.sum_period = _sum_period;
  }
};
