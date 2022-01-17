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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Data types.
#ifdef __cplusplus
#include <iomanip>
#include <locale>
#include <sstream>
#include <vector>

// Data types.
typedef std::string string;
typedef unsigned int uint;
typedef unsigned long datetime;
typedef unsigned long ulong;
typedef unsigned short ushort;
#endif

#ifdef __MQL__
#define ASSIGN_TO_THIS(TYPE, VALUE) ((TYPE)this) = ((TYPE)VALUE)
#else
#define ASSIGN_TO_THIS(TYPE, VALUE) ((TYPE&)this) = ((TYPE&)VALUE)
#endif

// Pointers.
#ifdef __MQL__
#define THIS_PTR (&this)
#define THIS_REF this
#define PTR_ATTRIB(O, A) O.A
#define PTR_TO_REF(PTR) PTR
#define MAKE_REF_FROM_PTR(TYPE, NAME, PTR) TYPE* NAME = PTR
#else
#define THIS_PTR (this)
#define THIS_REF (*this)
#define PTR_ATTRIB(O, A) O->A
#define PTR_TO_REF(PTR) (*PTR)
#define MAKE_REF_FROM_PTR(TYPE, NAME, PTR) TYPE& NAME = PTR
#endif

// References.
#ifdef __cplusplus
#define REF(X) (&X)
#else
#define REF(X) X&
#endif

// Arrays and references to arrays.
#ifdef __MQL__
#define ARRAY_DECLARATION_BRACKETS []
#else
// C++'s _cpp_array is an object, so no brackets are nedded.
#define ARRAY_DECLARATION_BRACKETS
#endif

#ifdef __MQL__
/**
 * Reference to the array.
 *
 * @usage
 *   ARRAY_REF(<type of the array items>, <name of the variable>)
 */
#define ARRAY_REF(T, N) REF(T) N ARRAY_DECLARATION_BRACKETS

/**
 * Array definition.
 *
 * @usage
 *   ARRAY(<type of the array items>, <name of the variable>)
 */
#define ARRAY(T, N) T N[];

#else

/**

 * Reference to the array.
 *
 * @usage
 *   ARRAY_REF(<type of the array items>, <name of the variable>)
 */
#define ARRAY_REF(T, N) _cpp_array<T>& N

/**
 * Array definition.
 *
 * @usage
 *   ARRAY(<type of the array items>, <name of the variable>)
 */
#define ARRAY(T, N) ::_cpp_array<T> N
#endif

// typename(T)
#ifndef __MQL__
#define typename(T) typeid(T).name()
#endif

// C++ array class.
#ifndef __MQL__
/**
 * Custom array template to be used as a replacement of dynamic array in MQL.
 */
template <typename T>
class _cpp_array {
  // List of items.
  std::vector<T> m_data;

  // IsSeries flag.
  bool m_isSeries = false;

 public:
  _cpp_array() {}

  template <int size>
  _cpp_array(const T REF(_arr)[size]) {
    for (const auto& _item : _arr) m_data.push_back(_item);
  }

  /**
   * Returns pointer of first element (provides a way to iterate over array elements).
   */
  // operator T*() { return &m_data.first(); }

  /**
   * Index operator. Takes care of IsSeries flag.
   */
  T& operator[](int index) { return m_data[m_isSeries ? (size() - index - 1) : index]; }

  /**
   * Index operator. Takes care of IsSeries flag.
   */
  const T& operator[](int index) const { return m_data[m_isSeries ? (size() - index - 1) : index]; }

  /**
   * Returns number of elements in the array.
   */
  int size() const { return m_data.size(); }

  /**
   * Checks whether
   */
  int getIsSeries() const { return m_isSeries; }

  /**
   * Sets IsSeries flag for an array.
   * Array indexing is from 0 without IsSeries flag or from last-element
   * with IsSeries flag.
   */
  void setIsSeries(bool _isSeries) { m_isSeries = _isSeries; }
};

template <typename T>
class _cpp_array;
#endif

// Mql's color class.
#ifndef __MQL__
class color {
  unsigned int value;

 public:
  color(unsigned int _color) { value = _color; }
  color& operator=(unsigned int _color) {
    value = _color;
    return *this;
  }
  operator unsigned int() const { return value; }
};
#endif

// GetPointer(ptr).
#ifndef __MQL__
unsigned int GetPointer(void* _ptr) { return (unsigned int)_ptr; }
#endif

// MQL defines.
#ifndef __MQL__
#define WHOLE_ARRAY -1  // For processing the entire array.
#endif

// Converts string into C++-style string pointer.
#ifdef __MQL__
#define C_STR(S) S
#else
#define C_STR(S) cstring_from(S)

const char* cstring_from(const std::string& _value) { return _value.c_str(); }
#endif

/**
 * Referencing struct's enum.
 *
 * @usage
 *   STRUCT_ENUM(<struct_name>, <enum_name>)
 */
#ifdef __MQL4__
#define STRUCT_ENUM(S, E) E
#else
#define STRUCT_ENUM(S, E) S::E
#endif

#ifndef __MQL__
/**
 * @file
 * Includes MQL-compatible enumerations.
 */
