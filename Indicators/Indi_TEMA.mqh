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
#include "../Storage/ValueStorage.price.h"
#include "Indi_MA.mqh"

// Structs.
struct TEMAParams : IndicatorParams {
  unsigned int period;
  unsigned int tema_shift;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  void TEMAParams(int _period = 14, int _tema_shift = 0, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0,
                  ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    applied_price = _ap;
    itype = INDI_TEMA;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\TEMA");
    SetDataSourceType(IDATA_BUILTIN);
    period = _period;
    shift = _shift;
    tema_shift = _tema_shift;
    tf = _tf;
  };
  void TEMAParams(TEMAParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Triple Exponential Moving Average indicator.
 */
class Indi_TEMA : public Indicator {
 protected:
  TEMAParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_TEMA(TEMAParams &_params) : params(_params.period, _params.tema_shift), Indicator((IndicatorParams)_params) {
    params = _params;
  };
  Indi_TEMA(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_TEMA, _tf) { params.tf = _tf; };

  /**
   * Built-in version of TEMA.
   */
  static double iTEMA(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, int _ma_shift, ENUM_APPLIED_PRICE _ap,
                      int _mode = 0, int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iTEMA(_symbol, _tf, _ma_period, _ma_shift, _ap), _mode, _shift);
#else
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(_symbol, _tf, _ap,
                                                        Util::MakeKey("Indi_TEMA", _ma_period, _ma_shift, (int)_ap));
    return iTEMAOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _ma_period, _ma_shift, _mode, _shift, _cache);
#endif
  }

  /**
   * Calculates iTEMA on the array of values.
   */
  static double iTEMAOnArray(INDICATOR_CALCULATE_PARAMS_SHORT, int _ma_period, int _ma_shift, int _mode, int _shift,
                             IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_price);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(4);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_TEMA::Calculate(INDICATOR_CALCULATE_GET_PARAMS_SHORT, _cache.GetBuffer<double>(0),
                                                  _cache.GetBuffer<double>(1), _cache.GetBuffer<double>(2),
                                                  _cache.GetBuffer<double>(3), _ma_period, _ma_shift));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for TEMA indicator.
   *
   * Note that InpShift is used for drawing only and thus is unused.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_SHORT, ValueStorage<double> &TemaBuffer,
                       ValueStorage<double> &Ema, ValueStorage<double> &EmaOfEma, ValueStorage<double> &EmaOfEmaOfEma,
                       int InpPeriodEMA, int InpShift) {
    if (rates_total < 3 * InpPeriodEMA - 3) return (0);
    //---
    int start;
    if (prev_calculated == 0)
      start = 0;
    else
      start = prev_calculated - 1;
    //--- calculate EMA
    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, 0, InpPeriodEMA, price, Ema);
    //--- calculate EMA on EMA array
    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, InpPeriodEMA - 1, InpPeriodEMA, Ema, EmaOfEma);
    //--- calculate EMA on EMA array on EMA array
    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, 2 * InpPeriodEMA - 2, InpPeriodEMA, EmaOfEma,
                                   EmaOfEmaOfEma);
    //--- calculate TEMA
    for (int i = start; i < rates_total && !IsStopped(); i++)
      TemaBuffer[i] = 3 * Ema[i].Get() - 3 * EmaOfEma[i].Get() + EmaOfEmaOfEma[i].Get();
    //--- OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_TEMA::iTEMA(GetSymbol(), GetTf(), /*[*/ GetPeriod(), GetTEMAShift(), GetAppliedPrice() /*]*/, 0,
                                  _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.GetCustomIndicatorName(), /*[*/ GetPeriod(),
                         GetTEMAShift() /*]*/, 0, _shift);
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
      _entry.values[0] = GetValue(_shift);
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

  /* Getters */

  /**
   * Get period.
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get TEMA shift.
   */
  unsigned int GetTEMAShift() { return params.tema_shift; }

  /**
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Set TEMA shift.
   */
  void SetTEMAShift(unsigned int _tema_shift) {
    istate.is_changed = true;
    params.tema_shift = _tema_shift;
  }

  /**
   * Set applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }
};
