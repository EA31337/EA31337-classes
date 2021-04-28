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
#ifndef SERIALIZER_BINARY_MQH
#define SERIALIZER_BINARY_MQH

// Includes.
#include "DictBase.mqh"
#include "Object.mqh"
#include "Serializer.mqh"
#include "SerializerNode.mqh"

class Log;

enum ENUM_SERIALIZER_BINARY_FLAGS { SERIALIZER_BINARY_INCLUDE_VERSION };

union SerializerBinaryValue {
  unsigned char Bytes[8];
  double Double;
  long Long;
  int Integer;
  short Short;
};

class SerializerBinary {
 public:
  /**
   * Serializes node and its children into binary format.
   */
  static string Stringify(SerializerNode* _node, unsigned int stringify_flags = 0, void* stringify_aux_arg = NULL) {
    int size = _node.BinarySize();

    unsigned char bytes[];
    ArrayResize(bytes, size);

    StringifyNode(_node, stringify_flags, stringify_aux_arg, bytes);

    return CharArrayToString(bytes, 0, size);
  }

  static void StringifyNode(SerializerNode* _node, unsigned int stringify_flags, void* stringify_aux_arg,
                            unsigned char& bytes[], int offset = 0) {
    SerializerBinaryValue value;
    int i;
    switch (_node.GetType()) {
      case SerializerNodeArray:
        break;
      case SerializerNodeObject:
        for (i = 0; i < sizeof(value.Double); ++i) {
          // bytes[offset + i] = value.Bytes[i];
        }
        break;
      case SerializerNodeObjectProperty:
      case SerializerNodeArrayItem:
        switch (_node.GetValueParam().GetType()) {
          case SerializerNodeParamBool:
            bytes[offset] = _node.GetValueParam()._integral._bool;
            break;
          case SerializerNodeParamDouble:
            value.Double = _node.GetValueParam()._integral._double;
            for (i = 0; i < sizeof(value.Double); ++i) {
              bytes[offset + i] = value.Bytes[i];
            }
            break;
          case SerializerNodeParamLong:
            value.Long = _node.GetValueParam()._integral._long;
            for (i = 0; i < sizeof(value.Long); ++i) {
              bytes[offset + i] = value.Bytes[i];
            }
            break;
          case SerializerNodeParamString:
            for (i = 0; i < StringLen(_node.GetValueParam()._string); ++i) {
              bytes[offset + i] = (unsigned char)_node.GetValueParam()._string[i];
            }
            bytes[StringLen(_node.GetValueParam()._string)] = '\0';
            break;
        }
        break;
    }
  }

  template <typename X>
  static bool Parse(string data, X* obj, Log* logger = NULL) {
    return Parse(data, *obj, logger);
  }

  template <typename X>
  static bool Parse(string data, X& obj, Log* logger = NULL) {
    SerializerNode* node = Parse(data);

    if (!node) {
      // Parsing failed.
      return false;
    }

    Serializer serializer(node, Unserialize);

    if (logger != NULL) serializer.Logger().Link(logger);

    // We don't use result. We parse data as it is.
    obj.Serialize(serializer);

    return true;
  }

  static SerializerNode* Parse(string data, unsigned int converter_flags = 0) {
    // node = new SerializerNode(SerializerNodeObject, current, key);

    return NULL;
  }
};

#endif
