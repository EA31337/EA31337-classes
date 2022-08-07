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

// Structs.
struct IndiVIDYAParams : IndicatorParams {
  unsigned int cmo_period;
  unsigned int ma_period;
  unsigned int vidya_shift;
  ENUM_APPLIED_PRICE applied_price;

  // Struct constructor.
  IndiVIDYAParams(unsigned int _cmo_period = 9, unsigned int _ma_period = 14, unsigned int _vidya_shift = 0,
                  ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0)
      : IndicatorParams(INDI_VIDYA) {
    applied_price = _ap;
    cmo_period = _cmo_period;
    ma_period = _ma_period;
    SetCustomIndicatorName("Examples\\VIDYA");
    shift = _shift;
    vidya_shift = _vidya_shift;
  };
  IndiVIDYAParams(IndiVIDYAParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Variable Index Dynamic Average indicator.
 */
class Indi_VIDYA : public Indicator<IndiVIDYAParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_VIDYA(IndiVIDYAParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_VIDYA(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(IndiVIDYAParams(),
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
   * Built-in version of iVIDyA.
   */
  static double iVIDyA(string _symbol, ENUM_TIMEFRAMES _tf, int _cmo_period, int _ema_period, int _ma_shift,
                       ENUM_APPLIED_PRICE _ap, int _mode = 0, int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iVIDyA(_symbol, _tf, _cmo_period, _ema_period, _ma_shift, _ap), _mode, _shift);
#else
    if (_obj == nullptr) {
      Print(
          "Indi_VIDYA::iVIDyA() can work without supplying pointer to IndicatorData only in MQL5. In this platform "
          "the pointer is required.");
      DebugBreak();
      return 0;
    }

    return iVIDyAOnIndicator(_obj, _symbol, _tf, _cmo_period, _ema_period, _ma_shift, _ap, _mode, _shift);
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
   * On-indicator version of VIDya indicator.
   */
  static double iVIDyAOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, int _cmo_period,
                                  int _ema_period, int _ma_shift, ENUM_APPLIED_PRICE _ap, int _mode = 0, int _shift = 0,
                                  IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(_indi, _ap,
                                                        Util::MakeKey(_cmo_period, _ema_period, _ma_shift, (int)_ap));
    return iVIDyAOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _cmo_period, _ema_period, _ma_shift, _mode, _shift,
                         _cache);
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
    // Main cycle.
    for (i = start; i < rates_total && !IsStopped(); i++) {
      double mul_CMO = MathAbs(CalculateCMO(i, InpPeriodCMO, price));
      // Calculate VIDYA.
      VIDYA_Buffer[i] = price[i] * ExtF * mul_CMO + VIDYA_Buffer[i - 1] * (1 - ExtF * mul_CMO);
    }
    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  /**
   * Chande Momentum Oscillator.
   */
  static double CalculateCMO(int pos, const int period, ValueStorage<double> &price) {
    double res = 0.0;
    double sum_up = 0.0, sum_down = 0.0;
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
    return (res);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_VIDYA::iVIDyA(GetSymbol(), GetTf(), /*[*/ GetCMOPeriod(), GetMAPeriod(), GetVIDYAShift(),
                                    GetAppliedPrice() /*]*/, 0, _ishift, THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        _value =
            Indi_VIDYA::iVIDyAOnIndicator(GetDataSource(), GetSymbol(), GetTf(), /*[*/ GetCMOPeriod(), GetMAPeriod(),
                                          GetVIDYAShift(), GetAppliedPrice() /*]*/, _mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/
                         GetCMOPeriod(), GetMAPeriod(),
                         GetVIDYAShift()
                         /*]*/,
                         0, _ishift);
        break;
      case IDATA_INDICATOR:
        _value =
            Indi_VIDYA::iVIDyAOnIndicator(GetDataSource(), GetSymbol(), GetTf(), /*[*/ GetCMOPeriod(), GetMAPeriod(),
                                          GetVIDYAShift(), GetAppliedPrice() /*]*/, _mode, _ishift, THIS_PTR);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get CMO period.
   */
  unsigned int GetCMOPeriod() { return iparams.cmo_period; }

  /**
   * Get MA period.
   */
  unsigned int GetMAPeriod() { return iparams.ma_period; }

  /**
   * Get VIDYA shift.
   */
  unsigned int GetVIDYAShift() { return iparams.vidya_shift; }

  /**
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /* Setters */

  /**
   * Set CMO period.
   */
  void SetCMOPeriod(unsigned int _cmo_period) {
    istate.is_changed = true;
    iparams.cmo_period = _cmo_period;
  }

  /**
   * Set MA period.
   */
  void SetMAPeriod(unsigned int _ma_period) {
    istate.is_changed = true;
    iparams.ma_period = _ma_period;
  }

  /**
   * Set VIDYA shift.
   */
  void SetVIDYAShift(unsigned int _vidya_shift) {
    istate.is_changed = true;
    iparams.vidya_shift = _vidya_shift;
  }

  /**
   * Set applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};
