//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../../Indicator/Indicator.h"
#include "../../Storage/Dict/DictStruct.h"
#include "../Price/Indi_Price.h"

// Structs.
struct IndiRSIParams : IndicatorParams {
  int period;
  ENUM_APPLIED_PRICE applied_price;

  IndiRSIParams(int _period = 14, ENUM_APPLIED_PRICE _ap = PRICE_OPEN, int _shift = 0)
      : IndicatorParams(INDI_RSI), applied_price(_ap) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\RSI");
    SetPeriod(_period);
  };
  IndiRSIParams(IndiRSIParams &_params) { THIS_REF = _params; };
  // Getters.
  ENUM_APPLIED_PRICE GetAppliedPrice() { return applied_price; }
  int GetPeriod() { return period; }
  // Setters.
  void SetPeriod(int _period) { period = _period; }
  void SetAppliedPrice(ENUM_APPLIED_PRICE _ap) { applied_price = _ap; }
  // Serializers.
  SERIALIZER_EMPTY_STUB;
  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(THIS_REF, "period", period);
    s.PassEnum(THIS_REF, "applied_price", applied_price);
    s.Enter(SerializerEnterObject);
    IndicatorParams::Serialize(s);
    s.Leave();
    return SerializerNodeObject;
  }
};

// Storing calculated average gain and loss for SMMA calculations.
struct RSIGainLossData {
  double avg_gain;
  double avg_loss;
  // Default constructor.
  RSIGainLossData() {}

  // Copy constructor.
  RSIGainLossData(const RSIGainLossData &r) : avg_gain(r.avg_gain), avg_loss(r.avg_loss) {}
};

/**
 * Implements the Relative Strength Index indicator.
 */
class Indi_RSI : public Indicator<IndiRSIParams> {
  DictStruct<int64, RSIGainLossData> aux_data;

