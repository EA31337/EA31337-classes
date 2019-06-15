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

/**
 * Implements OnInit().
 */
int OnInit() {
  // Initialize.
  Indicator *in = new Indicator();
  // Check empty values.
  assertTrueOrFail(in.GetEmpty().double_value == 0.0, "Wrong empty double value!");
  assertTrueOrFail(in.GetEmpty().integer_value == 0, "Wrong empty integer value!");
  // Check dynamic allocation.
  MqlParam entry;
  entry.integer_value = 1;
  for (uint i = 0; i < 20; i++) {
    in.AddValue(entry);
    Print("Index ", i, ": Curr: ", in.GetValue(0).integer_value, "; Prev: ", in.GetValue(1).integer_value);
    assertTrueOrFail(in.GetValue(0).integer_value == entry.integer_value,
      StringFormat("Wrong latest value (%d <> %d)!",
        in.GetValue(0).integer_value,
        entry.integer_value));
    assertTrueOrFail(in.GetValue(1).integer_value == entry.integer_value - 1,
      StringFormat("Wrong previous value (%d <> %d)!",
        in.GetValue(1).integer_value,
        entry.integer_value - 1));
    entry.integer_value++;
  }
  string _output = "Data: ";
  for (uint i = 0; i < in.GetBufferSize(); i++) {
    _output += StringFormat("%d; ", in.GetValue(i).integer_value);
  }
  Print(_output);
  // Clean up.
  delete in;
  return (INIT_SUCCEEDED);
}