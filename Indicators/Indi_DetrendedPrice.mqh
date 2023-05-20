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
#include "../Storage/ValueStorage.price.h"
#include "Indi_MA.mqh"

// Structs.
struct IndiDetrendedPriceParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  IndiDetrendedPriceParams(int _period = 12, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0)
      : IndicatorParams(INDI_DETRENDED_PRICE) {
    applied_price = _ap;
    SetCustomIndicatorName("Examples\\DPO");
    period = _period;
    shift = _shift;
  };
  IndiDetrendedPriceParams(IndiDetrendedPriceParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements Detrended Price Oscillator.
 */
class Indi_DetrendedPrice : public IndicatorTickOrCandleSource<IndiDetrendedPriceParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_DetrendedPrice(IndiDetrendedPriceParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                      IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : IndicatorTickOrCandleSource(
            _p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
            _indi_src){};
  Indi_DetrendedPrice(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0)
      : IndicatorTickOrCandleSource(INDI_DETRENDED_PRICE, _tf, _shift){};

  /**
   * Built-in version of AMA.
   */
  static double iDPO(string _symbol, ENUM_TIMEFRAMES _tf, int _period, ENUM_APPLIED_PRICE _ap, int _mode = 0,
                     int _shift = 0, IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(_symbol, _tf, _ap,
                                                        Util::MakeKey("Indi_DPO", _period, (int)_ap));
    return iDPOOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _period, _ap, _mode, _shift, _cache);
  }

  /**
   * Calculates DPO on the array of values.
   */
  static double iDPOOnArray(INDICATOR_CALCULATE_PARAMS_SHORT, int _period, ENUM_APPLIED_PRICE _ap, int _mode,
                            int _shift, IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_price);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1 + 1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_DetrendedPrice::Calculate(
        INDICATOR_CALCULATE_GET_PARAMS_SHORT, _cache.GetBuffer<double>(0), _cache.GetBuffer<double>(1), _period));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * On-indicator version of DPO.
   */
  static double iDPOOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, int _period,
                                ENUM_APPLIED_PRICE _ap, int _mode = 0, int _shift = 0, IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT_DS(
        _indi, _symbol, _tf, _ap, Util::MakeKey("Indi_DPO_ON_" + _indi.GetFullName(), _period, (int)_ap));
    return iDPOOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _period, _ap, _mode, _shift, _cache);
  }

  /**
   * OnCalculate() method for DPO indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_SHORT, ValueStorage<double> &ExtDPOBuffer,
                       ValueStorage<double> &ExtMABuffer, int InpDetrendPeriod) {
    int ExtMAPeriod = InpDetrendPeriod / 2 + 1;

    int start;
    int first_index = begin + ExtMAPeriod - 1;
    // Preliminary filling.
    if (prev_calculated < first_index) {
      ArrayInitialize(ExtDPOBuffer, 0.0);
      start = first_index;
      if (begin > 0) PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, first_index);
    } else
      start = prev_calculated - 1;
    // Calculate simple moving average.
    Indi_MA::SimpleMAOnBuffer(rates_total, prev_calculated, begin, ExtMAPeriod, price, ExtMABuffer);
    // The main loop of calculations.
    for (int i = start; i < rates_total && !IsStopped(); i++) ExtDPOBuffer[i] = price[i] - ExtMABuffer[i];
    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_DetrendedPrice::iDPO(GetSymbol(), GetTf(), /*[*/ GetPeriod(), GetAppliedPrice() /*]*/, _mode,
                                           _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         0, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_DetrendedPrice::iDPOOnIndicator(GetDataSource(), GetSymbol(), GetTf(), /*[*/ GetPeriod(),
                                                      GetAppliedPrice() /*]*/, _mode, _ishift, THIS_PTR);
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
   * Set applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};
