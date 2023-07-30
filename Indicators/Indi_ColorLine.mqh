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
#include "Indi_MA.mqh"

// Structs.
struct IndiColorLineParams : IndicatorParams {
  IndicatorData *indi_ma;
  // Struct constructor.
  IndiColorLineParams(int _shift = 0) : IndicatorParams(INDI_COLOR_LINE) {
    indi_ma = NULL;
    SetCustomIndicatorName("Examples\\ColorLine");
    shift = _shift;
  };
  IndiColorLineParams(IndiColorLineParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements Color Bars
 */
class Indi_ColorLine : public IndicatorTickOrCandleSource<IndiColorLineParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ColorLine(IndiColorLineParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                 IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : IndicatorTickOrCandleSource(
            _p, IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
            _indi_src){};
  Indi_ColorLine(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0)
      : IndicatorTickOrCandleSource(INDI_COLOR_LINE, _tf, _shift){};

  /**
   * "Built-in" version of Color Line.
   */
  static double iColorLine(string _symbol, ENUM_TIMEFRAMES _tf, int _mode = 0, int _shift = 0,
                           IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, "Indi_ColorLine");

    Indi_MA *_indi_ma = Indi_MA::GetCached(_symbol, _tf, 10, 0, MODE_EMA, PRICE_CLOSE);

    return iColorLineOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _shift, _cache, _indi_ma);
  }

  /**
   * Calculates Color Line on the array of values.
   */
  static double iColorLineOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _mode, int _shift,
                                  IndicatorCalculateCache<double> *_cache, IndicatorData *_indi_ma,
                                  bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1 + 1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_ColorLine::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0),
                                                       _cache.GetBuffer<double>(1), _indi_ma));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * On-indicator version of Color Line.
   */
  static double iColorLineOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, int _mode = 0,
                                      int _shift = 0, IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG_DS(_indi, _symbol, _tf,
                                                          Util::MakeKey("Indi_ColorLine_ON_" + _indi.GetFullName()));

    Indi_MA *_indi_ma = _obj.GetDataSource(INDI_MA);

    return iColorLineOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _shift, _cache, _indi_ma);
  }

  /**
   * Provides built-in indicators whose can be used as data source.
   */
  virtual IndicatorData *FetchDataSource(ENUM_INDICATOR_TYPE _id) override {
    switch (_id) {
      case INDI_MA:
        return iparams.indi_ma;
    }
    return NULL;
  }

  /**
   * OnCalculate() method for Color Line indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtColorLineBuffer,
                       ValueStorage<double> &ExtColorsBuffer, IndicatorData *ExtMAHandle) {
    static int ticks = 0, modified = 0;
    // Check data.
    int i, calculated = BarsCalculated(ExtMAHandle);
    // @added History of 100 values should be enough for MA.
    if (calculated < rates_total) {
      // Not all data of ExtMAHandle is calculated.
      return (0);
    }
    // First calculation or number of bars was changed.
    if (prev_calculated == 0) {
      // Copy values of MA into indicator buffer ExtColorLineBuffer.
      if (CopyBuffer(ExtMAHandle, 0, 0, rates_total, ExtColorLineBuffer, rates_total) <= 0) return (0);
      // Now set line color for every bar.
      for (i = 0; i < rates_total && !IsStopped(); i++) ExtColorsBuffer[i] = GetIndexOfColor(i);
    } else {
      // We can copy not all data.
      int to_copy;
      if (prev_calculated > rates_total || prev_calculated < 0)
        to_copy = rates_total;
      else {
        to_copy = rates_total - prev_calculated;
        if (prev_calculated > 0) to_copy++;
      }
      // Copy values of MA into indicator buffer ExtColorLineBuffer.
      int copied = CopyBuffer(ExtMAHandle, 0, 0, rates_total, ExtColorLineBuffer, rates_total);
      if (copied <= 0) return (0);

      ticks++;
      if (ticks >= 5) {
        // Time to change color scheme.
        ticks = 0;
        // Counter of color changes.
        modified++;
        if (modified >= 3) modified = 0;
        switch (modified) {
          case 0:
            // First color scheme.
            ExtColorLineBuffer.PlotIndexSetInteger(PLOT_LINE_COLOR, 0, Red);
            ExtColorLineBuffer.PlotIndexSetInteger(PLOT_LINE_COLOR, 1, Blue);
            ExtColorLineBuffer.PlotIndexSetInteger(PLOT_LINE_COLOR, 2, Green);
            break;
          case 1:
            // Second color scheme.
            ExtColorLineBuffer.PlotIndexSetInteger(PLOT_LINE_COLOR, 0, Yellow);
            ExtColorLineBuffer.PlotIndexSetInteger(PLOT_LINE_COLOR, 1, Pink);
            ExtColorLineBuffer.PlotIndexSetInteger(PLOT_LINE_COLOR, 2, LightSlateGray);
            break;
          default:
            // Third color scheme.
            ExtColorLineBuffer.PlotIndexSetInteger(PLOT_LINE_COLOR, 0, LightGoldenrod);
            ExtColorLineBuffer.PlotIndexSetInteger(PLOT_LINE_COLOR, 1, Orchid);
            ExtColorLineBuffer.PlotIndexSetInteger(PLOT_LINE_COLOR, 2, LimeGreen);
        }
      } else {
        // Set start position.
        int start = prev_calculated - 1;
        // Now we set line color for every bar.
        for (i = start; i < rates_total && !IsStopped(); i++) ExtColorsBuffer[i] = GetIndexOfColor(i);
      }
    }
    // Return value of prev_calculated for next call.
    return (rates_total);
  }

  static int GetIndexOfColor(const int i) {
    int j = i % 300;
    if (j < 100) {
      // First index.
      return (0);
    }
    if (j < 200) {
      // Second index.
      return (1);
    }
    // Third index.
    return (2);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_ColorLine::iColorLine(GetSymbol(), GetTf(), _mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_ColorLine::iColorLineOnIndicator(GetDataSource(), GetSymbol(), GetTf(), _mode, _ishift, THIS_PTR);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }
};
