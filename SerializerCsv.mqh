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
#ifndef SERIALIZER_CSV_MQH
#define SERIALIZER_CSV_MQH

// Includes.
#include "Dict.mqh"
#include "DictObject.mqh"
#include "DictStruct.mqh"
#include "Matrix.mqh"
#include "MiniMatrix.h"
#include "Object.mqh"
#include "SerializerConverter.mqh"
#include "SerializerNode.mqh"

struct CsvTitle {
  int column_index;
  string title;

  CsvTitle(int _column_index = 0, string _title = "") : column_index(_column_index), title(_title) {}
};

enum ENUM_SERIALIZER_CSV_FLAGS {
  SERIALIZER_CSV_INCLUDE_TITLES = 1,
  SERIALIZER_CSV_INCLUDE_TITLES_TREE = SERIALIZER_CSV_INCLUDE_TITLES + 2,
  SERIALIZER_CSV_INCLUDE_KEY = 4
};

class SerializerCsv {
 public:
  static string Stringify(SerializerNode* _root, unsigned int serializer_flags, void* serializer_aux_arg = NULL,
                          MiniMatrix2d<string>* _matrix_out = NULL,
                          MiniMatrix2d<SerializerNodeParamType>* _column_types_out = NULL) {
    SerializerConverter* _stub = (SerializerConverter*)serializer_aux_arg;

    if (CheckPointer(_root) == POINTER_INVALID) {
      Alert("SerializerCsv: Invalid root node poiner!");
      DebugBreak();
      return NULL;
    }

    if (_stub == NULL || _stub.Node() == NULL) {
      Alert("SerializerCsv: Cannot convert to CSV without stub object!");
      DebugBreak();
      return NULL;
    }

    bool _include_titles = bool(serializer_flags & SERIALIZER_CSV_INCLUDE_TITLES);
    bool _include_key = bool(serializer_flags & SERIALIZER_CSV_INCLUDE_KEY);

    unsigned int _num_columns, _num_rows;
    int x, y;

    if (_stub.Node().IsArray()) {
      _num_columns = _stub.Node().MaximumNumChildrenInDeepEnd();
      _num_rows = _root.NumChildren();
    } else {
      _num_columns = MathMax(_stub.Node().MaximumNumChildrenInDeepEnd(), _root.MaximumNumChildrenInDeepEnd());
      _num_rows = _root.NumChildren() > 0 ? 1 : 0;
    }

    if (_include_titles) {
      ++_num_rows;
    }

    if (_include_key) {
      ++_num_columns;
    }

    MiniMatrix2d<string> _cells;
    MiniMatrix2d<string> _column_titles;
    MiniMatrix2d<SerializerNodeParamType> _column_types;

    if (_matrix_out == NULL) {
      _matrix_out = &_cells;
    }

    if (_column_types_out == NULL) {
      _column_types_out = &_column_types;
    }

    _matrix_out.Resize(_num_columns, _num_rows);
    _column_types_out.Resize(_num_columns, 1);

    if (_include_titles) {
      _column_titles.Resize(_num_columns, 1);
      int _titles_current_column = 0;
      SerializerCsv::ExtractColumns(_stub.Node(), &_column_titles, _column_types_out, serializer_flags,
                                    _titles_current_column);
      for (x = 0; x < _matrix_out.SizeX(); ++x) {
        _matrix_out.Set(x, 0, EscapeString(_column_titles.Get(x, 0)));
      }
    }

#ifdef __debug__
    Print("Stub: ", _stub.Node().ToString());
    Print("Data: ", _root.ToString());
    Print("Size: ", _num_columns, " x ", _num_rows);
#endif

    if (!SerializerCsv::FlattenNode(_root, _stub.Node(), _matrix_out, _column_types_out, _include_key ? 1 : 0,
                                    _include_titles ? 1 : 0, serializer_flags)) {
      Alert("SerializerCsv: Error occured during flattening!");
    }

    string _result;

    for (y = 0; y < _matrix_out.SizeY(); ++y) {
      for (x = 0; x < _matrix_out.SizeX(); ++x) {
        _result += _matrix_out.Get(x, y);

        if (x != _matrix_out.SizeX() - 1) {
          _result += ",";
        }
      }

      if (y != _matrix_out.SizeY() - 1) _result += "\n";
    }

    if ((serializer_flags & SERIALIZER_FLAG_REUSE_STUB) == 0) {
      _stub.Clean();
    }

    return _result;
  }

  static string ParamToString(SerializerNodeParam* param) {
    switch (param.GetType()) {
      case SerializerNodeParamBool:
      case SerializerNodeParamLong:
      case SerializerNodeParamDouble:
        return param.AsString(false, false, false, param.GetFloatingPointPrecision());
      case SerializerNodeParamString:
        return EscapeString(param.AsString(false, false, false, param.GetFloatingPointPrecision()));
      default:
        Print("Error: Wrong param type ", EnumToString(param.GetType()), "!");
        DebugBreak();
    }

    return "";
  }

  static string EscapeString(string _value) {
    string _result = _value;
    StringReplace(_result, "\"", "\"\"");
    return "\"" + _result + "\"";
  }

