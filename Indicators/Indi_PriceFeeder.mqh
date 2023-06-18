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

// Includes.
#include "../Storage/Dict/Buffer/BufferStruct.h"
#include "../Indicator/Indicator.h"

// Structs.
struct IndiPriceFeederParams : IndicatorParams {
  ENUM_APPLIED_PRICE applied_price;
  double price_data[];

  /**
   * Struct constructor.
   */
  IndiPriceFeederParams(int _shift = 0) : IndicatorParams(INDI_PRICE_FEEDER) { shift = _shift; }

  /**
   * Struct constructor.
   *
   * @todo Use more modes (full OHCL).
   */
  IndiPriceFeederParams(const double& _price_data[], int _total = 0) : IndicatorParams(INDI_PRICE_FEEDER) {
    ArrayCopy(price_data, _price_data, 0, 0, _total == 0 ? WHOLE_ARRAY : _total);
  };
  IndiPriceFeederParams(IndiPriceFeederParams& _params) { THIS_REF = _params; };
};

/**
 * Price Indicator.
 */
class Indi_PriceFeeder : public Indicator<IndiPriceFeederParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_PriceFeeder(IndiPriceFeederParams& _p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                   IndicatorData* _indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src){};
  Indi_PriceFeeder(const double& _price_data[], int _total = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                   IndicatorData* _indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(IndiPriceFeederParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {}
  Indi_PriceFeeder(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData* _indi_src = NULL,
                   int _indi_src_mode = 0)
      : Indicator(IndiPriceFeederParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {}

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN; }

  void SetPrices(const double& _price_data[], int _total = 0) { iparams = IndiPriceFeederParams(_price_data, _total); }

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  virtual bool HasValidEntry(int _shift = 0) { return _shift >= 0 && _shift < ArraySize(iparams.price_data); }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) {
    int data_size = ArraySize(iparams.price_data);

    if (_abs_shift >= data_size || _abs_shift < 0) return DBL_MIN;

    double _value = iparams.price_data[data_size - _abs_shift - 1];
    return _value;
  }

  /**
   * Called when new tick is retrieved from attached data source.
   */
  bool OnTick(int _global_tick_index) override {
    bool _result = Indicator<IndiPriceFeederParams>::OnTick(_global_tick_index);

    if (idparams.IsPloting()) {
      int _max_modes = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));
      IndicatorDataEntry _entry = GetEntry(0);
      for (int i = 0; i < _max_modes; ++i) {
        // draw.DrawLineTo(GetName() + "_" + IntegerToString(i), GetBarTime(0), _entry.values[i].GetDbl());
      }
    }

    return _result;
  }
};
