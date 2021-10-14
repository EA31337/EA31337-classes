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
struct PriceFeederIndiParams : IndicatorParams {
  ENUM_APPLIED_PRICE applied_price;
  double price_data[];

  /**
   * Struct constructor.
   */
  PriceFeederIndiParams(int _shift = 0) : IndicatorParams(INDI_PRICE_FEEDER, 1, TYPE_DOUBLE) { shift = _shift; }

  /**
   * Struct constructor.
   *
   * @todo Use more modes (full OHCL).
   */
  PriceFeederIndiParams(const double& _price_data[], int _total = 0)
      : IndicatorParams(INDI_PRICE_FEEDER, 1, TYPE_DOUBLE) {
    tf = PERIOD_CURRENT;
    ArrayCopy(price_data, _price_data, 0, 0, _total == 0 ? WHOLE_ARRAY : _total);
  };
  PriceFeederIndiParams(PriceFeederIndiParams& _params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Price Indicator.
 */
class Indi_PriceFeeder : public Indicator<PriceFeederIndiParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_PriceFeeder(PriceFeederIndiParams& _p, IndicatorBase* _indi_src = NULL)
      : Indicator<PriceFeederIndiParams>(_p, _indi_src){};
  Indi_PriceFeeder(const double& _price_data[], int _total = 0) : Indicator(INDI_PRICE_FEEDER) {
    ArrayCopy(iparams.price_data, _price_data);
  };
  Indi_PriceFeeder(ENUM_TIMEFRAMES _tf) : Indicator(INDI_PRICE_FEEDER, _tf) {}

  void SetPrices(const double& _price_data[], int _total = 0) { iparams = PriceFeederIndiParams(_price_data, _total); }

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  virtual bool HasValidEntry(int _shift = 0) { return _shift >= 0 && _shift < ArraySize(iparams.price_data); }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_APPLIED_PRICE _ap, int _shift = 0) {
    int data_size = ArraySize(iparams.price_data);

    if (_shift >= data_size || _shift < 0) return DBL_MIN;

    double _value = iparams.price_data[data_size - _shift - 1];
    istate.is_ready = true;
    istate.is_changed = false;
    return _value;
  }

  void OnTick() {
    Indicator<PriceFeederIndiParams>::OnTick();

    if (iparams.is_draw) {
      IndicatorDataEntry _entry = GetEntry(0);
      for (int i = 0; i < (int)iparams.GetMaxModes(); ++i) {
        draw.DrawLineTo(GetName() + "_" + IntegerToString(i), GetBarTime(0), _entry.values[i].GetDbl());
      }
    }
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry(iparams.GetMaxModes());
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.values[0].Set(GetValue(PRICE_OPEN, _shift));
      _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID);
      _entry.AddFlags(_entry.GetDataTypeFlag(iparams.GetDataValueType()));
      idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    // @todo Use more modes (full OHCL).
    GetEntry(_shift).values[_mode].Get(_param.double_value);
    return _param;
  }
};
