//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * MqlTick structure.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

#ifndef __MQL__
/**
 * Structure for storing the latest prices of the symbol.
 * @docs
 * https://www.mql5.com/en/docs/constants/structures/mqltick
 */
struct MqlTick {
  datetime time;         // Time of the last prices update.
  double ask;            // Current Ask price.
  double bid;            // Current Bid price.
  double last;           // Price of the last deal (last).
  double volume_real;    // Volume for the current last price with greater accuracy.
  long time_msc;         // Time of a price last update in milliseconds.
  unsigned int flags;    // Tick flags.
  unsigned long volume;  // Volume for the current last price.
};
#endif
