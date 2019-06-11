//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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
 * Test functionality for Indicator class.
 */

// Properties.
#property strict

// Includes.
#include "../Indicator.mqh"
#include "../Test.mqh"

// Structs.
/*
struct Data {
  double value;
};
struct Data2 {
  double value[2];
};
struct Data3 {
  double value[3];
};
*/

/**
 * Implements OnInit().
 */
int OnInit() {
  // Initialize.
  Indicator *in = new Indicator();
  MqlParam entry;
  entry.double_value = 0.22;
  in.AddValue(entry);
  Print(in.GetValue(0).double_value);
  assertTrueOrFail(in.GetValue(0).double_value == entry.double_value, "Wrong latest value!");
  entry.double_value *= 2;
  in.AddValue(entry);
  Print(in.GetValue(0).double_value);
  assertTrueOrFail(in.GetValue(0).double_value == entry.double_value, "Wrong latest value!");
  Print(in.GetValue(1).double_value);
  // @fixme
  assertTrueOrFail(in.GetValue(1).double_value == entry.double_value * 2, "Wrong latest value!");
  // Clean up.
  delete in;
  return (INIT_SUCCEEDED);
}
