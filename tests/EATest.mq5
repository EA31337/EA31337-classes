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
 * Test functionality of EA class.
 */

// Includes.
#include "../EA.mqh"
#include "../Test.mqh"

// Defines EA classes.
class EA1 : public EA {
 public:
  EA1(EAParams &_params) : EA(_params) {}
};

class EA2 : public EA {
 public:
  EA2(EAParams &_params) : EA(_params) {}
};

// Global variables.
EA *ea;
EA1 *ea1;
EA2 *ea2;

/**
 * Implements OnInit().
 */
int OnInit() {
  /* Initialize base class EA */
  EAParams ea_params(__FILE__);
  ea = new EA(ea_params);
  assertTrueOrFail(ea.GetParams().GetName() == __FILE__, "Invalid EA name!");

  /* Initialize 1st custom EA */
  EAParams ea_params1("EA1");
  ea1 = new EA1(ea_params);
  assertTrueOrFail(ea1.GetParams().GetName() == "EA1", "Invalid EA1 name!");

  /* Initialize 2st custom EA */
  EAParams ea_params2("EA2");
  ea2 = new EA2(ea_params);
  assertTrueOrFail(ea2.GetParams().GetName() == "EA2", "Invalid EA2 name!");

  return (INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  delete ea1;
  delete ea2;
}
