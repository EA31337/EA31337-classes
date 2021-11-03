//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * Terminal's defines.
 */

/* Defines */

// Custom user errors.
// @docs
// - https://docs.mql4.com/common/setusererror
// - https://www.mql5.com/en/docs/common/SetUserError
#define ERR_USER_ARRAY_IS_EMPTY 1
#define ERR_USER_INVALID_ARG 2
#define ERR_USER_INVALID_BUFF_NUM 3
#define ERR_USER_INVALID_HANDLE 4
#define ERR_USER_ITEM_NOT_FOUND 5
#define ERR_USER_NOT_SUPPORTED 6

// Return codes of the trade server.
#define ERR_NO_ERROR 0
#define ERR_NO_RESULT 1
#define ERR_COMMON_ERROR 2
#define ERR_INVALID_TRADE_PARAMETERS 3
#define ERR_SERVER_BUSY 4
#define ERR_OLD_VERSION 5
#define ERR_NO_CONNECTION 6
#define ERR_NOT_ENOUGH_RIGHTS 7
#define ERR_TOO_FREQUENT_REQUESTS 8
#define ERR_MALFUNCTIONAL_TRADE 9
#define ERR_ACCOUNT_DISABLED 64
#define ERR_INVALID_ACCOUNT 65
#define ERR_TRADE_TIMEOUT 128
#define ERR_INVALID_PRICE 129
#define ERR_INVALID_STOPS 130
#define ERR_INVALID_TRADE_VOLUME 131
#define ERR_MARKET_CLOSED 132
//#define ERR_TRADE_DISABLED                   133
#define ERR_NOT_ENOUGH_MONEY 134
#define ERR_PRICE_CHANGED 135
#define ERR_OFF_QUOTES 136
#define ERR_BROKER_BUSY 137
#define ERR_REQUOTE 138
#define ERR_ORDER_LOCKED 139
#define ERR_LONG_POSITIONS_ONLY_ALLOWED 140
#define ERR_TOO_MANY_REQUESTS 141
#define ERR_TRADE_MODIFY_DENIED 145
#define ERR_TRADE_CONTEXT_BUSY 146
#define ERR_TRADE_EXPIRATION_DENIED 147
#define ERR_TRADE_TOO_MANY_ORDERS 148
#define ERR_TRADE_HEDGE_PROHIBITED 149
#define ERR_TRADE_PROHIBITED_BY_FIFO 150

// Missing error handling constants in MQL4.
// @see: https://docs.mql4.com/constants/errorswarnings/errorcodes
// @see: https://www.mql5.com/en/docs/constants/errorswarnings
#ifndef __MQL5__
// Return codes of the trade server.
// ...
#define ERR_INVALID_PARAMETER 4003  // Wrong parameter when calling the system function.
#endif

// MQL defines.
#ifdef __MQL4__
#define MQL_VER 4
#else
#define MQL_VER 5
#endif
#define MQL_EXT ".ex" + (string)MQL_VER

#ifdef __MQL4__
// The resolution of display on the screen in a number of Dots in a line per Inch (DPI).
// By knowing the value, you can set the size of graphical objects,
// so they can look the same on monitors with different resolution characteristics.
#ifndef TERMINAL_SCREEN_DPI
#define TERMINAL_SCREEN_DPI 27
#endif

// The last known value of a ping to a trade server in microseconds.
// One second comprises of one million microseconds.
#ifndef TERMINAL_PING_LAST
#define TERMINAL_PING_LAST 28
#endif
#endif
