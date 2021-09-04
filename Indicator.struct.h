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

/**
 * @file
 * Includes Indicator's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward declaration.
class Indicator;
struct ChartParams;

// Includes.
#include "Chart.struct.tf.h"
#include "Data.struct.h"
#include "DateTime.struct.h"
#include "Indicator.enum.h"
#include "SerializerNode.enum.h"

/**
 * Holds buffers used to cache values calculated via OnCalculate methods.
 */
struct IndicatorCalculateCache {
 public:
  // Total number of calculated values.
  int prev_calculated;

  // Number of buffers used.
  int num_buffers;

  // Whether input price array was passed as series.
  bool price_was_as_series;

  // Buffers used for OnCalculate calculations.
  ARRAY(double, buffer1);
  ARRAY(double, buffer2);
  ARRAY(double, buffer3);
  ARRAY(double, buffer4);
  ARRAY(double, buffer5);

  /**
   * Constructor.
   */
  IndicatorCalculateCache(int _num_buffers = 0, int _buffers_size = 0) {
    prev_calculated = 0;
    num_buffers = _num_buffers;

    Resize(_buffers_size);
  }

  /**
   * Resizes all buffers.
   */
  void Resize(int _buffers_size) {
    static int increase = 65536;
    switch (num_buffers) {
      case 5:
        ArrayResize(buffer5, _buffers_size, (_buffers_size - _buffers_size % increase) + increase);
      case 4:
        ArrayResize(buffer4, _buffers_size, (_buffers_size - _buffers_size % increase) + increase);
      case 3:
        ArrayResize(buffer3, _buffers_size, (_buffers_size - _buffers_size % increase) + increase);
      case 2:
        ArrayResize(buffer2, _buffers_size, (_buffers_size - _buffers_size % increase) + increase);
      case 1:
        ArrayResize(buffer1, _buffers_size, (_buffers_size - _buffers_size % increase) + increase);
    }
  }

  /**
   * Retrieves cached value from the given buffer (buffer is indexed from 1 to 5).
   */
  double GetValue(int _buffer_index, int _shift) {
    switch (_buffer_index) {
      case 1:
        return buffer1[ArraySize(buffer1) - 1 - _shift];
      case 2:
        return buffer2[ArraySize(buffer2) - 1 - _shift];
      case 3:
        return buffer3[ArraySize(buffer3) - 1 - _shift];
      case 4:
        return buffer4[ArraySize(buffer4) - 1 - _shift];
      case 5:
        return buffer5[ArraySize(buffer5) - 1 - _shift];
    }
    return DBL_MIN;
  }

  /**
   * Updates prev_calculated value used by indicator's OnCalculate method.
   */
  void SetPrevCalculated(ARRAY_REF(double, price), int _prev_calculated) {
    prev_calculated = _prev_calculated;
    ArraySetAsSeries(price, price_was_as_series);
  }

  /**
   * Returns prev_calculated value used by indicator's OnCalculate method.
   */
  int GetPrevCalculated(int _prev_calculated) { return prev_calculated; }
};

