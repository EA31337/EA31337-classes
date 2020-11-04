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
#include "DictObject.mqh"
#include "DictStruct.mqh"
#include "Object.mqh"
#include "Serializer.mqh"
#include "SerializerNode.mqh"

struct CsvTitle {
  int column_index;
  string title;

  CsvTitle(int _column_index = 0, string _title = "") : column_index(_column_index), title(_title) {}
};

class SerializerCsv {
 public:
  static SerializerNode* Parse(string _text) { return NULL; }

  static string Stringify(SerializerNode* _root) {
    // Going through all nodes and flattening them out.
    DictObject<int, Dict<int, string>> _values;
    int _column_index = -1;

    FlattenNode(_root, _values, _column_index);

    string _result;

    if (true) {
      for (DictObjectIterator<int, Dict<int, string>> _row = _values.Begin(); _row.IsValid(); ++_row) {
        for (DictIterator<int, string> _column = _row.Value().Begin(); _column.IsValid(); ++_column) {
          _result += _column.Value() + (_column.IsLast() ? "" : ",");
        }
        _result += "\n";
      }
    }

    return _result;
  }

  static string ParamToString(SerializerNodeParam* param) {
    switch (param.GetType()) {
      case SerializerNodeParamBool:
      case SerializerNodeParamLong:
      case SerializerNodeParamDouble:
      case SerializerNodeParamString:
        return param.AsString(false, false, false);
    }

    return "";
  }

  static void FlattenNode(SerializerNode* _node, DictObject<int, Dict<int, string>>& _values, int& _column_index) {
    if (_node.IsContainer()) {
      _values.Push(Dict<int, string>());
      _column_index++;
    } else {
      _values[0].Push(_node.HasKey() ? _node.Key() : "<no key>");

      _values[_column_index].Push(SerializerCsv::ParamToString(_node.GetValueParam()));
    }

    for (SerializerNodeIterator iter(_node); iter.IsValid(); ++iter) {
      FlattenNode(iter.Node(), _values, _column_index);

      _values.Push(Dict<int, string>());
      _column_index++;
    }
  }
};

#endif
