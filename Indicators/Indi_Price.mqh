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

// Enums.
enum ENUM_INDI_PRICE_MODE {
  INDI_PRICE_MODE_OPEN,
  INDI_PRICE_MODE_HIGH,
  INDI_PRICE_MODE_CLOSE,
  INDI_PRICE_MODE_LOW,
  FINAL_INDI_PRICE_MODE
};

// Structs.
struct PriceIndiParams : IndicatorParams {
  ENUM_APPLIED_PRICE applied_price;

  // Struct constructor.
  void PriceIndiParams(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_PRICE;
    max_modes = FINAL_INDI_PRICE_MODE;
    SetDataValueType(TYPE_DOUBLE);
    tf = _tf;
    tfi = Chart::TfToIndex(_tf);
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
  Indi_Price(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : params(_tf), Indicator(INDI_PRICE, _tf){};

  /**
   * Returns the indicator value.
   */
  static double iPrice(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                       Indi_Price *_obj = NULL) {
    ENUM_APPLIED_PRICE _ap = _obj == NULL ? PRICE_MEDIAN : _obj.params.applied_price;
    return Chart::iPrice(_ap, _symbol, _tf, _shift);
  }

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  virtual bool HasValidEntry(int _shift = 0) { return GetBarTime(_shift) != 0; }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_APPLIED_PRICE _ap, int _shift = 0) {
    double _value = Chart::iPrice(_ap, GetSymbol(), GetTf(), _shift);
    istate.is_ready = true;
    istate.is_changed = false;
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
      _entry.value.SetValue(params.idvtype, GetValue(PRICE_OPEN, _shift), INDI_PRICE_MODE_OPEN);
      _entry.value.SetValue(params.idvtype, GetValue(PRICE_HIGH, _shift), INDI_PRICE_MODE_HIGH);
      _entry.value.SetValue(params.idvtype, GetValue(PRICE_CLOSE, _shift), INDI_PRICE_MODE_CLOSE);
      _entry.value.SetValue(params.idvtype, GetValue(PRICE_LOW, _shift), INDI_PRICE_MODE_LOW);
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
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.idvtype, _mode);
    return _param;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idvtype); }
};
