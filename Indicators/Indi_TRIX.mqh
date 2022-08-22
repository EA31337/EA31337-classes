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
#include "Indi_MA.mqh"

// Structs.
struct IndiTRIXParams : IndicatorParams {
  unsigned int period;
  unsigned int tema_shift;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  IndiTRIXParams(int _period = 14, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0) : IndicatorParams(INDI_TRIX) {
    applied_price = _ap;
    SetCustomIndicatorName("Examples\\TRIX");
    period = _period;
    shift = _shift;
  };
  IndiTRIXParams(IndiTRIXParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Triple Exponential Average indicator.
 */
class Indi_TRIX : public Indicator<IndiTRIXParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_TRIX(IndiTRIXParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_TRIX(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(IndiTRIXParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
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
   * Built-in version of TriX.
   */
  static double iTriX(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, ENUM_APPLIED_PRICE _ap, int _mode = 0,
                      int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iTriX(_symbol, _tf, _ma_period, _ap), _mode, _shift);
#else
    if (_obj == nullptr) {
      Print(
          "Indi_TRIX::iTriX() can work without supplying pointer to IndicatorData only in MQL5. In this platform "
          "the pointer is required.");
      DebugBreak();
      return 0;
    }

    return iTriXOnIndicator(_obj, _ma_period, _ap, _mode, _shift);
#endif
  }

  /**
   * Calculates TriX on the array of values.
   */
  static double iTriXOnArray(INDICATOR_CALCULATE_PARAMS_SHORT, int _ma_period, int _mode, int _shift,
                             IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_price);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(4);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_TRIX::Calculate(INDICATOR_CALCULATE_GET_PARAMS_SHORT, _cache.GetBuffer<double>(0),
                                                  _cache.GetBuffer<double>(1), _cache.GetBuffer<double>(2),
                                                  _cache.GetBuffer<double>(3), _ma_period));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * On-indicator version of TriX.
   */
  static double iTriXOnIndicator(IndicatorData *_indi, int _ma_period, ENUM_APPLIED_PRICE _ap, int _mode = 0,
                                 int _shift = 0, IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(_indi, _ap, Util::MakeKey(_ma_period, (int)_ap));
    return iTriXOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _ma_period, _mode, _shift, _cache);
  }

  /**
   * OnCalculate() method for TriX indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_SHORT, ValueStorage<double> &TRIX_Buffer,
                       ValueStorage<double> &EMA, ValueStorage<double> &SecondEMA, ValueStorage<double> &ThirdEMA,
                       int InpPeriodEMA) {
    if (rates_total < 3 * InpPeriodEMA - 3) return (0);
    int start, i;
    if (prev_calculated == 0) {
      start = 3 * (InpPeriodEMA - 1);
      for (i = 0; i < start; i++) TRIX_Buffer[i] = EMPTY_VALUE;
    } else
      start = prev_calculated - 1;
    // Calculate EMA.
    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, 0, InpPeriodEMA, price, EMA);
    // Calculate EMA on EMA array.
    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, InpPeriodEMA - 1, InpPeriodEMA, EMA, SecondEMA);
    // Calculate EMA on EMA array on EMA array.
    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, 2 * InpPeriodEMA - 2, InpPeriodEMA, SecondEMA,
                                   ThirdEMA);
    // Calculate TRIX
    for (i = start; i < rates_total && !IsStopped(); i++) {
      if (ThirdEMA[i - 1] != 0.0)
        TRIX_Buffer[i] = (ThirdEMA[i] - ThirdEMA[i - 1]) / ThirdEMA[i - 1].Get();
      else
        TRIX_Buffer[i] = 0.0;
    }
    // OnCalculate done. Return new prev_calculated.
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
        _value = Indi_TRIX::iTriX(GetSymbol(), GetTf(), /*[*/ GetPeriod(), GetAppliedPrice() /*]*/, _mode, _ishift,
                                  THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        _value = Indi_TRIX::iTriXOnIndicator(GetDataSource(), GetPeriod(), GetAppliedPrice(), _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         0, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_TRIX::iTriXOnIndicator(GetDataSource(), GetPeriod(), GetAppliedPrice(), _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};
