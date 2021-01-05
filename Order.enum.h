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
 * Includes Order's enums.
 */

// Order actions.
enum ENUM_ORDER_ACTION {
  ORDER_ACTION_CLOSE = 1,  // Close the order.
  ORDER_ACTION_OPEN,       // Open the order.
  FINAL_ORDER_ACTION_ENTRY
};

// Order conditions.
enum ENUM_ORDER_CONDITION {
  ORDER_COND_NONE = 0,         // Empty condition.
  ORDER_COND_IN_LOSS,          // When order in loss
  ORDER_COND_IN_PROFIT,        // When order in profit
  ORDER_COND_IS_CLOSED,        // When order is closed
  ORDER_COND_IS_OPEN,          // When order is open
  ORDER_COND_LIFETIME_GT_ARG,  // Order lifetime greater than argument value.
  ORDER_COND_LIFETIME_LT_ARG,  // Order lifetime lesser than argument value.
  ORDER_COND_PROP_EQ_ARG,      // Order property equals argument value.
  ORDER_COND_PROP_GT_ARG,      // Order property greater than argument value.
  ORDER_COND_PROP_LT_ARG,      // Order property lesser than argument value.
  FINAL_ORDER_CONDITION_ENTRY
};

// Defines modes for order type values (Take Profit and Stop Loss).
enum ENUM_ORDER_TYPE_VALUE { ORDER_TYPE_TP = ORDER_TP, ORDER_TYPE_SL = ORDER_SL };

#ifndef __MQL5__
// Enums.
// Direction of an open position (buy or sell).
// @docs
// - https://www.mql5.com/en/docs/constants/tradingconstants/positionproperties
enum ENUM_POSITION_TYPE {
  POSITION_TYPE_BUY,  // Buy position.
  POSITION_TYPE_SELL  // Sell position.
};
// Defines the reason for order placing.
enum ENUM_ORDER_REASON {
  ORDER_REASON_CLIENT,  // The order was placed from a desktop terminal.
  ORDER_REASON_EXPERT,  // The order was placed from an MQL5-program (e.g. by an EA or a script).
  ORDER_REASON_MOBILE,  // The order was placed from a mobile application.
  ORDER_REASON_SL,      // The order was placed as a result of Stop Loss activation.
  ORDER_REASON_SO,      // The order was placed as a result of the Stop Out event.
  ORDER_REASON_TP,      // The order was placed as a result of Take Profit activation.
  ORDER_REASON_WEB,     // The order was placed from a web platform.
};
#else
// Enums has sense only in MQL5.
enum ENUM_ORDER_SELECT_TYPE {
  ORDER_SELECT_TYPE_NONE,
  ORDER_SELECT_TYPE_ACTIVE,
  ORDER_SELECT_TYPE_HISTORY,
  ORDER_SELECT_TYPE_DEAL,
  ORDER_SELECT_TYPE_POSITION
};

enum ENUM_ORDER_SELECT_DATA_TYPE {
  ORDER_SELECT_DATA_TYPE_INTEGER,
  ORDER_SELECT_DATA_TYPE_DOUBLE,
  ORDER_SELECT_DATA_TYPE_STRING
};
#endif
#ifndef __MQL__
// For functions OrderGet(), OrderGetDouble() and HistoryOrderGetDouble().
// @docs https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
enum ENUM_ORDER_PROPERTY_DOUBLE {
  ORDER_VOLUME_INITIAL,  // Order initial volume.
  ORDER_VOLUME_CURRENT,  // Order current volume.
  ORDER_PRICE_OPEN,      // Price specified in the order.
  ORDER_SL,              // Stop Loss value.
  ORDER_TP,              // Take Profit value.
  ORDER_PRICE_CURRENT,   // The current price of the order symbol.
  ORDER_PRICE_STOPLIMIT  // The Limit order price for the StopLimit order.
};
// A variety of properties for reading order values.
// For functions OrderGet(), OrderGetInteger() and HistoryOrderGetInteger().
// @docs https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
enum ENUM_ORDER_PROPERTY_INTEGER {
  ORDER_TICKET,           // Order ticket. Unique number assigned to each order.
  ORDER_TIME_SETUP,       // Order setup time.
  ORDER_TYPE,             // Order type.
  ORDER_STATE,            // Order state.
  ORDER_TIME_EXPIRATION,  // Order expiration time.
  ORDER_TIME_DONE,        // Order execution or cancellation time.
  ORDER_TIME_SETUP_MSC,   // The time of placing an order for execution in milliseconds since 01.01.1970.
  ORDER_TIME_DONE_MSC,    // Order execution/cancellation time in milliseconds since 01.01.1970.
  ORDER_TYPE_FILLING,     // Order filling type.
  ORDER_TYPE_TIME,        // Order lifetime.
  ORDER_MAGIC,            // ID of an Expert Advisor that has placed the order.
  ORDER_REASON,           // The reason or source for placing an order.
  ORDER_POSITION_ID,      // Position identifier that is set to an order as soon as it is executed.
  ORDER_POSITION_BY_ID    // Identifier of an opposite position used for closing by order ORDER_TYPE_CLOSE_BY.
};
#endif

#ifndef __MQLBUILD__
// Order operation type.
// @docs
// - https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
enum ENUM_ORDER_TYPE {
  ORDER_TYPE_BUY,              // Market Buy order.
  ORDER_TYPE_SELL,             // Market Sell order.
  ORDER_TYPE_BUY_LIMIT,        // Buy Limit pending order.
  ORDER_TYPE_SELL_LIMIT,       // Sell Limit pending order.
  ORDER_TYPE_BUY_STOP,         // Buy Stop pending order
  ORDER_TYPE_SELL_STOP,        // Sell Stop pending order.
  ORDER_TYPE_BUY_STOP_LIMIT,   // Upon reaching the order price, a pending Buy Limit order is placed at the StopLimit
                               // price.
  ORDER_TYPE_SELL_STOP_LIMIT,  // Upon reaching the order price, a pending Sell Limit order is placed at the StopLimit
                               // price.
  ORDER_TYPE_CLOSE_BY          // Order to close a position by an opposite one.
};
#endif
