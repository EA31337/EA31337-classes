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
 * Test functionality of Account class.
 */

// Includes standard libraries.
#include <string>

// Defines aliases for data types.
typedef std::string string;
typedef unsigned char uchar;
typedef unsigned int uint;
typedef unsigned long ulong;
typedef unsigned short ushort;


// Includes.
#include "../Account.mqh"

int main(int argc, char **argv) {

  // Initialize class.
  Account *acc = new Account();

  // Defines variables.
  double _balance = AccountInfoDouble(ACCOUNT_BALANCE);
  double _credit = AccountInfoDouble(ACCOUNT_CREDIT);
  double _equity = AccountInfoDouble(ACCOUNT_EQUITY);

  // Dummy calls.
  acc.GetAccountName();
  acc.GetCompanyName();
  acc.GetLogin();
  acc.GetServerName();

  // Print account details.
  Print(acc.ToString());
  Print(acc.ToCSV());

  // Clean up.
  delete acc;
}
