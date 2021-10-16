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
  DemoIndiParams(int _shift = 0) : IndicatorParams(INDI_DEMO, 1, TYPE_DOUBLE) {
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetShift(_shift);
    switch (idstype) {
      case IDATA_ICUSTOM:
        if (custom_indi_name == "") {
          SetCustomIndicatorName("Examples\\Demo");
        }
        break;
    }
  };
  DemoIndiParams(DemoIndiParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Demo/Dummy Indicator.
 */
class Indi_Demo : public Indicator<DemoIndiParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Demo(DemoIndiParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<DemoIndiParams>(_p, _indi_src){};
  Indi_Demo(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_DEMO, _tf){};

  /**
   * Returns the indicator value.
   */
  static double iDemo(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                      IndicatorBase *_obj = NULL) {
    return 0.1 + (0.1 * _obj.GetBarIndex());
  }

  /**
   * Returns the indicator's value.
   */
  virtual double GetValue(int _mode = 0, int _shift = 0) {
    double _value = Indi_Demo::iDemo(GetSymbol(), GetTf(), _shift, THIS_PTR);
    istate.is_ready = true;
    istate.is_changed = false;
    if (iparams.is_draw) {
      draw.DrawLineTo(GetName(), GetBarTime(_shift), _value);
    }
    return _value;
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
