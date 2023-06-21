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

// Enums.

enum ENUM_DATABASE_COLUMN_FLAGS {
  DATABASE_COLUMN_FLAG_NONE = 0,
  DATABASE_COLUMN_FLAG_IS_KEY = 1,
  DATABASE_COLUMN_FLAG_IS_NULL = 2,
};

// @docs: https://www.mql5.com/en/docs/database/databaseopen#enum_database_open_flags
enum ENUM_DATABASE_OPEN_FLAGS {
  DATABASE_OPEN_READONLY = 0,  // Read only.
  DATABASE_OPEN_READWRITE,     // Open for reading and writing.
  DATABASE_OPEN_CREATE,        // Create the file on a disk if necessary.
  DATABASE_OPEN_MEMORY,        // Create a database in RAM.
  DATABASE_OPEN_COMMON,        // The file is in the common folder of all terminals.
};
