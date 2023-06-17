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

// Defines.
// 38 bars (DATA_LIMIT) was originally specified by Indicators/Examples/BW-ZoneTrade.mq5
#define INDI_BWZT_DATA_LIMIT 100

// Includes.
#include "../Storage/Dict/Buffer/BufferStruct.h"
#include "../Indicator/IndicatorTf.h"
#include "../Storage/ValueStorage.all.h"
#include "Indi_AC.mqh"
#include "Indi_AO.mqh"

// Enumerations.
// Indicator line identifiers used in BWMFI indicators.
enum ENUM_INDI_BWZT_MODE {
  INDI_BWZT_MODE_OPEN = 0,
  INDI_BWZT_MODE_HIGH = 1,
  INDI_BWZT_MODE_LOW = 2,
  INDI_BWZT_MODE_CLOSE = 3,
  INDI_BWZT_MODE_COLOR = 4,
  FINAL_INDI_BWZT_MODE_ENTRY
};

// Structs.
struct IndiBWZTParams : IndicatorParams {
  Ref<IndicatorData> indi_ac;
  Ref<IndicatorData> indi_ao;
  unsigned int period;
  unsigned int second_period;
  unsigned int sum_period;
  // Struct constructor.
  IndiBWZTParams(int _shift = 0) : IndicatorParams(INDI_BWZT) {
    indi_ac = NULL;
    indi_ao = NULL;
    SetCustomIndicatorName("Examples\\BW-ZoneTrade");
    shift = _shift;
  };
  IndiBWZTParams(IndiBWZTParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Bill Williams' Zone Trade.
 */
class Indi_BWZT : public Indicator<IndiBWZTParams> {
 protected:
  /* Protected methods */

  /**
   * Initialize.
   */
  void Init() {}

 public:
  /**
   * Class constructor.
   */
  Indi_BWZT(IndiBWZTParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_INDI_BWZT_MODE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED,
                                                   _indi_src_mode),
                  _indi_src) {
    Init();
  };
  Indi_BWZT(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(IndiBWZTParams(),
                  IndicatorDataParams::GetInstance(FINAL_INDI_BWZT_MODE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED,
                                                   _indi_src_mode),
                  _indi_src) {
    Init();
  };

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_CUSTOM | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiBWZTParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // RS uses OHLC.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_OPEN) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_CLOSE);
  }

  /**
   * OnCalculate-based version of BWZT as there is no built-in one.
   */
  static double iBWZT(IndicatorData *_indi, int _mode = 0, int _rel_shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, "");

    // Will return Indi_AC with the same candles source as _indi's.
    Indi_AC *_indi_ac = Indi_AC::GetCached(_indi);

    // Will return Indi_AO with the same candles source as _indi's.
    Indi_AO *_indi_ao = Indi_AO::GetCached(_indi);

    return iBWZTOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _indi PTR_DEREF ToAbsShift(_rel_shift),
                        INDI_BWZT_DATA_LIMIT, _cache, _indi_ac, _indi_ao);
  }

  /**
   * Calculates BWZT on the array of values.
   */
  static double iBWZTOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _mode, int _abs_shift, int _data_limit,
                             IndiBufferCache<double> *_cache, Indi_AC *_indi_ac, Indi_AO *_indi_ao,
                             bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(4 + 1 + 2);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_BWZT::Calculate(
        INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0), _cache.GetBuffer<double>(1),
        _cache.GetBuffer<double>(2), _cache.GetBuffer<double>(3), _cache.GetBuffer<double>(4),
        _cache.GetBuffer<double>(5), _cache.GetBuffer<double>(6), _data_limit, _indi_ac, _indi_ao));

    return _cache.GetTailValue<double>(_mode, _abs_shift);
  }

  /**
   * On-indicator version of BWZT.
   */
  static double iBWZTOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, int _mode, int _rel_shift,
                                 int _data_limit, IndicatorData *_obj) {
    INDI_REQUIRE_BARS_OR_RETURN_EMPTY(_indi, _data_limit);
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey("Indi_BWZT_ON_" + _indi.GetFullName()));

    Indi_AC *_indi_ac = _obj.GetDataSource(INDI_AC);
    Indi_AO *_indi_ao = _obj.GetDataSource(INDI_AO);

    return iBWZTOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _indi PTR_DEREF ToAbsShift(_rel_shift),
                        _data_limit, _cache, _indi_ac, _indi_ao);
  }

  /**
   * Provides built-in indicators whose can be used as data source.
   */
  virtual IndicatorData *FetchDataSource(ENUM_INDICATOR_TYPE _id) override {
    switch (_id) {
      case INDI_AC:
        return iparams.indi_ac.Ptr();
      case INDI_AO:
        return iparams.indi_ao.Ptr();
    }

    return NULL;
  }

  /**
   * OnCalculate() method for BWZT indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtOBuffer,
                       ValueStorage<double> &ExtHBuffer, ValueStorage<double> &ExtLBuffer,
                       ValueStorage<double> &ExtCBuffer, ValueStorage<double> &ExtColorBuffer,
                       ValueStorage<double> &ExtAOBuffer, ValueStorage<double> &ExtACBuffer, int DATA_LIMIT,
                       IndicatorData *ExtACHandle, IndicatorData *ExtAOHandle) {
    if (rates_total < DATA_LIMIT) return (0);
    // Not all data may be calculated.
    int calculated = BarsCalculated(ExtACHandle);
    if (calculated < rates_total) {
      // Not all data of ExtACHandle is calculated.
      return (0);
    }
    calculated = BarsCalculated(ExtAOHandle);
    if (calculated < rates_total) {
      // Not all data of ExtAOHandle is calculated.
      return (0);
    }
    // We can copy not all data.
    int to_copy;
    if (prev_calculated > rates_total || prev_calculated < 0)
      to_copy = rates_total;
    else {
      to_copy = rates_total - prev_calculated;
      if (prev_calculated > 0) to_copy++;
    }
    // Get AC buffer.
    if (CopyBuffer(ExtACHandle, 0, 0, to_copy, ExtACBuffer, rates_total) <= 0) {
#ifdef __debug__
      Print("Getting iAC is failed! Error ", GetLastError());
#endif
      return (0);
    }
    // Get AO buffer.
    if (CopyBuffer(ExtAOHandle, 0, 0, to_copy, ExtAOBuffer, rates_total) <= 0) {
#ifdef __debug__
      Print("Getting iAO is failed! Error ", GetLastError());
#endif
      return (0);
    }
    // Set first bar from what calculation will start.
    int start;
    if (prev_calculated < DATA_LIMIT)
      start = DATA_LIMIT;
    else
      start = prev_calculated - 1;
    // The main loop of calculations.
    for (int i = start; i < rates_total && !IsStopped(); i++) {
      ExtOBuffer[i] = open[i];
      ExtHBuffer[i] = high[i];
      ExtLBuffer[i] = low[i];
      ExtCBuffer[i] = close[i];

      // Set colors for candle.
      // Set gray color.
      ExtColorBuffer[i] = 2.0;
      // Check for Green Zone and set Color Green.
      if (ExtACBuffer[i] > ExtACBuffer[i - 1] && ExtAOBuffer[i] > ExtAOBuffer[i - 1]) ExtColorBuffer[i] = 0.0;
      // Check for Red Zone and set Color Red.
      if (ExtACBuffer[i] < ExtACBuffer[i - 1] && ExtAOBuffer[i] < ExtAOBuffer[i - 1]) ExtColorBuffer[i] = 1.0;
    }
    // Return value of prev_calculated for next call.
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) {
    double _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
      case IDATA_ONCALCULATE:
        _value = Indi_BWZT::iBWZT(THIS_PTR, _mode, ToRelShift(_abs_shift));
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode,
                         ToRelShift(_abs_shift));
        break;
      case IDATA_INDICATOR:
        _value = Indi_BWZT::iBWZT(THIS_PTR, _mode, ToRelShift(_abs_shift));
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }

  /**
   * Checks if indicator entry is valid.
   *
   * @return
   *   Returns true if entry is valid (has valid values), otherwise false.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return !_entry.HasValue<double>(DBL_MAX) && _entry.GetMin<double>(4) > 0 && _entry[(int)INDI_BWZT_MODE_COLOR] >= 0;
  }
};