/* Structure for indicator data entry. */
struct IndicatorDataEntry {
  long timestamp;        // Timestamp of the entry's bar.
  unsigned short flags;  // Indicator entry flags.
  union IndicatorDataEntryValue {
    double vdbl;
    float vflt;
    int vint;
    long vlong;
    // Union operators.
    template <typename T>
    T operator*(const T _value) {
      return Get<T>() * _value;
    }
    template <typename T>
    T operator+(const T _value) {
      return Get<T>() + _value;
    }
    template <typename T>
    T operator-(const T _value) {
      return Get<T>() - _value;
    }
    template <typename T>
    T operator/(const T _value) {
      return Get<T>() / _value;
    }
    template <typename T>
    bool operator!=(const T _value) {
      return Get<T>() != _value;
    }
    template <typename T>
    bool operator<(const T _value) {
      return Get<T>() < _value;
    }
    template <typename T>
    bool operator<=(const T _value) {
      return Get<T>() <= _value;
    }
    template <typename T>
    bool operator==(const T _value) {
      return Get<T>() == _value;
    }
    template <typename T>
    bool operator>(const T _value) {
      return Get<T>() > _value;
    }
    template <typename T>
    bool operator>=(const T _value) {
      return Get<T>() >= _value;
    }
    template <typename T>
    void operator=(const T _value) {
      Set(_value);
    }
    // Checkers.
    template <typename T>
    bool IsGt(T _value) {
      return Get<T>() > _value;
    }
    template <typename T>
    bool IsLt(T _value) {
      return Get<T>() < _value;
    }
    // Getters.
    double GetDbl() { return vdbl; }
    float GetFloat() { return vflt; }
    int GetInt() { return vint; }
    long GetLong() { return vlong; }
    template <typename T>
    void Get(T &_out) {
      _out = Get<T>();
    }
    template <typename T>
    T Get() {
      T _v;
      Get(_v);
      return _v;
    }
    void Get(double &_out) { _out = vdbl; }
    void Get(float &_out) { _out = vflt; }
    void Get(int &_out) { _out = vint; }
    void Get(long &_out) { _out = vlong; }
    // Setters.
    template <typename T>
    void Set(T _value) {
      Set(_value);
    }
    void Set(double _value) { vdbl = _value; }
    void Set(float _value) { vflt = _value; }
    void Set(int _value) { vint = _value; }
    void Set(unsigned int _value) { vint = (int)_value; }
    void Set(long _value) { vlong = _value; }
    void Set(unsigned long _value) { vlong = (long)_value; }
    // Serializers.
    // SERIALIZER_EMPTY_STUB
    SerializerNodeType Serialize(Serializer &_s);
    // To string
    template <typename T>
    string ToString() {
      return (string)Get<T>();
    }
  };

  ARRAY(IndicatorDataEntryValue, values);

