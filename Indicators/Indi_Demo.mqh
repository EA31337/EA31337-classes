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
#include "../Indicators/Indi_Price.mqh"

/**
 * @file
 * Demo indicator for testing purposes.
 */

// Structs.
struct DemoIndiParams : IndicatorParams {
  // Struct constructors.
  void DemoIndiParams(int _shift = 0) {
    itype = INDI_DEMO;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetMaxModes(1);
    SetShift(_shift);
    SetCustomIndicatorName("Examples\\Demo");
  };
};

/**
 * Demo/Dummy Indicator.
 */
class Indi_Demo : public Indicator {
 protected:
  DemoIndiParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Demo(DemoIndiParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator((IndicatorParams)_params) {
    params = _params;
  };
  Indi_Demo(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_DEMO, _tf){};

  /**
   * Initialize indicator data drawing on custom data.
   */
  bool InitDraw() {
    if (iparams.is_draw) {
      draw = new DrawIndicator(&this);
    }
    return iparams.is_draw;
  }

  /**
   * Returns the indicator value.
   */
  static double iDemo(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                      Indicator *_obj = NULL) {
    return 0.1 + (0.1 * _obj.GetBarIndex());
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    double _value = Indi_Demo::iDemo(GetSymbol(), GetTf(), _shift, THIS_PTR);
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
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID);
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(params.GetDataValueType()));
        idata.Add(_entry, _bar_time);
      }
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
