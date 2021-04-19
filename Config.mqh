//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
 * Implements class for storing, importing and exporting configuration.
 */

// Prevents processing this includes file for the second time.
#ifndef CONFIG_MQH
#define CONFIG_MQH

// Includes.
#include "DictStruct.mqh"
#include "File.mqh"
#include "Object.mqh"
#include "Serializer.mqh"

enum CONFIG_FORMAT { CONFIG_FORMAT_JSON, CONFIG_FORMAT_JSON_NO_WHITESPACES, CONFIG_FORMAT_INI };

string ToJSON(const MqlParam& param, bool, int) {
  switch (param.type) {
    case TYPE_BOOL:
      // boolean
      return Serializer::ValueToString((bool)param.integer_value);
    case TYPE_INT:
      return Serializer::ValueToString((int)param.integer_value);
      break;
    case TYPE_DOUBLE:
    case TYPE_FLOAT:
      return Serializer::ValueToString(param.double_value);
      break;
    case TYPE_CHAR:
    case TYPE_STRING:
      return Serializer::ValueToString(param.string_value, true);
      break;
    case TYPE_DATETIME:
#ifdef __MQL5__
      return Serializer::ValueToString(TimeToString(param.integer_value), true);
#else
      return Serializer::ValueToString(TimeToStr(param.integer_value), true);
#endif
      break;
  }
  return "\"Unsupported MqlParam.ToJSON type: \"" + IntegerToString(param.type) + "\"";
}

template <typename X>
MqlParam MakeParam(X& value) {
  return MqlParam(value);
}

// Structs.
struct ConfigEntry : public MqlParam {
 public:
  void SetProperty(string key, SerializerNodeParam* value, SerializerNode* node = NULL) {
    // Print("Setting config entry property \"" + key + "\" = \"" + value.AsString() + "\" for object");
  }

  bool operator==(const ConfigEntry& _s) {
    return type == _s.type && double_value == _s.double_value && integer_value == _s.integer_value &&
           string_value == _s.string_value;
  }

  SerializerNodeType Serialize(Serializer& s) {
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
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {
    type = TYPE_INT;
    integer_value = 0;
  }
};

class Config : public DictStruct<string, ConfigEntry> {
 private:
 protected:
  File* file;

 public:
  /**
   * Class constructor.
   */
  Config(bool _use_file = false) {
    if (_use_file) {
      file = new File();
    }
  }

  /**
   * Copy constructor.
   */
  Config(const Config& r) : DictStruct<string, ConfigEntry>(r) {}

  bool Set(string key, bool value) {
    ConfigEntry param = {TYPE_BOOL, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, int value) {
    ConfigEntry param = {TYPE_INT, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, long value) {
    ConfigEntry param = {TYPE_LONG, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, double value) {
    ConfigEntry param = {TYPE_DOUBLE, 0, 0, ""};
    param.double_value = value;
    return Set(key, param);
  }

  bool Set(string key, string value) {
    ConfigEntry param = {TYPE_STRING, 0, 0, ""};
    param.string_value = value;
    return Set(key, param);
  }

  bool Set(string key, datetime value) {
    ConfigEntry param = {TYPE_DATETIME, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, ConfigEntry& value) {
    return ((DictStruct<string, ConfigEntry>*)GetPointer(this)).Set(key, value);
  }

  /* File methods */
  template <typename K, typename V>
  static void SetProperty(DictStruct<K, V>& obj, string key, SerializerNodeParam* value, SerializerNode* node = NULL) {
    // Print("Setting struct property \"" + key + "\" = \"" + value.AsString() + "\" for object");
  }

  /**
   * Loads config from the file.
   */
  template <typename C>
  bool LoadFromFile(string path) {
    string data = File::ReadFile(path);
    return SerializerConverter::FromString<C>(data).ToObject(this);
  }

  /**
   * Save config into the file.
   */
  template <typename C>
  bool SaveToFile(string path, unsigned int serializer_flags = 0, unsigned int stringify_flags = 0,
                  void* aux_target_arg = NULL) {
    string data = SerializerConverter::FromObject(this, serializer_flags).ToString<C>(stringify_flags, aux_target_arg);
    return File::SaveFile(path, data);
  }

  /**
   * Initializes object with given number of elements. Could be skipped for non-containers.
   */
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {
    // SetMode(DictModeDict);
    for (int i = 0; i < _n1; ++i) {
      ConfigEntry _child;
      _child.SerializeStub(_n2, _n3, _n4, _n5);
      Set(IntegerToString(i), _child);
    }
  }

  /**
   * Returns config in plain format.
   */
  string ToINI() { return "Ini file"; }  // @todo
};
#endif  // CONFIG_MQH
