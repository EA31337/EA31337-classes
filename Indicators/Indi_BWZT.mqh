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
#include "Indi_AC.mqh"
#include "Indi_AO.mqh"

// Structs.
struct BWZTParams : IndicatorParams {
  unsigned int period;
  unsigned int second_period;
  unsigned int sum_period;
  // Struct constructor.
  void BWZTParams(int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_BWZT;
    max_modes = 4;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\BW-ZoneTrade");
    SetDataSourceType(IDATA_ICUSTOM);
    shift = _shift;
    tf = _tf;
  };
  void BWZTParams(BWZTParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bill Williams' Zone Trade.
 */
class Indi_BWZT : public Indicator {
 protected:
  BWZTParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_BWZT(BWZTParams &_params) : Indicator((IndicatorParams)_params) { params = _params; };
  Indi_BWZT(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_BWZT, _tf) { params.tf = _tf; };

  /**
   * Built-in version of BWZT.
   */
  static double iBWZT(string _symbol, ENUM_TIMEFRAMES _tf, int _mode = 0, int _shift = 0, Indicator *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, "Indi_BWZT");

    //_cache.

    Indicator *_indi_ac = Indi_AC::GetCached(_symbol, _tf);
    Indicator *_indi_ao = Indi_AO::GetCached(_symbol, _tf);

    CachedIndicatorInfo _ac_info(_indi_ac, _cache.)  // Continue here.

        string _ac_key = Util::MakeKey("Indi_AC", _symbol, (int)_tf);
    if (!Objects<Indicator>::TryGet(_key, _indi_ac)) {
      _indi_ac = Objects<Indicator>::Set(_key, new Indi_AC(_tf));
    }

    string _ao_key = Util::MakeKey("Indi_AO", _symbol, (int)_tf);
    if (!Objects<Indicator>::TryGet(_key, _indi_ao)) {
      _indi_ao = Objects<Indicator>::Set(_key, new Indi_AO(_tf));
    }

    return iBWZTOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _shift, _cache, _indi_ac, _indi_ao);
  }

  /**
   * Calculates BWZT on the array of values.
   */
  static double iBWZTOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _mode, int _shift,
                             IndicatorCalculateCache<double> *_cache, Indicator *_indi_ac, Indicator *_indi_ao,
                             bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(4 + 1 + 2);
    }

    if (_recalculate) {
      _cache.SetPrevCalculated(0);
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
                       CachedIndicatorProxy &ExtACHandle, CachedIndicatorProxy &ExtAOHandle) {
    if (rates_total < DATA_LIMIT) return (0);
    //--- not all data may be calculated
    int calculated = BarsCalculated(ExtACHandle);
    if (calculated < rates_total) {
      Print("Not all data of ExtACHandle is calculated (", calculated, " bars). Error ", GetLastError());
      return (0);
    }
    calculated = BarsCalculated(ExtAOHandle);
    if (calculated < rates_total) {
      Print("Not all data of ExtAOHandle is calculated (", calculated, " bars). Error ", GetLastError());
      return (0);
    }
    //--- we can copy not all data
    int to_copy;
    if (prev_calculated > rates_total || prev_calculated < 0)
      to_copy = rates_total;
    else {
      to_copy = rates_total - prev_calculated;
      if (prev_calculated > 0) to_copy++;
    }
    //--- get AC buffer
    if (IsStopped())  // checking for stop flag
      return (0);
    if (CopyBuffer(ExtACHandle, 0, 0, to_copy, ExtACBuffer) <= 0) {
      Print("Getting iAC is failed! Error ", GetLastError());
      return (0);
    }
    //--- get AO buffer
    if (IsStopped())  // checking for stop flag
      return (0);
    if (CopyBuffer(ExtAOHandle, 0, 0, to_copy, ExtAOBuffer) <= 0) {
      Print("Getting iAO is failed! Error ", GetLastError());
      return (0);
    }
    //--- set first bar from what calculation will start
    int start;
    if (prev_calculated < DATA_LIMIT)
      start = DATA_LIMIT;
    else
      start = prev_calculated - 1;
    //--- the main loop of calculations
    for (int i = start; i < rates_total && !IsStopped(); i++) {
      ExtOBuffer[i] = open[i];
      ExtHBuffer[i] = high[i];
      ExtLBuffer[i] = low[i];
      ExtCBuffer[i] = close[i];
      //--- set color for candle
      ExtColorBuffer[i] = 2.0;  // set gray Color
      //--- check for Green Zone and set Color Green
      if (ExtACBuffer[i] > ExtACBuffer[i - 1] && ExtAOBuffer[i] > ExtAOBuffer[i - 1]) ExtColorBuffer[i] = 0.0;
      //--- check for Red Zone and set Color Red
      if (ExtACBuffer[i] < ExtACBuffer[i - 1] && ExtAOBuffer[i] < ExtAOBuffer[i - 1]) ExtColorBuffer[i] = 1.0;
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_BWZT::iBWZT(GetSymbol(), GetTf(), _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.GetCustomIndicatorName(), _mode, _shift);
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
};
