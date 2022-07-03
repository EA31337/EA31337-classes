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

// Defines.
#define STRUCT_ENUM_INDICATOR_STATE_PROP STRUCT_ENUM(IndicatorState, ENUM_INDICATOR_STATE_PROP)

// Includes.
#include "Array.mqh"
#include "Chart.struct.tf.h"
#include "Data.struct.h"
#include "DateTime.struct.h"
#include "Indicator.enum.h"
#include "SerializerNode.enum.h"

/* Structure for indicator parameters. */
struct IndicatorParams {
 public:                                // @todo: Change it to protected.
  string name;                          // Name of the indicator.
  int shift;                            // Shift (relative to the current bar, 0 - default).
  unsigned int max_params;              // Max supported input params.
  ChartTf tf;                           // Chart's timeframe.
  ENUM_INDICATOR_TYPE itype;            // Indicator type (e.g. INDI_RSI).
  color indi_color;                     // Indicator color.
  ARRAY(DataParamEntry, input_params);  // Indicator input params.
  bool is_draw;                         // Draw active.
  int draw_window;                      // Drawing window.
  string custom_indi_name;              // Name of the indicator passed to iCustom() method.
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
        itype(_itype),
        is_draw(false),
        indi_color(clrNONE),
        draw_window(0),
        tf(_tf) {
    Init();
  };
  IndicatorParams(string _name)
      : custom_indi_name(""),
        name(_name),
        shift(0),
        // max_modes(1),
        // max_buffers(10),
        // idstype(_idstype),
        // idvrange(IDATA_RANGE_UNKNOWN),
        // indi_data_source_id(-1),
        // indi_data_source_mode(-1),
        is_draw(false),
        indi_color(clrNONE),
        draw_window(0) {
    Init();
  };
  // Copy constructor.
  IndicatorParams(IndicatorParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    THIS_REF = _params;
    if (_tf != PERIOD_CURRENT) {
      tf.SetTf(_tf);
    }
  }
  void Init() {}
  /* Getters */
  string GetCustomIndicatorName() const { return custom_indi_name; }
  color GetIndicatorColor() const { return indi_color; }
  int GetMaxParams() const { return (int)max_params; }
  int GetShift() const { return shift; }
  ENUM_INDICATOR_TYPE GetIndicatorType() { return itype; }
  ENUM_TIMEFRAMES GetTf() const { return tf.GetTf(); }
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
  void SetDraw(bool _draw = true, int _window = 0) {
    is_draw = _draw;
    draw_window = _window;
  }
  void SetDraw(color _clr, int _window = 0) {
    is_draw = true;
    indi_color = _clr;
    draw_window = _window;
  }
  void SetIndicatorColor(color _clr) { indi_color = _clr; }
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
  void SetTf(ENUM_TIMEFRAMES _tf) { tf.SetTf(_tf); }
  // Serializers.
  // SERIALIZER_EMPTY_STUB;
  // template <>
  SerializerNodeType Serialize(Serializer &s);
};

/* Structure for indicator state. */
struct IndicatorState {
 public:            // @todo: Change it to protected.
  int handle;       // Indicator handle (MQL5 only).
  bool is_changed;  // Set when params has been recently changed.
  bool is_ready;    // Set when indicator is ready (has valid values).
 public:
  enum ENUM_INDICATOR_STATE_PROP {
    INDICATOR_STATE_PROP_HANDLE,
    INDICATOR_STATE_PROP_IS_CHANGED,
    INDICATOR_STATE_PROP_IS_READY,
  };
  // Constructor.
  IndicatorState() : handle(INVALID_HANDLE), is_changed(true), is_ready(false) {}
  // Getters.
  template <typename T>
  T Get(STRUCT_ENUM(IndicatorState, ENUM_INDICATOR_STATE_PROP) _prop) {
    switch (_prop) {
      case INDICATOR_STATE_PROP_HANDLE:
        return (T)handle;
      case INDICATOR_STATE_PROP_IS_CHANGED:
        return (T)is_changed;
      case INDICATOR_STATE_PROP_IS_READY:
        return (T)is_ready;
    };
    SetUserError(ERR_INVALID_PARAMETER);
    return (T)WRONG_VALUE;
  }
  // Setters.
  template <typename T>
  void Set(STRUCT_ENUM(IndicatorState, ENUM_INDICATOR_STATE_PROP) _prop, T _value) {
    switch (_prop) {
      case INDICATOR_STATE_PROP_HANDLE:
        handle = (T)_value;
        break;
      case INDICATOR_STATE_PROP_IS_CHANGED:
        is_changed = (T)_value;
        break;
      case INDICATOR_STATE_PROP_IS_READY:
        is_ready = (T)_value;
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    };
  }
  // State checkers.
  bool IsChanged() { return is_changed; }
  bool IsReady() { return is_ready; }
};
