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
 * Includes Data's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward class declaration.
class Serializer;
struct MqlParam;
struct MqlRates;

// Includes.
#include "Data.enum.h"
#include "DateTime.mqh"
#include "Serializer/Serializer.enum.h"
#include "Serializer/SerializerNode.enum.h"
#include "Std.h"
#include "Serializer/Serializer.h"

#ifndef __MQL__
/**
 * Struct to provide input parameters.
 *
 * For example input parameters for technical indicators.
 *
 * @see: https://www.mql5.com/en/docs/constants/structures/mqlparam
 */
struct MqlParam {
  ENUM_DATATYPE type;  // Type of the input parameter, value of ENUM_DATATYPE.
  union {
    long integer_value;   // Field to store an integer type.
    double double_value;  // Field to store a double type.
    string string_value;  // Field to store a string type.
  };
  MqlParam() { type = InvalidEnumValue<ENUM_DATATYPE>::value(); }

  MqlParam(const MqlParam &_r) { THIS_REF = _r; }

  MqlParam &operator=(const MqlParam &_r) {
    type = _r.type;
    switch (type) {
      case TYPE_BOOL:
      case TYPE_CHAR:
      case TYPE_INT:
      case TYPE_LONG:
      case TYPE_SHORT:
      case TYPE_UINT:
      case TYPE_ULONG:
      case TYPE_USHORT:
      case TYPE_UCHAR:
      case TYPE_COLOR:
      case TYPE_DATETIME:
        integer_value = _r.integer_value;
        break;
      case TYPE_DOUBLE:
      case TYPE_FLOAT:
        double_value = _r.double_value;
        break;
      case TYPE_STRING:
        string_value = _r.string_value;
    }
    return THIS_REF;
  }

  MqlParam(long _value) {
    type = ENUM_DATATYPE::TYPE_LONG;
    integer_value = _value;
  }
  MqlParam(int _value) {
    type = ENUM_DATATYPE::TYPE_INT;
    integer_value = _value;
  }
  MqlParam(bool _value) {
    type = ENUM_DATATYPE::TYPE_BOOL;
    integer_value = _value ? 1 : 0;
  }
  MqlParam(float _value) {
    type = ENUM_DATATYPE::TYPE_FLOAT;
    double_value = (double)_value;
  }
  MqlParam(double _value) {
    type = ENUM_DATATYPE::TYPE_DOUBLE;
    double_value = _value;
  }
  ~MqlParam() {}
};
#endif

/**
 * Struct to provide multitype data parameters.
 *
 * For example input parameters for technical indicators.
 *
 * @see: https://www.mql5.com/en/docs/constants/structures/mqlparam
 */
struct DataParamEntry : public MqlParam {
 public:
  DataParamEntry() { type = InvalidEnumValue<ENUM_DATATYPE>::value(); }
  DataParamEntry(ENUM_DATATYPE _type, long _integer_value, double _double_value, string _string_value) {
    type = _type;
    integer_value = _integer_value;
    double_value = _double_value;
    string_value = _string_value;
  }
  DataParamEntry(const DataParamEntry &_r) { ASSIGN_TO_THIS(MqlParam, _r); }
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
  bool operator==(const DataParamEntry &_s) {
    return type == _s.type && double_value == _s.double_value && integer_value == _s.integer_value &&
           string_value == _s.string_value;
  }

  /* Constructors */

  /*
  DataParamEntry() {}
  DataParamEntry(ENUM_DATATYPE _type, long _int, double _dbl, string _str) {
    type = _type;
    integer_value = _int;
    double_value = _dbl;
    string = _str;
  }
  DataParamEntry(ENUM_DATATYPE _type) { type = _type; }
  */

  /* Getters */

  /**
   * Gets a value of the given type.
   *
   */
  template <typename T>
  T ToValue() {
    switch (type) {
      case TYPE_CHAR:
      case TYPE_STRING:
      case TYPE_UCHAR:
        return (T)::StringToDouble(string_value);
      case TYPE_DOUBLE:
      case TYPE_FLOAT:
        return (T)ToDouble(THIS_REF);
      default:
      case TYPE_BOOL:
      case TYPE_INT:
      case TYPE_LONG:
      case TYPE_UINT:
      case TYPE_ULONG:
        return (T)ToInteger(THIS_REF);
    }
  }

