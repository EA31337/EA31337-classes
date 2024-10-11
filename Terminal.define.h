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

// Codepages.
// @see: https://www.mql5.com/en/docs/constants/io_constants/codepageusage
#define CP_ACP 0         // The current Windows ANSI code page.
#define CP_OEMCP 1       // The current system OEM code page.
#define CP_MACCP 2       // The current system Macintosh code page.
#define CP_THREAD_ACP 3  // The Windows ANSI code page for the current thread.
#define CP_SYMBOL 42     // Symbol code page
#define CP_UTF7 65000    // UTF-7 code page.
#define CP_UTF8 65001    // UTF-8 code page.

// Colors.
#define AliceBlue 0xFFF8F0
#define AntiqueWhite 0xD7EBFA
#define Aqua 0xFFFF00
#define Aquamarine 0xD4FF7F
#define Beige 0xDCF5F5
#define Bisque 0xC4E4FF
#define Black 0x000000
#define BlanchedAlmond 0xCDEBFF
#define Blue 0xFF0000
#define BlueViolet 0xE22B8A
#define Brown 0x2A2AA5
#define BurlyWood 0x87B8DE
#define CadetBlue 0xA09E5F
#define Chartreuse 0x00FF7F
#define Chocolate 0x1E69D2
#define Coral 0x507FFF
#define CornflowerBlue 0xED9564
#define Cornsilk 0xDCF8FF
#define Crimson 0x3C14DC
#define DarkBlue 0x8B0000
#define DarkGoldenrod 0x0B86B8
#define DarkGray 0xA9A9A9
#define DarkGreen 0x006400
#define DarkKhaki 0x6BB7BD
#define DarkOliveGreen 0x2F6B55
#define DarkOrange 0x008CFF
#define DarkOrchid 0xCC3299
#define DarkSalmon 0x7A96E9
#define DarkSlateBlue 0x8B3D48
#define DarkSlateGray 0x4F4F2F
#define DarkTurquoise 0xD1CE00
#define DarkViolet 0xD30094
#define DeepPink 0x9314FF
#define DeepSkyBlue 0xFFBF00
#define DimGray 0x696969
#define DodgerBlue 0xFF901E
#define FireBrick 0x2222B2
#define ForestGreen 0x228B22
#define Gainsboro 0xDCDCDC
#define Gold 0x00D7FF
#define Goldenrod 0x20A5DA
#define Gray 0x808080
#define Green 0x008000
#define GreenYellow 0x2FFFAD
#define Honeydew 0xF0FFF0
#define HotPink 0xB469FF
#define IndianRed 0x5C5CCD
#define Indigo 0x82004B
#define Ivory 0xF0FFFF
#define Khaki 0x8CE6F0
#define Lavender 0xFAE6E6
#define LavenderBlush 0xF5F0FF
#define LawnGreen 0x00FC7C
#define LemonChiffon 0xCDFAFF
#define LightBlue 0xE6D8AD
#define LightCoral 0x8080F0
#define LightCyan 0xFFFFE0
#define LightGoldenrod 0xD2FAFA
#define LightGray 0xD3D3D3
#define LightGreen 0x90EE90
#define LightPink 0xC1B6FF
#define LightSalmon 0x7AA0FF
#define LightSeaGreen 0xAAB220
#define LightSkyBlue 0xFACE87
#define LightSlateGray 0x998877
#define LightSteelBlue 0xDEC4B0
#define LightYellow 0xE0FFFF
#define Lime 0x00FF00
#define LimeGreen 0x32CD32
#define Linen 0xE6F0FA
#define Magenta 0xFF00FF
#define Maroon 0x000080
#define MediumAquamarine 0xAACD66
#define MediumBlue 0xCD0000
#define MediumOrchid 0xD355BA
#define MediumPurple 0xDB7093
#define MediumSeaGreen 0x71B33C
#define MediumSlateBlue 0xEE687B
#define MediumSpringGreen 0x9AFA00
#define MediumTurquoise 0xCCD148
#define MediumVioletRed 0x8515C7
#define MidnightBlue 0x701919
#define MintCream 0xFAFFF5
#define MistyRose 0xE1E4FF
#define Moccasin 0xB5E4FF
#define NavajoWhite 0xADDEFF
#define Navy 0x800000
#define OldLace 0xE6F5FD
#define Olive 0x008080
#define OliveDrab 0x238E6B
#define Orange 0x00A5FF
#define OrangeRed 0x0045FF
#define Orchid 0xD670DA
#define PaleGoldenrod 0xAAE8EE
#define PaleGreen 0x98FB98
#define PaleTurquoise 0xEEEEAF
#define PaleVioletRed 0x9370DB
#define PapayaWhip 0xD5EFFF
#define PeachPuff 0xB9DAFF
#define Peru 0x3F85CD
#define Pink 0xCBC0FF
#define Plum 0xDDA0DD
#define PowderBlue 0xE6E0B0
#define Purple 0x800080
#define Red 0x0000FF
#define RosyBrown 0x8F8FBC
#define RoyalBlue 0xE16941
#define SaddleBrown 0x13458B
#define Salmon 0x7280FA
#define SandyBrown 0x60A4F4
#define SeaGreen 0x578B2E
#define Seashell 0xEEF5FF
#define Sienna 0x2D52A0
#define Silver 0xC0C0C0
#define SkyBlue 0xEBCE87
#define SlateBlue 0xCD5A6A
#define SlateGray 0x908070
#define Snow 0xFAFAFF
#define SpringGreen 0x7FFF00
#define SteelBlue 0xB48246
#define Tan 0x8CB4D2
#define Teal 0x808000
#define Thistle 0xD8BFD8
#define Tomato 0x4763FF
#define Turquoise 0xD0E040
#define Violet 0xEE82EE
#define Wheat 0xB3DEF5
#define White 0xFFFFFF
#define WhiteSmoke 0xF5F5F5
#define Yellow 0x00FFFF
#define YellowGreen 0x32CD9A
#ifndef __MQL__
#define clrNONE -1
#define CLR_NONE -1
#define DarkSeaGreen 0x8BBC8F
#endif