  // Constructors.
  IndicatorDataEntry(int _size = 1) : flags(INDI_ENTRY_FLAG_NONE), timestamp(0) { Resize(_size); }
  int GetSize() { return ArraySize(values); }
  // Operator overloading methods.
  template <typename T>
  T operator*(const T _value) {
    return values[0].Get<T>() * _value;
  }
  template <typename T>
  T operator+(const T _value) {
    return values[0].Get<T>() + _value;
  }
  template <typename T>
  T operator-(const T _value) {
    return values[0].Get<T>() - _value;
  }
  template <typename T>
  T operator/(const T _value) {
    return values[0].Get<T>() / _value;
  }
  template <typename T, typename I>
  T operator[](I _index) {
    return values[(int)_index].Get<T>();
  }
  template <>
  double operator[](int _index) {
    if (_index >= ArraySize(values)) {
      return 0;
    }
    double _value;
    values[_index].Get(_value);
    return _value;
  }
  // Checkers.
  template <typename T>
  bool HasValue(T _value) {
    bool _result = false;
    int _asize = ArraySize(values);
    T _value2;
    for (int i = 0; i < _asize; i++) {
      values[i].Get(_value2);
      if (_value == _value2) {
        _result = true;
        break;
      }
    }
    return _result;
  }
  template <typename T>
  bool IsGe(T _value) {
    return GetMin<T>() >= _value;
  }
  template <typename T>
  bool IsGt(T _value) {
    return GetMin<T>() > _value;
  }
  template <typename T>
  bool IsLe(T _value) {
    return _value <= GetMax<T>();
  }
  template <typename T>
  bool IsLt(T _value) {
    return _value < GetMax();
  }
  template <typename T>
  bool IsWithinRange(T _min, T _max) {
    return GetMin<T>() >= _min && GetMax<T>() <= _max;
  }
  // Getters.
  template <typename T>
  void GetArray(ARRAY_REF(T, _out), int _size = 0) {
    int _asize = _size > 0 ? _size : ArraySize(_out);
    for (int i = 0; i < _asize; i++) {
      values[i].Get(_out[i]);
    }
  };
  template <typename T>
  T GetAvg(int _size = 0) {
    int _asize = _size > 0 ? _size : ArraySize(values);
    T _avg = GetSum<T>() / _asize;
    return _avg;
  };
  template <typename T>
  T GetMin(int _size = 0) {
    int _asize = _size > 0 ? _size : ArraySize(values);
    int _index = 0;
    for (int i = 1; i < _asize; i++) {
      _index = values[i].Get<T>() < values[_index].Get<T>() ? i : _index;
    }
    return values[_index].Get<T>();
  };
  template <typename T>
  T GetMax(int _size = 0) {
    int _asize = _size > 0 ? _size : ArraySize(values);
    int _index = 0;
    for (int i = 1; i < _asize; i++) {
      _index = values[i].Get<T>() > values[_index].Get<T>() ? i : _index;
    }
    return values[_index].Get<T>();
  };
  template <typename T>
  T GetSum(int _size = 0) {
    int _asize = _size > 0 ? _size : ArraySize(values);
    T _sum = 0;
    for (int i = 1; i < _asize; i++) {
      _sum = +values[i].Get<T>();
    }
    return _sum;
  };
  template <typename T>
  T GetValue(int _index = 0) {
    return values[_index].Get<T>();
  };
  template <typename T>
  void GetValues(T &_out1, T &_out2) {
    values[0].Get(_out1);
    values[1].Get(_out2);
  };
  template <typename T>
  void GetValues(T &_out1, T &_out2, T &_out3) {
    values[0].Get(_out1);
    values[1].Get(_out2);
    values[2].Get(_out3);
  };
  template <typename T>
  void GetValues(T &_out1, T &_out2, T &_out3, T &_out4) {
    values[0].Get(_out1);
    values[1].Get(_out2);
    values[2].Get(_out3);
    values[3].Get(_out4);
  };

  // Getters.
  int GetDayOfYear() { return DateTimeStatic::DayOfYear(timestamp); }
  int GetMonth() { return DateTimeStatic::Month(timestamp); }
  int GetYear() { return DateTimeStatic::Year(timestamp); }
  long GetTime() { return timestamp; };
  ENUM_DATATYPE GetDataType() {
    if (CheckFlags(INDI_ENTRY_FLAG_IS_FLOAT)) {
      return TYPE_FLOAT;
    } else if (CheckFlags(INDI_ENTRY_FLAG_IS_INT)) {
      return TYPE_INT;
    } else if (CheckFlags(INDI_ENTRY_FLAG_IS_LONG)) {
      return TYPE_LONG;
    }
    return TYPE_DOUBLE;
  }
  INDICATOR_ENTRY_FLAGS GetDataTypeFlag(ENUM_DATATYPE _dt) {
    switch (_dt) {
      case TYPE_DOUBLE:
        return INDI_ENTRY_FLAG_IS_DOUBLE;
      case TYPE_FLOAT:
        return INDI_ENTRY_FLAG_IS_FLOAT;
      case TYPE_INT:
        return INDI_ENTRY_FLAG_IS_INT;
      case TYPE_LONG:
        return INDI_ENTRY_FLAG_IS_LONG;
      default:
        break;
    }
    return (INDICATOR_ENTRY_FLAGS)0;
  }
  // Setters.
  bool Resize(int _size = 0) { return _size > 0 ? ArrayResize(values, _size) > 0 : true; }
  // Value flag methods for bitwise operations.
  bool CheckFlag(INDICATOR_ENTRY_FLAGS _prop) { return CheckFlags(_prop); }
  bool CheckFlags(unsigned short _flags) { return (flags & _flags) != 0; }
  bool CheckFlagsAll(unsigned short _flags) { return (flags & _flags) == _flags; }
  void AddFlags(unsigned short _flags) { flags |= _flags; }
  void RemoveFlags(unsigned short _flags) { flags &= ~_flags; }
  void SetFlag(INDICATOR_ENTRY_FLAGS _flag, bool _value) {
    if (_value) {
      AddFlags(_flag);
    } else {
      RemoveFlags(_flag);
    }
  }
  void SetFlags(unsigned short _flags) { flags = _flags; }
  // Converters.
  // State checkers.
  bool IsValid() { return CheckFlags(INDI_ENTRY_FLAG_IS_VALID); }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {
    ArrayResize(values, _n1);
    AddFlags(INDI_ENTRY_FLAG_IS_DOUBLE);
  }
  SerializerNodeType Serialize(Serializer &_s);
  template <typename T>
  string ToCSV() {
    int _asize = ArraySize(values);
    string _result = "";
    for (int i = 0; i < _asize; i++) {
      _result += StringFormat("%s%s", (string)values[i].Get<T>(), i < _asize ? "," : "");
    }
    return _result;
  }
  template <typename T>
  string ToString() {
    return ToCSV<T>();
  }
};

