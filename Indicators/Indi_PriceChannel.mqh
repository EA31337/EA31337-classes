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
#include "Indi_ZigZag.mqh"

// Structs.
struct IndiPriceChannelParams : IndicatorParams {
  unsigned int period;
  // Struct constructor.
  IndiPriceChannelParams(unsigned int _period = 22, int _shift = 0) : IndicatorParams(INDI_PRICE_CHANNEL) {
    period = _period;
    SetCustomIndicatorName("Examples\\Price_Channel");
    shift = _shift;
  };
  IndiPriceChannelParams(IndiPriceChannelParams &_params) { THIS_REF = _params; };
};

/**
 * Implements Price Channel indicator.
 */
class Indi_PriceChannel : public Indicator<IndiPriceChannelParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_PriceChannel(IndiPriceChannelParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                    IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(3, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_PriceChannel(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                    int _indi_src_mode = 0)
      : Indicator(IndiPriceChannelParams(),
                  IndicatorDataParams::GetInstance(3, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_CUSTOM; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiPriceChannelParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // PC uses high and low prices only.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH | PRICE_LOW);
  }

  /**
   * OnCalculate-based version of Price Channel indicator as there is no built-in one.
   */
  static double iPriceChannel(IndicatorData *_indi, int _period, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey(_period));
    return iPriceChannelOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _period, _mode, _shift, _cache);
  }

  /**
   * Calculates Price Channel on the array of values.
   */
  static double iPriceChannelOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _period, int _mode, int _shift,
                                     IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(3);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_PriceChannel::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG,
                                                          _cache.GetBuffer<double>(0), _cache.GetBuffer<double>(1),
                                                          _cache.GetBuffer<double>(2), _period));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for Price Channel indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtHighBuffer,
                       ValueStorage<double> &ExtLowBuffer, ValueStorage<double> &ExtMiddBuffer, int InpChannelPeriod) {
    if (rates_total < InpChannelPeriod) return (0);

    int start = prev_calculated == 0 ? InpChannelPeriod : prev_calculated - 1;
    for (int i = start; i < rates_total && !IsStopped(); i++) {
      ExtHighBuffer[i] = Indi_ZigZag::Highest(high, InpChannelPeriod, i);
      ExtLowBuffer[i] = Indi_ZigZag::Lowest(low, InpChannelPeriod, i);
      ExtMiddBuffer[i] = (ExtHighBuffer[i] + ExtLowBuffer[i]) / 2.0;
    }
    // Returns new prev_calculated.
    return rates_total;
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
        _value = iPriceChannel(THIS_PTR, GetPeriod(), _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         0, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = iPriceChannel(THIS_PTR, GetPeriod(), _mode, _ishift);
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

  /* Setters */

  /**
   * Set period.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }
};
