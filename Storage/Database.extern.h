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

// Includes.

// Define external global functions.
#ifndef __MQL__
// Closes a database.
// @docs: https://www.mql5.com/en/docs/database/databaseclose
void DatabaseClose(int database  // database handle received in DatabaseOpen
);
// Executes a request to a specified database.
// @docs: https://www.mql5.com/en/docs/database/databaseexecute
extern bool DatabaseExecute(int database,  // database handle received in DatabaseOpen
                            string sql     // SQL request
);

// Opens or creates a database in a specified file.
// @docs: https://www.mql5.com/en/docs/database/databaseopen
int DatabaseOpen(string filename,  // file name
                 uint flags        // combination of flags
);

// Starts transaction execution.
// @docs: https://www.mql5.com/en/docs/database/databasetransactionbegin
bool DatabaseTransactionBegin(int database  // database handle received in DatabaseOpen
);

// Completes transaction execution.
// @docs: https://www.mql5.com/en/docs/database/databasetransactioncommit
extern bool DatabaseTransactionCommit(int database  // database handle received in DatabaseOpen
);

// Checks the presence of the table in a database.
// @docs: https://www.mql5.com/en/docs/database/databasetableexists
bool DatabaseTableExists(int database,  // database handle received in DatabaseOpen
                         string table   // table name
);

// Rolls back transactions.
// @docs: https://www.mql5.com/en/docs/database/databasetransactionrollback
extern bool DatabaseTransactionRollback(int database  // database handle received in DatabaseOpen
);
#endif
