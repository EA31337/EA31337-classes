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
 * Includes IndicatorData's structs.
 */

// Defines.
#define STRUCT_ENUM_IDATA_PARAM STRUCT_ENUM(IndicatorDataParams, ENUM_IDATA_PARAM)
#define STRUCT_ENUM_INDICATOR_STATE_PROP STRUCT_ENUM(IndicatorState, ENUM_INDICATOR_STATE_PROP)

// Includes.
#include "../SerializerNode.enum.h"
#include "IndicatorData.enum.h"

// Type-less value for IndicatorDataEntryValue structure.
union IndicatorDataEntryTypelessValue {
  double vdbl;
  float vflt;
  int vint;
  long vlong;
};

// Type-aware value for IndicatorDataEntry class.
struct IndicatorDataEntryValue {
  unsigned char flags;
  IndicatorDataEntryTypelessValue value;

  // Constructors.
  template <typename T>
  IndicatorDataEntryValue(T _value, unsigned char _flags = 0) : flags(_flags) {
    Set(_value);
  }
  IndicatorDataEntryValue(unsigned char _flags = 0) : flags(_flags) {}

  // Returns type of the value.
  ENUM_DATATYPE GetDataType() { return (ENUM_DATATYPE)((flags & 0xF0) >> 4); }

  // Sets type of the value.
  void SetDataType(ENUM_DATATYPE _type) {
    // Clearing type.
    flags &= 0x0F;

    // Setting type.
    flags |= (unsigned char)_type << 4;
  }

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
  double GetDbl() { return value.vdbl; }
  float GetFloat() { return value.vflt; }
  int GetInt() { return value.vint; }
  long GetLong() { return value.vlong; }
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
  void Get(datetime &_out) { _out = (datetime)value.vlong; }
  void Get(double &_out) { _out = value.vdbl; }
  void Get(float &_out) { _out = value.vflt; }
  void Get(int &_out) { _out = value.vint; }
  void Get(unsigned int &_out) { _out = (unsigned int)value.vint; }
  void Get(long &_out) { _out = value.vlong; }
  void Get(unsigned long &_out) { _out = (unsigned long)value.vint; }
  // Setters.
  template <typename T>
  void Set(T _value) {
    Set(_value);
  }
  void Set(double _value) {
    value.vdbl = _value;
    SetDataType(TYPE_DOUBLE);
  }
  void Set(float _value) {
    value.vflt = _value;
    SetDataType(TYPE_FLOAT);
  }
  void Set(int _value) {
    value.vint = _value;
    SetDataType(TYPE_INT);
  }
  void Set(unsigned int _value) {
    value.vint = (int)_value;
    SetDataType(TYPE_UINT);
  }
  void Set(long _value) {
    value.vlong = _value;
    SetDataType(TYPE_LONG);
  }
  void Set(unsigned long _value) {
    value.vlong = (long)_value;
    SetDataType(TYPE_ULONG);
  }
  // Serializers.
  // SERIALIZER_EMPTY_STUB
  SerializerNodeType Serialize(Serializer &_s);
  // To string
  template <typename T>
  string ToString() {
    return (string)Get<T>();
  }
};

/* Structure for indicator data entry. */
struct IndicatorDataEntry {
  long timestamp;        // Timestamp of the entry's bar.
  unsigned short flags;  // Indicator entry flags.
  ARRAY(IndicatorDataEntryValue, values);

