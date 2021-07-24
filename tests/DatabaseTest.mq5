//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

/**
 * @file
 * Test functionality of Database class.
 */

// Need to be include before Database.mqh.
#include "../SymbolInfo.mqh"  // FOOBAR pragma: keep

// Includes.
#include "../BufferStruct.mqh"
#include "../Database.mqh"
#include "../Test.mqh"

// Global variables.
Database *db;

/**
 * Implements OnInit().
 */
int OnInit() {
#ifdef __MQL5__

  // Create new database.
  db = new Database(":memory:", DATABASE_OPEN_MEMORY);

  // Create Table1 table.
  DatabaseTableColumnEntry columns[] = {
      {"SYMBOL", TYPE_CHAR, DATABASE_COLUMN_FLAG_NONE, 6},
      {"BID", TYPE_DOUBLE},
      {"ASK", TYPE_DOUBLE},
      {"VOLUME", TYPE_INT, DATABASE_COLUMN_FLAG_IS_NULL},
      {"COMMENT", TYPE_STRING, DATABASE_COLUMN_FLAG_IS_NULL},
  };
  DatabaseTableSchema schema = columns;
  assertTrueOrFail(db.CreateTable("Table1", schema), "Cannot create table! Error: " + (string)_LastError);
  DatabasePrint(db.GetHandle(), "PRAGMA TABLE_INFO(Table1);", 0);

  // Create SymbolInfo table.
  DbSymbolInfoEntry _price_entry;
  db.CreateTable("SymbolInfo", _price_entry.schema);
  DatabasePrint(db.GetHandle(), "PRAGMA TABLE_INFO(SymbolInfo);", 0);

  // Prepare input data.
  BufferStruct<DbSymbolInfoEntry> _data;
  MqlTick _tick1 = {0, 0.10, 0.11, 0.12, 13, 1};
  DbSymbolInfoEntry _entry1(_tick1);
  _data.Push(_entry1);
  MqlTick _tick2 = {1, 0.11, 0.12, 0.13, 14, 1};
  DbSymbolInfoEntry _entry2(_tick2);
  _data.Push(_entry2);
  MqlTick _tick3 = {2, 0.12, 0.13, 0.14, 15, 1};
  DbSymbolInfoEntry _entry3(_tick3);
  _data.Push(_entry3);
  MqlTick _tick4 = {3, 0.13, 0.14, 0.15, 16, 1};
  DbSymbolInfoEntry _entry4(_tick4);
  _data.Push(_entry4);

  // Add data to table.
  db.Import("SymbolInfo", _data);

  // Print table.
  DatabasePrint(db.GetHandle(), "SELECT * FROM SymbolInfo", 0);
#endif

  return _LastError > 0 ? INIT_FAILED : INIT_SUCCEEDED;
}

/**
 * Implements OnTick().
 */
void OnTick() {}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) { delete db; }
