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
#include "Indi_MA.mqh"

// Structs.
struct ColorLineParams : IndicatorParams {
  // Struct constructor.
  void ColorLineParams(int _shift = 0) : IndicatorParams(INDI_COLOR_LINE, 2, TYPE_DOUBLE) {
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\ColorLine");
    shift = _shift;
  };
};

/**
 * Implements Color Bars
 */
class Indi_ColorLine : public Indicator<ColorLineParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ColorLine(ColorLineParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<ColorLineParams>(_p, _indi_src){};
  Indi_ColorLine(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_COLOR_LINE, _tf){};

  /**
   * "Built-in" version of Color Line.
   */
  static double iColorLine(string _symbol, ENUM_TIMEFRAMES _tf, int _mode = 0, int _shift = 0,
                           IndicatorBase *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, "Indi_ColorLine");

    Indi_MA *_indi_ma = Indi_MA::GetCached(_symbol, _tf, 10, 0, MODE_EMA, PRICE_CLOSE);

    return iColorLineOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _shift, _cache, _indi_ma);
  }

  /**
   * Calculates Color Line on the array of values.
   */
  static double iColorLineOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _mode, int _shift,
                                  IndicatorCalculateCache<double> *_cache, IndicatorBase *_indi_ma,
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
   * OnCalculate() method for Color Line indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtColorLineBuffer,
                       ValueStorage<double> &ExtColorsBuffer, IndicatorBase *ExtMAHandle) {
    static int ticks = 0, modified = 0;
    // Check data.
    int i, calculated = BarsCalculated(ExtMAHandle, rates_total);
    // @added History of 100 values should be enough for MA.
    if (calculated < rates_total && calculated < 100) {
      // Not all data of ExtMAHandle is calculated.
      Print("Not all MA data calculate for ColorLine! Expected ", rates_total, ", got only ", calculated);
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
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_ColorLine::iColorLine(GetSymbol(), GetTf(), _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode, _shift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
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
