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
#ifndef JSON_MQH
#define JSON_MQH

// Includes.
#include "Object.mqh"
#include "DictBase.mqh"

// Defines.
#define JSON_INDENTATION 2

enum JSONNODE_TYPE {
  JSONNODE_TYPE_OBJECT,
  JSONNODE_TYPE_ARRAY,
  JSONNODE_TYPE_OBJECT_PROPERTY,
  JSONNODE_TYPE_ARRAY_ITEM
};

enum JSONPARAM_TYPE {
  JSONPARAM_TYPE_BOOL,
  JSONPARAM_TYPE_LONG,
  JSONPARAM_TYPE_DOUBLE,
  JSONPARAM_TYPE_STRING
};

class JSONNode;

/**
 * Key or value.
 */
class JSONParam
{
public:

  union Value {
    bool _bool;
    long _long;
    double _double;
  } _integral;
  
  string _string;
  
  JSONPARAM_TYPE _type;
  
  static JSONParam* FromBool(long value) {
    JSONParam* param = new JSONParam();
    param._type = JSONPARAM_TYPE_BOOL;
    param._integral._bool = value;
    return param;
  }

  static JSONParam* FromLong(long value) {
    JSONParam* param = new JSONParam();
    param._type = JSONPARAM_TYPE_LONG;
    param._integral._long = value;
    return param;
  }
  
  static JSONParam* FromDouble(double value) {
    JSONParam* param = new JSONParam();
    param._type = JSONPARAM_TYPE_DOUBLE;
    param._integral._double = value;
    return param;
  }

  static JSONParam* FromString (string &value) {
    JSONParam* param = new JSONParam();
    param._type = JSONPARAM_TYPE_STRING;
    param._string = value;    
    return param;
  }
  
  static JSONParam* FromValue(bool value) {
    return FromBool(value);
  }

  static JSONParam* FromValue(long value) {
    return FromLong(value);
  }

  static JSONParam* FromValue(int value) {
    return FromLong(value);
  }

  static JSONParam* FromValue(double value) {
    return FromDouble(value);
  }

  static JSONParam* FromValue(string &value) {
    return FromString(value);
  }

  string AsString() {
    switch (_type) {
      case JSONPARAM_TYPE_BOOL:
        return JSON::ValueToString(_integral._bool, false);
      case JSONPARAM_TYPE_LONG:
        return JSON::ValueToString(_integral._long, false);
      case JSONPARAM_TYPE_DOUBLE:
        return JSON::ValueToString(_integral._double, false);
      case JSONPARAM_TYPE_STRING:
        return JSON::ValueToString(_string, true);
    }
    
    return "<invalid type>";
  }
  
  
  JSONPARAM_TYPE GetType() {
    return _type;
  }
};

class JSONNode {
protected:
  JSONNODE_TYPE _type;
  
  JSONNode* _parent;
  JSONParam* _key;
  JSONParam* _value;
  JSONNode* _children[];
  unsigned int _numChildren;
  
public:
  JSONNode(JSONNODE_TYPE type, JSONNode* parent = NULL, JSONParam* key = NULL, JSONParam* value = NULL) : _type(type), _parent(parent), _key(key), _value(value), _numChildren(0) {
  }
  
  ~JSONNode() {
    if (_key)
      delete _key;
      
    if (_value)
      delete _value;
      
    for (unsigned int i = 0; i < _numChildren; ++i)
      delete _children[i];
  }

  JSONNode* GetParent() {
    return _parent;
  }
  
  JSONNODE_TYPE GetType() {
    return _type;
  }
  
  void SetType(JSONNODE_TYPE type) {
    _type = type;
  }

  JSONParam* GetKey() {
    return _key;
  }

  JSONParam* GetValue() {
    return _value;
  }
  
  void AddChild(JSONNode *child) {
    if (_numChildren == ArraySize(_children))
      ArrayResize(_children, _numChildren + 10);

    _children[_numChildren++] = child;
  }