// Custom user errors.
// @docs
// - https://docs.mql4.com/common/setusererror
// - https://www.mql5.com/en/docs/common/SetUserError

#ifndef __MQL5__
#define ERR_USER_ARRAY_IS_EMPTY 1
#endif
#define ERR_USER_INVALID_ARG 2
#define ERR_USER_INVALID_BUFF_NUM 3
#define ERR_USER_INVALID_HANDLE 4
#define ERR_USER_ITEM_NOT_FOUND 5
#define ERR_USER_NOT_SUPPORTED 6
#define ERR_USER_ERROR_FIRST 65536  // User defined errors start with this code.

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

#ifndef __MQL__
// Return Codes of the Trade Server.
// @see: https://www.mql5.com/en/docs/constants/errorswarnings/enum_trade_return_codes
#define TRADE_RETCODE_REQUOTE 10004             // Requote
#define TRADE_RETCODE_REJECT 10006              // Request rejected
#define TRADE_RETCODE_CANCEL 10007              // Request canceled by trader
#define TRADE_RETCODE_PLACED 10008              // Order placed
#define TRADE_RETCODE_DONE 10009                // Request completed
#define TRADE_RETCODE_DONE_PARTIAL 10010        // Only part of the request was completed
#define TRADE_RETCODE_ERROR 10011               // Request processing error
#define TRADE_RETCODE_TIMEOUT 10012             // Request canceled by timeout
#define TRADE_RETCODE_INVALID 10013             // Invalid request
#define TRADE_RETCODE_INVALID_VOLUME 10014      // Invalid volume in the request
#define TRADE_RETCODE_INVALID_PRICE 10015       // Invalid price in the request
#define TRADE_RETCODE_INVALID_STOPS 10016       // Invalid stops in the request
#define TRADE_RETCODE_TRADE_DISABLED 10017      // Trade is disabled
#define TRADE_RETCODE_MARKET_CLOSED 10018       // Market is closed
#define TRADE_RETCODE_NO_MONEY 10019            // There is not enough money to complete the request
#define TRADE_RETCODE_PRICE_CHANGED 10020       // Prices changed
#define TRADE_RETCODE_PRICE_OFF 10021           // There are no quotes to process the request
#define TRADE_RETCODE_INVALID_EXPIRATION 10022  // Invalid order expiration date in the request
#define TRADE_RETCODE_ORDER_CHANGED 10023       // Order state changed
#define TRADE_RETCODE_TOO_MANY_REQUESTS 10024   // Too frequent requests
#define TRADE_RETCODE_NO_CHANGES 10025          // No changes in request
#define TRADE_RETCODE_SERVER_DISABLES_AT 10026  // Autotrading disabled by server
#define TRADE_RETCODE_CLIENT_DISABLES_AT 10027  // Autotrading disabled by client terminal
#define TRADE_RETCODE_LOCKED 10028              // Request locked for processing
#define TRADE_RETCODE_FROZEN 10029              // Order or position frozen
#define TRADE_RETCODE_INVALID_FILL 10030        // Invalid order filling type
#define TRADE_RETCODE_CONNECTION 10031          // No connection with the trade server
#define TRADE_RETCODE_ONLY_REAL 10032           // Operation is allowed only for live accounts
#define TRADE_RETCODE_LIMIT_ORDERS 10033        // The number of pending orders has reached the limit
#define TRADE_RETCODE_LIMIT_VOLUME 10034     // The volume of orders and positions for the symbol has reached the limit
#define TRADE_RETCODE_INVALID_ORDER 10035    // Incorrect or prohibited order type
#define TRADE_RETCODE_POSITION_CLOSED 10036  // Position with the specified POSITION_IDENTIFIER has already been closed
#define TRADE_RETCODE_INVALID_CLOSE_VOLUME 10038  // A close volume exceeds the current position volume
#define TRADE_RETCODE_CLOSE_ORDER_EXIST 10039     // A close order already exists.
#define TRADE_RETCODE_LIMIT_POSITIONS 10040  // The number of open positions can be limited (e.g. Netting, Hedging).
#endif

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
