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
 * Includes Order's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/* Order actions. */
enum ENUM_ORDER_ACTION {
  ORDER_ACTION_CLOSE = 1,       // Close the order.
  ORDER_ACTION_COND_CLOSE_ADD,  // Add close condition.
  ORDER_ACTION_OPEN,            // Open the order.
  FINAL_ORDER_ACTION_ENTRY
};

/* Order conditions. */
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

// Defines enumeration for order properties.
enum ENUM_ORDER_PARAM {
  ORDER_PARAM_NONE = 0,              // None.
  ORDER_PARAM_COLOR_ARROW,           // Color of the opening arrow on the chart.
  ORDER_PARAM_COND_CLOSE,            // Close condition.
  ORDER_PARAM_COND_CLOSE_ARG_VALUE,  // Close condition arguments.
  ORDER_PARAM_COND_CLOSE_NUM,        // Number of close conditions.
  ORDER_PARAM_DUMMY,                 // Whether order is dummy.
  ORDER_PARAM_REFRESH_FREQ,          // How often to refresh order values (in secs).
  ORDER_PARAM_UPDATE_FREQ,           // How often to update order stops (in secs).
  FINAL_ENUM_ORDER_PARAM
};

/**
 * A variety of custom properties for reading order values.
 */
enum ENUM_ORDER_PROPERTY_CUSTOM {
  ORDER_PROP_NONE = 0,
  ORDER_PROP_COMMISSION,         // Commission.
  ORDER_PROP_LAST_ERROR,         // Last error code.
  ORDER_PROP_PRICE_CLOSE,        // Close price.
  ORDER_PROP_PRICE_OPEN,         // Open price.
  ORDER_PROP_PRICE_STOPLIMIT,    // The limit order price for the StopLimit order.
  ORDER_PROP_PROFIT,             // Current profit in price difference.
  ORDER_PROP_PROFIT_PIPS,        // Current profit in pips.
  ORDER_PROP_PROFIT_TOTAL,       // Total profit (profit minus fees).
  ORDER_PROP_PROFIT_VALUE,       // Total profit in base currency value.
  ORDER_PROP_REASON_CLOSE,       // Reason or source for closing an order.
  ORDER_PROP_TICKET,             // Ticket number.
  ORDER_PROP_TIME_CLOSED,        // Closed time.
  ORDER_PROP_TIME_OPENED,        // Opened time.
  ORDER_PROP_TIME_LAST_REFRESH,  // Last refresh of the order values.
  ORDER_PROP_TIME_LAST_UPDATE,   // Last update of the order values.
  ORDER_PROP_TOTAL_FEES,         // Total fees.
};

// Defines enumeration for order close reasons.
enum ENUM_ORDER_REASON_CLOSE {
  ORDER_REASON_CLOSED_ALL = 0,      // Closed all
  ORDER_REASON_CLOSED_BY_ACTION,    // Closed by action
  ORDER_REASON_CLOSED_BY_EXPIRE,    // Closed by expiration
  ORDER_REASON_CLOSED_BY_OPPOSITE,  // Closed by opposite order
  ORDER_REASON_CLOSED_BY_SIGNAL,    // Closed by signal
  ORDER_REASON_CLOSED_BY_SL,        // Closed by stop loss
  ORDER_REASON_CLOSED_BY_TEST,      // Closed by test
  ORDER_REASON_CLOSED_BY_TP,        // Closed by take profit
  ORDER_REASON_CLOSED_BY_USER,      // Closed by user
  ORDER_REASON_CLOSED_UNKNOWN,      // Closed by unknown event
};

#ifndef __MQL5__
/* Defines the reason for order placing. */
enum ENUM_ORDER_REASON {
  ORDER_REASON_CLIENT,  // The order was placed from a desktop terminal.
  ORDER_REASON_EXPERT,  // The order was placed from an MQL5-program (e.g. by an EA or a script).
  ORDER_REASON_MOBILE,  // The order was placed from a mobile application.
  ORDER_REASON_SL,      // The order was placed as a result of Stop Loss activation.
  ORDER_REASON_SO,      // The order was placed as a result of the Stop Out event.
  ORDER_REASON_TP,      // The order was placed as a result of Take Profit activation.
  ORDER_REASON_WEB,     // The order was placed from a web platform.
};
#endif

#ifndef __MQ4__
/**
 * Enumeration for order selection type.
 *
 * Notes:
 * - Enum has sense only in MQL5 and C++.
 */
enum ENUM_ORDER_SELECT_TYPE {
  ORDER_SELECT_TYPE_NONE,
  ORDER_SELECT_TYPE_ACTIVE,
  ORDER_SELECT_TYPE_HISTORY,
  ORDER_SELECT_TYPE_DEAL,
  ORDER_SELECT_TYPE_POSITION
};

/**
 * Enumeration for order data type.
 *
 * Notes:
 * - Enums has sense only in MQL5.
 */
