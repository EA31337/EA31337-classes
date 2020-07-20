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

// Enums.
enum DATABASE_COLUMN_FLAGS {
  DATABASE_COLUMN_FLAG_NONE = 0,
  DATABASE_COLUMN_FLAG_IS_KEY = 1,
  DATABASE_COLUMN_FLAG_IS_NULL = 2,
};

// Structs.
struct DatabaseColumnEntry {
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
      case TYPE_STRING:
        return "TEXT";
    }
    return "UNKNOWN";
  }
  string GetFlags() { return GetKey() + GetNull(); }
  string GetName() { return name; }
  string GetNull() { return !IsNull() ? "NOT NULL" : ""; }
  string GetKey() { return IsKey() ? "KEY" : ""; }
  // State methods.
  bool IsKey() { return bool(flags & DATABASE_COLUMN_FLAG_IS_KEY); }
  bool IsNull() { return bool(flags & DATABASE_COLUMN_FLAG_IS_NULL); }
};

class Database {
 private:
  int handle;

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

  /* Query methods */

  /**
   * Creates table.
   */
  bool CreateTable(string _name, DatabaseColumnEntry &_columns[]) {
    bool _result = false;
#ifdef __MQL5__
    if (DatabaseTableExists(handle, _name)) {
      // Generic error (ERR_DATABASE_ERROR).
      SetUserError(5601);
      return _result;
    }
    string query = "", subquery = "";
    for (int i = 0; i < ArraySize(_columns); i++) {
      subquery += StringFormat("%s %s %s%s", _columns[i].GetName(), _columns[i].GetDatatype(), _columns[i].GetFlags(),
                               (i < ArraySize(_columns) - 1 ? ", " : ""));
    }
    query = StringFormat("CREATE TABLE %s(%s);", _name, subquery);
    if (_result = DatabaseExecute(handle, query)) {
      ResetLastError();
    }
#endif
    return _result;
  }

  /* Getters */

  /**
   * Class constructor.
   */
  int GetHandle() { return handle; }
};
#endif  // DATABASE_MQH
