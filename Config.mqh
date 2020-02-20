//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Implements class for storing, importing and exporting configuration.
 */

// Prevents processing this includes file for the second time.
#ifndef CONFIG_MQH
#define CONFIG_MQH

// Includes.
#include "Object.mqh"
#include "DictStruct.mqh"
#include "File.mqh"

string ToJSON(const MqlParam& param, bool, int) {
  switch (param.type) {
    case TYPE_BOOL:
      //boolean 
      return JSON::Stringify((bool)param.integer_value);
    case TYPE_INT:
      return JSON::Stringify((int)param.integer_value);
      break;
    case TYPE_DOUBLE:
    case TYPE_FLOAT:
      return JSON::Stringify(param.double_value);
      break;
    case TYPE_CHAR:
    case TYPE_STRING:
      return JSON::Stringify(param.string_value, true);
      break;
    case TYPE_DATETIME:
    #ifdef __MQL5__
      return JSON::Stringify(TimeToString(param.integer_value), true);
    #else
      return JSON::Stringify(TimeToStr(param.integer_value), true);
    #endif
      break;
  }
  return "\"Unsupported MqlParam.ToJSON type: \"" + IntegerToString(param.type) + "\"";
}

template<typename X>
MqlParam MakeParam(X& value) {
  return MqlParam(value);
}

class ConfigEntry : public Object {
 public:
  MqlParam value;
  
  ConfigEntry() {
  }
  
  ConfigEntry(const ConfigEntry& right) {
    value = right.value;
  }
};

class Config : public DictStruct<string, MqlParam> {
 private:
 protected:
  File *file;

 public:
  /**
   * Class constructor.
   */
  Config(bool _use_file = false) {
    if (_use_file) {
      file = new File();
    }
  }
  
  bool Set(string key, bool value) {
    MqlParam param = {TYPE_BOOL, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, int value) {
    MqlParam param = {TYPE_INT, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, long value) {
    MqlParam param = {TYPE_LONG, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, double value) {
    MqlParam param = {TYPE_DOUBLE, 0, 0, ""};
    param.double_value = value;
    return Set(key, param);
  }

  bool Set(string key, string value) {
    MqlParam param = {TYPE_STRING, 0, 0, ""};
    param.string_value = value;
    return Set(key, param);
  }

  bool Set(string key, datetime value) {
    MqlParam param = {TYPE_DATETIME, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, MqlParam &value) {
    return ((DictStruct<string, MqlParam> *) GetPointer(this)).Set(key, value);
  }

  /* File methods */

  /**
   * Loads config from the file.
   */
  bool LoadFromFile() { return false; }

  /**
   * Save config into the file.
   */
  bool SaveToFile() { return false; }

  /**
   * Returns config in plain format.
   */
  string ToString() { return ""; }
};
#endif  // CONFIG_MQH