  // Constructors.
  IndicatorDataEntry(int _size = 1) : flags(INDI_ENTRY_FLAG_NONE), timestamp(0) { Resize(_size); }
  IndicatorDataEntry(IndicatorDataEntry &_entry) { THIS_REF = _entry; }
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
    return GetMax<T>() <= _value;
  }
  template <typename T>
  bool IsLt(T _value) {
    return GetMax<T>() < _value;
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
  ENUM_DATATYPE GetDataType(int _mode) { return values[_mode].GetDataType(); }
  ushort GetDataTypeFlags(ENUM_DATATYPE _dt) {
    switch (_dt) {
      case TYPE_BOOL:
      case TYPE_CHAR:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
      case TYPE_INT:
        return INDI_ENTRY_FLAG_NONE;
      case TYPE_LONG:
        return INDI_ENTRY_FLAG_IS_DOUBLED;
      case TYPE_UINT:
        return INDI_ENTRY_FLAG_IS_UNSIGNED;
      case TYPE_ULONG:
        return INDI_ENTRY_FLAG_IS_UNSIGNED | INDI_ENTRY_FLAG_IS_DOUBLED;
      case TYPE_DOUBLE:
        return INDI_ENTRY_FLAG_IS_REAL | INDI_ENTRY_FLAG_IS_DOUBLED;
      case TYPE_FLOAT:
        return INDI_ENTRY_FLAG_IS_REAL;
      case TYPE_STRING:
      case TYPE_UCHAR:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return INDI_ENTRY_FLAG_NONE;
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
  unsigned short GetFlags() { return flags; }
  // Converters.
  // State checkers.
  bool IsValid() { return CheckFlags(INDI_ENTRY_FLAG_IS_VALID); }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {
    ArrayResize(values, _n1);
    for (int i = 0; i < _n1; ++i) {
      values[i] = (int)1;
    }
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

/* Structure for indicator data parameters. */
struct IndicatorDataParams {
 public:
  // @todo: Move to protected.
  bool is_draw;      // Draw active.
  color indi_color;  // Indicator color.
 protected:
  /* Struct protected variables */
  bool is_fed;                      // Whether calc_start_bar is already calculated.
  int data_src_mode;                // Mode used as input from data source.
  int draw_window;                  // Drawing window.
  int src_id;                       // Id of the indicator to be used as data source.
  int src_mode;                     // Mode of source indicator
  unsigned int max_buffers;         // Max buffers to store.
  unsigned int max_modes;           // Max supported indicator modes (values per entry).
  ENUM_DATATYPE dtype;              // Type of basic data to store values (DTYPE_DOUBLE, DTYPE_INT).
  ENUM_IDATA_SOURCE_TYPE idstype;   // Indicator's data source type (e.g. IDATA_BUILTIN, IDATA_ICUSTOM).
  ENUM_IDATA_VALUE_RANGE idvrange;  // Indicator's range value data type.
 public:
  /* Struct enumerations */
  enum ENUM_IDATA_PARAM {
    IDATA_PARAM_IS_FED = 0,
    IDATA_PARAM_DATA_SRC_MODE,
    IDATA_PARAM_DTYPE,
    IDATA_PARAM_IDSTYPE,
    IDATA_PARAM_IDVRANGE,
    IDATA_PARAM_MAX_BUFFERS,
    IDATA_PARAM_MAX_MODES,
    IDATA_PARAM_SRC_ID,
    IDATA_PARAM_SRC_MODE,
  };

 public:
  /* Special methods */
  // Constructor.
  IndicatorDataParams(unsigned int _max_modes = 1, ENUM_DATATYPE _dtype = TYPE_DOUBLE,
                      ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                      ENUM_IDATA_VALUE_RANGE _idvrange = IDATA_RANGE_UNKNOWN, int _data_src_mode = 0)
      : data_src_mode(_data_src_mode),
        draw_window(0),
        dtype(_dtype),
        max_modes(_max_modes),
        max_buffers(10),
        idstype(_idstype),
        idvrange(_idvrange),
        indi_color(clrNONE),
        is_draw(false),
        is_fed(false),
        src_id(-1),
        src_mode(-1){};
  // Copy constructor.
  IndicatorDataParams(const IndicatorDataParams &_idp) { THIS_REF = _idp; }
  // Deconstructor.
  ~IndicatorDataParams(){};
  /* Getters */
  template <typename T>
  T Get(STRUCT_ENUM_IDATA_PARAM _param) {
    switch (_param) {
      case IDATA_PARAM_IS_FED:
        return (T)is_fed;
      case IDATA_PARAM_DATA_SRC_MODE:
        return (T)data_src_mode;
      case IDATA_PARAM_DTYPE:
        return (T)dtype;
      case IDATA_PARAM_IDSTYPE:
        return (T)idstype;
      case IDATA_PARAM_IDVRANGE:
        return (T)idvrange;
      case IDATA_PARAM_MAX_BUFFERS:
        return (T)max_buffers;
      case IDATA_PARAM_MAX_MODES:
        return (T)max_modes;
      case IDATA_PARAM_SRC_ID:
        return (T)src_id;
      case IDATA_PARAM_SRC_MODE:
        return (T)src_mode;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return (T)WRONG_VALUE;
  }
  color GetIndicatorColor() const { return indi_color; }
  static IndicatorDataParams GetInstance(unsigned int _max_modes = 1, ENUM_DATATYPE _dtype = TYPE_DOUBLE,
                                         ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                                         ENUM_IDATA_VALUE_RANGE _idvrange = IDATA_RANGE_UNKNOWN,
                                         int _data_src_mode = 0) {
    IndicatorDataParams _instance(_max_modes, _dtype, _idstype, _idvrange, _data_src_mode);
    return _instance;
  }
  /* Setters */
  template <typename T>
  void Set(STRUCT_ENUM_IDATA_PARAM _param, T _value) {
    switch (_param) {
      case IDATA_PARAM_IS_FED:
        is_fed = (bool)_value;
        return;
      case IDATA_PARAM_DATA_SRC_MODE:
        data_src_mode = (int)_value;
        return;
      case IDATA_PARAM_DTYPE:
        dtype = (ENUM_DATATYPE)_value;
        return;
      case IDATA_PARAM_IDSTYPE:
        idstype = (ENUM_IDATA_SOURCE_TYPE)_value;
        return;
      case IDATA_PARAM_IDVRANGE:
        idvrange = (ENUM_IDATA_VALUE_RANGE)_value;
        return;
      case IDATA_PARAM_MAX_BUFFERS:
        max_buffers = (unsigned int)_value;
        return;
      case IDATA_PARAM_MAX_MODES:
        max_modes = (unsigned int)_value;
        return;
      case IDATA_PARAM_SRC_ID:
        src_id = (int)_value;
        return;
      case IDATA_PARAM_SRC_MODE:
        src_mode = (int)_value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
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
