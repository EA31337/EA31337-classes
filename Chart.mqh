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

// Properties.
#property strict

// Includes.
#include "Market.mqh"

/**
 * @file
 * Class to provide chart operations.
 *
 * @docs
 * - https://www.mql5.com/en/docs/chart_operations
 */

class Chart {
  protected:
    // Variables.
    string symbol;
    ENUM_TIMEFRAMES tf;

  public:

    /**
     * Class constructor.
     */
    void Chart(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _symbol = NULL) :
      symbol(_symbol != NULL ? _symbol : _Symbol),
      tf(_tf),
      market(new Market(symbol))
      {
      }

    /**
     * Redraws the current chart forcedly.
     *
     * @see:
     * https://docs.mql4.com/chart_operations/chartredraw
     */
    void ChartRedraw() {
      #ifdef __MQL4__ WindowRedraw(); #else ChartRedraw(0); #endif
    }

};
