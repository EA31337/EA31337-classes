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
#ifndef SERIALIZER_CONVERTER_MQH
#define SERIALIZER_CONVERTER_MQH

// Includes.
#include "File.mqh"
#include "SerializerNode.mqh"

class SerializerConverter {
  SerializerNode* root_node;

 public:
  SerializerConverter(SerializerNode* _root = NULL) : root_node(_root) {}

  SerializerConverter(SerializerConverter& right) { root_node = right.root_node; }

  SerializerNode* Node() { return root_node; }

  template <typename X>
  static SerializerConverter FromObject(X& _value, int serializer_flags = 0) {
    Serializer _serializer(NULL, Serialize, serializer_flags);
    _serializer.FreeRootNodeOwnership();
    _serializer.PassObject(_value, "", _value);
    SerializerConverter _converter(_serializer.GetRoot());
    return _converter;
  }

  template <typename X>
  static SerializerConverter FromStruct(X _value, int serializer_flags = 0) {
    Serializer _serializer(NULL, Serialize, serializer_flags);
    _serializer.FreeRootNodeOwnership();
    _serializer.PassStruct(_value, "", _value);
    SerializerConverter _converter(_serializer.GetRoot());
    return _converter;
  }

  template <typename C>
  static SerializerConverter FromString(string arg) {
    SerializerConverter _converter(C::Parse(arg));
    return _converter;
  }

  template <typename C>
  static SerializerConverter FromFile(string path) {
    string data = File::ReadFile(path);
    SerializerConverter _converter(C::Parse(data));
    return _converter;
  }

  template <typename R>
  string ToString(unsigned int stringify_flags = 0, void* stringify_aux_arg = NULL) {
    return ((R*)NULL).Stringify(root_node, stringify_flags, stringify_aux_arg);
  }


  template <typename X>
  bool ToObject(X& obj, unsigned int serializer_flags = 0) {
    Serializer _serializer(root_node, Unserialize, serializer_flags);    
    _serializer.PassObject(obj, "", obj);
    return true;
  }

  template <typename X>
  bool ToStruct(X& obj, unsigned int serializer_flags = 0) {
    Serializer _serializer(root_node, Unserialize, serializer_flags);
    _serializer.PassStruct(obj, "", obj);
    return true;
  }
};

#endif
