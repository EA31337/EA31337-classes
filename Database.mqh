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
#include "MiniMatrix.h"

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
  bool AddColumn(DatabaseTableColumnEntry &column) { return columns.Push(column); }
};
// Struct table entry for SymbolInfo.
#ifdef SYMBOLINFO_MQH
struct DbSymbolInfoEntry : public SymbolInfoEntry {
  DatabaseTableSchema schema;
  // Constructors.
  DbSymbolInfoEntry() { DefineSchema(); }
  DbSymbolInfoEntry(const MqlTick &_tick, const string _symbol = NULL) : SymbolInfoEntry(_tick, _symbol) {
    DefineSchema();
  }
  // Methods.
  void DefineSchema() {
    DatabaseTableColumnEntry _columns[] = {
        {"bid", TYPE_DOUBLE},    {"ask", TYPE_DOUBLE}, {"last", TYPE_DOUBLE},
        {"spread", TYPE_DOUBLE}, {"volume", TYPE_INT},
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
#ifndef __MQL4__
  Database(string _filename, unsigned int _flags = DATABASE_OPEN_CREATE){
#else
  Database(string _filename, unsigned int _flags = 0) {
#endif
#ifndef __MQL4__
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
#ifndef __MQL4__
  DatabaseClose(handle);
#endif
}

/* Table methods */

/**
 * Checks if table exists.
 */
bool TableExists(string _name) {
#ifndef __MQL4__
  return DatabaseTableExists(handle, _name);
#else
    SetUserError(ERR_USER_NOT_SUPPORTED);
    return false;
#endif
}

/**
 * Creates table if not yet exist.
 */
bool CreateTableIfNotExist(string _name, DatabaseTableSchema &_schema) {
  if (TableExists(_name)) {
    return true;
  }
  return CreateTable(_name, _schema);
}

/**
 * Creates table.
 */
bool CreateTable(string _name, DatabaseTableSchema &_schema) {
  bool _result = false;
#ifndef __MQL4__
  if (DatabaseTableExists(handle, _name)) {
    // Generic error (ERR_DATABASE_ERROR).
    SetUserError(5601);
    return _result;
  }

  string query = "", subquery = "";

  if (_schema.columns.Size() == 0) {
    // SQLite does'nt allow tables without columns;
    subquery = "`dummy` INTEGER";
  } else {
    for (DictStructIterator<short, DatabaseTableColumnEntry> iter = _schema.columns.Begin(); iter.IsValid(); ++iter) {
      subquery +=
          StringFormat("`%s` %s %s,", iter.Value().GetName(), iter.Value().GetDatatype(), iter.Value().GetFlags());
    }
    subquery = StringSubstr(subquery, 0, StringLen(subquery) - 1);  // Removes extra comma.
  }

  query = StringFormat("CREATE TABLE `%s`(%s);", _name, subquery);

#ifdef __debug__
  Print("Database: Executing query:\n", query);
#endif

  if (_result = DatabaseExecute(handle, query)) {
    ResetLastError();
    SetTableSchema(_name, _schema);
  } else {
#ifdef __debug__
    Print("Database: Query failed with error ", _LastError);
    DebugBreak();
#endif
  }
#endif
  return _result;
}

/**
 * Drops table.
 */
bool DropTable(string _name) {
  tables.Unset(_name);
#ifndef __MQL4__
  return DatabaseExecute(handle, "DROP TABLE IF EXISTS `" + _name + "`");
#else
    return false;
#endif
}

/* Import methods */

/**
 * Imports data into table. First row must contain column names. Strings must be enclosed with double quotes.
 */
bool ImportData(const string _name, MiniMatrix2d<string> &data) {
  if (data.SizeY() < 2 || data.SizeX() == 0) {
    // No data to import or there are no columns in input data (Serialize() serialized no fields).
    return true;
  }
  int x;
  bool _result = true;
  DatabaseTableSchema _schema = GetTableSchema(_name);
  string _query = "", _cols = "", _vals = "";
  for (x = 0; x < data.SizeX(); ++x) {
    const string key = data.Get(x, 0);
    _cols += "`" + StringSubstr(key, 1, StringLen(key) - 2) + "`,";
  }
  _cols = StringSubstr(_cols, 0, StringLen(_cols) - 1);  // Removes extra comma.
#ifndef __MQL4__
  if (DatabaseTransactionBegin(handle)) {
    _query = StringFormat("INSERT INTO `%s`(%s) VALUES\n", _name, _cols);
    for (int y = 1; y < data.SizeY(); ++y) {
      _query += "(";
      for (x = 0; x < data.SizeX(); ++x) {
        _query += data.Get(x, y) + (x < data.SizeX() - 1 ? ", " : "");
      }
      _query += ")" + (y < data.SizeY() - 1 ? ",\n" : "");
    }

#ifdef __debug__
    Print("Database: Executing query:\n", _query);
#endif

    _result &= DatabaseExecute(handle, _query);
  }
  if (_result) {
    DatabaseTransactionCommit(handle);
  } else {
    Print("Database: Query failed with error ", _LastError);
    DebugBreak();
    DatabaseTransactionRollback(handle);
  }
#else
    return false;
#endif
  return _result;
}

#ifdef BUFFER_STRUCT_MQH
/**
 * Imports BufferStruct records into a table.
 */
template <typename TStruct>
bool Import(const string _name, BufferStruct<TStruct> &_bstruct) {
  bool _result = true;
  DatabaseTableSchema _schema = GetTableSchema(_name);
  string _query = "", _cols = "", _vals = "";
  for (DictStructIterator<short, DatabaseTableColumnEntry> iter = _schema.columns.Begin(); iter.IsValid(); ++iter) {
    _cols += iter.Value().name + ",";
  }
  _cols = StringSubstr(_cols, 0, StringLen(_cols) - 1);  // Removes extra comma.
#ifndef __MQL4__
  if (DatabaseTransactionBegin(handle)) {
    for (DictStructIterator<long, TStruct> iter = _bstruct.Begin(); iter.IsValid(); ++iter) {
      _query = StringFormat("INSERT INTO %s(%s) VALUES (%s)", _name, _cols, iter.Value().ToCSV());
      _result &= DatabaseExecute(handle, _query);
    }
  }
  if (_result) {
    DatabaseTransactionCommit(handle);
  } else {
    DatabaseTransactionRollback(handle);
  }
#else
  return false;
#endif
  return _result;
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

/**
 * Checks if table schema exists.
 */
bool SchemaExists(string _name) { return tables.KeyExists(_name); }

/* Setters */

/**
 * Sets table schema.
 */
bool SetTableSchema(string _name, DatabaseTableSchema &_schema) { return tables.Set(_name, _schema); }
}
;
#endif  // DATABASE_MQH
