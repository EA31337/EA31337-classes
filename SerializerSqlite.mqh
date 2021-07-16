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
#ifndef SERIALIZER_SQL_MQH
#define SERIALIZER_SQL_MQH

// Includes.
#include "Database.mqh"
#include "SerializerConverter.mqh"
#include "SerializerCsv.mqh"

class SerializerSqlite {
 public:
  static ENUM_DATATYPE CsvParamTypeToSqlType(SerializerNodeParamType _param_type) {
    switch (_param_type) {
      case SerializerNodeParamBool:
        return TYPE_BOOL;
      case SerializerNodeParamLong:
        return TYPE_LONG;
      case SerializerNodeParamDouble:
        return TYPE_DOUBLE;
      case SerializerNodeParamString:
        return TYPE_STRING;
    }
    Print("Error: CsvParamTypeToSqlType: wrong _param_type parameter! Got ", _param_type, ".");
    DebugBreak();
    return (ENUM_DATATYPE)-1;
  }

  static bool ConvertToFile(SerializerConverter& source, string _path, string _table, unsigned int _stringify_flags = 0,
                            void* _stub = NULL) {
    // We must have titles tree as
    MiniMatrix2d<string> _matrix_out;
    MiniMatrix2d<SerializerNodeParamType> _column_types;
    string _csv = SerializerCsv::Stringify(source.root_node, _stringify_flags | SERIALIZER_CSV_INCLUDE_TITLES, _stub,
                                           &_matrix_out, &_column_types);

#ifdef __debug__
    Print("SerializerSqlite: Parsing CSV input:\n", _csv);
#endif

    Database _db(_path);
    int i;

    if (!_db.SchemaExists(_table)) {
      DatabaseTableSchema _schema;
      for (i = 0; i < _matrix_out.SizeX(); ++i) {
        string _column_name_quoted = _matrix_out.Get(i, 0);
        string _column_name_unquoted = StringSubstr(_column_name_quoted, 1, StringLen(_column_name_quoted) - 2);
        DatabaseTableColumnEntry _column;
        _column.name = _column_name_unquoted;
        _column.type = CsvParamTypeToSqlType(_column_types.Get(i, 0));
        _column.flags = 0;
        _column.char_size = 0;
        _schema.AddColumn(_column);
      }

      _db.SetTableSchema(_table, _schema);
    }

    if (!_db.TableExists(_table)) {
      if (!_db.CreateTable(_table, _db.GetTableSchema(_table))) {
        return false;
      }
    }

    if (!_db.ImportData(_table, _matrix_out)) {
      return false;
    }

    return true;
  }
};

#endif
