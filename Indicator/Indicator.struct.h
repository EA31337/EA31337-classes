//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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

/**
 * @file
 * Includes Indicator's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward declaration.
template <typename TS>
class Indicator;
struct ChartParams;

// Includes.
#include "../Array.mqh"
#include "../Chart.struct.tf.h"
#include "../Data.struct.h"
#include "../DateTime.struct.h"
#include "../SerializerNode.enum.h"
#include "Indicator.enum.h"
#include "IndicatorData.struct.cache.h"
//#include "Indicator.struct.serialize.h"

/* Structure for indicator parameters. */
struct IndicatorParams {
 public:                                // @todo: Change it to protected.
  string name;                          // Name of the indicator.
  int shift;                            // Shift (relative to the current bar, 0 - default).
  unsigned int max_params;              // Max supported input params.
  ENUM_INDICATOR_TYPE itype;            // Indicator type (e.g. INDI_RSI).
  color indi_color;                     // Indicator color.
  ARRAY(DataParamEntry, input_params);  // Indicator input params.
  string custom_indi_name;              // Name of the indicator passed to iCustom() method.
  string symbol;                        // Symbol used by indicator.
 public:
  /* Special methods */
  // Constructor.
  IndicatorParams(ENUM_INDICATOR_TYPE _itype = INDI_NONE, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _name = "")
      : custom_indi_name(""),
        name(_name),
        shift(0),
        // max_modes(_max_modes),
        // max_buffers(10),
        // idstype(_idstype),
        // idvrange(IDATA_RANGE_UNKNOWN),
        // indi_data_source_id(-1),
        // indi_data_source_mode(-1),
        itype(_itype) {
    Init();
  };
  IndicatorParams(string _name) : custom_indi_name(""), name(_name), shift(0) { Init(); };
  void Init() {}
  /* Getters */
  string GetCustomIndicatorName() const { return custom_indi_name; }
  int GetMaxParams() const { return (int)max_params; }
  int GetShift() const { return shift; }
  string GetSymbol() const { return symbol; }
  ENUM_INDICATOR_TYPE GetIndicatorType() { return itype; }
  template <typename T>
  T GetInputParam(int _index, T _default) const {
    DataParamEntry _param = input_params[_index];
    switch (_param.type) {
      case TYPE_BOOL:
        return (T)param.integer_value;
      case TYPE_INT:
      case TYPE_LONG:
      case TYPE_UINT:
      case TYPE_ULONG:
        return param.integer_value;
      case TYPE_DOUBLE:
      case TYPE_FLOAT:
        return (T)param.double_value;
      case TYPE_CHAR:
      case TYPE_STRING:
      case TYPE_UCHAR:
        return (T)param.string_value;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return (T)WRONG_VALUE;
  }
  /* Setters */
  void SetCustomIndicatorName(string _name) { custom_indi_name = _name; }
  void SetIndicatorType(ENUM_INDICATOR_TYPE _itype) { itype = _itype; }
  void SetInputParams(ARRAY_REF(DataParamEntry, _params)) {
    int _asize = ArraySize(_params);
    SetMaxParams(ArraySize(_params));
    for (int i = 0; i < _asize; i++) {
      input_params[i] = _params[i];
    }
  }
  void SetMaxParams(int _value) {
    max_params = _value;
    ArrayResize(input_params, max_params);
  }
  void SetName(string _name) { name = _name; };
  void SetShift(int _shift) { shift = _shift; }
  void SetSymbol(string _symbol) { symbol = _symbol; }
  // Serializers.
  // SERIALIZER_EMPTY_STUB;
  // template <>
  SerializerNodeType Serialize(Serializer &s);
};
