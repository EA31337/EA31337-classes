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
  IndiDetrendedPriceParams(IndiDetrendedPriceParams &_params) { THIS_REF = _params; };
};

/**
 * Implements Detrended Price Oscillator.
 */
class Indi_DetrendedPrice : public Indicator<IndiDetrendedPriceParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_DetrendedPrice(IndiDetrendedPriceParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                      IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_DetrendedPrice(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                      int _indi_src_mode = 0)
      : Indicator(IndiDetrendedPriceParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_AP; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiDetrendedPriceParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // Volume uses volume only.
    return _ds PTR_DEREF HasSpecificValueStorage(INDI_VS_TYPE_VOLUME);
  }

  /**
   * Built-in version of DPO.
   */
  static double iDPO(IndicatorData *_indi, int _period, ENUM_APPLIED_PRICE _ap, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(_indi, _ap, Util::MakeKey(_indi.GetId()));
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
      case IDATA_ONCALCULATE:
        _value = iDPO(THIS_PTR, GetPeriod(), GetAppliedPrice(), _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         0, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = iDPO(THIS_PTR, GetPeriod(), GetAppliedPrice(), _mode, _ishift);
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
