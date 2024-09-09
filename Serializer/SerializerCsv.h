//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

// Includes.
#include "../Math/Matrix.h"
#include "../Math/MatrixMini.h"
#include "../Storage/Dict/Dict.h"
#include "../Storage/Dict/DictObject.h"
#include "../Storage/Dict/DictStruct.h"
#include "../Storage/Object.h"
#include "SerializerConverter.h"
#include "SerializerNode.h"

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
                          MatrixMini2d<string>* _matrix_out = NULL,
                          MatrixMini2d<SerializerNodeParamType>* _column_types_out = NULL) {
    SerializerConverter* _stub = (SerializerConverter*)serializer_aux_arg;

    if (CheckPointer(_root) == POINTER_INVALID) {
      Alert("SerializerCsv: Invalid root node pointer!");
      DebugBreak();
      return NULL;
    }

    if (_stub == NULL || _stub PTR_DEREF Node() == NULL) {
      Alert("SerializerCsv: Cannot convert to CSV without stub object!");
      DebugBreak();
      return NULL;
    }

    bool _include_titles = bool(serializer_flags & SERIALIZER_CSV_INCLUDE_TITLES);
    bool _include_key = bool(serializer_flags & SERIALIZER_CSV_INCLUDE_KEY);

    unsigned int _num_columns, _num_rows;
    int x, y;

    if (_stub PTR_DEREF Node() PTR_DEREF IsArray()) {
      _num_columns = _stub PTR_DEREF Node() PTR_DEREF MaximumNumChildrenInDeepEnd();
      _num_rows = _root PTR_DEREF NumChildren();
    } else {
      _num_columns = MathMax(_stub PTR_DEREF Node() PTR_DEREF MaximumNumChildrenInDeepEnd(),
                             _root PTR_DEREF MaximumNumChildrenInDeepEnd());
      _num_rows = _root PTR_DEREF NumChildren() > 0 ? 1 : 0;
    }

    if (_include_titles) {
      ++_num_rows;
    }

    if (_include_key) {
      ++_num_columns;
    }

    MatrixMini2d<string> _cells;
    MatrixMini2d<string> _column_titles;
    MatrixMini2d<SerializerNodeParamType> _column_types;

    if (_matrix_out == NULL) {
      _matrix_out = &_cells;
    }

    if (_column_types_out == NULL) {
      _column_types_out = &_column_types;
    }

    _matrix_out PTR_DEREF Resize(_num_columns, _num_rows);
    _column_types_out PTR_DEREF Resize(_num_columns, 1);

    if (_include_titles) {
      _column_titles.Resize(_num_columns, 1);
      int _titles_current_column = 0;
      SerializerCsv::ExtractColumns(_stub PTR_DEREF Node(), &_column_titles, _column_types_out, serializer_flags,
                                    _titles_current_column);
      for (x = 0; x < _matrix_out PTR_DEREF SizeX(); ++x) {
        _matrix_out PTR_DEREF Set(x, 0, EscapeString(_column_titles.Get(x, 0)));
      }
    }

#ifdef __debug_verbose__
    Print("Stub: ", _stub PTR_DEREF Node() PTR_DEREF ToString());
    Print("Data: ", _root PTR_DEREF ToString());
    Print("Size: ", _num_columns, " x ", _num_rows);
#endif

    if (!SerializerCsv::FlattenNode(_root, _stub PTR_DEREF Node(), PTR_TO_REF(_matrix_out), _column_types_out,
                                    _include_key ? 1 : 0, _include_titles ? 1 : 0, serializer_flags)) {
      Alert("SerializerCsv: Error occured during flattening!");
    }

    string _result;

    for (y = 0; y < _matrix_out PTR_DEREF SizeY(); ++y) {
      for (x = 0; x < _matrix_out PTR_DEREF SizeX(); ++x) {
        _result += _matrix_out PTR_DEREF Get(x, y);

        if (x != _matrix_out PTR_DEREF SizeX() - 1) {
          _result += ",";
        }
      }

      if (y != _matrix_out PTR_DEREF SizeY() - 1) _result += "\n";
    }

    if ((serializer_flags & SERIALIZER_FLAG_REUSE_STUB) == 0) {
      _stub PTR_DEREF Clean();
    }

    return _result;
  }

  static string ParamToString(SerializerNodeParam* param) {
    switch (param PTR_DEREF GetType()) {
      case SerializerNodeParamBool:
      case SerializerNodeParamLong:
      case SerializerNodeParamDouble:
        return param PTR_DEREF AsString(false, false, false, param PTR_DEREF GetFloatingPointPrecision());
      case SerializerNodeParamString:
        return EscapeString(param PTR_DEREF AsString(false, false, false, param PTR_DEREF GetFloatingPointPrecision()));
      default:
        Print("Error: Wrong param type ", EnumToString(param PTR_DEREF GetType()), "!");
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
  static void ExtractColumns(SerializerNode* _stub, MatrixMini2d<string>* _titles,
                             MatrixMini2d<SerializerNodeParamType>* _column_types, int _flags, int& _column) {
    for (unsigned int _stub_entry_idx = 0; _stub_entry_idx < _stub PTR_DEREF NumChildren(); ++_stub_entry_idx) {
      SerializerNode* _child = _stub PTR_DEREF GetChild(_stub_entry_idx);
      if (_child PTR_DEREF IsContainer()) {
        ExtractColumns(_child, _titles, _column_types, _flags, _column);
      } else if (_child PTR_DEREF HasKey()) {
        _titles PTR_DEREF Set(_column++, 0, _child PTR_DEREF Key());
      }
    }
  }

  /**
   *
   */
  static bool FlattenNode(SerializerNode* _data, SerializerNode* _stub, MatrixMini2d<string>& _cells,
                          MatrixMini2d<SerializerNodeParamType>* _column_types, int _column, int _row, int _flags) {
    unsigned int _data_entry_idx;

    bool _include_key = bool(_flags & SERIALIZER_CSV_INCLUDE_KEY);

    if (_stub PTR_DEREF IsArray()) {
      for (_data_entry_idx = 0; _data_entry_idx < _data PTR_DEREF NumChildren(); ++_data_entry_idx) {
        if (_include_key) {
          // Adding object's key in the first row.
          SerializerNode* _child = _data PTR_DEREF GetChild(_data_entry_idx);
          string key = _child PTR_DEREF HasKey() ? _child PTR_DEREF Key() : "";
          _cells.Set(0, _row + _data_entry_idx, key);
        }

        if (!SerializerCsv::FillRow(_data PTR_DEREF GetChild(_data_entry_idx), _stub PTR_DEREF GetChild(0), _cells,
                                    _column_types, _column, _row + _data_entry_idx, 0, 0, _flags)) {
          return false;
        }
      }
    } else if (_stub PTR_DEREF IsObject()) {
      // Object means that there is only one row.
      if (_data PTR_DEREF IsArray()) {
        // Stub is an object, but data is an array (should be?).
        for (_data_entry_idx = 0; _data_entry_idx < _data PTR_DEREF NumChildren(); ++_data_entry_idx) {
          if (!SerializerCsv::FillRow(_data PTR_DEREF GetChild(_data_entry_idx), _stub, _cells, _column_types, _column,
                                      _row, 0, 0, _flags)) {
            return false;
          }

          _column += (int)_stub PTR_DEREF GetChild(_data_entry_idx) PTR_DEREF MaximumNumChildrenInDeepEnd();
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
  static bool FillRow(SerializerNode* _data, SerializerNode* _stub, MatrixMini2d<string>& _cells,
                      MatrixMini2d<SerializerNodeParamType>* _column_types, int _column, int _row, int _index,
                      int _level, int _flags) {
    unsigned int _data_entry_idx, _entry_size;

    if (_stub PTR_DEREF IsObject()) {
      for (_data_entry_idx = 0; _data_entry_idx < _data PTR_DEREF NumChildren(); ++_data_entry_idx) {
        if (_stub PTR_DEREF NumChildren() == 0) {
          Print("Stub is empty for object representation of: ", _data PTR_DEREF ToString(false, 2));
          Print(
              "Note that if you're serializing a dictionary, your stub must contain a single, dummy key and maximum "
              "possible object representation.");
          Print("Missing key \"", _data PTR_DEREF Key(), "\" in stub.");
          DebugBreak();
        }
        _entry_size = MathMax(_stub PTR_DEREF GetChild(_data_entry_idx) PTR_DEREF TotalNumChildren(),
                              _data PTR_DEREF GetChild(_data_entry_idx) PTR_DEREF TotalNumChildren());

        if (!SerializerCsv::FillRow(_data PTR_DEREF GetChild(_data_entry_idx),
                                    _stub != NULL ? _stub PTR_DEREF GetChild(_data_entry_idx) : NULL, _cells,
                                    _column_types, _column, _row, _data_entry_idx, _level + 1, _flags)) {
          return false;
        }

        _column += (int)_entry_size;
      }
    } else if (_stub PTR_DEREF IsArray()) {
      for (_data_entry_idx = 0; _data_entry_idx < _data PTR_DEREF NumChildren(); ++_data_entry_idx) {
        _entry_size = MathMax(_stub PTR_DEREF GetChild(_data_entry_idx) PTR_DEREF TotalNumChildren(),
                              _data PTR_DEREF GetChild(_data_entry_idx) PTR_DEREF TotalNumChildren());

        if (!SerializerCsv::FillRow(_data PTR_DEREF GetChild(_data_entry_idx), _stub PTR_DEREF GetChild(0), _cells,
                                    _column_types, _column, _row, _data_entry_idx, _level + 1, _flags)) {
          return false;
        }

        _column += (int)_entry_size;
      }
    } else {
      // A property.

      // bool _include_titles = bool(_flags & SERIALIZER_CSV_INCLUDE_TITLES);
      // bool _include_titles_tree = (_flags & SERIALIZER_CSV_INCLUDE_TITLES_TREE) ==
      // SERIALIZER_CSV_INCLUDE_TITLES_TREE;

      if (_column_types != NULL) {
        if (_data PTR_DEREF GetValueParam() == NULL) {
          Alert("Error: Expected value here! Stub is probably initialized without proper structure.");
          DebugBreak();
        }
        _column_types PTR_DEREF Set(_column, 0, _data PTR_DEREF GetValueParam() PTR_DEREF GetType());
      }

      _cells.Set(_column, _row, ParamToString(_data PTR_DEREF GetValueParam()));
    }

    return true;
  }
};
