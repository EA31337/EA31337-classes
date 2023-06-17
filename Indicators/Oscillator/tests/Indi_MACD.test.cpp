//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test C++ compilation of Indi_MACD class.
 */

// Include enumerations.
#include "../../../Chart.enum.h"

// Define external functions.

// Calculates the Moving Averages Convergence/Divergence indicator and returns its value.
// @docs
// - https://docs.mql4.com/indicators/imacd
// - https://www.mql5.com/en/docs/indicators/imacd
/*
extern double iMACD(
   string       symbol,           // Symbol.
   int          timeframe,        // Timeframe>
   int          fast_ema_period,  // Fast EMA period.
   int          slow_ema_period,  // Slow EMA period.
   int          signal_period,    // Signal line period.
   int          applied_price,    // Applied price.
   int          mode,             // Line index.
   int          shift             // Shift.
   );
extern int iMACD(
   string              symbol,              // Symbol name.
   ENUM_TIMEFRAMES     period,              // Period.
   int                 fast_ema_period,     // Period for Fast average calculation.
   int                 slow_ema_period,     // Period for Slow average calculation.
   int                 signal_period,       // Period for their difference averaging.
   ENUM_APPLIED_PRICE  applied_price        // Type of price or handle.
   );
*/

// Includes.
#include "../../../Platform.h"
#include "../Indi_MACD.h"

int main(int argc, char **argv) {
  // @todo

  return 0;
}
