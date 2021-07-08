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

class SerializerSql {
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
    Print("Error: CsvParamTypeToSqlType: wrong _param_type parameter!");
    DebugBreak();
    return (ENUM_DATATYPE)-1;
  }

  static string Convert(SerializerConverter& source, unsigned int _stringify_flags = 0, void* _stub = NULL) {
    // We must have titles tree as
    MiniMatrix2d<string> _matrix_out;
    MiniMatrix2d<SerializerNodeParamType> _column_types;
    string _csv = SerializerCsv::Stringify(source.root_node, _stringify_flags | SERIALIZER_CSV_INCLUDE_TITLES, _stub,
                                           &_matrix_out, &_column_types);

    Database _db("test.sqlite");
    DatabaseTableSchema _schema;
    int i;

    for (i = 0; i < _matrix_out.SizeX(); ++i) {
      DatabaseTableColumnEntry _column;
      _column.name = _matrix_out.Get(i, 0);
      _column.type = CsvParamTypeToSqlType(_column_types.Get(i, 0));
      _column.flags = 0;
      _column.char_size = 0;
      _schema.AddColumn(_column);
    }

    _db.CreateTableIfNotExist("bla", _schema);

    Print("Conversion from: \n", _csv);
    return "INSERT INTO ...";
  }

  /**
   * Converts object into CSV and then SQL. Thus way we don't duplicate CSV serializer's code.
   */
  static bool ConvertToFile(SerializerConverter& source, string _path, unsigned int _stringify_flags = 0,
                            void* _stub = NULL) {
    string _data = Convert(source, _stringify_flags, _stub);
    return File::SaveFile(_path, _data);
  }
};

#endif
