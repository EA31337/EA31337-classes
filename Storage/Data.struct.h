//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
#include "../Convert.extern.h"
#include "../Serializer/Serializer.enum.h"
#include "../Serializer/SerializerNode.enum.h"
#include "../Std.h"
#include "Data.enum.h"
#include "DateTime.extern.h"
#include "String.h"

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
    int64 integer_value;  // Field to store an integer type.
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

  MqlParam(int64 _value) {
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
  DataParamEntry(ENUM_DATATYPE _type, int64 _integer_value, double _double_value, string _string_value) {
    type = _type;
    integer_value = _integer_value;
    double_value = _double_value;
    string_value = _string_value;
  }
  DataParamEntry(const DataParamEntry &_r) { ASSIGN_TO_THIS(MqlParam, _r); }

  DataParamEntry(bool _value) {
    type = TYPE_BOOL;
    integer_value = _value;
  }
  DataParamEntry(const datetime _value) {
    type = TYPE_DATETIME;
    integer_value = _value;
  }
  DataParamEntry(double _value) {
    type = TYPE_DOUBLE;
    double_value = _value;
  }
  DataParamEntry(int _value) {
    type = TYPE_INT;
    integer_value = _value;
  }
  DataParamEntry(const string _value) {
    type = TYPE_STRING;
    string_value = _value;
  }
  DataParamEntry(unsigned int _value) {
    type = TYPE_UINT;
    integer_value = _value;
  }
  DataParamEntry(int64 _value) {
    type = TYPE_LONG;
    integer_value = _value;
  }
  DataParamEntry(uint64 _value) {
    type = TYPE_ULONG;
    integer_value = (int64)_value;
  }

  // Struct operators.
  void operator=(bool _value) {
    type = TYPE_BOOL;
    integer_value = _value;
  }
  void operator=(const datetime _value) {
    type = TYPE_DATETIME;
    integer_value = _value;
  }
  void operator=(double _value) {
    type = TYPE_DOUBLE;
    double_value = _value;
  }
  void operator=(int _value) {
    type = TYPE_INT;
    integer_value = _value;
  }
  void operator=(const string _value) {
    type = TYPE_STRING;
    string_value = _value;
  }
  void operator=(unsigned int _value) {
    type = TYPE_UINT;
    integer_value = _value;
  }
  void operator=(int64 _value) {
    type = TYPE_LONG;
    integer_value = _value;
  }
  void operator=(uint64 _value) {
    type = TYPE_ULONG;
    integer_value = (int64)_value;
  }

  bool operator==(const DataParamEntry &_s) {
    return type == _s.type && double_value == _s.double_value && integer_value == _s.integer_value &&
           string_value == _s.string_value;
  }

  /* Constructors */

  /*
  DataParamEntry() {}
  DataParamEntry(ENUM_DATATYPE _type, int64 _int, double _dbl, string _str) {
    type = _type;
    integer_value = _int;
    double_value = _dbl;
    string = _str;
  }
  DataParamEntry(ENUM_DATATYPE _type) { type = _type; }
  */

  /* Getters */

  /**
   * Gets a string of the given type.
   */
  string ToString() {
    switch (type) {
      case TYPE_CHAR:
      case TYPE_STRING:
      case TYPE_UCHAR:
        return string_value;
      case TYPE_DOUBLE:
      case TYPE_FLOAT:
        return DoubleToString(double_value);
      default:
      case TYPE_BOOL:
      case TYPE_INT:
      case TYPE_LONG:
      case TYPE_UINT:
      case TYPE_ULONG:
        return IntegerToString(integer_value);
    }
  }

  /**
   * Gets a value of the given type.
   */
  template <typename T>
  T ToValue() {
    switch (type) {
      case TYPE_CHAR:
      case TYPE_STRING:
      case TYPE_UCHAR:
        return (T)StringToDouble(string_value);
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
   * Gets DataParamEntry struct based on the value of int64 type.
   *
   */
  static DataParamEntry FromValue(int64 _value) {
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
      case TYPE_COLOR:
      case TYPE_DATETIME:
      case TYPE_INT:
      case TYPE_LONG:
      case TYPE_SHORT:
      case TYPE_UINT:
      case TYPE_ULONG:
      case TYPE_USHORT:
        return (double)param.integer_value;
      case TYPE_DOUBLE:
      case TYPE_FLOAT:
        return param.double_value;
      case TYPE_CHAR:
      case TYPE_STRING:
      case TYPE_UCHAR:
        return ::StringToDouble(param.string_value);
    }
    return DBL_MIN;
  }

  /**
   * Converts MqlParam struct to integer.
   *
   */
  static int64 ToInteger(MqlParam &param) {
    switch (param.type) {
      case TYPE_BOOL:
        return param.integer_value ? 1 : 0;
      case TYPE_DATETIME:
      case TYPE_INT:
      case TYPE_LONG:
      case TYPE_UINT:
      case TYPE_ULONG:
      case TYPE_SHORT:
      case TYPE_USHORT:
        return param.integer_value;
      case TYPE_DOUBLE:
      case TYPE_FLOAT:
        return (int)param.double_value;
      case TYPE_CHAR:
      case TYPE_COLOR:
      case TYPE_STRING:
      case TYPE_UCHAR:
        return ::StringToInteger(param.string_value);
    }
    return INT_MIN;
  }

  /**
   * Converts MqlParam struct to string.
   *
   */
  static string ToString(MqlParam &param) {
    switch (param.type) {
      case TYPE_BOOL:
        return param.integer_value ? "true" : "false";
      case TYPE_DATETIME:
      case TYPE_INT:
      case TYPE_LONG:
      case TYPE_UINT:
      case TYPE_ULONG:
      case TYPE_SHORT:
      case TYPE_USHORT:
        return IntegerToString(param.integer_value);
      case TYPE_DOUBLE:
      case TYPE_FLOAT:
        return DoubleToString(param.double_value);
      case TYPE_CHAR:
      case TYPE_COLOR:
      case TYPE_STRING:
      case TYPE_UCHAR:
        return param.string_value;
    }
    return "";
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
