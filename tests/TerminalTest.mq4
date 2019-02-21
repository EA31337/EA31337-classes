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

// Properties.
#property strict

// Includes.
#include "../Terminal.mqh"
#include "../Test.mqh"

// Variables.
Terminal *terminal;

/**
 * Implements OnInit().
 */
int OnInit() {
  terminal = new Terminal();
  Print("TERMINAL (OnInit):\n\t\t\t", terminal.ToString("\n\t\t\t"));
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  Print("TERMINAL (OnDeinit):\n\t\t\t", terminal.ToString("\n\t\t\t"));
  Object::Delete(terminal);
}