  bool HasChildren() {
    return _numChildren > 0;
  }
  
  unsigned int NumChildren() {
    return _numChildren;
  }
  
  JSONNode* GetChild(unsigned int index) {
    return index >= _numChildren ? NULL : _children[index];
  }
  
  bool IsLast() {
    if (!_parent)
      return true;
      
    for (unsigned int i = 0; i < _parent.NumChildren(); ++i) {
      if (_parent.GetChild(i) == &this && i != _parent.NumChildren() - 1)
        return false;
    }
    
    return true;
  }
  
  string Repr(unsigned int indent = 0) {
    string repr;
    string ident;
    
    for (unsigned int i = 0; i < indent * 2; ++i)
      ident += "  ";
      
    repr += ident;
    
    if (GetKey() != NULL && GetKey().AsString() != "")
      repr += GetKey().AsString() + ": ";
      
    if (GetValue() != NULL)
      repr += GetValue().AsString();

    switch (GetType()) {
      case JSONNODE_TYPE_OBJECT: repr += "{\n"; break;
      case JSONNODE_TYPE_ARRAY: repr += "[\n"; break;
    }
    
    if (HasChildren()) {
      for (unsigned int i = 0; i < NumChildren(); ++i) {
        repr += GetChild(i).Repr(indent + 1);
      }
    }
    

    switch (GetType()) {
      case JSONNODE_TYPE_OBJECT: repr += ident + "}"; break;
      case JSONNODE_TYPE_ARRAY: repr += ident + "]"; break;
    }

    if (!IsLast())
      repr += ",";
      
    repr += "\n";

    return repr;
  }
  
};

class JSON {
 public:
  static string ValueToString(datetime value, bool includeQuotes = false) {
#ifdef __MQL5__
    return (includeQuotes ? "\"" : "") + TimeToString(value) + (includeQuotes ? "\"" : "");
#else
    return (includeQuotes ? "\"" : "") + TimeToStr(value) + (includeQuotes ? "\"" : "");
#endif
  }

