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
enum JsonParamType {
  JsonParamBool,
  JsonParamLong,
  JsonParamDouble,
  JsonParamString
};

class JsonNode;

/**
 * Key or value.
 */
class JsonParam
{
public:

  /**
   * Storing all integral values in a single union. We can't hold string here.
   */
  union Value {
    bool _bool;
    long _long;
    double _double;
  } _integral;
  
  string _string;
  JsonParamType _type;
  
  /**
   * Returns new JsonParam object from given source value.
   */
  static JsonParam* FromBool(long value) {
    JsonParam* param = new JsonParam();
    param._type = JsonParamBool;
    param._integral._bool = value;
    return param;
  }

  /**
   * Returns new JsonParam object from given source value.
   */
  static JsonParam* FromLong(long value) {
    JsonParam* param = new JsonParam();
    param._type = JsonParamLong;
    param._integral._long = value;
    return param;
  }
  
  /**
   * Returns new JsonParam object from given source value.
   */
  static JsonParam* FromDouble(double value) {
    JsonParam* param = new JsonParam();
    param._type = JsonParamDouble;
    param._integral._double = value;
    return param;
  }

  /**
   * Returns new JsonParam object from given source value.
   */
  static JsonParam* FromString (string &value) {
    JsonParam* param = new JsonParam();
    param._type = JsonParamString;
    param._string = value;    
    return param;
  }
  
  /**
   * Returns new JsonParam object from given source value.
   */
  static JsonParam* FromValue(bool value) {
    return FromBool(value);
  }

  /**
   * Returns new JsonParam object from given source value.
   */
  static JsonParam* FromValue(long value) {
    return FromLong(value);
  }

  /**
   * Returns new JsonParam object from given source value.
   */
  static JsonParam* FromValue(int value) {
    return FromLong(value);
  }

  /**
   * Returns new JsonParam object from given source value.
   */
  static JsonParam* FromValue(double value) {
    return FromDouble(value);
  }

  /**
   * Returns new JsonParam object from given source value.
   */
  static JsonParam* FromValue(string &value) {
    return FromString(value);
  }

  /**
   * Returns stringified version of the value. Note "forceQuotesOnString" flag.
   */
  string AsString(bool includeQuotes = false, bool forceQuotesOnString = true) {
    switch (_type) {
      case JsonParamBool:
        return JSON::ValueToString(_integral._bool, includeQuotes);
      case JsonParamLong:
        return JSON::ValueToString(_integral._long, includeQuotes);
      case JsonParamDouble:
        return JSON::ValueToString(_integral._double, includeQuotes);
      case JsonParamString:
        return JSON::ValueToString(_string, includeQuotes || forceQuotesOnString);
    }
    
    Print("JsonParam.AsString() called for an unknown value type: ", _type, "!");
    return "<invalid param type " + IntegerToString(_type) + ">";
  }
  
  /**
   * Returns type of the param.
   */
  JsonParamType GetType() {
    return _type;
  }
};

#endif