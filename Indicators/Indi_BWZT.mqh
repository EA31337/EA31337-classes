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
  unsigned int period;
  unsigned int second_period;
  unsigned int sum_period;
  // Struct constructor.
  IndiBWZTParams(int _shift = 0) : IndicatorParams(INDI_BWZT, FINAL_INDI_BWZT_MODE_ENTRY, TYPE_DOUBLE) {
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\BW-ZoneTrade");
    shift = _shift;
  };
  IndiBWZTParams(IndiBWZTParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bill Williams' Zone Trade.
 */
class Indi_BWZT : public Indicator<IndiBWZTParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_BWZT(IndiBWZTParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiBWZTParams>(_p, _indi_src){};
  Indi_BWZT(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_BWZT, _tf, _shift){};

  /**
   * Built-in version of BWZT.
   */
  static double iBWZT(string _symbol, ENUM_TIMEFRAMES _tf, int _mode = 0, int _shift = 0, IndicatorBase *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, "Indi_BWZT");

    Indi_AC *_indi_ac = Indi_AC::GetCached(_symbol, _tf);
    Indi_AO *_indi_ao = Indi_AO::GetCached(_symbol, _tf);

    return iBWZTOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _shift, _cache, _indi_ac, _indi_ao);
  }

  /**
   * Calculates BWZT on the array of values.
   */
  static double iBWZTOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _mode, int _shift,
                             IndicatorCalculateCache<double> *_cache, Indi_AC *_indi_ac, Indi_AO *_indi_ao,
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
        _cache.GetBuffer<double>(5), _cache.GetBuffer<double>(6), 38, _indi_ac, _indi_ao));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for BWZT indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtOBuffer,
                       ValueStorage<double> &ExtHBuffer, ValueStorage<double> &ExtLBuffer,
                       ValueStorage<double> &ExtCBuffer, ValueStorage<double> &ExtColorBuffer,
                       ValueStorage<double> &ExtAOBuffer, ValueStorage<double> &ExtACBuffer, int DATA_LIMIT,
                       IndicatorBase *ExtACHandle, IndicatorBase *ExtAOHandle) {
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_BWZT::iBWZT(GetSymbol(), GetTf(), _mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode, _ishift);
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
