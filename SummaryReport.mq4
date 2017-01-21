//+------------------------------------------------------------------+
//| Prints summary report after testing.
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
   This file is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Includes
#include "SummaryReport.mqh"

// Properties.
#property strict

// Variables.
SummaryReport *report;

/**
 * Implements OnInit().
 */
int OnInit() {
  report = new SummaryReport();
  return (INIT_SUCCEEDED);
}

/**
 * Deletes created objects to free allocated memory.
 */
void CleanUp() {
  delete report;
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  Print(report.GetReport());
  CleanUp();
}

