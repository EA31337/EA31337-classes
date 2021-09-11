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
 * Class to provide methods for state checking of the client terminal.
 *
 * @docs
 * - https://docs.mql4.com/chart_operations/chartredraw
 * - https://www.mql5.com/en/docs/chart_operations
 */

// Forward declaration.
class Terminal;

// Prevents processing this includes file for the second time.
#ifndef TERMINAL_MQH
#define TERMINAL_MQH

// Includes.
#include "Convert.mqh"
#include "Data.struct.h"
#include "Object.mqh"
#include "Refs.mqh"
#include "String.mqh"
#include "Terminal.define.h"
#include "Terminal.enum.h"
#include "Terminal.struct.h"

#ifdef __MQL5__
// Provide backward compatibility for MQL4 in MQL5.
//#include "MQL4.mqh"
#else
// Provides forward compatibility for MQL5 in MQL4.
#include "MQL5.mqh"
#endif

/**
 * Class to provide functions that return parameters of the current terminal.
 */
class Terminal : public Object {
 public:
  /**
   * Class constructor.
   */
  Terminal() {}

  /**
   * Class deconstructor.
   */
  ~Terminal() {}

  /* Client Terminal property getters */

  /**
   * The client terminal build number.
   */
  static int GetBuild() { return Terminal::TerminalInfoInteger(TERMINAL_BUILD); }

  /**
   * Name of the program executed.
   */
  static string WindowExpertName(void) { return (::MQLInfoString(::MQL_PROGRAM_NAME)); }

  /**
   * Indicates the tester process.
   *
   * Checks if the Expert Advisor runs in the testing mode.
   */
  static bool IsTesting() {
#ifdef __MQL4__
    return ::IsTesting();
#else
    return (bool)MQLInfoInteger(MQL_TESTER);
#endif
  }

  /**
   * Indicates the optimization process.
   *
   * Checks if Expert Advisor runs in the Strategy Tester optimization mode.
   */
  static bool IsOptimization() {
#ifdef __MQL4__
    return ::IsOptimization();
#else
    return (bool)MQLInfoInteger(MQL_OPTIMIZATION);
#endif
  }

  /**
   * Checks if the Expert Advisor is tested in visual mode.
   */
  static bool IsVisualMode() {
#ifdef __MQL4__
    return ::IsVisualMode();
#else
    return (bool)MQLInfoInteger(MQL_VISUAL_MODE);
#endif
  }

  /**
   * Checks if the Expert Advisor is tested for real time mode
   * outside of the Strategy Tester.
   *
   * Note: It does not take into the account scripts.
   */
  static bool IsRealtime() {
    if (!IsTesting() && !IsOptimization() && !IsVisualMode()) {
      return (true);
    } else {
      return (false);
    }
  }

  /* State Checking methods */

  /**
   * Returns the contents of the system variable _LastError.
   *
   * @return
   * Returns the value of the last error that occurred during the execution of an program.
   *
   * @see
   * - https://docs.mql4.com/check/getlasterror
   * - https://www.mql5.com/en/docs/check/getlasterror
   */
  static int GetLastError() { return ::GetLastError(); }

  /**
   * Check if some error occured.
   *
   * @return
   * Returns true if the value of the last error indicates error.
   */
  static bool HasError() { return Terminal::GetLastError() > ERR_NO_ERROR; }

  /**
   * Checks the forced shutdown of an program.
   *
   * @return
   * Returns true, if the _StopFlag system variable contains a value other than 0.
   *
   * @see
   * - https://docs.mql4.com/check/isstopped
   * - https://www.mql5.com/en/docs/check/isstopped
   */
  static bool IsStopped() { return ::IsStopped(); }

  // UninitializeReason
  // MQLInfoInteger
  // MQLInfoString
  // MQLSetInteger
  // Symbol
  // Period
  // Digits
  // Point

