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
#include "../../BufferStruct.mqh"
#include "../../Indicator.mqh"
#include "../../Storage/Objects.h"

// Structs.
struct PriceIndiParams : IndicatorParams {
  ENUM_APPLIED_PRICE ap;
  // Struct constructor.
  PriceIndiParams(ENUM_APPLIED_PRICE _ap = PRICE_TYPICAL, int _shift = 0)
      : ap(_ap), IndicatorParams(INDI_PRICE, 1, TYPE_DOUBLE) {
    SetShift(_shift);
  };
  PriceIndiParams(PriceIndiParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
  // Getters.
  ENUM_APPLIED_PRICE GetAppliedPrice() { return ap; }
  // Setters.
  void SetAppliedPrice(ENUM_APPLIED_PRICE _ap) { ap = _ap; }
};

/**
 * Price Indicator.
 */
class Indi_Price : public Indicator<PriceIndiParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Price(PriceIndiParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<PriceIndiParams>(_p, _indi_src){};
  Indi_Price(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_PRICE, _tf, _shift){};

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  virtual bool HasValidEntry(int _shift = 0) { return GetBarTime(_shift) != 0; }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    return ChartStatic::iPrice(iparams.GetAppliedPrice(), GetSymbol(), GetTf(), _ishift);
  }

  /**
   * Returns already cached version of Indi_Price for a given parameters.
   */
  static Indi_Price *GetCached(string _symbol, ENUM_APPLIED_PRICE _ap, ENUM_TIMEFRAMES _tf, int _shift) {
    String _cache_key;
    _cache_key.Add(_symbol);
    _cache_key.Add((int)_ap);
    _cache_key.Add((int)_tf);
    _cache_key.Add(_shift);
    string _key = _cache_key.ToString();
    Indi_Price *_indi_price;
    if (!Objects<Indi_Price>::TryGet(_key, _indi_price)) {
      PriceIndiParams _indi_price_params(_ap, _shift);
      _indi_price_params.SetTf(_tf);
      _indi_price = Objects<Indi_Price>::Set(_key, new Indi_Price(_indi_price_params));
      _indi_price.SetSymbol(_symbol);
    }
    return _indi_price;
  }
};