 public:
  /**
   * Class constructor.
   */
  Indi_RSI(IndiRSIParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE, _indi_src_mode),
                  _indi_src) {}
  Indi_RSI(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(IndiRSIParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE, _indi_src_mode),
                  _indi_src) {}

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_AP; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * Returns applied price as set by the indicator's params.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.GetAppliedPrice(); }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/irsi
   * - https://www.mql5.com/en/docs/indicators/irsi
   */
  static double iRSI(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _period = 14,
                     ENUM_APPLIED_PRICE _applied_price = PRICE_CLOSE, int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iRSI(_symbol, _tf, _period, _applied_price, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iRSI(_symbol, _tf, _period, _applied_price), 0, _shift);
#endif
#else  // Non-MQL.
    // @todo: Use Platform class.
    RUNTIME_ERROR(
        "Not implemented. Please use an On-Indicator mode and attach "
        "indicator via Platform::Add/AddWithDefaultBindings().");
    return DBL_MAX;
#endif
  }

  /**
   * Calculates non-SMMA version of RSI on another indicator (uses iRSIOnArray).
   */
  template <typename IT>
  static double iRSIOnArrayOnIndicator(IndicatorData *_indi, string _symbol = NULL,
                                       ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _period = 14,
                                       ENUM_APPLIED_PRICE _applied_price = PRICE_CLOSE, int _shift = 0,
                                       Indi_RSI *_obj = NULL) {
    int i;
    ARRAY(double, indi_values);
    ArrayResize(indi_values, _period);

    double result;

    for (i = _shift; i < (int)_shift + (int)_period; i++) {
      indi_values[_shift + _period - (i - _shift) - 1] =
          _indi PTR_DEREF GetSpecificAppliedPriceValueStorage(_applied_price) PTR_DEREF Fetch(i);
    }

    result = iRSIOnArray(indi_values, 0, _period - 1, 0);

    return result;
  }

  /**
   * Calculates SMMA-based (same as iRSI method) RSI on another indicator.
   *
   * @see https://school.stockcharts.com/doku.php?id=technical_indicators:relative_strength_index_rsi
   *
   * Reason behind iRSI with SMMA and not just iRSIOnArray() (from above website):
   *
   * "Taking the prior value plus the current value is a smoothing technique
   * similar to that used in calculating an exponential moving average. This
   * also means that RSI values become more accurate as the calculation period
   * extends. SharpCharts uses at least 250 data points prior to the starting
   * date of any chart (assuming that much data exists) when calculating its
   * RSI values. To exactly replicate our RSI numbers, a formula will need at
   * least 250 data points."
   */
  static double iRSIOnIndicator(Indi_RSI *_target, IndicatorData *_source, string _symbol = NULL,
                                ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _period = 14,
                                ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0) {
    INDI_REQUIRE_BARS_OR_RETURN_EMPTY(_target, _period + _shift + 1);  // +1 because of _bar_time_prev.

    int64 _bar_time_curr = _source PTR_DEREF GetBarTime(_shift);
    int64 _bar_time_prev = _source PTR_DEREF GetBarTime(_shift + 1);
    if (fmin(_bar_time_curr, _bar_time_prev) < 0) {
      // Return empty value on invalid bar time.
      return EMPTY_VALUE;
    }

    int i;
    ARRAY(double, indi_values);
    ArrayResize(indi_values, _period);

    double result;

    // SMMA-based version of RSI.
    RSIGainLossData last_data, new_data;
    unsigned int data_position;
    double diff;

    ValueStorage<double> *_data = _source PTR_DEREF GetSpecificAppliedPriceValueStorage(_ap, _target);

    if (!_target PTR_DEREF aux_data.KeyExists(_bar_time_prev, data_position)) {
      // No previous SMMA-based average gain and loss. Calculating SMA-based ones.
      double sum_gain = 0;
      double sum_loss = 0;

      for (i = 1; i < (int)_period; i++) {
        double price_new = PTR_TO_REF(_data)[(_shift + 1) + i - 1].Get();
        double price_old = PTR_TO_REF(_data)[(_shift + 1) + i].Get();

        if (price_new == 0.0 || price_old == 0.0) {
          // Missing history price data, skipping calculations.
          return 0.0;
        }

        diff = price_new - price_old;

        if (diff > 0) {
          sum_gain += diff;
        } else {
          sum_loss += -diff;
        }
      }

      // Calculating SMA-based values.
      last_data.avg_gain = sum_gain / _period;
      last_data.avg_loss = sum_loss / _period;
    } else {
      // Data already exists, retrieving it by position got by KeyExists().
      last_data = _target PTR_DEREF aux_data.GetByPos(data_position);
    }

    diff = PTR_TO_REF(_data)[_shift].Get() - PTR_TO_REF(_data)[_shift + 1].Get();

    double curr_gain = 0;
    double curr_loss = 0;

    if (diff > 0)
      curr_gain += diff;
    else
      curr_loss += -diff;

    new_data.avg_gain = (last_data.avg_gain * (_period - 1) + curr_gain) / _period;
    new_data.avg_loss = (last_data.avg_loss * (_period - 1) + curr_loss) / _period;

    _target PTR_DEREF aux_data.Set(_bar_time_curr, new_data);

    if (new_data.avg_loss == 0.0) {
      // @fixme Why 0 loss?
      return 0;
    }

    double rs = new_data.avg_gain / new_data.avg_loss;

    result = 100.0 - (100.0 / (1.0 + rs));

    return result;
  }

  /**
   * Calculates RSI on the array of values.
   */
  static double iRSIOnArray(ARRAY_REF(double, array), int total, int period, int shift) {
#ifdef __MQL4__
    return ::iRSIOnArray(array, total, period, shift);
#else
    double diff;
    if (total == 0) total = ArraySize(array);
    int stop = total - shift;
    if (period <= 1 || shift < 0 || stop <= period) return 0;
    bool isSeries = ArrayGetAsSeries(array);
    if (isSeries) ArraySetAsSeries(array, false);
    int i;
    double SumP = 0;
    double SumN = 0;
    for (i = 1; i <= period; i++) {
      diff = array[i] - array[i - 1];
      if (diff > 0)
        SumP += diff;
      else
        SumN += -diff;
    }
    double AvgP = SumP / period;
    double AvgN = SumN / period;
    for (; i < stop; i++) {
      diff = array[i] - array[i - 1];
      AvgP = (AvgP * (period - 1) + (diff > 0 ? diff : 0)) / period;
      AvgN = (AvgN * (period - 1) + (diff < 0 ? -diff : 0)) / period;
    }
    double rsi;
    if (AvgN == 0.0) {
      rsi = (AvgP == 0.0 ? 50.0 : 100.0);
    } else {
      rsi = 100.0 - (100.0 / (1.0 + AvgP / AvgN));
    }
    if (isSeries) ArraySetAsSeries(array, true);
    return rsi;
#endif
  }

  /**
   * Returns the indicator's value.
   *
   * For IDATA_ICUSTOM mode, use those three externs:
   *
   * extern unsigned int period;
   * extern ENUM_APPLIED_PRICE applied_price; // Required only for MQL4.
   * extern int shift;
   *
   * Also, remember to use iparams.SetCustomIndicatorName(name) method to choose
   * indicator name, e.g.,: iparams.SetCustomIndicatorName("Examples\\RSI");
   *
   * Note that in MQL5 Applied Price must be passed as the last parameter
   * (before mode and shift).
   */
  IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) override {
#ifdef __debug_indicator__
    Print("Indi_RSI::GetEntryValue(mode = ", _mode, ", abs_shift = ", _abs_shift, ")");
#endif

    double _value = EMPTY_VALUE;
    ARRAY(double, _res);
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_RSI::iRSI(GetSymbol(), GetTf(), iparams.GetPeriod(), iparams.GetAppliedPrice(),
                                ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        // @todo Modify iRSIOnIndicator() to operate on single IndicatorData pointer.
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.custom_indi_name, /* [ */ iparams.GetPeriod(),
                         iparams.GetAppliedPrice() /* ] */, 0, ToRelShift(_abs_shift));
        break;
      case IDATA_INDICATOR:
        _value = Indi_RSI::iRSIOnIndicator(THIS_PTR, GetDataSource(), GetSymbol(), GetTf(), iparams.GetPeriod(),
                                           iparams.GetAppliedPrice(), ToRelShift(_abs_shift));
        break;
      default:
        RUNTIME_ERROR("Invalid indicator IDATA_* type!");
    }
    return _value;
  }
};

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iRSI(string _symbol, int _tf, int _period, int _ap, int _shift) {
  ResetLastError();
  return Indi_RSI::iRSI(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_APPLIED_PRICE)_ap, _shift);
}
double iRSIOnArray(ARRAY_REF(double, _arr), int _total, int _period, int _abs_shift) {
  ResetLastError();
  return Indi_RSI::iRSIOnArray(_arr, _total, _period, _abs_shift);
}
#endif

