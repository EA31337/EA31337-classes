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

// Prevents processing this includes file for the second time.
#ifndef SERIALIZER_CONVERTER_MQH
#define SERIALIZER_CONVERTER_MQH

// Forward declarations.
class SerializerNode;

// Includes.
#include "File.mqh"
#include "Serializer.enum.h"
#include "SerializerDict.mqh"
#include "SerializerNode.mqh"

class SerializerConverter {
 public:
  SerializerNode* root_node;

  SerializerConverter(SerializerNode* _root = NULL) : root_node(_root) {}

  SerializerConverter(SerializerConverter& right) { root_node = right.root_node; }

  SerializerNode* Node() { return root_node; }

  template <typename X>
  static SerializerConverter FromObject(X& _value, int serializer_flags = SERIALIZER_FLAG_INCLUDE_ALL) {
    Serializer _serializer(NULL, Serialize, serializer_flags);
    _serializer.FreeRootNodeOwnership();
    _serializer.PassObject(_value, "", _value, SERIALIZER_FIELD_FLAG_VISIBLE);
    SerializerConverter _converter(_serializer.GetRoot());
#ifdef __debug__
    Print("FromObject() result: ", _serializer.GetRoot() != NULL ? _serializer.GetRoot().ToString() : "NULL");
#endif
    return _converter;
  }

  /**
   * Overrides floating-point precision for all fields.
   */
  SerializerConverter* Precision(int _fp_precision) {
    if (root_node == NULL) {
      return &this;
    }
    root_node.OverrideFloatingPointPrecision(_fp_precision);
    return &this;
  }

  template <typename X>
  static SerializerConverter FromStruct(X _value, int serializer_flags = SERIALIZER_FLAG_INCLUDE_ALL) {
    Serializer _serializer(NULL, Serialize, serializer_flags);
    _serializer.FreeRootNodeOwnership();
    _serializer.PassStruct(_value, "", _value, SERIALIZER_FIELD_FLAG_VISIBLE);
    SerializerConverter _converter(_serializer.GetRoot());
    return _converter;
  }

  template <typename C>
  static SerializerConverter FromString(string arg) {
    SerializerConverter _converter(((C*)NULL).Parse(arg));
    return _converter;
  }

  template <typename C>
  static SerializerConverter FromFile(string path) {
    string data = File::ReadFile(path);
    SerializerConverter _converter(((C*)NULL).Parse(data));
    return _converter;
  }

  template <typename R>
  string ToString(unsigned int stringify_flags = 0, void* stringify_aux_arg = NULL) {
    string result = ((R*)NULL).Stringify(root_node, stringify_flags, stringify_aux_arg);
    Clean();
    return result;
  }

  template <typename X>
  bool ToObject(X& obj, unsigned int serializer_flags = 0) {
    Serializer _serializer(root_node, Unserialize, serializer_flags);
    _serializer.PassObject(obj, "", obj, SERIALIZER_FIELD_FLAG_VISIBLE);
    return true;
  }

  template <typename X>
  bool ToStruct(X& obj, unsigned int serializer_flags = 0) {
    Serializer _serializer(root_node, Unserialize, serializer_flags);
    _serializer.PassStruct(obj, "", obj, SERIALIZER_FIELD_FLAG_VISIBLE);
    return true;
  }

  template <typename C>
  bool ToFile(string path, unsigned int stringify_flags = 0, void* aux_target_arg = NULL) {
    string data = ToString<C>(stringify_flags, aux_target_arg);
    return File::SaveFile(path, data);
  }

  template <typename C>
  bool ToFileBinary(string path, unsigned int stringify_flags = 0, void* aux_target_arg = NULL) {
    string data = ToString<C>(stringify_flags, aux_target_arg);
    return File::SaveFile(path, data, true);
  }

  template <typename X, typename V>
  bool ToDict(X& obj, unsigned int extractor_flags = 0) {
    SerializerDict::Extract<X, V>(root_node, obj, extractor_flags);
    Clean();
    return true;
  }

  void Clean() {
    if (root_node != NULL) {
      delete root_node;
      root_node = NULL;
    }
  }

  template <typename X>
  static SerializerConverter MakeStubObject(int _serializer_flags = 0, int _n1 = 1, int _n2 = 1, int _n3 = 1,
                                            int _n4 = 1, int _n5 = 1) {
    X stub;
    stub.SerializeStub(_n1, _n2, _n3, _n4, _n5);
    return SerializerConverter::FromObject(stub, _serializer_flags);
  }
};

#endif
