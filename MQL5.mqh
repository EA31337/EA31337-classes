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
 * Provides forward compatibility for MQL5 in MT4/MQL4.
 */

// Prevents processing this includes file for the second time.
#ifndef MQL5_MQH
#define MQL5_MQH

//+------------------------------------------------------------------+
//| Declaration of constants
//+------------------------------------------------------------------+

// Missing error handling constants in MQL4.
// @see: https://docs.mql4.com/constants/errorswarnings/errorcodes
// @see: https://www.mql5.com/en/docs/constants/errorswarnings
#ifdef __MQL4__
// Return codes of the trade server.
#define TRADE_RETCODE_REQUOTE              10004 // Requote
#define TRADE_RETCODE_REJECT               10006 // Request rejected
#define TRADE_RETCODE_CANCEL               10007 // Request canceled by trader
#define TRADE_RETCODE_PLACED               10008 // Order placed
#define TRADE_RETCODE_DONE                 10009 // Request completed
#define TRADE_RETCODE_DONE_PARTIAL         10010 // Only part of the request was completed
#define TRADE_RETCODE_ERROR                10011 // Request processing error
#define TRADE_RETCODE_TIMEOUT              10012 // Request canceled by timeout
#define TRADE_RETCODE_INVALID              10013 // Invalid request
#define TRADE_RETCODE_INVALID_VOLUME       10014 // Invalid volume in the request
#define TRADE_RETCODE_INVALID_PRICE        10015 // Invalid price in the request
#define TRADE_RETCODE_INVALID_STOPS        10016 // Invalid stops in the request
#define TRADE_RETCODE_TRADE_DISABLED       10017 // Trade is disabled
#define TRADE_RETCODE_MARKET_CLOSED        10018 // Market is closed
#define TRADE_RETCODE_NO_MONEY             10019 // There is not enough money to complete the request
#define TRADE_RETCODE_PRICE_CHANGED        10020 // Prices changed
#define TRADE_RETCODE_PRICE_OFF            10021 // There are no quotes to process the request
#define TRADE_RETCODE_INVALID_EXPIRATION   10022 // Invalid order expiration date in the request
#define TRADE_RETCODE_ORDER_CHANGED        10023 // Order state changed
#define TRADE_RETCODE_TOO_MANY_REQUESTS    10024 // Too frequent requests
#define TRADE_RETCODE_NO_CHANGES           10025 // No changes in request
#define TRADE_RETCODE_SERVER_DISABLES_AT   10026 // Autotrading disabled by server
#define TRADE_RETCODE_CLIENT_DISABLES_AT   10027 // Autotrading disabled by client terminal
#define TRADE_RETCODE_LOCKED               10028 // Request locked for processing
#define TRADE_RETCODE_FROZEN               10029 // Order or position frozen
#define TRADE_RETCODE_INVALID_FILL         10030 // Invalid order filling type
#define TRADE_RETCODE_CONNECTION           10031 // No connection with the trade server
#define TRADE_RETCODE_ONLY_REAL            10032 // Operation is allowed only for live accounts
#define TRADE_RETCODE_LIMIT_ORDERS         10033 // The number of pending orders has reached the limit
#define TRADE_RETCODE_LIMIT_VOLUME         10034 // The volume of orders and positions for the symbol has reached the limit
#define TRADE_RETCODE_INVALID_ORDER        10035 // Incorrect or prohibited order type
#define TRADE_RETCODE_POSITION_CLOSED      10036 // Position with the specified POSITION_IDENTIFIER has already been closed
#define TRADE_RETCODE_INVALID_CLOSE_VOLUME 10038 // A close volume exceeds the current position volume
#define TRADE_RETCODE_CLOSE_ORDER_EXIST    10039 // A close order already exists.
#define TRADE_RETCODE_LIMIT_POSITIONS      10040 // The number of open positions can be limited (e.g. Netting, Hedging).
#endif
// Runtime Errors (@see: https://www.mql5.com/en/docs/constants/errorswarnings/errorcodes)
// General error codes.
#ifndef ERR_SUCCESS
#define ERR_SUCCESS                            0 // The operation completed successfully.
#endif
#define ERR_NO_MQLERROR                     4000
#ifndef ERR_INTERNAL_ERROR
#define ERR_INTERNAL_ERROR                  4001 // Operating system error.
#endif
#define ERR_WRONG_INTERNAL_PARAMETER        4002 // Wrong parameter in the inner call of the client terminal function.
//#define ERR_INVALID_PARAMETER               4003 // Wrong parameter when calling the system function.
#define ERR_NOT_ENOUGH_MEMORY               4004 // Not enough memory to perform the system function.
#define ERR_STRUCT_WITHOBJECTS_ORCLASS      4005 // The structure contains objects of strings and/or dynamic arrays and/or structure of such objects and/or classes.
#define ERR_INVALID_ARRAY                   4006 // Array of a wrong type, wrong size, or a damaged object of a dynamic array.
#define ERR_ARRAY_RESIZE_ERROR              4007 // Not enough memory for the relocation of an array, or an attempt to change the size of a static array.
#define ERR_STRING_RESIZE_ERROR             4008 // Not enough memory for the relocation of string.
#define ERR_NOTINITIALIZED_STRING           4009 // Not initialized string.
#define ERR_INVALID_DATETIME                4010 // Invalid date and/or time.
#define ERR_ARRAY_BAD_SIZE                  4011 // Requested array size exceeds 2 GB.
#ifndef ERR_INVALID_POINTER
#define ERR_INVALID_POINTER                 4012 // Wrong pointer.
#endif
#define ERR_INVALID_POINTER_TYPE            4013 // Wrong type of pointer.
#define ERR_FUNCTION_NOT_ALLOWED            4014 // Function is not allowed for call.
#define ERR_RESOURCE_NAME_DUPLICATED        4015 // The names of the dynamic and the static resource match.
#ifndef ERR_RESOURCE_NOT_FOUND
#define ERR_RESOURCE_NOT_FOUND              4016 // Resource with this name has not been found in EX5.
#endif
#define ERR_RESOURCE_UNSUPPOTED_TYPE        4017 // Unsupported resource type or its size exceeds 16 Mb.
#define ERR_RESOURCE_NAME_IS_TOO_LONG       4018 // The resource name exceeds 63 characters.
// Charts.
#define ERR_CHART_WRONG_ID                  4101 // Wrong chart ID.
#define ERR_CHART_NO_REPLY                  4102 // Chart does not respond.
#ifndef ERR_CHART_NOT_FOUND
#define ERR_CHART_NOT_FOUND                 4103 // Chart not found.
#endif
#define ERR_CHART_NO_EXPERT                 4104 // No Expert Advisor in the chart that could handle the event.
#define ERR_CHART_CANNOT_OPEN               4105 // Chart opening error.
#define ERR_CHART_CANNOT_CHANGE             4106 // Failed to change chart symbol and period.
#define ERR_CHART_WRONG_PARAMETER           4107 // Error value of the parameter for the function of working with charts.
#define ERR_CHART_CANNOT_CREATE_TIMER       4108 // Failed to create timer.
#define ERR_CHART_WRONG_PROPERTY            4109 // Wrong chart property ID.
#define ERR_CHART_SCREENSHOT_FAILED         4110 // Error creating screenshots.
#define ERR_CHART_NAVIGATE_FAILED           4111 // Error navigating through chart.
#define ERR_CHART_TEMPLATE_FAILED           4112 // Error applying template.
#define ERR_CHART_WINDOW_NOT_FOUND          4113 // Subwindow containing the indicator was not found.
#define ERR_CHART_INDICATOR_CANNOT_ADD      4114 // Error adding an indicator to chart.
#define ERR_CHART_INDICATOR_CANNOT_DEL      4115 // Error deleting an indicator from the chart.
#define ERR_CHART_INDICATOR_NOT_FOUND       4116 // Indicator not found on the specified chart.
// Graphical Objects.
#define ERR_OBJECT_ERROR                    4201 // Error working with a graphical object.
#define ERR_OBJECT_NOT_FOUND                4202 // Graphical object was not found.
#define ERR_OBJECT_WRONG_PROPERTY           4203 // Wrong ID of a graphical object property.
#define ERR_OBJECT_GETDATE_FAILED           4204 // Unable to get date corresponding to the value.
#define ERR_OBJECT_GETVALUE_FAILED          4205 // Unable to get value corresponding to the date.
// MarketInfo.
#define ERR_MARKET_UNKNOWN_SYMBOL           4301 // Unknown symbol.
#define ERR_MARKET_NOT_SELECTED             4302 // Symbol is not selected in MarketWatch.
#define ERR_MARKET_WRONG_PROPERTY           4303 // Wrong identifier of a symbol property.
#define ERR_MARKET_LASTTIME_UNKNOWN         4304 // Time of the last tick is not known (no ticks).
#define ERR_MARKET_SELECT_ERROR             4305 // Error adding or deleting a symbol in MarketWatch.
// History Access.
#define ERR_HISTORY_NOT_FOUND               4401 // Requested history not found.
#define ERR_HISTORY_WRONG_PROPERTY          4402 // Wrong ID of the history property.
#define ERR_HISTORY_TIMEOUT                 4403 // Exceeded history request timeout.
#define ERR_HISTORY_BARS_LIMIT              4404 // Number of requested bars limited by terminal settings.
#define ERR_HISTORY_LOAD_ERRORS             4405 // Multiple errors when loading history.
#define ERR_HISTORY_SMALL_BUFFER            4407 // Receiving array is too small to store all requested data.
// Global_Variables.
#define ERR_GLOBALVARIABLE_NOT_FOUND        4501 // Global variable of the client terminal is not found.
#define ERR_GLOBALVARIABLE_EXISTS           4502 // Global variable of the client terminal with the same name already exists.
#define ERR_MAIL_SEND_FAILED                4510 // Email sending failed.
#define ERR_PLAY_SOUND_FAILED               4511 // Sound playing failed.
#define ERR_MQL5_WRONG_PROPERTY             4512 // Wrong identifier of the program property.
#define ERR_TERMINAL_WRONG_PROPERTY         4513 // Wrong identifier of the terminal property.
#define ERR_FTP_SEND_FAILED                 4514 // File sending via ftp failed.
#define ERR_NOTIFICATION_SEND_FAILED        4515 // Failed to send a notification.
#define ERR_NOTIFICATION_WRONG_PARAMETER    4516 // Invalid parameter for sending a notification - an empty string or NULL has been passed to the SendNotification() function.
#define ERR_NOTIFICATION_WRONG_SETTINGS     4517 // Wrong settings of notifications in the terminal (ID is not specified or permission is not set).
#ifndef ERR_NOTIFICATION_TOO_FREQUENT
#define ERR_NOTIFICATION_TOO_FREQUENT       4518 // Too frequent sending of notifications.
#endif
#ifndef ERR_FTP_NOSERVER
#define ERR_FTP_NOSERVER                    4519 // FTP server is not specified.
#endif
#ifndef ERR_FTP_NOLOGIN
#define ERR_FTP_NOLOGIN                     4520 // FTP login is not specified.
#endif
#ifndef ERR_FTP_FILE_ERROR
#define ERR_FTP_FILE_ERROR                  4521 // File not found in the MQL5\Files directory to send on FTP server.
#endif
#ifndef ERR_FTP_CONNECT_FAILED
#define ERR_FTP_CONNECT_FAILED              4522 // FTP connection failed.
#endif
#ifndef ERR_FTP_CHANGEDIR
#define ERR_FTP_CHANGEDIR                   4523 // FTP path not found on server.
#endif
#ifndef ERR_FTP_CLOSED
#define ERR_FTP_CLOSED                      4524 // FTP connection closed.
#endif
// Custom Indicator Buffers.
#define ERR_BUFFERS_NO_MEMORY               4601 // Not enough memory for the distribution of indicator buffers.
#define ERR_BUFFERS_WRONG_INDEX             4602 // Wrong indicator buffer index.
// Custom Indicator Properties.
#define ERR_CUSTOM_WRONG_PROPERTY           4603 // Wrong ID of the custom indicator property.
// Account.
#define ERR_ACCOUNT_WRONG_PROPERTY          4701 // Wrong account property ID.
#define ERR_TRADE_WRONG_PROPERTY            4751 // Wrong trade property ID.
#ifndef ERR_TRADE_DISABLED
#define ERR_TRADE_DISABLED                  4752 // Trading by Expert Advisors prohibited.
#endif
#define ERR_TRADE_POSITION_NOT_FOUND        4753 // Position not found.
#define ERR_TRADE_ORDER_NOT_FOUND           4754 // Order not found.
#define ERR_TRADE_DEAL_NOT_FOUND            4755 // Deal not found.
#define ERR_TRADE_SEND_FAILED               4756 // Trade request sending failed.
// Indicators.
#define ERR_INDICATOR_UNKNOWN_SYMBOL        4801 // Unknown symbol.
#define ERR_INDICATOR_CANNOT_CREATE         4802 // Indicator cannot be created.
#define ERR_INDICATOR_NO_MEMORY             4803 // Not enough memory to add the indicator.
#define ERR_INDICATOR_CANNOT_APPLY          4804 // The indicator cannot be applied to another indicator.
#define ERR_INDICATOR_CANNOT_ADD            4805 // Error applying an indicator to chart.
#define ERR_INDICATOR_DATA_NOT_FOUND        4806 // Requested data not found.
#define ERR_INDICATOR_WRONG_HANDLE          4807 // Wrong indicator handle.
#define ERR_INDICATOR_WRONG_PARAMETERS      4808 // Wrong number of parameters when creating an indicator.
#define ERR_INDICATOR_PARAMETERS_MISSING    4809 // No parameters when creating an indicator.
#define ERR_INDICATOR_CUSTOM_NAME           4810 // The first parameter in the array must be the name of the custom indicator.
#define ERR_INDICATOR_PARAMETER_TYPE        4811 // Invalid parameter type in the array when creating an indicator.
#define ERR_INDICATOR_WRONG_INDEX           4812 // Wrong index of the requested indicator buffer.
// Depth of Market.
#define ERR_BOOKS_CANNOT_ADD                4901 // Depth Of Market can not be added.
#define ERR_BOOKS_CANNOT_DELETE             4902 // Depth Of Market can not be removed.
#define ERR_BOOKS_CANNOT_GET                4903 // The data from Depth Of Market can not be obtained.
#define ERR_BOOKS_CANNOT_SUBSCRIBE          4904 // Error in subscribing to receive new data from Depth Of Market.
// File Operations.
#define ERR_TOO_MANY_FILES                  5001 // More than 64 files cannot be opened at the same time.
#define ERR_WRONG_FILENAME                  5002 // Invalid file name.
#define ERR_TOO_LONG_FILENAME               5003 // Too long file name.
#ifndef ERR_CANNOT_OPEN_FILE
#define ERR_CANNOT_OPEN_FILE                5004 // File opening error.
#endif
#define ERR_FILE_CACHEBUFFER_ERROR          5005 // Not enough memory for cache to read.
#define ERR_CANNOT_DELETE_FILE              5006 // File deleting error.
#define ERR_INVALID_FILEHANDLE              5007 // A file with this handle was closed, or was not opening at all.
#define ERR_WRONG_FILEHANDLE                5008 // Wrong file handle.
#define ERR_FILE_NOTTOWRITE                 5009 // The file must be opened for writing.
#define ERR_FILE_NOTTOREAD                  5010 // The file must be opened for reading.
#define ERR_FILE_NOTBIN                     5011 // The file must be opened as a binary one.
#define ERR_FILE_NOTTXT                     5012 // The file must be opened as a text.
#define ERR_FILE_NOTTXTORCSV                5013 // The file must be opened as a text or CSV.
#define ERR_FILE_NOTCSV                     5014 // The file must be opened as CSV.
#define ERR_FILE_READERROR                  5015 // File reading error.
#define ERR_FILE_BINSTRINGSIZE              5016 // String size must be specified, because the file is opened as binary.
#define ERR_INCOMPATIBLE_FILE               5017 // A text file must be for string arrays, for other arrays - binary.
#ifndef ERR_FILE_IS_DIRECTORY
#define ERR_FILE_IS_DIRECTORY               5018 // This is not a file, this is a directory.
#endif
#ifndef ERR_FILE_NOT_EXIST
#define ERR_FILE_NOT_EXIST                  5019 // File does not exist.
#endif
#ifndef ERR_FILE_CANNOT_REWRITE
#define ERR_FILE_CANNOT_REWRITE             5020 // File can not be rewritten.
#endif
#define ERR_WRONG_DIRECTORYNAME             5021 // Wrong directory name.
#define ERR_DIRECTORY_NOT_EXIST             5022 // Directory does not exist.
#define ERR_FILE_ISNOT_DIRECTORY            5023 // This is a file, not a directory.
#define ERR_CANNOT_DELETE_DIRECTORY         5024 // The directory cannot be removed.
#define ERR_CANNOT_CLEAN_DIRECTORY          5025 // Failed to clear the directory (probably one or more files are blocked and removal operation failed).
#define ERR_FILE_WRITEERROR                 5026 // Failed to write a resource to a file.
#define ERR_FILE_ENDOFFILE                  5027 // Unable to read the next piece of data from a CSV file (FileReadString, FileReadNumber, FileReadDatetime, FileReadBool), since the end of file is reached.
// String Casting.
#define ERR_NO_STRING_DATE                  5030 // No date in the string.
#define ERR_WRONG_STRING_DATE               5031 // Wrong date in the string.
#define ERR_WRONG_STRING_TIME               5032 // Wrong time in the string.
#define ERR_STRING_TIME_ERROR               5033 // Error converting string to date.
#define ERR_STRING_OUT_OF_MEMORY            5034 // Not enough memory for the string.
#define ERR_STRING_SMALL_LEN                5035 // The string length is less than expected.
#define ERR_STRING_TOO_BIGNUMBER            5036 // Too large number, more than ULONG_MAX.
#define ERR_WRONG_FORMATSTRING              5037 // Invalid format string.
#define ERR_TOO_MANY_FORMATTERS             5038 // Amount of format specifiers more than the parameters.
#define ERR_TOO_MANY_PARAMETERS             5039 // Amount of parameters more than the format specifiers.
#define ERR_WRONG_STRING_PARAMETER          5040 // Damaged parameter of string type.
#define ERR_STRINGPOS_OUTOFRANGE            5041 // Position outside the string.
#define ERR_STRING_ZEROADDED                5042 // 0 added to the string end, a useless operation.
#define ERR_STRING_UNKNOWNTYPE              5043 // Unknown data type when converting to a string.
#define ERR_WRONG_STRING_OBJECT             5044 // Damaged string object.
// Operations with Array.
#ifndef ERR_INCOMPATIBLE_ARRAYS
#define ERR_INCOMPATIBLE_ARRAYS             5050 // Copying incompatible arrays. String array can be copied only to a string array, and a numeric array - in numeric array only.
#endif
#define ERR_SMALL_ASSERIES_ARRAY            5051 // The receiving array is declared as AS_SERIES, and it is of insufficient size.
#define ERR_SMALL_ARRAY                     5052 // Too small array, the starting position is outside the array.
#define ERR_ZEROSIZE_ARRAY                  5053 // An array of zero length.
#define ERR_NUMBER_ARRAYS_ONLY              5054 // Must be a numeric array.
#define ERR_ONEDIM_ARRAYS_ONLY              5055 // Must be a one-dimensional array.
#define ERR_SERIES_ARRAY                    5056 // Timeseries cannot be used.
#define ERR_DOUBLE_ARRAY_ONLY               5057 // Must be an array of type double.
#define ERR_FLOAT_ARRAY_ONLY                5058 // Must be an array of type float.
#define ERR_LONG_ARRAY_ONLY                 5059 // Must be an array of type long.
#define ERR_INT_ARRAY_ONLY                  5060 // Must be an array of type int.
#define ERR_SHORT_ARRAY_ONLY                5061 // Must be an array of type short.
#define ERR_CHAR_ARRAY_ONLY                 5062 // Must be an array of type char.
// Operations with OpenCL.
#define ERR_OPENCL_NOT_SUPPORTED            5100 // OpenCL functions are not supported on this computer.
#define ERR_OPENCL_INTERNAL                 5101 // Internal error occurred when running OpenCL.
#define ERR_OPENCL_INVALID_HANDLE           5102 // Invalid OpenCL handle.
#define ERR_OPENCL_CONTEXT_CREATE           5103 // Error creating the OpenCL context.
#define ERR_OPENCL_QUEUE_CREATE             5104 // Failed to create a run queue in OpenCL.
#define ERR_OPENCL_PROGRAM_CREATE           5105 // Error occurred when compiling an OpenCL program.
#define ERR_OPENCL_TOO_LONG_KERNEL_NAME     5106 // Too long kernel name (OpenCL kernel).
#define ERR_OPENCL_KERNEL_CREATE            5107 // Error creating an OpenCL kernel.
#define ERR_OPENCL_SET_KERNEL_PARAMETER     5108 // Error occurred when setting parameters for the OpenCL kernel.
#define ERR_OPENCL_EXECUTE                  5109 // OpenCL program runtime error.
#define ERR_OPENCL_WRONG_BUFFER_SIZE        5110 // Invalid size of the OpenCL buffer.
#define ERR_OPENCL_WRONG_BUFFER_OFFSET      5111 // Invalid offset in the OpenCL buffer.
#define ERR_OPENCL_BUFFER_CREATE            5112 // Failed to create an OpenCL buffer.
// Operations with WebRequest.
#ifndef ERR_WEBREQUEST_INVALID_ADDRESS
#define ERR_WEBREQUEST_INVALID_ADDRESS      5200 // Invalid URL.
#endif
#ifndef ERR_WEBREQUEST_CONNECT_FAILED
#define ERR_WEBREQUEST_CONNECT_FAILED       5201 // Failed to connect to specified URL.
#endif
#ifndef ERR_WEBREQUEST_TIMEOUT
#define ERR_WEBREQUEST_TIMEOUT              5202 // Timeout exceeded.
#endif
#ifndef ERR_WEBREQUEST_REQUEST_FAILED
#define ERR_WEBREQUEST_REQUEST_FAILED       5203 // HTTP request failed.
#endif
// User-Defined Errors.
#ifndef ERR_USER_ERROR_FIRST
#define ERR_USER_ERROR_FIRST               65536 // User defined errors start with this code.
#endif

