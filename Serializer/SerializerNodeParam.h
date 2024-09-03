//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
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

// Prevents processing this includes file for the second time.
#ifndef SERIALIZER_NODE_PARAM_H
#define SERIALIZER_NODE_PARAM_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

#include "SerializerConversions.h"

/**
 * Enumeration.
 */
enum SerializerNodeParamType {
  SerializerNodeParamBool,
  SerializerNodeParamLong,
  SerializerNodeParamDouble,
  SerializerNodeParamString
};

class SerializerNode;

/**
 * Key or value.
 */
class SerializerNodeParam {
 public:
  /**
   * Storing all integral values in a single union. We can't hold string here.
   */
  union USerializerNodeValue {
    bool _bool;
    int64 _long;
    double _double;
  } _integral;

  string _string;
  SerializerNodeParamType _type;

  // Floating-point precision.
  int fp_precision;

  /**
   * Returns floating-point precision.
   */
  int GetFloatingPointPrecision() { return fp_precision; }

  /**
   * Sets floating-point precision.
   */
  void SetFloatingPointPrecision(int _fp_precision) { fp_precision = _fp_precision; }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromBool(int64 value);

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromLong(int64 value);

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromDouble(double value);

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromString(string& value);

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(bool value) { return FromBool(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(char value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(color value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(datetime value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(double value) { return FromDouble(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(int value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(int64 value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(short value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(string& value) { return FromString(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(unsigned char value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(unsigned int value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(uint64 value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(unsigned short value) { return FromLong(value); }

  /**
   * Returns stringified version of the value. Note "forceQuotesOnString" flag.
   */
  string AsString(bool includeQuotes = false, bool forceQuotesOnString = true, bool escapeString = true,
                  int _fp_precision = -1) {
    _fp_precision = _fp_precision >= 0 ? _fp_precision : GetFloatingPointPrecision();
    switch (_type) {
      case SerializerNodeParamBool:
        return SerializerConversions::ValueToString(_integral._bool, includeQuotes, escapeString, _fp_precision);
      case SerializerNodeParamLong:
        return SerializerConversions::ValueToString(_integral._long, includeQuotes, escapeString, _fp_precision);
      case SerializerNodeParamDouble:
        return SerializerConversions::ValueToString(_integral._double, includeQuotes, escapeString, _fp_precision);
      case SerializerNodeParamString:
        return SerializerConversions::ValueToString(_string, includeQuotes || forceQuotesOnString, escapeString,
                                                    _fp_precision);
    }

#ifdef __debug_serializer__
    PrintFormat("%s: Error: SerializerNodeParam.AsString() called for an unknown value type: %d!", __FUNCTION__, _type);
#endif
    return "<invalid param type " + IntegerToString(_type) + ">";
  }

  /**
   * Returns type of the param.
   */
  SerializerNodeParamType GetType() { return _type; }

  int64 ToBool() {
    switch (_type) {
      case SerializerNodeParamBool:
        return _integral._bool;
      case SerializerNodeParamLong:
        return _integral._long != 0;
      case SerializerNodeParamDouble:
        return _integral._double != 0;
      case SerializerNodeParamString:
        return _string != "" && _string != "0";
      default:
        Alert("Internal Error. Cannot convert source type to bool");
    }

    return false;
  }

  int ToInt() {
    switch (_type) {
      case SerializerNodeParamBool:
        return _integral._bool ? 1 : 0;
      case SerializerNodeParamLong:
        return (int)_integral._long;
      case SerializerNodeParamDouble:
        return (int)_integral._double;
      case SerializerNodeParamString:
        return (int)StringToInteger(_string);
      default:
        Alert("Internal Error. Cannot convert source type to int");
    }

    return 0;
  }

  int64 ToLong() {
    switch (_type) {
      case SerializerNodeParamBool:
        return _integral._bool ? 1 : 0;
      case SerializerNodeParamLong:
        return _integral._long;
      case SerializerNodeParamDouble:
        return (int64)_integral._double;
      case SerializerNodeParamString:
        return StringToInteger(_string);
      default:
        Alert("Internal Error. Cannot convert source type to int64");
    }

    return 0;
  }

  float ToFloat() {
    switch (_type) {
      case SerializerNodeParamBool:
        return _integral._bool ? 1.0f : 0.0f;
      case SerializerNodeParamLong:
        return (float)_integral._long;
      case SerializerNodeParamDouble:
        return (float)_integral._double;
      case SerializerNodeParamString:
        return (float)StringToDouble(_string);
      default:
        Alert("Internal Error. Cannot convert source type to float");
    }

    return 0;
  }

  double ToDouble() {
    switch (_type) {
      case SerializerNodeParamBool:
        return _integral._bool ? 1.0 : 0.0;
      case SerializerNodeParamLong:
        return (double)_integral._long;
      case SerializerNodeParamDouble:
        return _integral._double;
      case SerializerNodeParamString:
        return StringToDouble(_string);
      default:
        Alert("Internal Error. Cannot convert source type to double");
    }

    return 0;
  }

  string ToString() {
    switch (_type) {
      case SerializerNodeParamBool:
        return _integral._bool ? "1" : "0";
      case SerializerNodeParamLong:
        return IntegerToString(_integral._long);
      case SerializerNodeParamDouble:
        return DoubleToString(_integral._double);
      case SerializerNodeParamString:
        return _string;
      default:
        Alert("Internal Error. Cannot convert source type to string");
    }

    return "";
  }

  int ConvertTo(int) { return ToInt(); }

  int64 ConvertTo(int64) { return ToInt(); }

  float ConvertTo(float) { return ToFloat(); }

  double ConvertTo(double) { return ToDouble(); }

  string ConvertTo(string) { return ToString(); }
};

/**
 * Returns new SerializerNodeParam object from given source value.
 */
SerializerNodeParam* SerializerNodeParam::FromBool(int64 value) {
  SerializerNodeParam* param = new SerializerNodeParam();
  PTR_ATTRIB(param, _type) = SerializerNodeParamBool;
  PTR_ATTRIB(param, _integral)._bool = value;
  return param;
}

/**
 * Returns new SerializerNodeParam object from given source value.
 */
SerializerNodeParam* SerializerNodeParam::FromLong(int64 value) {
  SerializerNodeParam* param = new SerializerNodeParam();
  PTR_ATTRIB(param, _type) = SerializerNodeParamLong;
  PTR_ATTRIB(param, _integral)._long = value;
  return param;
}

/**
 * Returns new SerializerNodeParam object from given source value.
 */
SerializerNodeParam* SerializerNodeParam::FromDouble(double value) {
  SerializerNodeParam* param = new SerializerNodeParam();
  PTR_ATTRIB(param, _type) = SerializerNodeParamDouble;
  PTR_ATTRIB(param, _integral)._double = value;
  return param;
}

/**
 * Returns new SerializerNodeParam object from given source value.
 */
SerializerNodeParam* SerializerNodeParam::FromString(string& value) {
  SerializerNodeParam* param = new SerializerNodeParam();
  PTR_ATTRIB(param, _type) = SerializerNodeParamString;
  PTR_ATTRIB(param, _string) = value;
  return param;
}

#endif // SERIALIZER_NODE_PARAM_H
