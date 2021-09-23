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
struct ColorCandlesDailyParams : IndicatorParams {
  // Struct constructor.
  void ColorCandlesDailyParams(int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_COLOR_CANDLES_DAILY;
    max_modes = 5;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\ColorCandlesDaily");
    SetDataSourceType(IDATA_BUILTIN);
    shift = _shift;
    tf = _tf;
  };
  void ColorCandlesDailyParams(ColorCandlesDailyParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements Color Bars
 */
class Indi_ColorCandlesDaily : public Indicator {
 protected:
  ColorCandlesDailyParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_ColorCandlesDaily(ColorCandlesDailyParams &_params) : Indicator((IndicatorParams)_params) { params = _params; };
  Indi_ColorCandlesDaily(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_COLOR_CANDLES_DAILY, _tf) {
    params.tf = _tf;
  };

  /**
   * "Built-in" version of Color Candles Daily.
   */
  static double iCCD(string _symbol, ENUM_TIMEFRAMES _tf, int _mode = 0, int _shift = 0, Indicator *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, "Indi_ColorCandlesDaily");
    return iCCDOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _shift, _cache);
  }

  /**
   * Calculates Color Candles Daily on the array of values.
   */
  static double iCCDOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _mode, int _shift,
                            IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(4 + 1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_ColorCandlesDaily::Calculate(
        INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0), _cache.GetBuffer<double>(1),
        _cache.GetBuffer<double>(2), _cache.GetBuffer<double>(3), _cache.GetBuffer<double>(4)));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for Color Candles Daily indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtOpenBuffer,
                       ValueStorage<double> &ExtHighBuffer, ValueStorage<double> &ExtLowBuffer,
                       ValueStorage<double> &ExtCloseBuffer, ValueStorage<double> &ExtColorsBuffer) {
    color ExtColorOfDay[6] = {CLR_NONE, MediumSlateBlue, DarkGoldenrod, ForestGreen, BlueViolet, Red};

    int pos;
    MqlDateTime tstruct;
    pos = prev_calculated < 1 ? 0 : prev_calculated - 1;
    // Main cycle.
    for (int i = pos; i < rates_total && !IsStopped(); i++) {
      ExtOpenBuffer[i] = open[i];
      ExtHighBuffer[i] = high[i];
      ExtLowBuffer[i] = low[i];
      ExtCloseBuffer[i] = close[i];
      // Set color for every candle.
      TimeToStruct(time[i].Get(), tstruct);
      ExtColorsBuffer[i] = tstruct.day_of_week;
    }
    // Return value of prev_calculated for next call.
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
        _value = Indi_ColorCandlesDaily::iCCD(GetSymbol(), GetTf(), _mode, _shift, GetPointer(this));
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