/* Structure for indicator parameters. */
struct IndicatorParams {
  string name;                      // Name of the indicator.
  int shift;                        // Shift (relative to the current bar, 0 - default).
  unsigned int max_buffers;         // Max buffers to store.
  unsigned int max_modes;           // Max supported indicator modes (values per entry).
  unsigned int max_params;          // Max supported input params.
  ChartTf tf;                       // Chart's timeframe.
  ENUM_INDICATOR_TYPE itype;        // Indicator type (e.g. INDI_RSI).
  ENUM_IDATA_SOURCE_TYPE idstype;   // Indicator's data source type (e.g. IDATA_BUILTIN, IDATA_ICUSTOM).
  ENUM_IDATA_VALUE_RANGE idvrange;  // Indicator's range value data type.
  // ENUM_IDATA_VALUE_TYPE idvtype;    // Indicator's data value type (e.g. TDBL1, TDBL2, TINT1).
  ENUM_DATATYPE dtype;                  // Type of basic data to store values (DTYPE_DOUBLE, DTYPE_INT).
  color indi_color;                     // Indicator color.
  int indi_data_source_id;              // Id of the indicator to be used as data source.
  int indi_data_source_mode;            // Mode used as input from data source.
  Indicator *indi_data_source;          // Custom indicator to be used as data source.
  bool indi_managed;                    // Whether indicator should be owned by indicator.
  ARRAY(DataParamEntry, input_params);  // Indicator input params.
  int indi_mode;                        // Index of indicator data to be used as data source.
  bool is_draw;                         // Draw active.
  int draw_window;                      // Drawing window.
  string custom_indi_name;              // Name of the indicator passed to iCustom() method.
  /* Special methods */
  // Constructor.
  IndicatorParams(ENUM_INDICATOR_TYPE _itype = INDI_NONE, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                  string _name = "")
      : custom_indi_name(""),
        name(_name),
        shift(0),
        max_modes(1),
        max_buffers(10),
        idstype(_idstype),
        idvrange(IDATA_RANGE_UNKNOWN),
        indi_data_source(NULL),
        indi_data_source_id(-1),
        indi_data_source_mode(-1),
        itype(_itype),
        is_draw(false),
        indi_color(clrNONE),
        indi_mode(0),
        draw_window(0) {
    SetDataSourceType(_idstype);
  };
  IndicatorParams(string _name, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN)
      : custom_indi_name(""),
        name(_name),
        shift(0),
        max_modes(1),
        max_buffers(10),
        idstype(_idstype),
        idvrange(IDATA_RANGE_UNKNOWN),
        indi_data_source(NULL),
        indi_data_source_id(-1),
        indi_data_source_mode(-1),
        is_draw(false),
        indi_color(clrNONE),
        indi_mode(0),
        draw_window(0) {
    SetDataSourceType(_idstype);
  };
  /* Getters */
  string GetCustomIndicatorName() { return custom_indi_name; }
  Indicator *GetDataSource() { return indi_data_source; }
  int GetDataSourceId() { return indi_data_source_id; }
  int GetDataSourceMode() { return indi_data_source_mode; }
  color GetIndicatorColor() { return indi_color; }
  int GetMaxModes() { return (int)max_modes; }
  int GetMaxParams() { return (int)max_params; }
  int GetShift() { return shift; }
  ENUM_DATATYPE GetDataValueType() { return dtype; }
  ENUM_IDATA_SOURCE_TYPE GetDataSourceType() { return idstype; }
  ENUM_IDATA_VALUE_RANGE GetIDataValueRange() { return idvrange; }
  ENUM_TIMEFRAMES GetTf() { return tf.GetTf(); }
  template <typename T>
  T GetInputParam(int _index, T _default) {
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
    }
    return (T)WRONG_VALUE;
  }
  /* Setters */
  void SetCustomIndicatorName(string _name) { custom_indi_name = _name; }
  void SetDataSourceMode(int _mode) { indi_data_source_mode = _mode; }
  void SetDataSourceType(ENUM_IDATA_SOURCE_TYPE _idstype) { idstype = _idstype; }
  void SetDataValueRange(ENUM_IDATA_VALUE_RANGE _idvrange) { idvrange = _idvrange; }
  void SetDataValueType(ENUM_DATATYPE _dtype) { dtype = _dtype; }
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
  void SetDataSource(int _id, int _input_mode = -1) {
    indi_data_source_id = _id;
    indi_data_source_mode = _input_mode;
    idstype = IDATA_INDICATOR;
  }
  void SetDataSource(Indicator *_indi, bool _managed = true, int _input_mode = -1) {
    indi_data_source_id = -1;
    indi_data_source = _indi;
    indi_data_source_mode = _input_mode;
    indi_managed = _managed;
    idstype = IDATA_INDICATOR;
  }
  void SetIndicatorType(ENUM_INDICATOR_TYPE _itype) { itype = _itype; }
  void SetInputParams(ARRAY_REF(DataParamEntry, _params)) {
    int _asize = ArraySize(_params);
    SetMaxParams(ArraySize(_params));
    for (int i = 0; i < _asize; i++) {
      input_params[i] = _params[i];
    }
  }
  void SetMaxModes(int _value) { max_modes = _value; }
  void SetMaxParams(int _value) {
    max_params = _value;
    ArrayResize(input_params, max_params);
  }
  void SetName(string _name) { name = _name; };
  void SetShift(int _shift) { shift = _shift; }
  void SetSize(int _size) { max_buffers = _size; };
  // Serializers.
  // SERIALIZER_EMPTY_STUB;
  // template <>
  SerializerNodeType Serialize(Serializer &s);
};

/* Structure for indicator state. */
struct IndicatorState {
  enum ENUM_INDICATOR_STATE_PROP {
    INDICATOR_STATE_PROP_HANDLE,
    INDICATOR_STATE_PROP_IS_CHANGED,
    INDICATOR_STATE_PROP_IS_READY,
  };
  int handle;       // Indicator handle (MQL5 only).
  bool is_changed;  // Set when params has been recently changed.
  bool is_ready;    // Set when indicator is ready (has valid values).
  // Constructor.
  IndicatorState() : handle(INVALID_HANDLE), is_changed(true), is_ready(false) {}
  // Getters.
  template <typename T>
#ifdef __MQL4__
  T Get(ENUM_INDICATOR_STATE_PROP _prop) {
#else
  T Get(IndicatorState::ENUM_INDICATOR_STATE_PROP _prop) {
#endif
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
  // State checkers.
  bool IsChanged() { return is_changed; }
  bool IsReady() { return is_ready; }
};
