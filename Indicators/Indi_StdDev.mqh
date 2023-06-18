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

/*
 * @file
 * Standard Deviation indicator.
 *
 * It doesn't give independent signals. Is used to define volatility (trend strength).
 */

// Includes.
#include "../Indicator/Indicator.h"
#include "../Storage/Cache/ObjectsCache.h"
#include "Price/Indi_MA.h"
#include "Indi_PriceFeeder.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iStdDev(string _symbol, int _tf, int _ma_period, int _ma_shift, int _ma_method, int _ap, int _shift) {
  ResetLastError();
  return Indi_StdDev::iStdDev(_symbol, (ENUM_TIMEFRAMES)_tf, _ma_period, _ma_shift, (ENUM_MA_METHOD)_ma_method,
                              (ENUM_APPLIED_PRICE)_ap, _shift);
}
double iStdDevOnArray(double &_arr[], int _total, int _ma_period, int _ma_shift, int _ma_method, int _abs_shift) {
  ResetLastError();
  return Indi_StdDev::iStdDevOnArray(_arr, _total, _ma_period, _ma_shift, (ENUM_MA_METHOD)_ma_method, _abs_shift);
}
#endif

// Structs.
struct IndiStdDevParams : IndicatorParams {
  int ma_period;
  int ma_shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  IndiStdDevParams(int _ma_period = 13, int _ma_shift = 10, ENUM_MA_METHOD _ma_method = MODE_SMA,
                   ENUM_APPLIED_PRICE _ap = PRICE_OPEN, int _shift = 0)
      : ma_period(_ma_period),
        ma_shift(_ma_shift),
        ma_method(_ma_method),
        applied_price(_ap),
        IndicatorParams(INDI_STDDEV) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\StdDev");
  };
  IndiStdDevParams(IndiStdDevParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Standard Deviation indicator.
 */
class Indi_StdDev : public Indicator<IndiStdDevParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_StdDev(IndiStdDevParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {}
  Indi_StdDev(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0)
      : Indicator(IndiStdDevParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {}
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_AP; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override {
    return IDATA_BUILTIN | IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR;
  }

  /**
   * Calculates the Standard Deviation indicator and returns its value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/istddev
   * - https://www.mql5.com/en/docs/indicators/istddev
   */
  static double iStdDev(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, int _ma_shift, ENUM_MA_METHOD _ma_method,
                        ENUM_APPLIED_PRICE _applied_price, int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price), 0,
                                      _shift);
#endif
#else // Non-MQL.
    // @todo: Use Platform class.
    RUNTIME_ERROR(
        "Not implemented. Please use an On-Indicator mode and attach "
        "indicator via Platform::Add/AddWithDefaultBindings().");
    return DBL_MAX;
#endif
  }

  /**
   * Note that this method operates on current price (set by _applied_price).
   */
  static double iStdDevOnIndicator(IndicatorData *_target, IndicatorData *_source, string _symbol, ENUM_TIMEFRAMES _tf,
                                   int _ma_period, int _ma_shift, ENUM_APPLIED_PRICE _ap, int _shift = 0,
                                   Indi_StdDev *_obj = NULL) {
    INDI_REQUIRE_BARS_OR_RETURN_EMPTY(_source, _ma_period + _ma_shift + _shift)

    double _indi_value_buffer[];
    double _std_dev;
    int i;

    ValueStorage<double> *_data = _source PTR_DEREF GetSpecificAppliedPriceValueStorage(_ap, _target);

    ArrayResize(_indi_value_buffer, _ma_period);

    for (i = _shift; i < (int)_shift + (int)_ma_period; i++) {
      // Getting current indicator value. Input data may be shifted on
      // the graph, so we need to take that shift into consideration.
      _indi_value_buffer[i - _shift] = PTR_TO_REF(_data)[i + _ma_shift].Get();
    }

    double _ma = Indi_MA::SimpleMA(_shift, _ma_period, _indi_value_buffer);

    // Standard deviation.
    _std_dev = Indi_StdDev::iStdDevOnArray(_indi_value_buffer, _ma, _ma_period);

    return _std_dev;
  }

  static double iStdDevOnArray(const double &price[], double MAprice, int period) {
    double std_dev = 0;
    int i;

    for (i = 0; i < period; ++i) std_dev += MathPow(price[i] - MAprice, 2);

    return MathSqrt(std_dev / period);
  }

  static double iStdDevOnArray(double &array[], int total, int ma_period, int ma_shift, int ma_method, int shift) {
#ifdef __MQL4__
    return ::iStdDevOnArray(array, total, ma_period, ma_shift, ma_method, shift);
#endif
    bool was_series = ArrayGetAsSeries(array);
    if (!was_series) {
      ArraySetAsSeries(array, true);
    }
    int num = shift + ma_shift;
    bool flag = total == 0;
    if (flag) {
      total = ArraySize(array);
    }
    bool flag2 = num < 0 || num >= total;
    double result;
    if (flag2) {
      result = -1.0;
    } else {
      bool flag3 = ma_method != 1 && num + ma_period > total;
      if (flag3) {
        result = -1.0;
      } else {
        double num2 = 0.0;
        double num3 = Indi_MA::iMAOnArray(array, total, ma_period, 0, ma_method, num);
        for (int i = 0; i < ma_period; i++) {
          double num4 = array[num + i];  // true?
          num2 += (num4 - num3) * (num4 - num3);
        }
        double num5 = MathSqrt(num2 / (double)ma_period);
        result = num5;
      }
    }

    if (!was_series) {
      ArraySetAsSeries(array, false);
    }

    return result;
  }

  /**
   * Standard Deviation On Array is just a normal standard deviation over MA with a selected method.
   */
  static double iStdDevOnArray(const double &price[], int period, ENUM_MA_METHOD ma_method = MODE_SMA) {
    string _key = "Indi_PriceFeeder";
    Indi_PriceFeeder *_indi_price_feeder;
    if (!ObjectsCache<Indi_PriceFeeder>::TryGet(_key, _indi_price_feeder)) {
      IndiPriceFeederParams _params();
      IndicatorData *_indi_pf = new Indi_PriceFeeder(_params);
      _indi_price_feeder = ObjectsCache<Indi_PriceFeeder>::Set(_key, _indi_pf);
    }

    // Filling reused price feeder.
    _indi_price_feeder.SetPrices(price);

    IndiMAParams ma_params(period, 0, ma_method, PRICE_OPEN);

    /*
    Indi_MA *_indi_ma =
        Indi_MA::GetCached("Indi_StdDev:Unbuffered", (ENUM_TIMEFRAMES)-1, period, 0, ma_method, (ENUM_APPLIED_PRICE)-1);

    _indi_ma.SetDataSource(_indi_price_feeder, 0);  // Using first and only mode from price feeder.
    double _result = iStdDevOnIndicator(_indi_ma, NULL, NULL, period, 0, PRICE_OPEN, 0); // Last parameter is unused.
    // We don't want to store reference to indicator too long.
    _indi_ma.SetDataSource(NULL, 0);

    return _result;
    */
    Print(__FUNCTION__ + " must be refactored!");
    DebugBreak();
    return 0;
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) {
    double _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_StdDev::iStdDev(GetSymbol(), GetTf(), GetMAPeriod(), GetMAShift(), GetMAMethod(),
                                      GetAppliedPrice(), ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        _value = Indi_StdDev::iStdDevOnIndicator(THIS_PTR, GetDataSource(), GetSymbol(), GetTf(), GetMAPeriod(),
                                                 GetMAShift(), GetAppliedPrice(), ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetMAPeriod(),
                         GetMAShift(), GetMAMethod() /*]*/, 0, ToRelShift(_abs_shift));
        break;
      case IDATA_INDICATOR:
        _value = Indi_StdDev::iStdDevOnIndicator(THIS_PTR, GetDataSource(), GetSymbol(), GetTf(), GetMAPeriod(),
                                                 GetMAShift(), GetAppliedPrice(), ToRelShift(_abs_shift), THIS_PTR);
        break;
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  int GetMAPeriod() { return iparams.ma_period; }

  /**
   * Get MA shift value.
   *
   * Indicators line offset relate to the chart by timeframe.
   */
  unsigned int GetMAShift() { return iparams.ma_shift; }

  /**
   * Set MA method (smoothing type).
   */
  ENUM_MA_METHOD GetMAMethod() { return iparams.ma_method; }

  /**
   * Get applied price value.
   *
   * The desired price base for calculations.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /* Setters */

  /**
   * Set period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  void SetMAPeriod(int _ma_period) {
    istate.is_changed = true;
    iparams.ma_period = _ma_period;
  }

  /**
   * Set MA shift value.
   */
  void SetMAShift(int _ma_shift) {
    istate.is_changed = true;
    iparams.ma_shift = _ma_shift;
  }

  /**
   * Set MA method.
   *
   * Indicators line offset relate to the chart by timeframe.
   */
  void SetMAMethod(ENUM_MA_METHOD _ma_method) {
    istate.is_changed = true;
    iparams.ma_method = _ma_method;
  }

  /**
   * Set applied price value.
   *
   * The desired price base for calculations.
   * @docs
   * - https://docs.mql4.com/constants/indicatorconstants/prices#enum_applied_price_enum
   * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};
