//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

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

#ifndef __MQL__

// Colors.
#define clrAliceBlue 0x00F0F8FF
#define clrAntiqueWhite 0x00FAEBD7
#define clrAqua 0x0000FFFF
#define clrAquamarine 0x007FFFD4
#define clrBeige 0x00F5F5DC
#define clrBisque 0x00FFE4C4
#define clrBlack 0x00000000
#define clrBlanchedAlmond 0x00FFEBCD
#define clrBlue 0x000000FF
#define clrBlueViolet 0x008A2BE2
#define clrBrown 0x00A52A2A
#define clrBurlyWood 0x00DEB887
#define clrCadetBlue 0x005F9EA0
#define clrChartreuse 0x007FFF00
#define clrChocolate 0x00D2691E
#define clrCoral 0x00FF7F50
#define clrCornflowerBlue 0x006495ED
#define clrCornsilk 0x00FFF8DC
#define clrCrimson 0x00DC143C
#define clrDarkBlue 0x0000008B
#define clrDarkGoldenrod 0x00B8860B
#define clrDarkGray 0x00A9A9A9
#define clrDarkGreen 0x00006400
#define clrDarkKhaki 0x00BDB76B
#define clrDarkOliveGreen 0x00556B2F
#define clrDarkOrange 0x00FF8C00
#define clrDarkOrchid 0x009932CC
#define clrDarkSalmon 0x00E9967A
#define clrDarkSeaGreen 0x008FBC8F
#define clrDarkSlateBlue 0x00483D8B
#define clrDarkSlateGray 0x002F4F4F
#define clrDarkTurquoise 0x0000CED1
#define clrDarkViolet 0x009400D3
#define clrDeepPink 0x00FF1493
#define clrDeepSkyBlue 0x0000BFFF
#define clrDimGray 0x00696969
#define clrDodgerBlue 0x001E90FF
#define clrFireBrick 0x00B22222
#define clrForestGreen 0x00228B22
#define clrGainsboro 0x00DCDCDC
#define clrGold 0x00FFD700
#define clrGoldenrod 0x00DAA520
#define clrGray 0x00808080
#define clrGreen 0x00008000
#define clrGreenYellow 0x00ADFF2F
#define clrHoneydew 0x00F0FFF0
#define clrHotPink 0x00FF69B4
#define clrIndianRed 0x00CD5C5C
#define clrIndigo 0x004B0082
#define clrIvory 0x00FFFFF0
#define clrKhaki 0x00F0E68C
#define clrLavender 0x00E6E6FA
#define clrLavenderBlush 0x00FFF0F5
#define clrLawnGreen 0x007CFC00
#define clrLemonChiffon 0x00FFFACD
#define clrLightBlue 0x00ADD8E6
#define clrLightCoral 0x00F08080
#define clrLightCyan 0x00E0FFFF
#define clrLightGoldenrod 0x00EEDC82
#define clrLightGoldenrodYellow 0x00FAFAD2
#define clrLightGreen 0x0090EE90
#define clrLightGrey 0x00D3D3D3
#define clrLightPink 0x00FFB6C1
#define clrLightSalmon 0x00FFA07A
#define clrLightSeaGreen 0x0020B2AA
#define clrLightSkyBlue 0x0087CEFA
#define clrLightSlateGray 0x00778899
#define clrLightSteelBlue 0x00B0C4DE
#define clrLightYellow 0x00FFFFE0
#define clrLime 0x0000FF00
#define clrLimeGreen 0x0032CD32
#define clrLinen 0x00FAF0E6
#define clrMagenta 0x00FF00FF
#define clrMaroon 0x00800000
#define clrMediumAquamarine 0x0066CDAA
#define clrMediumBlue 0x000000CD
#define clrMediumOrchid 0x00BA55D3
#define clrMediumPurple 0x009370DB
#define clrMediumSeaGreen 0x003CB371
#define clrMediumSlateBlue 0x007B68EE
#define clrMediumSpringGreen 0x0000FA9A
#define clrMediumTurquoise 0x0048D1CC
#define clrMediumVioletRed 0x00C71585
#define clrMidnightBlue 0x00191970
#define clrMintCream 0x00F5FFFA
#define clrMistyRose 0x00FFE4E1
#define clrMoccasin 0x00FFE4B5
#define clrNavajoWhite 0x00FFDEAD
#define clrNavy 0x00000080
#define clrOldLace 0x00FDF5E6
#define clrOlive 0x00808000
#define clrOliveDrab 0x006B8E23
#define clrOrange 0x00FFA500
#define clrOrangeRed 0x00FF4500
#define clrOrchid 0x00DA70D6
#define clrPaleGoldenrod 0x00EEE8AA
#define clrPaleGreen 0x0098FB98
#define clrPaleTurquoise 0x00AFEEEE
#define clrPaleVioletRed 0x00DB7093
#define clrPapayaWhip 0x00FFEFD5
#define clrPeachPuff 0x00FFDAB9
#define clrPeru 0x00CD853F
#define clrPink 0x00FFC0CB
#define clrPlum 0x00DDA0DD
#define clrPowderBlue 0x00B0E0E6
#define clrPurple 0x00800080
#define clrRed 0x00FF0000
#define clrRosyBrown 0x00BC8F8F
#define clrRoyalBlue 0x004169E1
#define clrSaddleBrown 0x008B4513
#define clrSalmon 0x00FA8072
#define clrSandyBrown 0x00F4A460
#define clrSeaGreen 0x002E8B57
#define clrSeashell 0x00FFF5EE
#define clrSienna 0x00A0522D
#define clrSilver 0x00C0C0C0
#define clrSkyBlue 0x0087CEEB
#define clrSlateBlue 0x006A5ACD
#define clrSlateGray 0x00708090
#define clrSnow 0x00FFFAFA
#define clrSpringGreen 0x0000FF7F
#define clrSteelBlue 0x004682B4
#define clrTan 0x00D2B48C
#define clrTeal 0x00008080
#define clrThistle 0x00D8BFD8
#define clrTomato 0x00FF6347
#define clrTurquoise 0x0040E0D0
#define clrViolet 0x00EE82EE
#define clrWheat 0x00F5DEB3
#define clrWhite 0x00FFFFFF
#define clrWhiteSmoke 0x00F5F5F5
#define clrYellow 0x00FFFF00
#define clrYellowGreen 0x009ACD32

