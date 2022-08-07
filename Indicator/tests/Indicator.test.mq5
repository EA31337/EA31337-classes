//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
 * Test functionality of Indicator class.
 */

// Includes.
#include "../Indicator.h"
#include "../../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  /* @fixme
  // Initialize.
  IndicatorParams iparams(INDI_NONE, TYPE_INT, 10);
  Indicator *in = new Indicator(iparams, NULL);
  // Check empty values.
  assertTrueOrFail(in.GetBufferSize() == 10, "Wrong buffer size!");
  assertTrueOrFail(in.GetEmpty().double_value == 0.0, "Wrong empty double value!");
  assertTrueOrFail(in.GetEmpty().integer_value == 0, "Wrong empty integer value!");
  // Check dynamic allocation.
  MqlParam entry;
  entry.integer_value = 1;
  for (unsigned int i = 0; i < in.GetBufferSize() * 2; i++) {
    in.AddValue(entry);
    Print("Index ", i, ": Curr: ", in.GetValue(0, 0).integer_value, "; Prev: ", in.GetValue(0, 1).integer_value);
    assertTrueOrFail(in.GetValue(0, 0).integer_value == entry.integer_value,
      StringFormat("Wrong latest value (%d <> %d)!",
        in.GetValue(0, 0).integer_value,
        entry.integer_value));
    assertTrueOrFail(in.GetValue(0, 1).integer_value == entry.integer_value - 1,
      StringFormat("Wrong previous value (%d <> %d)!",
        in.GetValue(0, 1).integer_value,
        entry.integer_value - 1));
    entry.integer_value++;
  }
  Print(in.ToString());
  // Clean up.
  delete in;
  */
  return (INIT_SUCCEEDED);
}
