//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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

// Includes.
#include "Chart.struct.h"
#include "Indicator.enum.h"

// Forward declaration.
class Indicator;

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
  double buffer1[];
  double buffer2[];
  double buffer3[];
  double buffer4[];
  double buffer5[];

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
  void SetPrevCalculated(double &price[], int _prev_calculated) {
    prev_calculated = _prev_calculated;
    ArraySetAsSeries(price, price_was_as_series);
  }

  /**
   * Returns prev_calculated value used by indicator's OnCalculate method.
   */
  int GetPrevCalculated(int _prev_calculated) { return prev_calculated; }
};

#ifndef __MQLBUILD__
// The structure of input parameters of indicators.
// @docs
// - https://www.mql5.com/en/docs/constants/structures/mqlparam
struct MqlParam {
  ENUM_DATATYPE type;   // Type of the input parameter, value of ENUM_DATATYPE.
  long integer_value;   // Field to store an integer type.
  double double_value;  // Field to store a double type.
  string string_value;  // Field to store a string type.
};
#endif

// Struct to provide input parameters for technical indicators.
// @see: https://www.mql5.com/en/docs/constants/structures/mqlparam
struct IndiParamEntry : public MqlParam {
 public:
  // Struct operators.
  void operator=(const bool _value) {
    type = TYPE_BOOL;
    integer_value = _value;
  }
  void operator=(const datetime _value) {
    type = TYPE_DATETIME;
    integer_value = _value;
  }
  void operator=(const double _value) {
    type = TYPE_DOUBLE;
    double_value = _value;
  }
  void operator=(const int _value) {
    type = TYPE_INT;
    integer_value = _value;
  }
  void operator=(const string _value) {
    type = TYPE_STRING;
    string_value = _value;
  }
  void operator=(const unsigned int _value) {
    type = TYPE_UINT;
    integer_value = _value;
  }
  template <typename T>
  void operator=(const T _value) {
    type = TYPE_INT;
    integer_value = (int)_value;
  }
  bool operator==(const IndiParamEntry &_s) {
    return type == _s.type && double_value == _s.double_value && integer_value == _s.integer_value &&
           string_value == _s.string_value;
  }
  // Constructors.
  /*
  IndiParamEntry() {}
  IndiParamEntry(ENUM_DATATYPE _type, long _int, double _dbl, string _str) {
    type = _type;
    integer_value = _int;
    double_value = _dbl;
    string = _str;
  }
  IndiParamEntry(ENUM_DATATYPE _type) { type = _type; }
  */
  // Serializers.
  SerializerNodeType Serialize(Serializer &s) {
    s.PassEnum(this, "type", type, SERIALIZER_FIELD_FLAG_HIDDEN);

    string aux_string;

    switch (type) {
      case TYPE_BOOL:
      case TYPE_UCHAR:
      case TYPE_CHAR:
      case TYPE_USHORT:
      case TYPE_SHORT:
      case TYPE_UINT:
      case TYPE_INT:
      case TYPE_ULONG:
      case TYPE_LONG:
        s.Pass(this, "value", integer_value);
        break;

      case TYPE_DOUBLE:
        s.Pass(this, "value", double_value);
        break;

      case TYPE_STRING:
        s.Pass(this, "value", string_value);
        break;

      case TYPE_DATETIME:
        if (s.IsWriting()) {
          aux_string = TimeToString(integer_value);
          s.Pass(this, "value", aux_string);
        } else {
          s.Pass(this, "value", aux_string);
          integer_value = StringToTime(aux_string);
        }
        break;

      default:
        // Unknown type. Serializing anyway.
        s.Pass(this, "value", aux_string);
    }
    return SerializerNodeObject;
  }

  /**
   * Initializes object with given number of elements. Could be skipped for non-containers.
   */
  template <>
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {
    type = TYPE_INT;
    integer_value = 0;
  }
};

