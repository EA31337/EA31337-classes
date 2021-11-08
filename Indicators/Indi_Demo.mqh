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
#include "Price/Indi_Price.mqh"

/**
 * @file
 * Demo indicator for testing purposes.
 */

// Structs.
struct IndiDemoParams : IndicatorParams {
  // Struct constructors.
  IndiDemoParams(int _shift = 0) : IndicatorParams(INDI_DEMO, 1, TYPE_DOUBLE) {
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
  IndiDemoParams(IndiDemoParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Demo/Dummy Indicator.
 */
class Indi_Demo : public Indicator<IndiDemoParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Demo(IndiDemoParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiDemoParams>(_p, _indi_src){};
  Indi_Demo(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_DEMO, _tf, _shift){};

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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    double _value = Indi_Demo::iDemo(GetSymbol(), GetTf(), _ishift, THIS_PTR);
    if (iparams.is_draw) {
      draw.DrawLineTo(GetName(), GetBarTime(_ishift), _value);
    }
    return _value;
  }
};