  static string ValueToString(bool value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + (value ? "true" : "false") + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(int value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + IntegerToString(value) + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(long value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + IntegerToString(value) + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(string value, bool includeQuotes = false) {
    string output = "\"";

    for (unsigned short i = 0; i < StringLen(value); ++i) {
#ifdef __MQL5__
      switch (StringGetCharacter(value, i))
#else
      switch (StringGetChar(value, i))
#endif
      {
        case '"':
          output += "\\\"";
          break;
        case '/':
          output += "\\/";
          break;
        case '\n':
          output += "\\n";
          break;
        case '\r':
          output += "\\r";
          break;
        case '\t':
          output += "\\t";
          break;
        case '\\':
          output += "\\\\";
          break;
        default:
#ifdef __MQL5__
          output += ShortToString(StringGetCharacter(value, i));
#else
          output += ShortToString(StringGetChar(value, i));
#endif
          break;
      }
    }

    return output + "\"";
  }

  static string ValueToString(float value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + StringFormat("%.6f", value) + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(double value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + StringFormat("%.8f", value) + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(Object* _obj, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + ((Object*)_obj).ToString() + (includeQuotes ? "\"" : "");
  }
  template <typename T>
  static string ValueToString(T value, bool includeQuotes = false) {
    return StringFormat("%s%s%s", (includeQuotes ? "\"" : ""), value, (includeQuotes ? "\"" : ""));
  }
  
  template<typename X>
  static string Stringify(X& obj) {
    JSONSerializer serializer(NULL, JSONSerializer::Mode::SERIALIZE);
    serializer.EnterObject();
    obj.Serialize(serializer);
    serializer.Leave();
    if (serializer.GetRoot()) {
      return serializer.GetRoot().Repr();
    }
    
    // Error occured.
    return "{\"error\": \"Cannot stringify object!\"}";
  }

  template<typename X>
  static JSONNode* Parse(string data, X& obj) {
    JSONNode* node = Parse(data);
    
    if (!node) {
      // Parsing failed.
      return NULL;
    }
      
    JSONSerializer serializer(node, JSONSerializer::Mode::UNSERIALIZE);
    obj.Serialize(serializer);
    return node;
  }

  template<typename X>
  static JSONNode* Parse(string data, X* obj) {
    JSONNode* node = Parse(data);
    
    if (!node) {
      // Parsing failed.
      return NULL;
    }

    JSONSerializer serializer(node, JSONSerializer::Mode::UNSERIALIZE);
    obj.Serialize(&serializer);
    return node;
  }

  static JSONNode* Parse(string data) {
    JSONNODE_TYPE type;
    if (StringGetCharacter(data, 0) == '{')
      type = JSONNODE_TYPE_OBJECT;
    else
    if (StringGetCharacter(data, 0) == '[')
      type = JSONNODE_TYPE_ARRAY;
    else {
      return GracefulReturn("Failed to parse JSON. It must start with either \"1\" or \"[\".", 0, NULL, NULL);
    }

    JSONNode* root = NULL;
    JSONNode* current = NULL;
    
    bool isOuterScope = true;
    bool expectingKey = false;
    bool expectingValue = false;
    bool expectingSemicolon = false;
    JSONParam* key = NULL;
    
    for (unsigned int i = 0; i < (unsigned int)StringLen(data); ++i)
    {
    #ifdef __MQL5__
      unsigned short ch = StringGetCharacter(data, i);
    #else
      unsigned short ch = StringGetChar(data, i);
    #endif
    
      if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r')
        continue;

      if (expectingKey) {
        if (ch != '"') {
          return GracefulReturn("Expected '\"' symbol", i, root, key);
        }
        
        string strKey = ExtractString(data, i+1);
        
        if (strKey == NULL) {
          return GracefulReturn("Unexpected end of file when parsing string", i, root, key);
        }
        
        key = JSONParam::FromString(strKey);
        
        expectingKey = false;
        expectingSemicolon = true;
        
        // Skipping double quotes.
        i += StringLen(strKey) + 1;
        continue;
      }
    
      if (expectingSemicolon) {
        if (ch != ':') {
          return GracefulReturn("Expected semicolon", i, root, key);
        }
        expectingSemicolon = false;
        expectingValue = true;
        continue;
      }
      
      if (ch == '{') {
        if (expectingKey) {
          return GracefulReturn("Cannot use object as a key", i, root, key);
        }
        
        JSONNode* node = new JSONNode(JSONNODE_TYPE_OBJECT, current, key);
        
        if (!root)
          root = node;
        
        if (expectingValue)
          current.AddChild(node);
        
        current = node;

        isOuterScope = false;
        expectingKey = true;
        key = NULL;
      }
      else
      if (ch == '}') {
        if (expectingKey || expectingValue || current.GetType() != JSONNODE_TYPE_OBJECT) {
          return GracefulReturn("Unexpected end of object", i, root, key);
        }
        
        current = current.GetParent();
        expectingValue = false;
        continue;
      }
      else
      if (ch == '[') {
        if (expectingKey) {
          return GracefulReturn("Cannot use array as a key", i, root, key);
        }
        
        JSONNode* node = new JSONNode(JSONNODE_TYPE_ARRAY, current, key);
        
        if (!root)
          root = node;
        
        if (expectingValue)
          current.AddChild(node);
        
        current = node;
        expectingValue = true;
        isOuterScope = false;
        key = NULL;
        continue;
      }
      else
      if (ch == ']') {
        if (expectingKey || expectingValue || current.GetType() != JSONNODE_TYPE_ARRAY) {
          return GracefulReturn("Unexpected end of array", i, root, key);
        }
        
        current = current.GetParent();
        expectingValue = false;
        continue;
      }
      else
      if (ch >= '0' && ch <= '9') {
        if (!expectingValue) {
          return GracefulReturn("Unexpected numeric value", i, root, key);
        }
        
        string str;
        
        if (!ExtractNumber(data, i, str)) {
          return GracefulReturn("Cannot parse numberic value", i, root, key);
        }
        
        // Inserting value into node.
        JSONParam* value = StringFind(str, ".") != -1 ? JSONParam::FromValue(StringToDouble(str)) : JSONParam::FromValue(StringToInteger(str));
        current.AddChild(new JSONNode(current.GetType() == JSONNODE_TYPE_OBJECT ? JSONNODE_TYPE_OBJECT_PROPERTY : JSONNODE_TYPE_ARRAY_ITEM, current, key, value));
        expectingValue = false;
        
        // Skipping value.
        i += StringLen(str) - 1;
        
        // We don't want to delete it twice.
        key = NULL;
        continue;
      }
      else
      if (ch == '"') {
        // A string value.
        if (!expectingValue) {
          return GracefulReturn("Unexpected quotes", i, root, key);
        }
        
        string strKey = ExtractString(data, i+1);
        
        if (strKey == NULL) {
          return GracefulReturn("Unexpected end of file when parsing string", i, root, key);
        }
        
        // Skipping double quotes.
        i += StringLen(strKey) + 1;
        
        // Inserting value into node.
        
        JSONParam* value = new JSONParam();
        
        value._type = JSONPARAM_TYPE_STRING;
        value._string = strKey;
                  
        current.AddChild(new JSONNode(current.GetType() == JSONNODE_TYPE_OBJECT ? JSONNODE_TYPE_OBJECT_PROPERTY : JSONNODE_TYPE_ARRAY_ITEM, current, key, value));
        
        expectingValue = false;
       
        // We don't want to delete it twice.
        key = NULL;
        continue;
      }
      else
      if (ch == ',') {
        if (expectingKey || expectingValue || expectingSemicolon) {
          return GracefulReturn("Unexpected comma", i, root, key);
        }
        
        if (current.GetType() == JSONNODE_TYPE_OBJECT)
          expectingKey = true;
        else
          expectingValue = true;
        
        continue;
      }
    }
    
    if (key)
      delete key;
            
    return root;
  }
  
  static JSONNode* GracefulReturn(string error, unsigned int index, JSONNode* root, JSONParam* key) {
    Print(error + " at index ", index);
  
    if (root != NULL)
      delete root;
      
    if (key != NULL)
      delete key;

    return NULL;
  }
  
  static bool ExtractNumber(string& data, unsigned int index, string& number) {
    string str;
     
    for (unsigned int i = index; i < (unsigned int)StringLen(data); ++i)
    {
    #ifdef __MQL5__
      unsigned short ch = StringGetCharacter(data, i);
    #else
      unsigned short ch = StringGetChar(data, i);
    #endif
    
      if (ch >= '0' && ch <= '9') {
        str += ShortToString(ch);
      }
      else
      if (ch == '.') {
        if (i == index) {
          return false;
        }
        str += ShortToString(ch);
      }
      else {
       // End of the number.
       number = str;
       return true;
      }
    }
  
    return true;
  }
  
  static string ExtractString(string &data, unsigned int index) {
    for (unsigned int i = index; i < (unsigned int)StringLen(data); ++i)
    {
    #ifdef __MQL5__
      unsigned short ch = StringGetCharacter(data, i);
    #else
      unsigned short ch = StringGetChar(data, i);
    #endif
    
      if (ch == '"') {
        return StringSubstr(data, index, i - index);
      }
    }
    
    return NULL;
  }
};

class JSONSerializer
{
  JSONNode* _node;
  JSONNode* _root;
  
  enum Mode {
    SERIALIZE,
    UNSERIALIZE
  } _mode;
  
public:

  JSONSerializer(JSONNode* node, Mode mode) : _node(node), _mode(mode) {
  }
  
  void MarkArray() {
    if (_node)
      _node.SetType(JSONNODE_TYPE_ARRAY);
  }
  
  void MarkObject() {
    if (_node)
      _node.SetType(JSONNODE_TYPE_OBJECT);
  }

  void EnterObject(string name = "") {
    JSONParam* nameParam = (name != NULL && name != "") ? JSONParam::FromString(name) : NULL;
    
    _node = new JSONNode(JSONNODE_TYPE_OBJECT, _node, nameParam);
    
    // When writing, we need to make parent->child structure. It is not
    // required when writing, because structure is previously parsed from
    // the string.
    if (IsWriting() && _node.GetParent() != NULL)
      _node.GetParent().AddChild(_node);
    
    if (_root == NULL)
      _root = _node;
  }
  
  void EnterArray(string name = "") {
    JSONParam* nameParam = (name != NULL && name != "") ? JSONParam::FromString(name) : NULL;
    
    _node = new JSONNode(JSONNODE_TYPE_ARRAY, _node, nameParam);
    
    // When writing, we need to make parent->child structure. It is not
    // required when writing, because structure is previously parsed from
    // the string.
    if (IsWriting() && _node.GetParent() != NULL)
      _node.GetParent().AddChild(_node);
    
    if (_root == NULL)
      _root = _node;
  }

  void Leave() {
    _node = _node.GetParent();
  }
  
  bool IsWriting() {
    return _mode == Mode::SERIALIZE;
  }
  
  bool IsReading() {
    return _mode == Mode::UNSERIALIZE;
  }
  
  bool IsArray() {
    return _mode == Mode::UNSERIALIZE && _node != NULL && _node.GetType() == JSONNODE_TYPE_ARRAY;
  }
  
  bool IsObject() {
    return _mode == Mode::UNSERIALIZE && _node != NULL && _node.GetType() == JSONNODE_TYPE_OBJECT;  
  }
  
  unsigned int NumChildren() {
    return _node ? _node.NumChildren() : 0;
  }
  
  string GetChildKey(unsigned int index) {
    if (_node.GetChild(index).GetKey() == NULL)
      return "";
      
    JSONParam* key = _node.GetChild(index).GetKey();
      
    return key ? key.AsString() : "";
  }
  
  JSONNode* GetRoot() {
    return _root;
  }

  // Serializes or unserializes structure.
  template<typename T, typename V>
  void PassStruct (T& self, string name, V& value) {
    EnterObject(name);
    value.Serialize(this);
    Leave();
  }

  // Serializes or unserializes enum value.
  template<typename T, typename V>
  void PassEnum (T& self, string name, V& value) {
    if (_mode == SERIALIZE) {
      int enumValue = (int)value;
      Pass(self, name, enumValue);
    }
    else {
      int enumValue;
      Pass(self, name, enumValue);
      value = (V)enumValue;
    }
  }

  // Serializes or unserializes simple value.
  template<typename T, typename V>
  void Pass(T& self, string name, V& value) {
    if (_mode == SERIALIZE) {
      JSONParam *key = name != NULL ? JSONParam::FromString(name) : NULL;
      JSONParam *val = JSONParam::FromValue(value);
      _node.AddChild(new JSONNode(JSONNODE_TYPE_OBJECT_PROPERTY, _node, key, val));
    }
    else {
      for (unsigned int i = 0; i < _node.NumChildren(); ++i) {
        JSONNode* child = _node.GetChild(i);
        if (child.GetKey().AsString() == name) {
          JSONPARAM_TYPE paramType = child.GetValue().GetType();
          
          switch (paramType) {
            case JSONPARAM_TYPE_BOOL:
              value = child.GetValue()._integral._bool;
              break;
            case JSONPARAM_TYPE_LONG:
              value = (V)child.GetValue()._integral._long;
              break;
            case JSONPARAM_TYPE_DOUBLE:
              value = (V)child.GetValue()._integral._double;
              break;
            case JSONPARAM_TYPE_STRING:
              value = (V)child.GetValue()._string;
              break;
          }
          
          return;
        }
      }
    }
  }
};

#endif