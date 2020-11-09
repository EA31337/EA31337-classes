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
#ifndef SERIALIZER_CSV_MQH
#define SERIALIZER_CSV_MQH

// Includes.
#include "Dict.mqh"
#include "DictStruct.mqh"
#include "DictObject.mqh"
#include "Matrix.mqh"
#include "SerializerNode.mqh"
#include "Serializer.mqh"
#include "Object.mqh"

struct CsvTitle
{
  int column_index;
  string title;
  
  CsvTitle(int _column_index = 0, string _title = "") : column_index(_column_index), title(_title) {
  }
};

template<typename T>
class MiniMatrix2d {
public:

  T data[];
  int size_x;
  int size_y;
  
  MiniMatrix2d(int _size_x, int _size_y) : size_x(_size_x), size_y(_size_y) {
    ArrayResize(data, _size_x * _size_y);
  }
  
  T Get(int _x, int _y) {
    return data[(size_x * _y) + _x];
  }

  void Set(int _x, int _y, T _value) {
    data[(size_x * _y) + _x] = _value;
  }
  
  int SizeX() {
    return size_x;
  }
  
  int SizeY() {
    return size_y;
  }
};

class SerializerCsv {
 public:
 
  static SerializerNode* Parse(string _text) {
    return NULL;
  }
 
  static string Stringify(SerializerNode* _root, SerializerConverter& _stub) {
  
    RemoveHiddenNodes(_root);
    RemoveHiddenNodes(_stub.Node());
  
    unsigned int _num_columns = _stub.Node().MaximumNumChildrenInDeepEnd();
    
    for (unsigned int i = 0; i < _root.NumChildren(); ++i) {
      _num_columns = MathMax(_num_columns, _root.GetChild(i).MaximumNumChildrenInDeepEnd());
    }
    
    unsigned int _num_rows    = _root.NumChildren();
    
    MiniMatrix2d<string> _cells(_num_columns, _num_rows);
  
    Print("Stub: ", _stub.Node().ToString());
    Print("Data: ", _root.ToString());
    Print("Size: ", _num_columns, " x ", _num_rows);
    
    if (!FlattenNode(_root, _stub.Node(), _cells)) {
      Alert("SerializerCsv: Error occured during flattening!");
    }
    
    string _result;
    
    for(int y = 0; y < _cells.SizeY(); ++y) {
      for(int x = 0; x < _cells.SizeX(); ++x) {
        _result += _cells.Get(x, y);
        
        if (x != _cells.SizeX() - 1) {
          _result += ",";
        }
      }
      _result += "\n";
    }
    
    return _result;
  }
  
  static string ParamToString(SerializerNodeParam* param)
  {
    switch (param.GetType())
    {
      case SerializerNodeParamBool:
      case SerializerNodeParamLong:
      case SerializerNodeParamDouble:
        return param.AsString(false, false, false);
      case SerializerNodeParamString:
        return EscapeString(param.AsString(false, false, false));
    }
    
    return "";
  }
  
  static string EscapeString(string _value) {
    string _result = _value;
    StringReplace(_result, "\"", "\"\"");
    return "\"" + _result + "\"";
  }

  /**
   *
   */
  static bool FlattenNode(SerializerNode* _data, SerializerNode* _stub, MiniMatrix2d<string>& _cells, int _column = 0, int _row = 0)
  {
    if (_stub.IsArray()) {
      for (unsigned int _data_entry_idx = 0; _data_entry_idx < _data.NumChildren(); ++_data_entry_idx) {
        if (!FillRow(_data.GetChild(_data_entry_idx), _stub, _cells, _column, _row + _data_entry_idx)) {
          return false;
        }
      }
    }
    else
    if (_stub.IsObject()) {
      // Object means that we stay at our row and populate columns with data from data entries.
      for (unsigned int _data_entry_idx = 0; _data_entry_idx < _data.NumChildren(); ++_data_entry_idx) {
        if (!FillRow(_data.GetChild(_data_entry_idx), _stub, _cells, _column + _data_entry_idx, _row, _data_entry_idx)) {
          return false;
        }
      }
    }
    
    return true;
  }

  /**
   * 
   */
  static bool FillRow(SerializerNode* _data, SerializerNode* _stub, MiniMatrix2d<string>& _cells, int _column, int _row, int _index = 0, int _level = 0)
  {
    if (_data.IsObject()) {
      for (unsigned int _data_entry_idx = 0; _data_entry_idx < _data.NumChildren(); ++_data_entry_idx) {
        if (!FillRow(_data.GetChild(_data_entry_idx), _stub.GetChild(_index), _cells, _column + _data_entry_idx, _row, _data_entry_idx, _level + 1)) {
          return false;
        }
      }      
    }
    else
    if (_data.IsArray()) {
      for (unsigned int _data_entry_idx = 0; _data_entry_idx < _data.NumChildren(); ++_data_entry_idx) {
        unsigned int _entry_size = _stub.GetChild(_index).GetChild(0).MaximumNumChildrenInDeepEnd();

        if (!FillRow(_data.GetChild(_data_entry_idx), _stub.GetChild(0), _cells, _column + _data_entry_idx * _entry_size, _row, _data_entry_idx, _level + 1)) {
          return false;
        }
      }
    }
    else {
      // A property.
      if (!(_data.GetFlags() & SERIALIZER_FLAG_HIDE_FIELD)) {
        _cells.Set(_column, _row, ParamToString(_data.GetValueParam()));
      }
    }
    
    return true;
  }
  
  static void RemoveHiddenNodes(SerializerNode* _node) {
    for (unsigned int i = 0; i < _node.NumChildren(); ++i) {
      if ((_node.GetChild(i).GetFlags() & SERIALIZER_FLAG_HIDE_FIELD) == SERIALIZER_FLAG_HIDE_FIELD) {
        _node.RemoveChild(i--);
      }
    }
  }

};

#endif
