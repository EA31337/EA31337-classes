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

// Prevents processing this includes file for the second time.
#ifndef JSON_PARAM_MQH
#define JSON_PARAM_MQH

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
    long _long;
    double _double;
  } _integral;

  string _string;
  SerializerNodeParamType _type;

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromBool(long value) {
    SerializerNodeParam* param = new SerializerNodeParam();
    param._type = SerializerNodeParamBool;
    param._integral._bool = value;
    return param;
  }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromLong(long value) {
    SerializerNodeParam* param = new SerializerNodeParam();
    param._type = SerializerNodeParamLong;
    param._integral._long = value;
    return param;
  }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromDouble(double value) {
    SerializerNodeParam* param = new SerializerNodeParam();
    param._type = SerializerNodeParamDouble;
    param._integral._double = value;
    return param;
  }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromString(string& value) {
    SerializerNodeParam* param = new SerializerNodeParam();
    param._type = SerializerNodeParamString;
    param._string = value;
    return param;
  }

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
  static SerializerNodeParam* FromValue(unsigned char value) { return FromLong(value); }

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
  static SerializerNodeParam* FromValue(color value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(int value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(long value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(string& value) { return FromString(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(unsigned int value) { return FromLong(value); }

  /**
   * Returns new SerializerNodeParam object from given source value.
   */
  static SerializerNodeParam* FromValue(unsigned long value) { return FromLong(value); }

  /**
   * Returns stringified version of the value. Note "forceQuotesOnString" flag.
   */
  string AsString(bool includeQuotes = false, bool forceQuotesOnString = true, bool escapeString = true) {
    switch (_type) {
      case SerializerNodeParamBool:
        return Serializer::ValueToString(_integral._bool, includeQuotes, escapeString);
      case SerializerNodeParamLong:
        return Serializer::ValueToString(_integral._long, includeQuotes, escapeString);
      case SerializerNodeParamDouble:
        return Serializer::ValueToString(_integral._double, includeQuotes, escapeString);
      case SerializerNodeParamString:
        return Serializer::ValueToString(_string, includeQuotes || forceQuotesOnString, escapeString);
    }

#ifdef __debug__
    PrintFormat("%s: Error: SerializerNodeParam.AsString() called for an unknown value type: %d!", __FUNCTION__, _type);
#endif
    return "<invalid param type " + IntegerToString(_type) + ">";
  }

  /**
   * Returns type of the param.
   */
  SerializerNodeParamType GetType() { return _type; }
};

#endif
