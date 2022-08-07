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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef SERIALIZER_CONVERTER_MQH
#define SERIALIZER_CONVERTER_MQH

// Forward declarations.
class SerializerNode;

// Includes.
#include "File.mqh"
#include "Serializer.enum.h"
#include "Serializer.mqh"
#include "SerializerDict.mqh"
#include "SerializerNode.mqh"

class SerializerConverter {
 public:
  SerializerNode* root_node;
  int _serializer_flags;

  SerializerConverter(SerializerNode* _root = NULL, int serializer_flags = 0)
      : root_node(_root), _serializer_flags(serializer_flags) {}

  SerializerConverter(SerializerConverter& right) {
    root_node = right.root_node;
    _serializer_flags = right._serializer_flags;
  }

  SerializerNode* Node() { return root_node; }

  string ToDebugString(int _json_flags = 0) {
    if (root_node == NULL) {
      return "<NULL>";
    }

    return root_node PTR_DEREF ToString(_json_flags);
  }

  template <typename X>
  static SerializerConverter FromObject(X& _value, int serializer_flags = SERIALIZER_FLAG_INCLUDE_ALL) {
    Serializer _serializer(NULL, Serialize, serializer_flags);
    _serializer.FreeRootNodeOwnership();
    _serializer.PassObject(_value, "", _value, SERIALIZER_FIELD_FLAG_VISIBLE);
    SerializerConverter _converter(_serializer.GetRoot(), serializer_flags);
#ifdef __debug__
    Print("FromObject(): serializer flags: ", serializer_flags);
    Print("FromObject(): result: ",
          _serializer.GetRoot() != NULL ? _serializer.GetRoot().ToString(SERIALIZER_JSON_NO_WHITESPACES) : "NULL");
#endif
    return _converter;
  }

  template <typename X>
  static SerializerConverter FromObject(X* _value, int serializer_flags = SERIALIZER_FLAG_INCLUDE_ALL) {
    Serializer _serializer(NULL, Serialize, serializer_flags);
    _serializer.FreeRootNodeOwnership();
    _serializer.PassObject(_value, "", _value, SERIALIZER_FIELD_FLAG_VISIBLE);
    SerializerConverter _converter(_serializer.GetRoot(), serializer_flags);
#ifdef __debug__
    Print("FromObject(): serializer flags: ", serializer_flags);
    Print("FromObject(): result: ",
          _serializer.GetRoot() != NULL ? _serializer.GetRoot().ToString(SERIALIZER_JSON_NO_WHITESPACES) : "NULL");
#endif
    return _converter;
  }

  /**
   * Overrides floating-point precision for all fields.
   */
  SerializerConverter* Precision(int _fp_precision) {
    if (root_node == NULL) {
      return THIS_PTR;
    }
    PTR_ATTRIB(root_node, OverrideFloatingPointPrecision(_fp_precision));
    return THIS_PTR;
  }

  template <typename X>
  static SerializerConverter FromStruct(X _value, int serializer_flags = SERIALIZER_FLAG_INCLUDE_ALL) {
    Serializer _serializer(NULL, Serialize, serializer_flags);
    _serializer.FreeRootNodeOwnership();
    _serializer.PassStruct(_value, "", _value, SERIALIZER_FIELD_FLAG_VISIBLE);
    SerializerConverter _converter(_serializer.GetRoot(), serializer_flags);
    return _converter;
  }

  template <typename C>
  static SerializerConverter FromString(string arg) {
    SerializerConverter _converter(((C*)NULL)PTR_DEREF Parse(arg), 0);
#ifdef __debug__
    Print("FromString(): result: ",
          _converter.Node() != NULL ? _converter.Node().ToString(SERIALIZER_JSON_NO_WHITESPACES) : "NULL");
#endif
    return _converter;
  }

  template <typename C>
  static SerializerConverter FromFile(string path) {
    string data = File::ReadFile(path);
    SerializerConverter _converter(((C*)nullptr)PTR_DEREF Parse(data), 0);
    return _converter;
  }

  template <typename R>
  string ToString(unsigned int stringify_flags = 0, void* stringify_aux_arg = NULL) {
    string result = ((R*)NULL)PTR_DEREF Stringify(root_node, stringify_flags, stringify_aux_arg);
    if ((_serializer_flags & SERIALIZER_FLAG_REUSE_OBJECT) == 0) {
      Clean();
    }
    return result;
  }

  template <typename X>
  bool ToObject(X& obj, unsigned int serializer_flags = 0) {
    Serializer _serializer(root_node, Unserialize, serializer_flags);
    _serializer.PassObject(obj, "", obj, SERIALIZER_FIELD_FLAG_VISIBLE);
    if ((_serializer_flags & SERIALIZER_FLAG_REUSE_OBJECT) == 0) {
      // We don't want serializer and converter to delete the same root node.
      _serializer.FreeRootNodeOwnership();
      Clean();
    }
    return true;
  }

  template <typename X>
  bool ToStruct(X& obj, unsigned int serializer_flags = 0) {
    Serializer _serializer(root_node, Unserialize, serializer_flags);
    _serializer.PassStruct(obj, "", obj, SERIALIZER_FIELD_FLAG_VISIBLE);
    if ((_serializer_flags & SERIALIZER_FLAG_REUSE_OBJECT) == 0) {
      // We don't want serializer and converter to delete the same root node.
      _serializer.FreeRootNodeOwnership();
      Clean();
    }
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
    if ((_serializer_flags & SERIALIZER_FLAG_REUSE_OBJECT) == 0) {
      Clean();
    }
    return true;
  }

#ifdef SERIALIZER_CSV_MQH

  /**
   * Converts object into CSV and then SQL. Thus way we don't duplicate CSV serializer's code.
   */
  string ToSQL(unsigned int _stringify_flags = 0, void* _stub = NULL);

  /**
   * Converts object into CSV and then SQL. Thus way we don't duplicate CSV serializer's code.
   */
  bool ToSQLFile(string _path, unsigned int _stringify_flags = 0, void* _stub = NULL) {
    string _data = ToSQL(_stringify_flags, _stub);
    return File::SaveFile(_path, _data);
  }

#endif

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

  template <typename X>
  static SerializerConverter MakeStubObject(X& stub, int _serializer_flags = 0, int _n1 = 1, int _n2 = 1, int _n3 = 1,
                                            int _n4 = 1, int _n5 = 1) {
    stub.SerializeStub(_n1, _n2, _n3, _n4, _n5);
    return SerializerConverter::FromObject(stub, _serializer_flags);
  }
};

#endif
