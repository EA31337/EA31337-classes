//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
struct PriceIndiParams : IndicatorParams {
  ENUM_APPLIED_PRICE applied_price;
  
  // Struct constructor.
  void PriceIndiParams(ENUM_APPLIED_PRICE _ap = PRICE_LOW, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_PRICE;
    max_modes = 1;
    SetDataType(TYPE_DOUBLE);
    tf = _tf;
    tfi = Chart::TfToIndex(_tf);
    applied_price = _ap;
  };
};

/**
 * Price Indicator.
 */
class Indi_Price : public Indicator {
 protected:
 
  PriceIndiParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Price(PriceIndiParams &_p) : Indicator((IndicatorParams)_p) { params = _p; };
  Indi_Price(ENUM_APPLIED_PRICE _ap = PRICE_LOW, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : params(_ap, _tf), Indicator(INDI_PRICE, _tf){};

  /**
   * Returns the indicator value.
   */
  static double iPrice(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                    Indi_Price *_obj = NULL) {
    switch (_obj.params.applied_price) {
      case PRICE_OPEN:
        return Chart::iOpen(_symbol, _tf, _shift);
      case PRICE_CLOSE:
        return Chart::iClose(_symbol, _tf, _shift);
      case PRICE_LOW:
        return Chart::iLow(_symbol, _tf, _shift);
      case PRICE_HIGH:
        return Chart::iHigh(_symbol, _tf, _shift);
      default:
        Print("Invalid _applied_price given for Price indicator. ", _obj.params.applied_price, " passed!");
        return 0;
    }
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    double _value = Indi_Price::iPrice(GetSymbol(), GetTf(), _shift, GetPointer(this));
    istate.is_ready = true;
    istate.is_changed = false;
    if (iparams.is_draw) {
      draw.DrawLineTo(GetName(), GetBarTime(_shift), _value);
    }
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.value.SetValue(params.idtype, GetValue(_shift));
      _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID);
      idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.idtype, _mode);
    return _param;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idtype); }
};