  /**
   * Indicates the permission to use DLL files.
   */
  static bool IsDllsAllowed() {
    return Terminal::TerminalInfoInteger(TERMINAL_DLLS_ALLOWED) && MQLInfoInteger(MQL_DLLS_ALLOWED);
  }

  /**
   * Checks if Expert Advisors are enabled for running.
   *
   * @docs: https://docs.mql4.com/check/isexpertenabled
   */
  static bool IsExpertEnabled() {
#ifdef __MQL4__
    return ::IsExpertEnabled();
#else  // __MQL5__
    // In MQL5 there is no equivalent function,
    // so checks only the permission to trade.
    return (bool)Terminal::TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
#endif
  }

  /**
   * Indicates the permission to use external libraries (such as DLL).
   */
  static bool IsLibrariesAllowed() {
    return Terminal::TerminalInfoInteger(TERMINAL_DLLS_ALLOWED) && MQLInfoInteger(MQL_DLLS_ALLOWED);
  }

  /**
   * Indicates the permission to trade.
   *
   * Check the permission to trade at the running program level and at the terminal level.
   */
  static bool IsTradeAllowed() {
    return (bool)MQLInfoInteger(MQL_TRADE_ALLOWED) && (bool)Terminal::TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
  }

  /**
   * Checks whether context is occupied.
   *
   * @return
   * Returns true if context is occupied with an expert trading operation,
   * another expert or script cannot call trading functions at that moment due to error 146 (ERR_TRADE_CONTEXT_BUSY).
   */
  static bool IsTradeContextBusy() {
#ifdef __MQL4__
    return ::IsTradeContextBusy();
#else
    return false;
#endif
  }

  /**
   * The flag indicates the presence of MQL5.community authorization data in the terminal.
   *
   * Note: In the latest build, it returns ERR_TERMINAL_WRONG_PROPERTY (4513).
   */
  static bool HasCommunityAccount() { return (bool)Terminal::TerminalInfoInteger(TERMINAL_COMMUNITY_ACCOUNT); }

  /**
   * Check connection to MQL5 community.
   *
   * Note: In the latest build, it returns ERR_FUNCTION_NOT_ALLOWED (4014).
   */
  static bool IsCommunityConnected() { return (bool)Terminal::TerminalInfoInteger(TERMINAL_COMMUNITY_CONNECTION); }

  /**
   * Get MQL5 community balance.
   *
   * Note: In the latest build, it returns ERR_FUNCTION_NOT_ALLOWED (4014).
   */
  static double GetCommunityBalance() { return Terminal::TerminalInfoDouble(TERMINAL_COMMUNITY_BALANCE); }

  /**
   * Checks connection to a trade server.
   *
   * @see
   * - https://docs.mql4.com/check/isconnected
   * - https://www.mql5.com/en/docs/constants/environment_state/terminalstatus
   */
  static bool IsConnected() { return (bool)Terminal::TerminalInfoInteger(TERMINAL_CONNECTED); }

  /**
   * Permission to send e-mails using SMTP-server and login, specified in the terminal settings.
   */
  static bool IsEmailEnabled() { return (bool)Terminal::TerminalInfoInteger(TERMINAL_EMAIL_ENABLED); }

  /**
   * Permission to send reports using FTP-server and login, specified in the terminal settings.
   */
  static bool IsFtpEnabled() { return (bool)Terminal::TerminalInfoInteger(TERMINAL_FTP_ENABLED); }