/**
 * MQL5 wrapper to work in MQL4.
 */
class MQL5 {

  public:
    // Enums.
    #ifdef __MQL4__
    // Trading operations.
    enum ENUM_TRADE_REQUEST_ACTIONS {
      // @see: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions
      TRADE_ACTION_DEAL,    // Place a trade order for an immediate execution with the specified parameters (market order).
      TRADE_ACTION_PENDING, // Place a trade order for the execution under specified conditions (pending order).
      TRADE_ACTION_SLTP,    // Modify Stop Loss and Take Profit values of an opened position.
      TRADE_ACTION_MODIFY,  // Modify the parameters of the order placed previously.
      TRADE_ACTION_REMOVE,  // Delete the pending order placed previously.
      TRADE_ACTION_CLOSE_BY // Close a position by an opposite one.
    };
    // Fill Policy.
    enum ENUM_SYMBOL_FILLING {
      // @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
      SYMBOL_FILLING_FOK = 1, // A deal can be executed only with the specified volume.
      SYMBOL_FILLING_IOC = 2  // Trader agrees to execute a deal with the volume maximally available in the market.
    };
    enum ENUM_ORDER_TYPE_FILLING {
      // @see: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties
      ORDER_FILLING_FOK, // An order can be filled only in the specified amount.
      ORDER_FILLING_IOC, // A trader agrees to execute a deal with the volume maximally available in the market.
      ORDER_FILLING_RETURN // In case of partial filling a market or limit order with remaining volume is not canceled but processed further.
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
      ORDER_STATE_STARTED,        // Order checked, but not yet accepted by broker
      ORDER_STATE_PLACED,         // Order accepted
      ORDER_STATE_CANCELED,       // Order canceled by client
      ORDER_STATE_PARTIAL,        // Order partially executed
      ORDER_STATE_FILLED,         // Order fully executed
      ORDER_STATE_REJECTED,       // Order rejected
      ORDER_STATE_EXPIRED,        // Order expired
      ORDER_STATE_REQUEST_ADD,    // Order is being registered (placing to the trading system)
      ORDER_STATE_REQUEST_MODIFY, // Order is being modified (changing its parameters)
      ORDER_STATE_REQUEST_CANCEL  // Order is being deleted (deleting from the trading system)
    };
    #endif

