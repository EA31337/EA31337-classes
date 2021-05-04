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

// Forward class declaration.
class Serializer;
struct MqlParam;

// Includes.
#include "Data.enum.h"
#include "Serializer.mqh"
#include "SerializerNode.enum.h"

/**
 * Struct to provide multitype data parameters.
 *
 * For example input parameters for technical indicators.
 *
 * @see: https://www.mql5.com/en/docs/constants/structures/mqlparam
 */
struct DataParamEntry : public MqlParam {
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

#ifndef __MQL__
/**
 * Struct to provide input parameters.
 *
 * For example input parameters for technical indicators.
 *
 * @see: https://www.mql5.com/en/docs/constants/structures/mqlparam
 */
struct DataParamEntry : public MqlParam {
  ENUM_DATATYPE type;  // Type of the input parameter, value of ENUM_DATATYPE.
  union {
    long integer_value;   // Field to store an integer type.
    double double_value;  // Field to store a double type.
    string string_value;  // Field to store a string type.
  }
};
#endif