  /**
   * Permission to send notifications to smartphone.
   *
   * Note: In the latest build, it returns ERR_TERMINAL_WRONG_PROPERTY (4513).
   */
  static bool IsNotificationsEnabled() { return (bool)Terminal::TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED); }

  /**
   * The maximal bars count on the chart.
   */
  static int GetMaxBars() { return Terminal::TerminalInfoInteger(TERMINAL_MAXBARS); }

  /**
   * The flag indicates the presence of MetaQuotes ID data to send Push notifications.
   *
   * Note: In the latest build, it returns ERR_TERMINAL_WRONG_PROPERTY (4513).
   */
  static bool HasMetaQuotesId() { return (bool)Terminal::TerminalInfoInteger(TERMINAL_MQID); }

  /**
   * Number of the code page of the language installed in the client terminal.
   *
   * @see
   * - https://www.mql5.com/en/docs/constants/io_constants/codepageusage
   */
  static int GetCodePage() { return Terminal::TerminalInfoInteger(TERMINAL_CODEPAGE); }

  /**
   * The number of CPU cores in the system.
   */
  static int GetCpuCores() { return Terminal::TerminalInfoInteger(TERMINAL_CPU_CORES); }

  /**
   * Free disk space for the Files folder of the terminal in Mb.
   */
  static int GetDiskSpace() { return Terminal::TerminalInfoInteger(TERMINAL_DISK_SPACE); }

  /**
   * Physical memory in the system in Mb.
   */
  static int GetPhysicalMemory() { return Terminal::TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL); }

  /**
   * Memory available to the process of the terminal in Mb.
   */
  static int GetTotalMemory() { return Terminal::TerminalInfoInteger(TERMINAL_MEMORY_TOTAL); }

  /**
   * Free memory of the terminal process in Mb.
   */
  static int GetFreeMemory() { return Terminal::TerminalInfoInteger(TERMINAL_MEMORY_AVAILABLE); }

  /**
   * Memory used by the terminal in Mb.
   */
  static int GetUsedMemory() { return Terminal::TerminalInfoInteger(TERMINAL_MEMORY_USED); }

  /**
   * The resolution of information display on the screen.
   *
   * It is measured as number of Dots in a line per Inch (DPI).
   * Knowing the parameter value, you can set the size of graphical objects,
   * so that they look the same on monitors with different resolution characteristics.
   */
  static int GetScreenDpi() { return Terminal::TerminalInfoInteger((ENUM_TERMINAL_INFO_INTEGER)TERMINAL_SCREEN_DPI); }

  /**
   * The last known value of a ping to a trade server in microseconds.
   *
   * One second comprises of one million microseconds.
   */
  static int GetPingLast() { return Terminal::TerminalInfoInteger((ENUM_TERMINAL_INFO_INTEGER)TERMINAL_PING_LAST); }

  /*
   * Terminal file operations.
   *
   * @see: ENUM_TERMINAL_INFO_STRING
   * @docs
   * - https://www.mql5.com/en/docs/constants/environment_state/terminalstatus
   *
   */

  /**
   * Returns language of the terminal
   */
  static string GetLanguage() { return Terminal::TerminalInfoString(TERMINAL_LANGUAGE); }

  /**
   * Returns the name of company owning the client terminal.
   */
  static string GetCompany() { return Terminal::TerminalInfoString(TERMINAL_COMPANY); }

  /**
   * Returns the client terminal name.
   */
  static string GetName() { return Terminal::TerminalInfoString(TERMINAL_NAME); }

  /**
   * Returns the current working directory.
   *
   * It is usually the directory where the client terminal was launched.
   */
  static string GetTerminalPath() { return Terminal::TerminalInfoString(TERMINAL_PATH); }

  /**
   * Returns folder in which terminal data are stored.
   */
  static string GetDataPath() { return Terminal::TerminalInfoString(TERMINAL_DATA_PATH); }

  /**
   * Returns common path for all of the terminals installed on a computer.
   */
  static string GetCommonPath() { return Terminal::TerminalInfoString(TERMINAL_COMMONDATA_PATH); }

  /**
   * Returns folder in which expert files are stored.
   */
  static string GetExpertPath() {
#ifdef __MQL4__
    return GetDataPath() + "\\MQL4\\Experts";
#endif
#ifdef __MQL5__
    return GetDataPath() + "\\MQL5\\Experts";
#endif
#ifndef __MQLBUILD__
    return GetDataPath() + "\\Experts";
#endif
  }

  /* Check methods */

  /**
   * Check permissions to trade.
   */
  static bool CheckPermissionToTrade() {
    if (IsRealtime()) {
      return IsConnected() && IsTradeAllowed();
    }
    return true;
  }

  /*
   * Methods to provide error handling.
   *
   * @docs
   * - https://docs.mql4.com/constants/errorswarnings/errorcodes
   * - https://www.mql5.com/en/docs/constants/errorswarnings
   */

  /**
   * Get textual representation of the error based on its code.
   *
   * Note: The error codes are defined in stderror.mqh.
   * Alternatively you can print the error description by using ErrorDescription() function, defined in stdlib.mqh.
   */
  static string GetErrorText(int code) {
    string text;

    switch (code) {
      case 0:
        text = "No error returned.";
        break;
      case 1:
        text = "No error returned, but the result is unknown.";
        break;
      case 2:
        text = "Common error.";
        break;
      case 3:
        text = "Invalid trade parameters.";
        break;
      case 4:
        text = "Trade server is busy.";
        break;
      case 5:
        text = "Old version of the client terminal,";
        break;
      case 6:
        text = "No connection with trade server.";
        break;
      case 7:
        text = "Not enough rights.";
        break;
      case 8:
        text = "Too frequent requests.";
        break;
      case 9:
        text = "Malfunctional trade operation (never returned error).";
        break;
      case 64:
        text = "Account disabled.";
        break;
      case 65:
        text = "Invalid account.";
        break;
      case 128:
        text = "Trade timeout.";
        break;
      // --
      // The error 129 (ERR_INVALID_PRICE) is generated when calculated or unnormalized price cannot be applied.
      // E.g. If there has not been the requested open price in the price thread,
      // or it has not been normalized according to the amount of digits after decimal point.
      case 129:
        text = "Invalid price.";
        break;
      // --
      // The error 130 (ERR_INVALID_STOPS) is generated in the case of erroneous or unnormalized stop levels
      // (MODE_STOPLEVEL).
      case 130: /* ERR_INVALID_STOPS */
        text = "Invalid stops.";
        break;
      case 131:
        text = "Invalid trade volume.";
        break;
      case 132:
        text = "Market is closed.";
        break;
      case 133:
        text = "Trade is disabled.";
        break;
      case 134:
        text = "Not enough money.";
        break;
      case 135:
        text = "Price changed.";
        break;
      // --
      // ERR_OFF_QUOTES
      //   1. Off Quotes may be a technical issue.
      //   2. Off Quotes may be due to unsupported orders.
      //      - Trying to partially close a position. For example, attempting to close 0.10 (10k) of a 20k position.
      //      - Placing a micro lot trade. For example, attempting to place a 0.01 (1k) volume trade.
      //      - Placing a trade that is not in increments of 0.10 (10k) volume. For example, attempting to place a 0.77
      //      (77k) trade.
      //      - Adding a stop or limit to a market order before the order executes. For example, setting an EA to place
      //      a 0.1 volume (10k) buy market order with a stop loss of 50 pips.
      case 136: /* ERR_OFF_QUOTES */
        text = "Off quotes.";
        break;
      case 137:
        text = "Broker is busy (never returned error).";
        break;
      // --
      // The error 138 (ERR_REQUOTE) is generated when the requested open price is fully out of date.
      // The order can be opened at the current price only if the current price lies within the slippage range of price.
      case 138: /* ERR_REQUOTE */
        text = "Requote.";
        break;
      case 139:
        text = "Order is locked.";
        break;
      case 140:
        text = "Long positions only allowed.";
        break;
      case 141: /* ERR_TOO_MANY_REQUESTS */
        text = "Too many requests.";
        break;
      case 145:
        text = "Modification denied because order too close to market.";
        break;
      case 146:
        text = "Trade context is busy.";
        break;
      // --
      // The error 147 (ERR_TRADE_EXPIRATION_DENIED) is generated,
      // when a non-zero value is specified in the expiration time parameter of pending order.
      case 147:
        text = "Expirations are denied by broker.";
        break;
      // --
      // The error 148 (ERR_TRADE_TOO_MANY_ORDERS) is generated on some trade servers,
      // when the total amount of open and pending orders is limited.
      // If this limit has been exceeded, no new position can be opened.
      case 148: /* ERR_TRADE_TOO_MANY_ORDERS */
        text = "Amount of open and pending orders has reached the limit set by the broker";
        break;  // ERR_TRADE_TOO_MANY_ORDERS
      case 149:
        text = "An attempt to open an order opposite to the existing one when hedging is disabled";
        break;  // ERR_TRADE_HEDGE_PROHIBITED
      case 150:
        text = "An attempt to close an order contravening the FIFO rule.";
        break;  // ERR_TRADE_PROHIBITED_BY_FIFO
      /* Runtime Errors */
      // @docs: https://www.mql5.com/en/docs/constants/errorswarnings/errorcodes
      case 4000:
        text = "No error (never generated code).";
        break;
      case 4001:
        text = "Wrong function pointer.";
        break;
      case 4002:
        text = "Array index is out of range.";
        break;
      case 4003:
        text = "No memory for function call stack.";
        break;
      case 4004:
        text = "Recursive stack overflow.";
        break;
      case 4005:
        text = "Not enough stack for parameter.";
        break;
      case 4006:
        text = "No memory for parameter string.";
        break;
      case 4007:
        text = "No memory for temp string.";
        break;
      case 4008:
        text = "Not initialized string.";
        break;
      case 4009:
        text = "Not initialized string in array.";
        break;
      case 4010:
        text = "No memory for array\' string.";
        break;
      case 4011:
        text = "Too long string.";
        break;
      case 4012:
        text = "Remainder from zero divide.";
        break;
      case 4013:
        text = "Zero divide.";
        break;
      case 4014:
        text = "Unknown command.";
        break;
      case 4015:
        text = "Wrong jump (never generated error).";
        break;
      case 4016:
        text = "Not initialized array.";
        break;
      case 4017:
        text = "Dll calls are not allowed.";
        break;
      case 4018:
        text = "Cannot load library.";
        break;
      case 4019:
        text = "Cannot call function.";
        break;
      case 4020:
        text = "Expert function calls are not allowed.";
        break;
      case 4021:
        text = "Not enough memory for temp string returned from function.";
        break;
      case 4022:
        text = "System is busy (never generated error).";
        break;
      case 4050:
        text = "Invalid function parameters count.";
        break;
      case 4051:
        text = "Invalid function parameter value.";
        break;
      case 4052:
        text = "String function internal error.";
        break;
      case 4053:
        text = "Some array error.";
        break;
      case 4054:
        text = "Incorrect series array using.";
        break;
      case 4055:
        text = "Custom indicator error.";
        break;
      case 4056:
        text = "Array are incompatible.";
        break;
      case 4057:
        text = "Global variables processing error.";
        break;
      case 4058:
        text = "Global variable not found.";
        break;
      case 4059:
        text = "Function is not allowed in testing mode.";
        break;
      case 4060:
        text = "Function is not confirmed.";
        break;
      case 4061:
        text = "Send mail error.";
        break;
      case 4062:
        text = "String parameter expected.";
        break;
      case 4063:
        text = "Integer parameter expected.";
        break;
      case 4064:
        text = "Double parameter expected.";
        break;
      case 4065:
        text = "Array as parameter expected.";
        break;
      case 4066:
        text = "Requested history data in update state.";
        break;
      case 4074: /* ERR_NO_MEMORY_FOR_HISTORY */
        text = "No memory for history data.";
        break;
      case 4099:
        text = "End of file.";
        break;
      case 4100:
        text = "Some file error.";
        break;
      case 4101:
        text = "Wrong file name.";
        break;
      case 4102:
        text = "Too many opened files.";
        break;
      case 4103:
        text = "Cannot open file.";
        break;
      case 4104:
        text = "Incompatible access to a file.";
        break;
      case 4105:
        text = "No order selected.";
        break;
      case 4106:
        text = "Unknown symbol.";
        break;
      case 4107:
        text = "Invalid stoploss parameter for trade (OrderSend) function.";
        break;
      case 4108:
        text = "Invalid ticket.";
        break;
      case 4109:
        text = "Trade is not allowed in the expert properties.";
        break;
      case 4110:
        text = "Longs are not allowed in the expert properties.";
        break;
      case 4111:
        text = "Shorts are not allowed in the expert properties.";
        break;
      case 4200:
        text = "Object is already exist.";
        break;
      case 4201:
        text = "Unknown object property.";
        break;
      case 4202:
        text = "Object is not exist.";
        break;
      case 4203:
        text = "Unknown object type.";
        break;
      case 4204:
        text = "No object name.";
        break;
      case 4205:
        text = "Object coordinates error.";
        break;
      case 4206:
        text = "No specified subwindow.";
        break;
      /* Return Codes of the Trade Server */
      // @docs: https://www.mql5.com/en/docs/constants/errorswarnings/enum_trade_return_codes
      default:
        text = "Unknown error.";
    }
    return (text);
  }

  /**
   * Get last error text.
   */
  static string GetLastErrorText() { return GetErrorText(GetLastError()); }

  /**
   * Get text description based on the uninitialization reason code.
   */
  static string GetUninitReasonText(int reasonCode) {
    string text = "";
    switch (reasonCode) {
      case REASON_PROGRAM:  // 0
        text = "EA terminated its operation by calling the ExpertRemove() function.";
        break;
      case REASON_REMOVE:  // 1 (implemented for the indicators only)
        text = string("Program ") + __FILE__ + " has been deleted from the chart.";
        break;
      case REASON_RECOMPILE:  // 2 (implemented for the indicators)
        text = string("Program ") + __FILE__ + " has been recompiled.";
        break;
      case REASON_CHARTCHANGE:  // 3
        text = "Symbol or chart period has been changed.";
        break;
      case REASON_CHARTCLOSE:  // 4
        text = "Chart has been closed.";
        break;
      case REASON_PARAMETERS:  // 5
        text = "Input parameters have been changed by a user.";
        break;
      case REASON_ACCOUNT:  // 6
        text =
            "Another account has been activated or reconnection to the trade server has occurred due to changes in the "
            "account settings.";
        break;
      case REASON_TEMPLATE:  // 7
        text = "  A new template has been applied to chart.";
        break;
      case REASON_INITFAILED:  // 8
        text = "Configuration issue - initialization handler has returned a nonzero value.";
        break;
      case REASON_CLOSE:  // 9
        text = "Terminal has been closed.";
        break;
      default:
        text = "Unknown reason.";
        break;
    }
    return text;
  }

  /**
   * Returns the value of a corresponding property of the terminal.
   *
   * @param ENUM_TERMINAL_INFO_DOUBLE property_id
   *   Identifier of a property.
   *
   * @return double
   * Returns the value of the property.
   *
   * @docs
   * - https://docs.mql4.com/check/terminalinfodouble
   * - https://www.mql5.com/en/docs/check/terminalinfodouble
   *
   */
  static double TerminalInfoDouble(ENUM_TERMINAL_INFO_DOUBLE property_id) {
#ifdef __MQLBUILD__
    return ::TerminalInfoDouble(property_id);
#else
    printf("@fixme: %s\n", "Terminal::TerminalInfoDouble()");
    return 0;
#endif
  }

  /**
   * Returns the value of a corresponding property of the terminal.
   *
   * @param ENUM_TERMINAL_INFO_INTEGER property_id
   *   Identifier of a property.
   *
   * @return int
   * Returns the value of the property.
   *
   * @docs
   * - https://docs.mql4.com/check/terminalinfointeger
   * - https://www.mql5.com/en/docs/check/terminalinfointeger
   *
   */
  static int TerminalInfoInteger(ENUM_TERMINAL_INFO_INTEGER property_id) {
#ifdef __MQLBUILD__
    return ::TerminalInfoInteger(property_id);
#else
    printf("@fixme: %s\n", "Terminal::TerminalInfoInteger()");
    return 0;
#endif
  }

  /**
   * Returns the value of a corresponding property of the terminal.
   *
   * @param ENUM_TERMINAL_INFO_STRING property_id
   *   Identifier of a property.
   *
   * @return string
   * Returns the value of the property.
   *
   * @docs
   * - https://docs.mql4.com/check/terminalinfostring
   * - https://www.mql5.com/en/docs/check/terminalinfostring
   *
   */
  static string TerminalInfoString(ENUM_TERMINAL_INFO_STRING property_id) {
#ifdef __MQLBUILD__
    return ::TerminalInfoString(property_id);
#else
    printf("@fixme: %s\n", "Terminal::TerminalInfoString()");
    return 0;
#endif
  }

  /* Conditions */

  /**
   * Checks for terminal condition.
   *
   * @param ENUM_TERMINAL_CONDITION _cond
   *   Terminal condition.
   * @param MqlParam[] _args
   *   Terminal condition arguments.
   * @return
   *   Returns true when the condition is met.
   */
  bool CheckCondition(ENUM_TERMINAL_CONDITION _cond, ARRAY_REF(DataParamEntry, _args)) {
    long _arg1l = ArraySize(_args) > 0 ? DataParamEntry::ToInteger(_args[0]) : WRONG_VALUE;
    long _arg2l = ArraySize(_args) > 1 ? DataParamEntry::ToInteger(_args[1]) : WRONG_VALUE;
    switch (_cond) {
      case TERMINAL_COND_IS_CONNECTED:
        return !IsConnected();
      default:
        Print(StringFormat("Invalid terminal condition: %s!", EnumToString(_cond), __FUNCTION__));
        return false;
    }
  }
  bool CheckCondition(ENUM_TERMINAL_CONDITION _cond, long _arg1) {
    ARRAY(DataParamEntry, _args);
    DataParamEntry _param1 = _arg1;
    ArrayPushObject(_args, _param1);
    return Terminal::CheckCondition(_cond, _args);
  }
  bool CheckCondition(ENUM_TERMINAL_CONDITION _cond) {
    ARRAY(DataParamEntry, _args);
    return Terminal::CheckCondition(_cond, _args);
  }

  /* Actions */

  /**
   * Execute terminal action.
   *
   * @param ENUM_TERMINAL_ACTION _action
   *   Terminal action to execute.
   * @param MqlParam _args
   *   Terminal action arguments.
   * @return
   *   Returns true when the condition is met.
   */
  bool ExecuteAction(ENUM_TERMINAL_ACTION _action, ARRAY_REF(MqlParam, _args)) {
    long _arg1l = ArraySize(_args) > 0 ? DataParamEntry::ToInteger(_args[0]) : WRONG_VALUE;
    long _arg2l = ArraySize(_args) > 1 ? DataParamEntry::ToInteger(_args[1]) : WRONG_VALUE;
    long _arg3l = ArraySize(_args) > 2 ? DataParamEntry::ToInteger(_args[2]) : WRONG_VALUE;
    switch (_action) {
      case TERMINAL_ACTION_CRASH:
        delete THIS_PTR;
      default:
        Print(StringFormat("Invalid terminal action: %s!", EnumToString(_action), __FUNCTION__));
        return false;
    }
  }
  bool ExecuteAction(ENUM_TERMINAL_ACTION _action) {
    ARRAY(MqlParam, _args);
    return Terminal::ExecuteAction(_action, _args);
  }

  /* Printer methods */

  /**
   * Returns textual representation of the Terminal class.
   */
  string ToString(string _sep = "; ") {
    return StringFormat("Allow DLL: %s", IsDllsAllowed() ? "Yes" : "No") + _sep +
           StringFormat("Allow Libraries: %s", IsLibrariesAllowed() ? "Yes" : "No") + _sep +
           StringFormat("CPUs: %d", GetCpuCores()) + _sep +
           // StringFormat("Community account: %s", (string)HasCommunityAccount()) + _sep +
           // StringFormat("Community balance: %.2f", GetCommunityBalance()) + _sep +
           // StringFormat("Community connection: %s", (string)IsCommunityConnected()) + _sep +
           StringFormat("Disk space: %d", GetDiskSpace()) + _sep +
           StringFormat("Enabled FTP: %s", IsFtpEnabled() ? "Yes" : "No") + _sep +
           StringFormat("Enabled e-mail: %s", IsEmailEnabled() ? "Yes" : "No") + _sep +
           // StringFormat("Enabled notifications: %s", (string)IsNotificationsEnabled()) + _sep +
           StringFormat("IsOptimization: %s", IsOptimization() ? "Yes" : "No") + _sep +
           StringFormat("IsRealtime: %s", IsRealtime() ? "Yes" : "No") + _sep +
           StringFormat("IsTesting: %s", IsTesting() ? "Yes" : "No") + _sep +
           StringFormat("IsVisual: %s", IsVisualMode() ? "Yes" : "No") + _sep +
           // StringFormat("MQ ID: %s", (string)HasMetaQuotesId()) + _sep +
           StringFormat("Memory (free): %d", GetFreeMemory()) + _sep +
           StringFormat("Memory (physical): %d", GetPhysicalMemory()) + _sep +
           StringFormat("Memory (total): %d", GetTotalMemory()) + _sep +
           StringFormat("Memory (used): %d", GetUsedMemory()) + _sep +
           StringFormat("Path (Common): %s", GetCommonPath()) + _sep + StringFormat("Path (Data): %s", GetDataPath()) +
           _sep + StringFormat("Path (Expert): %s", GetExpertPath()) + _sep +
           StringFormat("Path (Terminal): %s", GetTerminalPath()) + _sep +
           StringFormat("Program name: %s", WindowExpertName()) + _sep +
           StringFormat("Screen DPI: %d", GetScreenDpi()) + _sep + StringFormat("Terminal build: %d", GetBuild()) +
           _sep + StringFormat("Terminal code page: %d", IntegerToString(GetCodePage())) + _sep +
           StringFormat("Terminal company: %s", GetCompany()) + _sep +
           StringFormat("Terminal connected: %s", IsConnected() ? "Yes" : "No") + _sep +
           StringFormat("Terminal language: %s", GetLanguage()) + _sep + StringFormat("Terminal name: %s", GetName()) +
           _sep + StringFormat("Termnal max bars: %d", GetMaxBars()) + _sep +
           StringFormat("Trade allowed: %s", IsTradeAllowed() ? "Yes" : "No") + _sep +
           StringFormat("Trade context busy: %s", IsTradeContextBusy() ? "Yes" : "No") + _sep +
           StringFormat("Trade perm: %s", CheckPermissionToTrade() ? "Yes" : "No") + _sep +
           StringFormat("Trade ping (last): %d", GetPingLast());
  }
};

// Defines macros (for MQL4 backward compatibility).
#ifndef __MQL4__
// @docs: https://docs.mql4.com/chart_operations/windowexpertname
string WindowExpertName(void) { return Terminal::WindowExpertName(); }
#endif

#endif  // TERMINAL_MQH
