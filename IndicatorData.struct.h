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

// Includes.
#include "SerializerNode.enum.h"

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
