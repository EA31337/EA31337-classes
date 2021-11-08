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
struct IndiTEMAParams : IndicatorParams {
  unsigned int period;
  unsigned int tema_shift;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  IndiTEMAParams(int _period = 14, int _tema_shift = 0, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0)
      : IndicatorParams(INDI_TEMA, 1, TYPE_DOUBLE) {
    applied_price = _ap;
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\TEMA");
    period = _period;
    shift = _shift;
    tema_shift = _tema_shift;
  };
  IndiTEMAParams(IndiTEMAParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Triple Exponential Moving Average indicator.
 */
class Indi_TEMA : public Indicator<IndiTEMAParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_TEMA(IndiTEMAParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiTEMAParams>(_p, _indi_src){};
  Indi_TEMA(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_TEMA, _tf, _shift){};

  /**
   * Built-in version of TEMA.
   */
  static double iTEMA(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, int _ma_shift, ENUM_APPLIED_PRICE _ap,
                      int _mode = 0, int _shift = 0, Indi_TEMA *_obj = NULL) {
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
    // Calculate EMA.
    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, 0, InpPeriodEMA, price, Ema);
    // Calculate EMA on EMA array.
    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, InpPeriodEMA - 1, InpPeriodEMA, Ema, EmaOfEma);
    // Calculate EMA on EMA array on EMA array.
    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, 2 * InpPeriodEMA - 2, InpPeriodEMA, EmaOfEma,
                                   EmaOfEmaOfEma);
    // Calculate TEMA.
    for (int i = start; i < rates_total && !IsStopped(); i++)
      TemaBuffer[i] = 3 * Ema[i].Get() - 3 * EmaOfEma[i].Get() + EmaOfEmaOfEma[i].Get();
    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_TEMA::iTEMA(GetSymbol(), GetTf(), /*[*/ GetPeriod(), GetTEMAShift(), GetAppliedPrice() /*]*/, 0,
                                  _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod(),
                         GetTEMAShift() /*]*/, 0, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE);
  }

  /* Getters */

  /**
   * Get period.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get TEMA shift.
   */
  unsigned int GetTEMAShift() { return iparams.tema_shift; }

  /**
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return iparams.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set TEMA shift.
   */
  void SetTEMAShift(unsigned int _tema_shift) {
    istate.is_changed = true;
    iparams.tema_shift = _tema_shift;
  }

  /**
   * Set applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};
