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
#include "../../Bar.struct.h"
#include "../../Indicator.struct.h"
#include "../../Serializer.mqh"
#include "Indi_Math.mqh"

// Structs.
struct PivotParams : IndicatorParams {
  ENUM_PP_TYPE method;  // Pivot point calculation method.
  // Struct constructor.
  void PivotParams(ENUM_PP_TYPE _method = PP_CLASSIC, int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_PIVOT;
    max_modes = 9;
    method = _method;
    SetDataValueType(TYPE_FLOAT);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetDataSourceType(IDATA_BUILTIN);
    shift = _shift;
    tf = _tf;
  };
  void PivotParams(PivotParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements Pivot Detector.
 */
class Indi_Pivot : public Indicator {
 protected:
  PivotParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Pivot(PivotParams &_params) : params(_params), Indicator((IndicatorParams)_params){};
  Indi_Pivot(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_PIVOT, _tf) { params.tf = _tf; };

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

      ResetLastError();
      BarOHLC _ohlc;
      int _value = WRONG_VALUE;

      switch (params.idstype) {
        case IDATA_BUILTIN:
          // In this mode, price is fetched from chart.
          _ohlc = Chart::GetOHLC(_shift);
          break;
        case IDATA_INDICATOR:
          // In this mode, price is fetched from given indicator. Such indicator
          // must have at least 4 buffers and define OHLC in the first 4 buffers.
          // Indi_Price is an example of such indicator.
          if (!HasDataSource()) {
            GetLogger().Error(
                "In order use custom indicator as a source, you need to select one using SetIndicatorData() method, "
                "which is a part of PivotParams structure.",
                "Indi_Pivot");
            Alert(
                "Indi_Pivot: In order use custom indicator as a source, you need to select one using "
                "SetIndicatorData() "
                "method, which is a part of PivotParams structure.");
            SetUserError(ERR_INVALID_PARAMETER);
            return _value;
          }

          _ohlc.open = GetDataSource().GetValue<float>(_shift, PRICE_OPEN);
          _ohlc.high = GetDataSource().GetValue<float>(_shift, PRICE_HIGH);
          _ohlc.low = GetDataSource().GetValue<float>(_shift, PRICE_LOW);
          _ohlc.close = GetDataSource().GetValue<float>(_shift, PRICE_CLOSE);
          break;
        default:
          SetUserError(ERR_INVALID_PARAMETER);
      }

      _ohlc.GetPivots(GetMethod(), _entry.values[0].vflt, _entry.values[1].vflt, _entry.values[2].vflt,
                      _entry.values[3].vflt, _entry.values[4].vflt, _entry.values[5].vflt, _entry.values[6].vflt,
                      _entry.values[7].vflt, _entry.values[8].vflt);

      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, true);

      istate.is_ready = true;

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
    MqlParam _param = {TYPE_INT};
    _param.integer_value = GetEntry(_shift).GetValue<int>(_mode);
    return _param;
  }

  /* Getters */

  /**
   * Get pivot point calculation method.
   */
  ENUM_PP_TYPE GetMethod() { return params.method; }

  /* Setters */

  /**
   * Set pivot point calculation method.
   */
  void SetMethod(ENUM_PP_TYPE _method) {
    istate.is_changed = true;
    params.method = _method;
  }

  /**
   * Whether we can and have to select mode when specifying data source.
   */
  virtual bool IsDataSourceModeSelectable() { return false; }
};
