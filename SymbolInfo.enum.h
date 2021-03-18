//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
 * Includes SymbolInfo's enums.
 */

// Enum constants.
const ENUM_SYMBOL_INFO_DOUBLE market_dcache[] = {SYMBOL_MARGIN_INITIAL,
                                                 SYMBOL_MARGIN_LIMIT,
                                                 SYMBOL_MARGIN_LONG,
                                                 SYMBOL_MARGIN_MAINTENANCE,
                                                 SYMBOL_MARGIN_SHORT,
                                                 SYMBOL_MARGIN_STOP,
                                                 SYMBOL_MARGIN_STOPLIMIT,
                                                 SYMBOL_POINT,
                                                 SYMBOL_SWAP_LONG,
                                                 SYMBOL_SWAP_SHORT,
                                                 SYMBOL_TRADE_CONTRACT_SIZE,
                                                 SYMBOL_TRADE_TICK_SIZE,
                                                 SYMBOL_TRADE_TICK_VALUE,
                                                 SYMBOL_TRADE_TICK_VALUE_LOSS,
                                                 SYMBOL_TRADE_TICK_VALUE_PROFIT,
                                                 SYMBOL_VOLUME_LIMIT,
                                                 SYMBOL_VOLUME_MAX,
                                                 SYMBOL_VOLUME_MIN,
                                                 SYMBOL_VOLUME_STEP};
const ENUM_SYMBOL_INFO_INTEGER market_icache[] = {
    SYMBOL_DIGITS,          SYMBOL_EXPIRATION_MODE, SYMBOL_FILLING_MODE,
    SYMBOL_ORDER_MODE,      SYMBOL_SWAP_MODE,       SYMBOL_SWAP_ROLLOVER3DAYS,
    SYMBOL_TRADE_CALC_MODE, SYMBOL_TRADE_EXEMODE,   SYMBOL_TRADE_MODE};

#ifndef __MQL4__
// Methods of swap calculation at position transfer.
// @see: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_swap_mode
enum ENUM_SYMBOL_SWAP_MODE {
  SYMBOL_SWAP_MODE_DISABLED = -1,         // Swaps disabled (no swaps).
  SYMBOL_SWAP_MODE_POINTS = 0,            // Swaps are charged in points.
  SYMBOL_SWAP_MODE_CURRENCY_SYMBOL = 1,   // Swaps are charged in money in base currency of the symbol.
  SYMBOL_SWAP_MODE_INTEREST_CURRENT = 2,  // Swaps are charged as the specified annual interest.
  SYMBOL_SWAP_MODE_CURRENCY_MARGIN = 3,   // Swaps are charged in money in margin currency of the symbol.
  SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT,      // Swaps are charged in money, in client deposit currency.
  SYMBOL_SWAP_MODE_INTEREST_OPEN,         // Swaps are charged as the specified annual interest from the open price.
  SYMBOL_SWAP_MODE_REOPEN_CURRENT,        // Swaps are charged by reopening positions.
  SYMBOL_SWAP_MODE_REOPEN_BID             // Swaps are charged by reopening positions.
};
#endif