#ifdef EMSCRIPTEN
#include <emscripten/bind.h>

EMSCRIPTEN_BINDINGS(Indi_RSI_Params) {
  emscripten::value_object<IndiRSIParams>("indicators.RSIParams")
      .field("period", &IndiRSIParams::period)
      .field("appliedPrice", &IndiRSIParams::applied_price)
      // Inherited fields:
      .field("shift", &IndiRSIParams::shift);
}

EMSCRIPTEN_BINDINGS(Indi_RSIBase) {
  emscripten::class_<Indicator<IndiRSIParams>, emscripten::base<IndicatorData>>("Indi_RSIBase");
}

EMSCRIPTEN_BINDINGS(Indi_RSI) {
  emscripten::class_<Indi_RSI, emscripten::base<Indicator<IndiRSIParams>>>("indicators.RSI")
      .smart_ptr<Ref<Indi_RSI>>("Ref<Indi_RSI>")
      .constructor(&make_ref<Indi_RSI, IndiRSIParams &>)
      .constructor(&make_ref<Indi_RSI, IndiRSIParams &, ENUM_IDATA_SOURCE_TYPE>)
      .constructor(&make_ref<Indi_RSI, IndiRSIParams &, ENUM_IDATA_SOURCE_TYPE, IndicatorData *>,
                   emscripten::allow_raw_pointer<emscripten::arg<2>>())
      .constructor(&make_ref<Indi_RSI, IndiRSIParams &, ENUM_IDATA_SOURCE_TYPE, IndicatorData *, int>,
                   emscripten::allow_raw_pointer<emscripten::arg<2>>());
}

#endif
