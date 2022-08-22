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
#include "../Indicator/Indicator.h"
#include "Price/Indi_Price.mqh"

/**
 * @file
 * Demo indicator for testing purposes.
 */

// Structs.
struct IndiDemoParams : IndicatorParams {
  // Struct constructors.
  IndiDemoParams(int _shift = 0) : IndicatorParams(INDI_DEMO) {
    SetShift(_shift);
    if (custom_indi_name == "") {
      SetCustomIndicatorName("Examples\\Demo");
    }
  };
  IndiDemoParams(IndiDemoParams &_params) { THIS_REF = _params; };
};

/**
 * Demo/Dummy Indicator.
 */
class Indi_Demo : public Indicator<IndiDemoParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Demo(IndiDemoParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_Demo(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(IndiDemoParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_CANDLE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN; }

  /**
   * Returns the indicator value.
   */
  static double iDemo(IndicatorData *_obj, int _shift = 0) {
    return 0.1 + (0.1 * _obj PTR_DEREF GetCandle() PTR_DEREF GetBarIndex());
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    double _value = Indi_Demo::iDemo(THIS_PTR, _ishift);
    if (idparams.is_draw) {
      draw.DrawLineTo(GetName(), GetCandle() PTR_DEREF GetBarTime(_ishift), _value);
    }
    return _value;
  }
};
