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

/**
 * @file
 * Test functionality of Database class.
 */

// Includes.
#include "../Database.mqh"
#include "../Test.mqh"

// Global variables.
Database *db;

/**
 * Implements OnInit().
 */
int OnInit() {
#ifdef __MQL5__
  db = new Database(":memory:", DATABASE_OPEN_MEMORY);
  DatabaseColumnEntry columns[] = {
      {"SYMBOL", TYPE_CHAR, DATABASE_COLUMN_FLAG_NONE, 6},
      {"BID", TYPE_DOUBLE},
      {"ASK", TYPE_DOUBLE},
      {"VOLUME", TYPE_INT},
      {"COMMENT", TYPE_STRING},
  };
  assertTrueOrFail(db.CreateTable("Table1", columns), "Cannot create table! Error: " + (string)_LastError);
  DatabasePrint(db.GetHandle(), "PRAGMA TABLE_INFO(Table1);", 0);
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