struct IndicatorDataEntry {
  long timestamp;       // Timestamp of the entry's bar.
  unsigned char flags;  // Indicator entry flags.
  union IndicatorDataEntryValue {
    double vdbl;
    int vint;
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
    void operator=(const double _value) { vdbl = _value; }
    void operator=(const int _value) { vint = _value; }
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
    int GetInt() { return vint; }
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
    void Get(int &_out) { _out = vint; }
    // Setters.
    template <typename T>
    void Set(T _value) {
      Set(_value);
    }
    void Set(double _value) { vdbl = _value; }
    void Set(int _value) { vint = _value; }
    // To string
    template <typename T>
    string ToString() {
      return (string)Get<T>();
    }
  } values[];
  // Constructors.
  void IndicatorDataEntry(int _size = 1) : flags(INDI_ENTRY_FLAG_NONE), timestamp(0) { ArrayResize(values, _size); }
  // Operator overloading methods.
  template <typename T, typename I>
  T operator[](I _index) {
    return values[(int)_index].Get<T>();
  }
  template <>
  double operator[](int _index) {
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
    values[1].Get(_out1);
  };
  template <typename T>
  void GetValues(T &_out1, T &_out2, T &_out3) {
    values[0].Get(_out1);
    values[1].Get(_out1);
    values[2].Get(_out1);
  };
  template <typename T>
  void GetValues(T &_out1, T &_out2, T &_out3, T &_out4) {
    values[0].Get(_out1);
    values[1].Get(_out1);
    values[2].Get(_out1);
    values[3].Get(_out1);
  };
  IndiParamEntry GetEntry(int _index = 0) {
    IndiParamEntry _entry;
    _entry.type = IsDouble() ? TYPE_DOUBLE : TYPE_INT;
    return _entry;
  }
  // Getters.
  int GetDayOfYear() { return DateTime::TimeDayOfYear(timestamp); }
  int GetMonth() { return DateTime::TimeMonth(timestamp); }
  int GetYear() { return DateTime::TimeYear(timestamp); }
  // Value flag methods for bitwise operations.
  bool CheckFlags(unsigned short _flags) { return (flags & _flags) != 0; }
  bool CheckFlagsAll(unsigned short _flags) { return (flags & _flags) == _flags; }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= ~_flags; }
  void SetFlag(INDICATOR_ENTRY_FLAGS _flag, bool _value) {
    if (_value)
      AddFlags(_flag);
    else
      RemoveFlags(_flag);
  }
  void SetFlags(unsigned char _flags) { flags = _flags; }
  // State checkers.
  bool IsBitwise() { return CheckFlags(INDI_ENTRY_FLAG_IS_BITWISE); }
  bool IsDouble() { return CheckFlags(INDI_ENTRY_FLAG_IS_DOUBLE); }
  bool IsExpired() { return CheckFlags(INDI_ENTRY_FLAG_IS_EXPIRED); }
  bool IsPrice() { return CheckFlags(INDI_ENTRY_FLAG_IS_PRICE); }
  bool IsValid() { return CheckFlags(INDI_ENTRY_FLAG_IS_VALID); }
  // Serializers.
  SERIALIZER_EMPTY_STUB
  SerializerNodeType Serialize(Serializer &_s) {
    int _asize = ArraySize(values);
    _s.Pass(this, "datetime", timestamp);
    for (int i = 0; i < _asize; i++) {
      if (IsDouble()) {
        _s.Pass(this, (string)i, values[i].vdbl);
      } else if (IsBitwise()) {
        // Split for each bit and pass 0 or 1.
        for (int j = 0; j < sizeof(int) * 8; j = j << 2) {
          // _s.Pass(this, (string) i + "@" + (string) j, (values[i].vint & j) != 0, SERIALIZER_FIELD_FLAG_HIDDEN);
        }
      } else {
        _s.Pass(this, (string)i, values[i].vint);
      }
    }
    // _s.Pass(this, "is_valid", IsValid(), SERIALIZER_FIELD_FLAG_HIDDEN);
    // _s.Pass(this, "is_bitwise", IsBitwise(), SERIALIZER_FIELD_FLAG_HIDDEN);
    return SerializerNodeObject;
  }
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