enum ENUM_ORDER_SELECT_DATA_TYPE {
  ORDER_SELECT_DATA_TYPE_INTEGER,
  ORDER_SELECT_DATA_TYPE_DOUBLE,
  ORDER_SELECT_DATA_TYPE_STRING
};
#endif

#ifndef __MQL__
/**
 * Enumeration for OrderGetDouble() and HistoryOrderGetDouble().
 *
 * @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
 */
enum ENUM_ORDER_PROPERTY_DOUBLE {
  ORDER_VOLUME_INITIAL,  // Order initial volume.
  ORDER_VOLUME_CURRENT,  // Order current volume.
  ORDER_PRICE_OPEN,      // Price specified in the order.
  ORDER_SL,              // Stop Loss value.
  ORDER_TP,              // Take Profit value.
  ORDER_PRICE_CURRENT,   // The current price of the order symbol.
  ORDER_PRICE_STOPLIMIT  // The Limit order price for the StopLimit order.
};

/**
 * A variety of properties for reading order values.
 * Enumeration for OrderGetInteger() and HistoryOrderGetInteger().
 *
 * @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
 */
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

/**
 * A variety of properties for reading order values.
 * Enumeration for OrderGetString() and HistoryOrderGetString().
 *
 * @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
 */
enum ENUM_ORDER_PROPERTY_STRING {
  ORDER_COMMENT,      // Order comment.
  ORDER_EXTERNAL_ID,  // Order identifier in an external trading system (on the Exchange).
  ORDER_SYMBOL,       // Symbol of the order.
};
#endif

/* Defines modes for order type values (Take Profit and Stop Loss). */
enum ENUM_ORDER_TYPE_VALUE { ORDER_TYPE_TP = ORDER_TP, ORDER_TYPE_SL = ORDER_SL };

#ifndef __MQL__
/**
 * Order operation type.
 *
 * @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
 */
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

/* Positions */

#ifndef __MQL5__
/**
 * Returns double type of the position property.
 *
 * @see:
 * - https://www.mql5.com/en/docs/constants/tradingconstants/positionproperties
 */
enum ENUM_POSITION_PROPERTY_DOUBLE {
  POSITION_PRICE_CURRENT,  // Current price of the position symbol (double).
  POSITION_PRICE_OPEN,     // Position open price (double).
  POSITION_PROFIT,         // Current profit (double).
  POSITION_SL,             // Stop Loss level of opened position (double).
  POSITION_SWAP,           // Cumulative swap (double).
  POSITION_TP,             // Take Profit level of opened position (double).
  POSITION_VOLUME,         // Position volume (double).
};

//#define POSITION_TICKET

/**
 * Returns integer type of the position property.
 *
 * @see:
 * - https://www.mql5.com/en/docs/constants/tradingconstants/positionproperties
 */
enum ENUM_POSITION_PROPERTY_INTEGER {
  POSITION_IDENTIFIER,       // A unique number assigned to each re-opened position (long).
  POSITION_MAGIC,            // Position magic number (see ORDER_MAGIC) (long).
  POSITION_REASON,           // The reason for opening a position (ENUM_POSITION_REASON).
  POSITION_TICKET,           // Unique number assigned to each newly opened position (long).
  POSITION_TIME,             // Position open time (datetime).
  POSITION_TIME_MSC,         // Position opening time in milliseconds since 01.01.1970 (long).
  POSITION_TIME_UPDATE,      // Position changing time (datetime).
  POSITION_TIME_UPDATE_MSC,  // Position changing time in milliseconds since 01.01.1970 (long).
  POSITION_TYPE,             // Position type (ENUM_POSITION_TYPE).
};

/**
 * Returns string type of the position property.
 *
 * @see:
 * - https://www.mql5.com/en/docs/constants/tradingconstants/positionproperties
 */
enum ENUM_POSITION_PROPERTY_STRING {
  POSITION_COMMENT,      // Position comment (string).
  POSITION_EXTERNAL_ID,  // Position identifier in an external trading system (on the Exchange) (string).
  POSITION_SYMBOL,       // Symbol of the position (string).
};

/**
 * Returns reason for opening a position.
 *
 * @see:
 * - https://www.mql5.com/en/docs/constants/tradingconstants/positionproperties
 */
enum ENUM_POSITION_REASON {
  POSITION_REASON_CLIENT,  // Order placed from a desktop terminal.
  POSITION_REASON_EXPERT,  // Order placed from an Expert.
  POSITION_REASON_MOBILE,  // Order placed from a mobile application.
  POSITION_REASON_WEB,     // Order placed from the web platform.
};

/**
 * Direction of an open position (buy or sell).
 *
 * @see:
 * - https://www.mql5.com/en/docs/constants/tradingconstants/positionproperties
 */
enum ENUM_POSITION_TYPE {
  POSITION_TYPE_BUY,  // Buy position.
  POSITION_TYPE_SELL  // Sell position.
};
#endif
