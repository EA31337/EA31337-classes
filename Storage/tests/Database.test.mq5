//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

// Need to be include before Database.h.
#include "../../SymbolInfo.mqh"  // FOOBAR pragma: keep

// Includes.
#include "../../Test.mqh"
#include "../Database.h"
#include "../Dict/Buffer/BufferStruct.h"

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
  ARRAY(DatabaseTableColumnEntry, columns);
  ArrayPushObject(columns, DatabaseTableColumnEntry("SYMBOL", TYPE_CHAR, DATABASE_COLUMN_FLAG_NONE, 6));
  ArrayPushObject(columns, DatabaseTableColumnEntry("BID", TYPE_DOUBLE));
  ArrayPushObject(columns, DatabaseTableColumnEntry("ASK", TYPE_DOUBLE));
  ArrayPushObject(columns, DatabaseTableColumnEntry("VOLUME", TYPE_INT, DATABASE_COLUMN_FLAG_IS_NULL));
  ArrayPushObject(columns, DatabaseTableColumnEntry("COMMENT", TYPE_STRING, DATABASE_COLUMN_FLAG_IS_NULL));

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
