//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                     Copyright 2016-2021, EA31337 |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Includes Order's defines.
 */

#ifndef __MQL4__
// Mode constants.
#define MODE_TRADES 0
#define MODE_HISTORY 1
// Order operations.
#define OP_BUY ORDER_TYPE_BUY               // Buy
#define OP_SELL ORDER_TYPE_SELL             // Sell
#define OP_BUYLIMIT ORDER_TYPE_BUY_LIMIT    // Pending order of BUY LIMIT type
#define OP_SELLLIMIT ORDER_TYPE_SELL_LIMIT  // Pending order of SELL LIMIT type
#define OP_BUYSTOP ORDER_TYPE_BUY_STOP      // Pending order of BUY STOP type
#define OP_SELLSTOP ORDER_TYPE_SELL_STOP    // Pending order of SELL STOP type
#define OP_BALANCE 6
// --
#endif
