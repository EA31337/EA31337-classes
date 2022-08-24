//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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

// Includes.
#include "Order.enum.h"
#include "SymbolInfo.enum.h"
#include "Tick/Tick.struct.h"

// Define external global functions.
#ifndef __MQL__
extern long SymbolInfoInteger(string name, ENUM_SYMBOL_INFO_INTEGER prop_id);
extern bool SymbolInfoMarginRate(string name, ENUM_ORDER_TYPE order_type, double &initial_margin_rate,
                                 double &maintenance_margin_rate);
extern bool SymbolInfoTick(string symbol, MqlTick &tick);

// Define external global variables.
extern string _Symbol;
#endif
