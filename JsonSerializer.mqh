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
#ifndef JSON_SERIALIZER_MQH
#define JSON_SERIALIZER_MQH

// Includes.
#include "DictBase.mqh"
#include "JsonParam.mqh"
#include "JsonNode.mqh"
#include "JsonIterator.mqh"
#include "Log.mqh"

enum JsonSerializerEnterMode {
  JsonEnterArray,
  JsonEnterObject
};

enum JsonSerializerMode {
  JsonSerialize,
  JsonUnserialize
};

class JsonSerializer
{
protected:

  JsonNode* _node;
  JsonNode* _root;
  JsonSerializerMode _mode;
  
  Log* _logger;
  
public:

  /**
   * Constructor.
   */
  JsonSerializer(JsonNode* node, JsonSerializerMode mode) : _node(node), _mode(mode) {
  }

  /**
   * Returns logger object.
   */  
  Log* Logger() {
    return _logger;
  }
  
  template<typename X>
  JsonIterator<X> Begin() {
    JsonIterator<X> iter(&this, _node);
    return iter;
  }
  
  /**
   * Enters object or array for a given key or just iterates over objects/array during unserializing.
   */
  void Enter(JsonSerializerEnterMode mode, string key = "")
  {
    if (IsWriting()) {
      JsonParam* nameParam = (key != NULL && key != "") ? JsonParam::FromString(key) : NULL;
            
      // When writing, we need to make parent->child structure. It is not
      // required when reading, because structure is full done by parsing the
      // string.
      _node = new JsonNode(mode == JsonEnterObject ? JsonNodeObject : JsonNodeArray, _node, nameParam);
      
      if (_node.GetParent() != NULL)
        _node.GetParent().AddChild(_node);
      
      if (_root == NULL)
        _root = _node;
    }
    else {
      JsonNode* child;
      
      if (key != "") {
        // We need to enter object that matches given key.
        for (unsigned int i = 0; i < _node.NumChildren(); ++i) {
          child = _node.GetChild(i);
          if (child.GetKeyParam().AsString(false, false) == key) {
            _node = child;
            return;
          }
        }
      }
      else
      if (key == "") {
        child = _node.GetNextChild();
        
        if (!child)
          Print("End of objects during JSON deserialization! There were only ", _node.NumChildren(), " nodes!");

        _node = child;
      }
    }
  }
 
  /**
   * Leaves current object/array. Used in custom Serialize() method.
   */
  void Leave() {
    _node = _node.GetParent();
  }
  
  /**
   * Checks whether we are in serialization process. Used in custom Serialize() method.
   */
  bool IsWriting() {
    return _mode == JsonSerialize;
  }
  
  /**
   * Checks whether we are in unserialization process. Used in custom Serialize() method.
   */
  bool IsReading() {
    return _mode == JsonUnserialize;
  }
  
  /**
   * Checks whether current node is an array. Used in custom Serialize() method.
   */
  bool IsArray() {
    return _mode == JsonUnserialize && _node != NULL && _node.GetType() == JsonNodeArray;
  }
  
  /**
   * Checks whether current node is an object. Used in custom Serialize() method.
   */
  bool IsObject() {
    return _mode == JsonUnserialize && _node != NULL && _node.GetType() == JsonNodeObject;
  }
  
  /**
   * Returns number of child nodes.
   */
  unsigned int NumChildren() {
    return _node ? _node.NumChildren() : 0;
  }
  
  /**
   * Returns root node or NULL. Could be used after unserialization.
   */
  JsonNode* GetRoot() {
    return _root;
  }
  
  /**
   * Returns child node for a given index or NULL.
   */
  JsonNode* GetChild(unsigned int index) {
    return _node ? _node.GetChild(index) : NULL;
  }

  /**
   * Serializes or unserializes object.
   */
  template<typename T, typename V>
  void PassObject (T& self, string name, V& value) {
    PassStruct(self, name, value);
  }

  /**
   * Serializes or unserializes structure.
   */
  template<typename T, typename V>
  void PassStruct (T& self, string name, V& value) {
    Enter(JsonEnterObject, name);
    JsonNodeType newType = value.Serialize(this);
    
    if (newType != JsonNodeUnknown)
      _node.SetType(newType);
      
    Leave();
  }

  /**
   * Serializes or unserializes enum value (stores it as integer).
   */
  template<typename T, typename V>
  void PassEnum (T& self, string name, V& value) {
    int enumValue;
    if (_mode == JsonSerialize) {
      enumValue = (int)value;
      Pass(self, name, enumValue);
    }
    else {
      Pass(self, name, enumValue);
      value = (V)enumValue;
    }
  }

  /**
   * Serializes or unserializes pointer to object.
   */
  template<typename T, typename V>
  void Pass(T& self, string name, V*& value) {
    if (_mode == JsonSerialize) {
      PassObject(self, name, value);
    }
    else {
      V* newborn = new V();
      
      PassObject(self, name, newborn);
      
      value = newborn;
    }
  }

  /**
   * Helper method to avoid ambiguous call.
   */
  template<typename T, typename V>
  void PassObjectPointer(T& self, string name, V& value) {
    Pass(self, name, value);
  }

  /**
   * Serializes or unserializes simple value.
   */
  template<typename T, typename V>
  void Pass(T& self, string name, V& value) {
    if (_mode == JsonSerialize) {
      JsonParam *key = name != "" ? JsonParam::FromString(name) : NULL;
      JsonParam *val = JsonParam::FromValue(value);
      _node.AddChild(new JsonNode(JsonNodeObjectProperty, _node, key, val));
    }
    else {
      for (unsigned int i = 0; i < _node.NumChildren(); ++i) {
        JsonNode* child = _node.GetChild(i);
        if (child.GetKeyParam().AsString(false, false) == name) {
          JsonParamType paramType = child.GetValueParam().GetType();
          
          switch (paramType) {
            case JsonParamBool:
              value = (V)child.GetValueParam()._integral._bool;
              break;
            case JsonParamLong:
              value = (V)child.GetValueParam()._integral._long;
              break;
            case JsonParamDouble:
              value = (V)child.GetValueParam()._integral._double;
              break;
            case JsonParamString:
              value = (V)child.GetValueParam()._string;
              break;
          }
          
          return;
        }
      }
    }
  }
};

#endif