    #ifdef __MQL4__
    // @see: https://www.mql5.com/en/docs/constants/structures/mqltraderequest
    struct MqlTradeRequest {
      ENUM_TRADE_REQUEST_ACTIONS    action;           // Trade operation type.
      ulong                         magic;            // Expert Advisor ID (magic number).
      ulong                         order;            // Order ticket.
      string                        symbol;           // Trade symbol.
      double                        volume;           // Requested volume for a deal in lots.
      double                        price;            // Price.
      double                        stoplimit;        // StopLimit level of the order.
      double                        sl;               // Stop Loss level of the order.
      double                        tp;               // Take Profit level of the order.
      ulong                         deviation;        // Maximal possible deviation from the requested price.
      ENUM_ORDER_TYPE               type;             // Order type.
      ENUM_ORDER_TYPE_FILLING       type_filling;     // Order execution type.
      ENUM_ORDER_TYPE_TIME          type_time;        // Order expiration type.
      datetime                      expiration;       // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type.
      string                        comment;          // Order comment.
      ulong                         position;         // Position ticket.
      ulong                         position_by;      // The ticket of an opposite position.
    };
    // @see: https://www.mql5.com/en/docs/constants/structures/mqltraderesult
    struct MqlTradeResult  {
      uint     retcode;          // Operation return code.
      ulong    deal;             // Deal ticket, if it is performed.
      ulong    order;            // Order ticket, if it is placed.
      double   volume;           // Deal volume, confirmed by broker.
      double   price;            // Deal price, confirmed by broker.
      double   bid;              // Current Bid price.
      double   ask;              // Current Ask price.
      string   comment;          // Broker comment to operation (by default it is filled by description of trade server return code).
      uint     request_id;       // Request ID set by the terminal during the dispatch.
      uint     retcode_external; // Return code of an external trading system.
    };
    #endif
};
#endif // MQL5_MQH
