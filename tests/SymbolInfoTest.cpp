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
 * Test functionality of SymbolInfo class.
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
#include "../SymbolInfo.mqh"

int main(int argc, char **argv) {
  SymbolInfo *si = new SymbolInfo();

  // Test saving ticks.
  si.SaveTick(dtick);
  si.SaveTick(ltick);
  si.ResetTicks();
  // Print.
  Print("MARKET: ", si.ToString());
  Print("CSV (Header): ", si.ToCSV(true));
  Print("CSV (Data): ", si.ToCSV());
  delete si;
}
