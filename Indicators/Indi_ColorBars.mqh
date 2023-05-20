//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
#include "../Indicator/IndicatorTickOrCandleSource.h"
#include "../Storage/ValueStorage.all.h"

// Structs.
struct IndiColorBarsParams : IndicatorParams {
  // Struct constructor.
  IndiColorBarsParams(int _shift = 0) : IndicatorParams(INDI_COLOR_BARS) {
    SetCustomIndicatorName("Examples\\ColorBars");
    shift = _shift;
  };
  IndiColorBarsParams(IndiColorBarsParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements Color Bars
 */
class Indi_ColorBars : public IndicatorTickOrCandleSource<IndiColorBarsParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ColorBars(IndiColorBarsParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                 IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : IndicatorTickOrCandleSource(
            _p, IndicatorDataParams::GetInstance(5, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
            _indi_src){};
  Indi_ColorBars(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0)
      : IndicatorTickOrCandleSource(INDI_COLOR_BARS, _tf, _shift){};

  /**
   * "Built-in" version of Color Bars.
   */
  static double iColorBars(string _symbol, ENUM_TIMEFRAMES _tf, int _mode = 0, int _shift = 0,
                           IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, "Indi_ColorBars");
    return iColorBarsOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _shift, _cache);
  }

  /**
   * Calculates Color Bars on the array of values.
   */
  static double iColorBarsOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _mode, int _shift,
                                  IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(4 + 1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_ColorBars::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0),
                                                       _cache.GetBuffer<double>(1), _cache.GetBuffer<double>(2),
                                                       _cache.GetBuffer<double>(3), _cache.GetBuffer<double>(4)));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * On-indicator version of Color Bars.
   */
  static double iColorBarsOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, int _mode = 0,
                                      int _shift = 0, IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG_DS(_indi, _symbol, _tf,
                                                          Util::MakeKey("Indi_ColorBars_ON_" + _indi.GetFullName()));
    return iColorBarsOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _shift, _cache);
  }

  /**
   * OnCalculate() method for Color Bars indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtOpenBuffer,
                       ValueStorage<double> &ExtHighBuffer, ValueStorage<double> &ExtLowBuffer,
                       ValueStorage<double> &ExtCloseBuffer, ValueStorage<double> &ExtColorsBuffer) {
    int i = 0;
    bool vol_up = true;
    // Set position for beginning.
    if (i < prev_calculated) i = prev_calculated - 1;
    // Start calculations.
    while (i < rates_total && !IsStopped()) {
      ExtOpenBuffer[i] = open[i];
      ExtHighBuffer[i] = high[i];
      ExtLowBuffer[i] = low[i];
      ExtCloseBuffer[i] = close[i];
      // Determine volume change.
      if (i > 0) {
        if (tick_volume[i] > tick_volume[i - 1]) vol_up = true;
        if (tick_volume[i] < tick_volume[i - 1]) vol_up = false;
      }
      ExtColorsBuffer[i] = vol_up ? 0.0 : 1.0;
      i++;
    }
    // Return value of prev_calculated for next call.
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_ColorBars::iColorBars(GetSymbol(), GetTf(), _mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_ColorBars::iColorBarsOnIndicator(GetDataSource(), GetSymbol(), GetTf(), _mode, _ishift, THIS_PTR);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }
};
