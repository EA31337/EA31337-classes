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
#include "../ValueStorage.price.h"

// Structs.
struct VIDYAParams : IndicatorParams {
  unsigned int cmo_period;
  unsigned int ma_period;
  unsigned int vidya_shift;
  ENUM_APPLIED_PRICE applied_price;

  // Struct constructor.
  void VIDYAParams(unsigned int _cmo_period = 9, unsigned int _ma_period = 14, unsigned int _vidya_shift = 0,
                   ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    applied_price = _ap;
    cmo_period = _cmo_period;
    itype = INDI_VIDYA;
    ma_period = _ma_period;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\VIDYA");
    SetDataSourceType(IDATA_BUILTIN);
    shift = _shift;
    tf = _tf;
    vidya_shift = _vidya_shift;
  };
  void VIDYAParams(VIDYAParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Variable Index Dynamic Average indicator.
 */
class Indi_VIDYA : public Indicator {
 protected:
  VIDYAParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_VIDYA(VIDYAParams &_params) : Indicator((IndicatorParams)_params) { params = _params; };
  Indi_VIDYA(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_VIDYA, _tf) { params.tf = _tf; };

  /**
   * Built-in version of iVIDyA.
   */
  static double iVIDyA(string _symbol, ENUM_TIMEFRAMES _tf, int _cmo_period, int _ema_period, int _ma_shift,
                       ENUM_APPLIED_PRICE _ap, int _mode = 0, int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iVIDyA(_symbol, _tf, _cmo_period, _ema_period, _ma_shift, _ap), _mode, _shift);
#else
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(
        _symbol, _tf, _ap, Util::MakeKey("Indi_VIDYA", _cmo_period, _ema_period, _ma_shift, (int)_ap));
    return iVIDyAOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _cmo_period, _ema_period, _ma_shift, _mode, _shift,
                         _cache);
#endif
  }

  /**
   * Calculates iVIDyA on the array of values.
   */
  static double iVIDyAOnArray(INDICATOR_CALCULATE_PARAMS_SHORT, int _cmo_period, int _ema_period, int _ma_shift,
                              int _mode, int _shift, IndicatorCalculateCache<double> *_cache,
                              bool _recalculate = false) {
    _cache.SetPriceBuffer(_price);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_VIDYA::Calculate(INDICATOR_CALCULATE_GET_PARAMS_SHORT, _cache.GetBuffer<double>(0),
                                                   _cmo_period, _ema_period, _ma_shift));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for VIDyA indicator.
   *
   * Note that InpShift is used for drawing only and thus is unused.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_SHORT, ValueStorage<double> &VIDYA_Buffer, int InpPeriodCMO,
                       int InpPeriodEMA, int InpShift) {
    double ExtF = 2.0 / (1.0 + InpPeriodEMA);

    if (rates_total < InpPeriodEMA + InpPeriodCMO - 1) return (0);
    //---
    int i, start;
    if (prev_calculated < InpPeriodEMA + InpPeriodCMO - 1) {
      start = InpPeriodEMA + InpPeriodCMO - 1;
      for (i = 0; i < start; i++) VIDYA_Buffer[i] = price[i];
    } else
      start = prev_calculated - 1;
    //--- main cycle
    for (i = start; i < rates_total && !IsStopped(); i++) {
      double mul_CMO = MathAbs(CalculateCMO(i, InpPeriodCMO, price));
      //--- calculate VIDYA
      VIDYA_Buffer[i] = price[i] * ExtF * mul_CMO + VIDYA_Buffer[i - 1] * (1 - ExtF * mul_CMO);
    }
    //--- OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  /**
   * Chande Momentum Oscillator.
   */
  static double CalculateCMO(int pos, const int period, ValueStorage<double> &price) {
    double res = 0.0;
    double sum_up = 0.0, sum_down = 0.0;
    //---
    if (pos >= period && pos < ArraySize(price)) {
      for (int i = 0; i < period; i++) {
        double diff = price[pos - i] - price[pos - i - 1];
        if (diff > 0.0)
          sum_up += diff;
        else
          sum_down += (-diff);
      }
      if (sum_up + sum_down != 0.0) res = (sum_up - sum_down) / (sum_up + sum_down);
    }
    //---
    return (res);
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_VIDYA::iVIDyA(GetSymbol(), GetTf(), /*[*/ GetCMOPeriod(), GetMAPeriod(), GetVIDYAShift(),
                                    GetAppliedPrice() /*]*/, 0, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.GetCustomIndicatorName(), /*[*/
                         GetCMOPeriod(), GetMAPeriod(),
                         GetVIDYAShift()
                         /*]*/,
                         0, _shift);
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
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
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
   * Get CMO period.
   */
  unsigned int GetCMOPeriod() { return params.cmo_period; }

  /**
   * Get MA period.
   */
  unsigned int GetMAPeriod() { return params.ma_period; }

  /**
   * Get VIDYA shift.
   */
  unsigned int GetVIDYAShift() { return params.vidya_shift; }

  /**
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

  /* Setters */

  /**
   * Set CMO period.
   */
  void SetCMOPeriod(unsigned int _cmo_period) {
    istate.is_changed = true;
    params.cmo_period = _cmo_period;
  }

  /**
   * Set MA period.
   */
  void SetMAPeriod(unsigned int _ma_period) {
    istate.is_changed = true;
    params.ma_period = _ma_period;
  }

  /**
   * Set VIDYA shift.
   */
  void SetVIDYAShift(unsigned int _vidya_shift) {
    istate.is_changed = true;
    params.vidya_shift = _vidya_shift;
  }

  /**
   * Set applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }
};