#define AliceBlue clrAliceBlue
#define AntiqueWhite clrAntiqueWhite
#define Aqua clrAqua
#define Aquamarine clrAquamarine
#define Beige clrBeige
#define Bisque clrBisque
#define Black clrBlack
#define BlanchedAlmond clrBlanchedAlmond
#define Blue clrBlue
#define BlueViolet clrBlueViolet
#define Brown clrBrown
#define BurlyWood clrBurlyWood
#define CadetBlue clrCadetBlue
#define Chartreuse clrChartreuse
#define Chocolate clrChocolate
#define Coral clrCoral
#define CornflowerBlue clrCornflowerBlue
#define Cornsilk clrCornsilk
#define Crimson clrCrimson
#define DarkBlue clrDarkBlue
#define DarkGoldenrod clrDarkGoldenrod
#define DarkGray clrDarkGray
#define DarkGreen clrDarkGreen
#define DarkKhaki clrDarkKhaki
#define DarkOliveGreen clrDarkOliveGreen
#define DarkOrange clrDarkOrange
#define DarkOrchid clrDarkOrchid
#define DarkSalmon clrDarkSalmon
#define DarkSeaGreen clrDarkSeaGreen
#define DarkSlateBlue clrDarkSlateBlue
#define DarkSlateGray clrDarkSlateGray
#define DarkTurquoise clrDarkTurquoise
#define DarkViolet clrDarkViolet
#define DeepPink clrDeepPink
#define DeepSkyBlue clrDeepSkyBlue
#define DimGray clrDimGray
#define DodgerBlue clrDodgerBlue
#define FireBrick clrFireBrick
#define ForestGreen clrForestGreen
#define Gainsboro clrGainsboro
#define Gold clrGold
#define Goldenrod clrGoldenrod
#define Gray clrGray
#define Green clrGreen
#define GreenYellow clrGreenYellow
#define Honeydew clrHoneydew
#define HotPink clrHotPink
#define IndianRed clrIndianRed
#define Indigo clrIndigo
#define Ivory clrIvory
#define Khaki clrKhaki
#define Lavender clrLavender
#define LavenderBlush clrLavenderBlush
#define LawnGreen clrLawnGreen
#define LemonChiffon clrLemonChiffon
#define LightBlue clrLightBlue
#define LightCoral clrLightCoral
#define LightCyan clrLightCyan
#define LightGoldenrod clrLightGoldenrod
#define LightGray clrLightGray
#define LightGreen clrLightGreen
#define LightPink clrLightPink
#define LightSalmon clrLightSalmon
#define LightSeaGreen clrLightSeaGreen
#define LightSkyBlue clrLightSkyBlue
#define LightSlateGray clrLightSlateGray
#define LightSteelBlue clrLightSteelBlue
#define LightYellow clrLightYellow
#define Lime clrLime
#define LimeGreen clrLimeGreen
#define Linen clrLinen
#define Magenta clrMagenta
#define Maroon clrMaroon
#define MediumAquamarine clrMediumAquamarine
#define MediumBlue clrMediumBlue
#define MediumOrchid clrMediumOrchid
#define MediumPurple clrMediumPurple
#define MediumSeaGreen clrMediumSeaGreen
#define MediumSlateBlue clrMediumSlateBlue
#define MediumSpringGreen clrMediumSpringGreen
#define MediumTurquoise clrMediumTurquoise
#define MediumVioletRed clrMediumVioletRed
#define MidnightBlue clrMidnightBlue
#define MintCream clrMintCream
#define MistyRose clrMistyRose
#define Moccasin clrMoccasin
#define NavajoWhite clrNavajoWhite
#define Navy clrNavy
#define OldLace clrOldLace
#define Olive clrOlive
#define OliveDrab clrOliveDrab
#define Orange clrOrange
#define OrangeRed clrOrangeRed
#define Orchid clrOrchid
#define PaleGoldenrod clrPaleGoldenrod
#define PaleGreen clrPaleGreen
#define PaleTurquoise clrPaleTurquoise
#define PaleVioletRed clrPaleVioletRed
#define PapayaWhip clrPapayaWhip
#define PeachPuff clrPeachPuff
#define Peru clrPeru
#define Pink clrPink
#define Plum clrPlum
#define PowderBlue clrPowderBlue
#define Purple clrPurple
#define Red clrRed
#define RosyBrown clrRosyBrown
#define RoyalBlue clrRoyalBlue
#define SaddleBrown clrSaddleBrown
#define Salmon clrSalmon
#define SandyBrown clrSandyBrown
#define SeaGreen clrSeaGreen
#define Seashell clrSeashell
#define Sienna clrSienna
#define Silver clrSilver
#define SkyBlue clrSkyBlue
#define SlateBlue clrSlateBlue
#define SlateGray clrSlateGray
#define Snow clrSnow
#define SpringGreen clrSpringGreen
#define SteelBlue clrSteelBlue
#define Tan clrTan
#define Teal clrTeal
#define Thistle clrThistle
#define Tomato clrTomato
#define Turquoise clrTurquoise
#define Violet clrViolet
#define Wheat clrWheat
#define White clrWhite
#define WhiteSmoke clrWhiteSmoke
#define Yellow clrYellow
#define YellowGreen clrYellowGreen

#endif

#ifndef __MQL__
#define clrNONE -1
#define CLR_NONE -1
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
