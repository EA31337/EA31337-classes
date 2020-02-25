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
  JSONPARAM_TYPE_STRING,
  JSONPARAM_TYPE_OBJECT,
  JSONPARAM_TYPE_ARRAY,
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
  
  void FromString (string &value) {
    _type = JSONPARAM_TYPE_STRING;
    _string = value;
  }

  string AsString() {
    return _string;
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
};

class JSON {
 public:
  static string Stringify(datetime value, bool includeQuotes = false) {
#ifdef __MQL5__
    return (includeQuotes ? "\"" : "") + TimeToString(value) + (includeQuotes ? "\"" : "");
#else
    return (includeQuotes ? "\"" : "") + TimeToStr(value) + (includeQuotes ? "\"" : "");
#endif
  }

  static string Stringify(bool value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + (value ? "true" : "false") + (includeQuotes ? "\"" : "");
  }

  static string Stringify(int value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + IntegerToString(value) + (includeQuotes ? "\"" : "");
  }

  static string Stringify(long value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + IntegerToString(value) + (includeQuotes ? "\"" : "");
  }

  static string Stringify(string value, bool includeQuotes = false) {
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

  static string Stringify(float value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + StringFormat("%.6f", value) + (includeQuotes ? "\"" : "");
  }

  static string Stringify(double value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + StringFormat("%.8f", value) + (includeQuotes ? "\"" : "");
  }

  static string Stringify(Object* _obj, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + ((Object*)_obj).ToString() + (includeQuotes ? "\"" : "");
  }
  template <typename T>
  static string Stringify(T value, bool includeQuotes = false) {
    return StringFormat("%s%s%s", (includeQuotes ? "\"" : ""), value, (includeQuotes ? "\"" : ""));
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
    
    JSONNode* current = root;
    
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
    
      if (expectingKey) {
        if (ch != '"') {
          return GracefulReturn("Expected '\"' symbol", i, root, key);
        }
        
        string strKey = ExtractString(data, i+1);
        
        if (strKey == NULL) {
          return GracefulReturn("Unexpected end of file when parsing string", i, root, key);
        }
        
        key = new JSONParam();
        key.FromString(strKey);
        
        expectingKey = false;
        expectingSemicolon = true;
        
        // Skipping double quotes.
        i += StringLen(strKey) + 1;
        continue;
      }
    
      if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r')
        continue;
        
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
        
        JSONNode* node = new JSONNode(JSONNODE_TYPE_OBJECT, current);
        
        if (!root)
          root = node;
        
        if (expectingValue)
          current.AddChild(node);
        else
          current = node;

        isOuterScope = false;
        expectingKey = true;
      }
      else
      if (ch == '}') {
        if (expectingKey || expectingValue || current.GetType() != JSONNODE_TYPE_OBJECT) {
          return GracefulReturn("Unexpected end of object/array", i, root, key);
        }
      }
      else
      if (ch == '[') {
        current = new JSONNode(JSONNODE_TYPE_ARRAY, current);

        if (!root)
          root = current;

        isOuterScope = false;
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
        
      
        if (current.GetType() == JSONNODE_TYPE_OBJECT) {
          // Inserting value into object node.
          
          JSONParam* value = new JSONParam();
          
          value.FromString(str);
                    
          current.AddChild(new JSONNode(JSONNODE_TYPE_OBJECT_PROPERTY, current, key, value));
          
          expectingValue = false;
          
          // Skipping value.
          i += StringLen(str);
          
          // We don't want to delete it twice.
          key = NULL;
          continue;
        }
      }
    }
    
    if (key)
      delete key;
            
      // ....[..... .......E.. .......... ..........
      //Print("JSON error at index ", i, " near: " + StringSubstr(data, MathMax(0, i - 15), MathMax(15, MathMax(0, i - 15))));
      //return NULL;
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

#endif