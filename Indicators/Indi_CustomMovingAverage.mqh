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

// Structs.
struct IndiCustomMovingAverageParams : IndicatorParams {
  unsigned int smooth_period;
  unsigned int smooth_shift;
  ENUM_MA_METHOD smooth_method;
  // Struct constructor.
  IndiCustomMovingAverageParams(int _smooth_period = 13, int _smooth_shift = 0,
                                ENUM_MA_METHOD _smooth_method = MODE_SMMA, int _shift = 0)
      : IndicatorParams(INDI_CUSTOM_MOVING_AVG) {
    if (custom_indi_name == "") {
#ifdef __MQL5__
      SetCustomIndicatorName("Examples\\Custom Moving Average");
#else
      SetCustomIndicatorName("Custom Moving Averages");
#endif
    }
    shift = _shift;
    smooth_method = _smooth_method;
    smooth_period = _smooth_period;
    smooth_shift = _smooth_shift;
  };
  IndiCustomMovingAverageParams(IndiCustomMovingAverageParams& _params) { THIS_REF = _params; };
};

/**
 * Implements the Custom Moving Average indicator.
 */
class Indi_CustomMovingAverage : public Indicator<IndiCustomMovingAverageParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_CustomMovingAverage(IndiCustomMovingAverageParams& _p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_ICUSTOM,
                           IndicatorData* _indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src){};
  Indi_CustomMovingAverage(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_ICUSTOM,
                           IndicatorData* _indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(IndiCustomMovingAverageParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src){};

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ICUSTOM; }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetSmoothPeriod(),
                         GetSmoothShift(), GetSmoothMethod() /*]*/, 0, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get smooth period.
   */
  unsigned int GetSmoothPeriod() { return iparams.smooth_period; }

  /**
   * Get smooth shift.
   */
  unsigned int GetSmoothShift() { return iparams.smooth_shift; }

  /**
   * Get smooth method.
   */
  ENUM_MA_METHOD GetSmoothMethod() { return iparams.smooth_method; }

  /* Setters */

  /**
   * Set smooth period.
   */
  void SetSmoothPeriod(unsigned int _smooth_period) {
    istate.is_changed = true;
    iparams.smooth_period = _smooth_period;
  }

  /**
   * Set smooth shift.
   */
  void SetSmoothShift(unsigned int _smooth_shift) {
    istate.is_changed = true;
    iparams.smooth_shift = _smooth_shift;
  }

  /**
   * Set smooth method.
   */
  void SetSmoothMethod(ENUM_MA_METHOD _smooth_method) {
    istate.is_changed = true;
    iparams.smooth_method = _smooth_method;
  }
};
