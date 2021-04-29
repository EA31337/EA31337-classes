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

// Enums.

// Price indicator enum. Made to be compatible with MQL's ENUM_APPLIED_PRICE's PRICE_* enumeration.
enum ENUM_INDI_PRICE_MODE {
  INDI_PRICE_MODE_CLOSE,
  INDI_PRICE_MODE_OPEN,
  INDI_PRICE_MODE_HIGH,
  INDI_PRICE_MODE_LOW,
  FINAL_INDI_PRICE_MODE
};

// Structs.
struct PriceIndiParams : IndicatorParams {
  ENUM_APPLIED_PRICE applied_price;

  // Struct constructor.
  void PriceIndiParams(int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_PRICE;
    max_modes = FINAL_INDI_PRICE_MODE;
    SetDataValueType(TYPE_DOUBLE);
    shift = _shift;
    tf = _tf;
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
    return ChartStatic::iPrice(_ap, _symbol, _tf, _shift);
  }

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  virtual bool HasValidEntry(int _shift = 0) { return GetBarTime(_shift) != 0; }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_APPLIED_PRICE _ap, int _shift = 0) {
    double _value =
        ChartStatic::iPrice(_ap, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), _shift);
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
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.values[INDI_PRICE_MODE_OPEN] = GetValue(PRICE_OPEN, _shift);
      _entry.values[INDI_PRICE_MODE_HIGH] = GetValue(PRICE_HIGH, _shift);
      _entry.values[INDI_PRICE_MODE_CLOSE] = GetValue(PRICE_CLOSE, _shift);
      _entry.values[INDI_PRICE_MODE_LOW] = GetValue(PRICE_LOW, _shift);
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
    GetEntry(_shift).values[_mode].Get(_param.double_value);
    return _param;
  }
};
