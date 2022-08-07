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
struct IndiColorBarsParams : IndicatorParams {
  // Struct constructor.
  IndiColorBarsParams(int _shift = 0) : IndicatorParams(INDI_COLOR_BARS) {
    SetCustomIndicatorName("Examples\\ColorBars");
    shift = _shift;
  };
  IndiColorBarsParams(IndiColorBarsParams &_params) { THIS_REF = _params; };
};

/**
 * Implements Color Bars
 */
class Indi_ColorBars : public Indicator<IndiColorBarsParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ColorBars(IndiColorBarsParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                 IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(5, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_ColorBars(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                 int _indi_src_mode = 0)
      : Indicator(IndiColorBarsParams(),
                  IndicatorDataParams::GetInstance(5, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
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
   * OnCalculate-based version of Color Bars as there is no built-in one.
   */
  static double iColorBars(IndicatorData *_indi, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, "");
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
      case IDATA_ONCALCULATE:
        _value = Indi_ColorBars::iColorBars(THIS_PTR, _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_ColorBars::iColorBars(THIS_PTR, _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }
};