  /**
   * Extracts column names and types from the stub, so even if there is not data, we'll still have information about
   * columns.
   */
  static void ExtractColumns(SerializerNode* _stub, MiniMatrix2d<string>* _titles,
                             MiniMatrix2d<SerializerNodeParamType>* _column_types, int _flags, int& _column) {
    for (unsigned int _stub_entry_idx = 0; _stub_entry_idx < _stub.NumChildren(); ++_stub_entry_idx) {
      SerializerNode* _child = _stub.GetChild(_stub_entry_idx);
      if (_child.IsContainer()) {
        ExtractColumns(_child, _titles, _column_types, _flags, _column);
      } else if (_child.HasKey()) {
        _titles.Set(_column++, 0, _child.Key());
      }
    }
  }

  /**
   *
   */
  static bool FlattenNode(SerializerNode* _data, SerializerNode* _stub, MiniMatrix2d<string>& _cells,
                          MiniMatrix2d<SerializerNodeParamType>* _column_types, int _column, int _row, int _flags) {
    unsigned int _data_entry_idx;

    bool _include_key = bool(_flags & SERIALIZER_CSV_INCLUDE_KEY);

    if (_stub.IsArray()) {
      for (_data_entry_idx = 0; _data_entry_idx < _data.NumChildren(); ++_data_entry_idx) {
        if (_include_key) {
          // Adding object's key in the first row.
          SerializerNode* _child = _data.GetChild(_data_entry_idx);
          string key = _child.HasKey() ? _child.Key() : "";
          _cells.Set(0, _row + _data_entry_idx, key);
        }

        if (!SerializerCsv::FillRow(_data.GetChild(_data_entry_idx), _stub.GetChild(0), _cells, _column_types, _column,
                                    _row + _data_entry_idx, 0, 0, _flags)) {
          return false;
        }
      }
    } else if (_stub.IsObject()) {
      // Object means that there is only one row.
      if (_data.IsArray()) {
        // Stub is an object, but data is an array (should be?).
        for (_data_entry_idx = 0; _data_entry_idx < _data.NumChildren(); ++_data_entry_idx) {
          if (!SerializerCsv::FillRow(_data.GetChild(_data_entry_idx), _stub, _cells, _column_types, _column, _row, 0,
                                      0, _flags)) {
            return false;
          }

          _column += (int)_stub.GetChild(_data_entry_idx).MaximumNumChildrenInDeepEnd();
        }
      } else {
        // Stub and object are both arrays.
        if (!SerializerCsv::FillRow(_data, _stub, _cells, _column_types, _column, _row, 0, 0, _flags)) {
          return false;
        }
      }
    }

    return true;
  }

  /**
   *
   */
  static bool FillRow(SerializerNode* _data, SerializerNode* _stub, MiniMatrix2d<string>& _cells,
                      MiniMatrix2d<SerializerNodeParamType>* _column_types, int _column, int _row, int _index,
                      int _level, int _flags) {
    unsigned int _data_entry_idx, _entry_size;

    if (_stub.IsObject()) {
      for (_data_entry_idx = 0; _data_entry_idx < _data.NumChildren(); ++_data_entry_idx) {
        if (_stub.NumChildren() == 0) {
          Print("Stub is empty for object representation of: ", _data.ToString(false, 2));
          Print(
              "Note that if you're serializing a dictionary, your stub must contain a single, dummy key and maximum "
              "possible object representation.");
          Print("Missing key \"", _data.Key(), "\" in stub.");
          DebugBreak();
        }
        _entry_size = MathMax(_stub.GetChild(_data_entry_idx).TotalNumChildren(),
                              _data.GetChild(_data_entry_idx).TotalNumChildren());

        if (!SerializerCsv::FillRow(_data.GetChild(_data_entry_idx),
                                    _stub != NULL ? _stub.GetChild(_data_entry_idx) : NULL, _cells, _column_types,
                                    _column, _row, _data_entry_idx, _level + 1, _flags)) {
          return false;
        }

        _column += (int)_entry_size;
      }
    } else if (_stub.IsArray()) {
      for (_data_entry_idx = 0; _data_entry_idx < _data.NumChildren(); ++_data_entry_idx) {
        _entry_size = MathMax(_stub.GetChild(_data_entry_idx).TotalNumChildren(),
                              _data.GetChild(_data_entry_idx).TotalNumChildren());

        if (!SerializerCsv::FillRow(_data.GetChild(_data_entry_idx), _stub.GetChild(0), _cells, _column_types, _column,
                                    _row, _data_entry_idx, _level + 1, _flags)) {
          return false;
        }

        _column += (int)_entry_size;
      }
    } else {
      // A property.

      bool _include_titles = bool(_flags & SERIALIZER_CSV_INCLUDE_TITLES);
      bool _include_titles_tree = (_flags & SERIALIZER_CSV_INCLUDE_TITLES_TREE) == SERIALIZER_CSV_INCLUDE_TITLES_TREE;

      if (_column_types != NULL) {
        if (_data.GetValueParam() == NULL) {
          Alert("Error: Expected value here! Stub is probably initialized without proper structure.");
          DebugBreak();
        }
        _column_types.Set(_column, 0, _data.GetValueParam().GetType());
      }

      _cells.Set(_column, _row, ParamToString(_data.GetValueParam()));
    }

    return true;
  }
};

#endif
