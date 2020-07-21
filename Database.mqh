//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Implements Database class.
 *
 * The methods for working with databases uses SQLite engine.
 *
 * @docs https://www.mql5.com/en/docs/database
 */

// Prevents processing this includes file for the second time.
#ifndef DATABASE_MQH
#define DATABASE_MQH

// Includes.
#include "DictStruct.mqh"

// Enums.
enum DATABASE_COLUMN_FLAGS {
  DATABASE_COLUMN_FLAG_NONE = 0,
  DATABASE_COLUMN_FLAG_IS_KEY = 1,
  DATABASE_COLUMN_FLAG_IS_NULL = 2,
};

// Structs.
struct DatabaseTableColumnEntry {
  string name;
  ENUM_DATATYPE type;
  unsigned short flags;
  unsigned short char_size;
  // Getter methods;
  string GetDatatype() {
    switch (type) {
      case TYPE_BOOL:
        return "BOOL";
      case TYPE_CHAR:
        return StringFormat("CHAR(%d)", char_size);
      case TYPE_DOUBLE:
        return "REAL";
      case TYPE_INT:
        return "INT";
      case TYPE_LONG:
        return "LONG";
      case TYPE_STRING:
        return "TEXT";
    }
    return "UNKNOWN";
  }
  string GetFlags() { return GetKey() + " " + GetNull(); }
  string GetName() { return name; }
  string GetNull() { return !IsNull() ? "NOT NULL" : ""; }
  string GetKey() { return IsKey() ? "KEY" : ""; }
  // State methods.
  bool IsKey() { return bool(flags & DATABASE_COLUMN_FLAG_IS_KEY); }
  bool IsNull() { return bool(flags & DATABASE_COLUMN_FLAG_IS_NULL); }
};
struct DatabaseTableSchema {
  DictStruct<short, DatabaseTableColumnEntry> columns;
  // Constructor.
  DatabaseTableSchema() {}
  DatabaseTableSchema(DatabaseTableColumnEntry &_columns[]) {
    for (int i = 0; i < ArraySize(_columns); i++) {
      columns.Push(_columns[i]);
    }
  }
  // Methods.
  bool AddColumn(DatabaseTableColumnEntry &column) {
    return columns.Push(column);
  }
};
// Struct table entry for SymbolInfo.
#ifdef SYMBOLINFO_MQH
struct DbSymbolInfoEntry : public SymbolInfoEntry {
  DatabaseTableSchema schema;
  // Constructor.
  DbSymbolInfoEntry()
  {
    DatabaseTableColumnEntry _columns[] = {
      {"bid", TYPE_DOUBLE},
      {"ask", TYPE_DOUBLE},
      {"last", TYPE_DOUBLE},
      {"spread", TYPE_DOUBLE},
      {"volume", TYPE_INT},
      };
    for (int i = 0; i < ArraySize(_columns); i++) {
      schema.columns.Push(_columns[i]);
    }
  }
};
#endif

class Database {
 private:
  int handle;
  DictStruct<string, DatabaseTableSchema> tables;

 public:
  /**
   * Class constructor.
   */
  Database(string _filename, unsigned int _flags) {
#ifdef __MQL5__
    handle = DatabaseOpen(_filename, _flags);
#else
    handle = -1;
    SetUserError(ERR_USER_NOT_SUPPORTED);
#endif
  }

  /**
   * Class deconstructor.
   */
  ~Database() {
#ifdef __MQL5__
    DatabaseClose(handle);
#endif
  }

  /* Table methods */

  /**
   * Creates table.
   */
  bool CreateTable(string _name, DatabaseTableSchema &_schema) {
    bool _result = false;
#ifdef __MQL5__
    if (DatabaseTableExists(handle, _name)) {
      // Generic error (ERR_DATABASE_ERROR).
      SetUserError(5601);
      return _result;
    }
    string query = "", subquery = "";
    for (DictStructIterator<short, DatabaseTableColumnEntry> iter = _schema.columns.Begin();
      iter.IsValid(); ++iter) {
      subquery += StringFormat("%s %s %s,", iter.Value().GetName(), iter.Value().GetDatatype(),
                               iter.Value().GetFlags());
    }
    subquery = StringSubstr(subquery, 0, StringLen(subquery) - 1); // Removes extra comma.
    query = StringFormat("CREATE TABLE %s(%s);", _name, subquery);
    if (_result = DatabaseExecute(handle, query)) {
      ResetLastError();
      SetTableSchema(_name, _schema);
    }
#endif
    return _result;
  }

  /**
   * Drops table.
   */
  bool DropTable(string _name) {
    tables.Unset(_name);
    return DatabaseExecute(handle, "DROP TABLE IF EXISTS " + _name);
  }

  /* Import methods */

#ifdef BUFFER_STRUCT_MQH
  /**
   * Imports BufferStruct records into a table.
   */
  template <typename TStruct>
  bool Import(const string _name, const BufferStruct<TStruct> &_bstruct) {
    DatabaseTableSchema _schema = GetTableSchema(_name);
    // @todo
  }
#endif

  /* Getters */

  /**
   * Gets database handle.
   */
  int GetHandle() { return handle; }

  /**
   * Gets table schema.
   */
  DatabaseTableSchema GetTableSchema(string _name) { return tables.GetByKey(_name); }

  /* Setters */

  /**
   * Sets table schema.
   */
  bool SetTableSchema(string _name, DatabaseTableSchema &_schema) { return tables.Set(_name, _schema); }
};
#endif  // DATABASE_MQH