struct IndicatorParams : ChartParams {
  string name;                      // Name of the indicator.
  int shift;                        // Shift (relative to the current bar, 0 - default).
  unsigned int max_buffers;         // Max buffers to store.
  unsigned int max_modes;           // Max supported indicator modes (values per entry).
  unsigned int max_params;          // Max supported input params.
  ENUM_INDICATOR_TYPE itype;        // Indicator type (e.g. INDI_RSI).
  ENUM_IDATA_SOURCE_TYPE idstype;   // Indicator's data source type (e.g. IDATA_BUILTIN, IDATA_ICUSTOM).
  ENUM_IDATA_VALUE_RANGE idvrange;  // Indicator's range value data type.
  // ENUM_IDATA_VALUE_TYPE idvtype;    // Indicator's data value type (e.g. TDBL1, TDBL2, TINT1).
  ENUM_DATATYPE dtype;            // Type of basic data to store values (DTYPE_DOUBLE, DTYPE_INT).
  Indicator *indi_data;           // Indicator to be used as data source. @todo: Convert to struct.
  IndiParamEntry input_params[];  // Indicator input params.
  bool indi_data_ownership;       // Whether this indicator should delete given indicator at the end.
  color indi_color;               // Indicator color.
  int indi_mode;                  // Index of indicator data to be used as data source.
  bool is_draw;                   // Draw active.
  int draw_window;                // Drawing window.
  string custom_indi_name;        // Name of the indicator passed to iCustom() method.
  /* Special methods */
  // Constructor.
  IndicatorParams(ENUM_INDICATOR_TYPE _itype = INDI_NONE, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                  string _name = "")
      : name(_name),
        shift(0),
        max_modes(1),
        max_buffers(10),
        idstype(_idstype),
        idvrange(IDATA_RANGE_UNKNOWN),
        itype(_itype),
        is_draw(false),
        indi_color(clrNONE),
        indi_mode(0),
        indi_data_ownership(true),
        draw_window(0) {
    SetDataSourceType(_idstype);
  };
  IndicatorParams(string _name, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN)
      : name(_name),
        shift(0),
        max_modes(1),
        max_buffers(10),
        idstype(_idstype),
        idvrange(IDATA_RANGE_UNKNOWN),
        is_draw(false),
        indi_color(clrNONE),
        indi_mode(0),
        indi_data_ownership(true),
        draw_window(0) {
    SetDataSourceType(_idstype);
  };
  /* Getters */
  string GetCustomIndicatorName() { return custom_indi_name; }
  color GetIndicatorColor() { return indi_color; }
  int GetIndicatorMode() { return indi_mode; }
  int GetMaxModes() { return (int)max_modes; }
  int GetMaxParams() { return (int)max_params; }
  int GetShift() { return shift; }
  ENUM_IDATA_SOURCE_TYPE GetIDataSourceType() { return idstype; }
  ENUM_IDATA_VALUE_RANGE GetIDataValueRange() { return idvrange; }
  template <typename T>
  T GetInputParam(int _index, T _default) {
    IndiParamEntry _param = input_params[_index];
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
  void SetIndicatorData(Indicator *_indi, bool take_ownership = true) {
    if (indi_data != NULL && indi_data_ownership) {
      delete indi_data;
    };
    indi_data = _indi;
    idstype = IDATA_INDICATOR;
    indi_data_ownership = take_ownership;
  }
  void SetIndicatorMode(int mode) { indi_mode = mode; }
  void SetIndicatorType(ENUM_INDICATOR_TYPE _itype) { itype = _itype; }
  void SetInputParams(IndiParamEntry &_params[]) {
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
  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(this, "name", name);
    s.Pass(this, "shift", shift);
    s.Pass(this, "max_modes", max_modes);
    s.Pass(this, "max_buffers", max_buffers);
    s.PassEnum(this, "itype", itype);
    s.PassEnum(this, "idstype", idstype);
    s.PassEnum(this, "dtype", dtype);
    // s.PassObject(this, "indicator", indi_data); // @todo
    // s.Pass(this, "indi_data_ownership", indi_data_ownership);
    s.Pass(this, "indi_color", indi_color, SERIALIZER_FIELD_FLAG_HIDDEN);
    s.Pass(this, "indi_mode", indi_mode);
    s.Pass(this, "is_draw", is_draw);
    s.Pass(this, "draw_window", draw_window, SERIALIZER_FIELD_FLAG_HIDDEN);
    s.Pass(this, "custom_indi_name", custom_indi_name);
    s.Enter(SerializerEnterObject, "chart");
    ChartParams::Serialize(s);
    s.Leave();
    return SerializerNodeObject;
  }
};

struct IndicatorState {
  int handle;       // Indicator handle (MQL5 only).
  bool is_changed;  // Set when params has been recently changed.
  bool is_ready;    // Set when indicator is ready (has valid values).
  void IndicatorState() : handle(INVALID_HANDLE), is_changed(true), is_ready(false) {}
  int GetHandle() { return handle; }
  bool IsChanged() { return is_changed; }
  bool IsReady() { return is_ready; }
};
