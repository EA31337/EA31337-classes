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

// Structs.
struct IndiPriceFeederParams : IndicatorParams {
  ENUM_APPLIED_PRICE applied_price;
  double price_data[];

  /**
   * Struct constructor.
   */
  IndiPriceFeederParams(int _shift = 0) : IndicatorParams(INDI_PRICE_FEEDER, 1, TYPE_DOUBLE) { shift = _shift; }

  /**
   * Struct constructor.
   *
   * @todo Use more modes (full OHCL).
   */
  IndiPriceFeederParams(const double& _price_data[], int _total = 0)
      : IndicatorParams(INDI_PRICE_FEEDER, 1, TYPE_DOUBLE) {
    tf = PERIOD_CURRENT;
    ArrayCopy(price_data, _price_data, 0, 0, _total == 0 ? WHOLE_ARRAY : _total);
  };
  IndiPriceFeederParams(IndiPriceFeederParams& _params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Price Indicator.
 */
class Indi_PriceFeeder : public Indicator<IndiPriceFeederParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_PriceFeeder(IndiPriceFeederParams& _p, IndicatorBase* _indi_src = NULL)
      : Indicator<IndiPriceFeederParams>(_p, _indi_src){};
  Indi_PriceFeeder(const double& _price_data[], int _total = 0) : Indicator(INDI_PRICE_FEEDER) {
    ArrayCopy(iparams.price_data, _price_data);
  };
  Indi_PriceFeeder(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_PRICE_FEEDER, _tf, _shift) {}

  void SetPrices(const double& _price_data[], int _total = 0) { iparams = IndiPriceFeederParams(_price_data, _total); }

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  virtual bool HasValidEntry(int _shift = 0) { return _shift >= 0 && _shift < ArraySize(iparams.price_data); }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    int data_size = ArraySize(iparams.price_data);
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();

    if (_ishift >= data_size || _ishift < 0) return DBL_MIN;

    double _value = iparams.price_data[data_size - _ishift - 1];
    return _value;
  }

  void OnTick() {
    Indicator<IndiPriceFeederParams>::OnTick();

    if (iparams.is_draw) {
      IndicatorDataEntry _entry = GetEntry(0);
      for (int i = 0; i < (int)iparams.GetMaxModes(); ++i) {
        draw.DrawLineTo(GetName() + "_" + IntegerToString(i), GetBarTime(0), _entry.values[i].GetDbl());
      }
    }
  }
};