  /* Static methods */

  /**
   * Gets DataParamEntry struct based on the value of double type.
   *
   */
  static DataParamEntry FromValue(double _value) {
    DataParamEntry _dpe;
    _dpe.type = TYPE_DOUBLE;
    _dpe.double_value = _value;
    return _dpe;
  }

  /**
   * Gets DataParamEntry struct based on the value of float type.
   *
   */
  static DataParamEntry FromValue(float _value) {
    DataParamEntry _dpe;
    _dpe.type = TYPE_FLOAT;
    _dpe.double_value = _value;
    return _dpe;
  }

  /**
   * Gets DataParamEntry struct based on the value of integer type.
   *
   */
  static DataParamEntry FromValue(int _value) {
    DataParamEntry _dpe;
    _dpe.type = TYPE_INT;
    _dpe.integer_value = _value;
    return _dpe;
  }

  /**
   * Gets DataParamEntry struct based on the value of long type.
   *
   */
  static DataParamEntry FromValue(long _value) {
    DataParamEntry _dpe;
    _dpe.type = TYPE_LONG;
    _dpe.integer_value = _value;
    return _dpe;
  }

  /**
   * Gets DataParamEntry struct based on the value of unknown type.
   *
   * Warning: You'll get an infinite loop, if the typename is unknown.
   *
   */
  template <typename T>
  static DataParamEntry FromValue(T _value) {
    DataParamEntry _dpe = FromValue((T)_value);
    return _dpe;
  }

  /**
   * Converts MqlParam struct to double.
   *
   */
  static double ToDouble(MqlParam &param) {
    switch (param.type) {
      case TYPE_BOOL:
        return param.integer_value ? 1 : 0;
      case TYPE_INT:
      case TYPE_LONG:
      case TYPE_UINT:
      case TYPE_ULONG:
        return (double)param.integer_value;
      case TYPE_DOUBLE:
      case TYPE_FLOAT:
        return param.double_value;
      case TYPE_CHAR:
      case TYPE_STRING:
      case TYPE_UCHAR:
        return ::StringToDouble(param.string_value);
      case TYPE_COLOR:
      case TYPE_DATETIME:
      case TYPE_SHORT:
      case TYPE_USHORT:
        return DBL_MIN;
    }
    return DBL_MIN;
  }

  /**
   * Converts MqlParam struct to integer.
   *
   */
  static long ToInteger(MqlParam &param) {
    switch (param.type) {
      case TYPE_BOOL:
        return param.integer_value ? 1 : 0;
      case TYPE_DATETIME:
      case TYPE_INT:
      case TYPE_LONG:
      case TYPE_UINT:
      case TYPE_ULONG:
      case TYPE_SHORT:
        return param.integer_value;
      case TYPE_DOUBLE:
      case TYPE_FLOAT:
        return (int)param.double_value;
      case TYPE_CHAR:
      case TYPE_COLOR:
      case TYPE_STRING:
      case TYPE_UCHAR:
        return ::StringToInteger(param.string_value);
      case TYPE_USHORT:
        return INT_MIN;
    }
    return INT_MIN;
  }

  /* Serializers */

  /**
   * Initializes object with given number of elements. Could be skipped for non-containers.
   */
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {
    type = TYPE_INT;
    integer_value = 0;
  }
  SerializerNodeType Serialize(Serializer &s);
};

/* Method to serialize DataParamEntry struct. */
SerializerNodeType DataParamEntry::Serialize(Serializer &s) {
  s.PassEnum(THIS_REF, "type", type, SERIALIZER_FIELD_FLAG_HIDDEN);
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
      s.Pass(THIS_REF, "value", integer_value);
      break;

    case TYPE_DOUBLE:
      s.Pass(THIS_REF, "value", double_value);
      break;

    case TYPE_STRING:
      s.Pass(THIS_REF, "value", string_value);
      break;

    case TYPE_DATETIME:
      if (s.IsWriting()) {
        aux_string = TimeToString(integer_value);
        s.Pass(THIS_REF, "value", aux_string);
      } else {
        s.Pass(THIS_REF, "value", aux_string);
        integer_value = StringToTime(aux_string);
      }
      break;

    default:
      // Unknown type. Serializing anyway.
      s.Pass(THIS_REF, "value", aux_string);
  }
  return SerializerNodeObject;
}
