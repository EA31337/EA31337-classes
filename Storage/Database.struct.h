//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

/*
 * Defines structures related to Database class.
 *
 */

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

  DatabaseTableColumnEntry() {}
  DatabaseTableColumnEntry(const string _name, const ENUM_DATATYPE _type, unsigned short _flags = 0,
                           unsigned short _char_size = 0) {
    name = _name;
    type = _type;
    flags = _flags;
    char_size = _char_size;
  }
  DatabaseTableColumnEntry(const DatabaseTableColumnEntry &r) {
    name = r.name;
    type = r.type;
    flags = r.flags;
    char_size = r.char_size;
  }
};

struct DatabaseTableSchema {
  DictStruct<short, DatabaseTableColumnEntry> columns;
  // Constructor.
  DatabaseTableSchema() {}
  DatabaseTableSchema(ARRAY_REF(DatabaseTableColumnEntry, _columns)) {
    for (int i = 0; i < ArraySize(_columns); i++) {
      columns.Push(_columns[i]);
    }
  }
  DatabaseTableSchema(const DatabaseTableSchema &r) { columns = r.columns; }
  // Methods.
  bool AddColumn(DatabaseTableColumnEntry &column) { return columns.Push(column); }
};

// Struct table entry for SymbolInfo.
#ifdef SYMBOLINFO_H
struct DbSymbolInfoEntry : public SymbolInfoEntry {
  DatabaseTableSchema schema;
  // Constructors.
  DbSymbolInfoEntry() { DefineSchema(); }
  DbSymbolInfoEntry(const DbSymbolInfoEntry &r) { schema = r.schema; }
  DbSymbolInfoEntry(const MqlTick &_tick, const string _symbol = NULL) : SymbolInfoEntry(_tick, _symbol) {
    DefineSchema();
  }
  // Methods.
  void DefineSchema() {
    schema.columns.Push(DatabaseTableColumnEntry("bid", TYPE_DOUBLE));
    schema.columns.Push(DatabaseTableColumnEntry("ask", TYPE_DOUBLE));
    schema.columns.Push(DatabaseTableColumnEntry("last", TYPE_DOUBLE));
    schema.columns.Push(DatabaseTableColumnEntry("spread", TYPE_DOUBLE));
    schema.columns.Push(DatabaseTableColumnEntry("volume", TYPE_INT));
  }
};
#endif
