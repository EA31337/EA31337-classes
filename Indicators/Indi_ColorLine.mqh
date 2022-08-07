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
struct IndiColorLineParams : IndicatorParams {
  IndicatorData *indi_ma;
  // Struct constructor.
  IndiColorLineParams(int _shift = 0) : IndicatorParams(INDI_COLOR_LINE) {
    indi_ma = NULL;
    SetCustomIndicatorName("Examples\\ColorLine");
    shift = _shift;
  };
  IndiColorLineParams(IndiColorLineParams &_params) { THIS_REF = _params; };
};

/**
 * Implements Color Bars
 */
class Indi_ColorLine : public Indicator<IndiColorLineParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ColorLine(IndiColorLineParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                 IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_ColorLine(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                 int _indi_src_mode = 0)
      : Indicator(IndiColorLineParams(),
                  IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   *
   * @fixit Should require Candle data source?
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_CANDLE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiColorLineParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // Volume uses volume only.
    return _ds PTR_DEREF HasSpecificValueStorage(INDI_VS_TYPE_VOLUME);
  }

  /**
   * OnCalculate-based version of Color Line as there is no built-in one.
   */
  static double iColorLine(IndicatorData *_indi, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, "");
    // Will return Indi_MA with the same candles source as _indi's.
    // @fixit There should be Candle attached to MA!
    Indi_MA *_indi_ma = Indi_MA::GetCached(_indi, 10, 0, MODE_EMA, PRICE_CLOSE);
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
  static double iColorLineOnIndicator(IndicatorData *_indi, int _mode, int _shift, IndicatorData *_obj) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, "");
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
      case IDATA_ONCALCULATE:
        _value = iColorLine(THIS_PTR, _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = iColorLine(THIS_PTR, _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }
};