enum ENUM_TRADE_REQUEST_ACTIONS {
  // @see: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions
  TRADE_ACTION_DEAL,     // Place a trade order for an immediate execution with the specified parameters (market order).
  TRADE_ACTION_PENDING,  // Place a trade order for the execution under specified conditions (pending order).
  TRADE_ACTION_SLTP,     // Modify Stop Loss and Take Profit values of an opened position.
  TRADE_ACTION_MODIFY,   // Modify the parameters of the order placed previously.
  TRADE_ACTION_REMOVE,   // Delete the pending order placed previously.
  TRADE_ACTION_CLOSE_BY  // Close a position by an opposite one.
};
// Fill Policy.
enum ENUM_SYMBOL_FILLING {
  // @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
  SYMBOL_FILLING_FOK = 1,  // A deal can be executed only with the specified volume.
  SYMBOL_FILLING_IOC = 2   // Trader agrees to execute a deal with the volume maximally available in the market.
};
enum ENUM_ORDER_TYPE_FILLING {
  // @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
  ORDER_FILLING_FOK,    // An order can be filled only in the specified amount.
  ORDER_FILLING_IOC,    // A trader agrees to execute a deal with the volume maximally available in the market.
  ORDER_FILLING_RETURN  // In case of partial filling a market or limit order with remaining volume is not canceled but
                        // processed further.
};
enum ENUM_ORDER_TYPE_TIME {
  // @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
  ORDER_TIME_GTC,           // Good till cancel order.
  ORDER_TIME_DAY,           // Good till current trade day order.
  ORDER_TIME_SPECIFIED,     // Good till expired order.
  ORDER_TIME_SPECIFIED_DAY  // The order will be effective till 23:59:59 of the specified day.
};
// An order status that describes its state.
enum ENUM_ORDER_STATE {
  ORDER_STATE_STARTED,         // Order checked, but not yet accepted by broker
  ORDER_STATE_PLACED,          // Order accepted
  ORDER_STATE_CANCELED,        // Order canceled by client
  ORDER_STATE_PARTIAL,         // Order partially executed
  ORDER_STATE_FILLED,          // Order fully executed
  ORDER_STATE_REJECTED,        // Order rejected
  ORDER_STATE_EXPIRED,         // Order expired
  ORDER_STATE_REQUEST_ADD,     // Order is being registered (placing to the trading system)
  ORDER_STATE_REQUEST_MODIFY,  // Order is being modified (changing its parameters)
  ORDER_STATE_REQUEST_CANCEL   // Order is being deleted (deleting from the trading system)
};

// @see: https://www.mql5.com/en/docs/constants/structures/mqltraderequest
struct MqlTradeRequest {
  ENUM_TRADE_REQUEST_ACTIONS action;     // Trade operation type.
  ulong magic;                           // Expert Advisor ID (magic number).
  ulong order;                           // Order ticket.
  string symbol;                         // Trade symbol.
  double volume;                         // Requested volume for a deal in lots.
  double price;                          // Price.
  double stoplimit;                      // StopLimit level of the order.
  double sl;                             // Stop Loss level of the order.
  double tp;                             // Take Profit level of the order.
  ulong deviation;                       // Maximal possible deviation from the requested price.
  ENUM_ORDER_TYPE type;                  // Order type.
  ENUM_ORDER_TYPE_FILLING type_filling;  // Order execution type.
  ENUM_ORDER_TYPE_TIME type_time;        // Order expiration type.
  datetime expiration;                   // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type.
  string comment;                        // Order comment.
  ulong position;                        // Position ticket.
  ulong position_by;                     // The ticket of an opposite position.
};
// @see: https://www.mql5.com/en/docs/constants/structures/mqltraderesult
struct MqlTradeResult {
  uint retcode;     // Operation return code.
  ulong deal;       // Deal ticket, if it is performed.
  ulong order;      // Order ticket, if it is placed.
  double volume;    // Deal volume, confirmed by broker.
  double price;     // Deal price, confirmed by broker.
  double bid;       // Current Bid price.
  double ask;       // Current Ask price.
  string comment;   // Broker comment to operation (by default it is filled by description of trade server return code).
  uint request_id;  // Request ID set by the terminal during the dispatch.
  uint retcode_external;  // Return code of an external trading system.
};

#define ERR_USER_ERROR_FIRST 65536  // User defined errors start with this code.

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
#define DarkSeaGreen 0x8BBC8F
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
#define clrNONE -1
#define CLR_NONE -1

// Additional enum values for ENUM_SYMBOL_INFO_DOUBLE
#define SYMBOL_MARGIN_LIMIT ((ENUM_SYMBOL_INFO_DOUBLE)46)
#define SYMBOL_MARGIN_MAINTENANCE ((ENUM_SYMBOL_INFO_DOUBLE)43)
#define SYMBOL_MARGIN_LONG ((ENUM_SYMBOL_INFO_DOUBLE)44)
#define SYMBOL_MARGIN_SHORT ((ENUM_SYMBOL_INFO_DOUBLE)45)
#define SYMBOL_MARGIN_STOP ((ENUM_SYMBOL_INFO_DOUBLE)47)
#define SYMBOL_MARGIN_STOPLIMIT ((ENUM_SYMBOL_INFO_DOUBLE)48)

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

#ifndef __MQL__
// Converter of NULL_VALUE into expected type. e.g., "int x = NULL_VALUE" will end up with "x = 0".
struct _NULL_VALUE {
  template <typename T>
  explicit operator T() const {
    return (T)0;
  }
} NULL_VALUE;

template <>
inline _NULL_VALUE::operator const std::string() const {
  return "";
}
#else
#define NULL_VALUE NULL
#endif
