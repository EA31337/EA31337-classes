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

  /* Getters */

  /**
   * Class constructor.
   */
  int GetHandle() {
    return handle;
  }

};
#endif // DATABASE_MQH
