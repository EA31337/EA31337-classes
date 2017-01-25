//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
   This file is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Class to provide methods for state checking of the client terminal.
 *
 * @docs
 * - https://docs.mql4.com/chart_operations/chartredraw
 * - https://www.mql5.com/en/docs/chart_operations
 */

// Properties.
#property strict

// Forward declaration.
class Log;
class Terminal;

// Includes.
#include "DateTime.mqh"
#include "Log.mqh"
#include "MQL4.mqh"
#include "MQL5.mqh"

/**
 * Class to provide functions that return parameters of the current terminal.
 */
class Terminal {

  protected:

    // Class variables.
    Log *logger;

  public:

    /**
     * Class constructor.
     */
    void Terminal(Log *_logger = NULL)
      : logger(_logger != NULL ? _logger : new Log)
      {
      }

    /**
     * Class deconstructor.
     */
    void ~Terminal() {
      delete logger;
    }

    /* Client Terminal property getters */

    /**
     * The client terminal build number.
     */
    static int GetBuild() {
      return TerminalInfoInteger(TERMINAL_BUILD);
    }

    /**
     * Name of the program executed.
     */
    string WindowExpertName(void) {
      return(::MQLInfoString(::MQL_PROGRAM_NAME));
    }

    /**
     * Indicates the tester process.
     *
     * Checks if the Expert Advisor runs in the testing mode.
     */
    static bool IsTesting() {
      return #ifdef __MQL4__ ::IsTesting(); #else MQLInfoInteger(MQL_TESTER); #endif
    }

    /**
     * Indicates the optimization process.
     *
     * Checks if Expert Advisor runs in the Strategy Tester optimization mode.
     */
    static bool IsOptimization() {
      return #ifdef __MQL4__ ::IsOptimization(); #else MQLInfoInteger(MQL_OPTIMIZATION); #endif
    }

    /**
     * Checks if the Expert Advisor is tested in visual mode.
     */
    static bool IsVisualMode() {
      return #ifdef __MQL4__ ::IsVisualMode(); #else MQLInfoInteger(MQL_VISUAL_MODE); #endif
    }

    /**
     * Checks if the Expert Advisor is tested for real time mode
     * outside of the Strategy Tester.
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
    static int GetLastError() {
      return GetLastError();
    }

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
    static bool isStopped() {
      return IsStopped();
    }

    // UninitializeReason
    // MQLInfoInteger
    // MQLInfoString
    // MQLSetInteger
    // TerminalInfoInteger
    // TerminalInfoDouble
    // TerminalInfoString
    // Symbol
    // Period
    // Digits
    // Point

    /**
     * Indicates the permission to use DLL files.
     */
    static bool IsDllsAllowed() {
      return TerminalInfoInteger(TERMINAL_DLLS_ALLOWED) && MQLInfoInteger(MQL_DLLS_ALLOWED);
    }

    /**
     * Indicates the permission to use external libraries (such as DLL).
     */
    static bool IsLibrariesAllowed() {
      return TerminalInfoInteger(TERMINAL_DLLS_ALLOWED) && MQLInfoInteger(MQL_DLLS_ALLOWED);
    }

    /**
     * Indicates the permission to trade.
     */
    static bool IsTradeAllowed() {
      return (bool) MQLInfoInteger(MQL_TRADE_ALLOWED) && (bool) TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
    }

    /**
     * Indicates the permission to trade.
     */
    static bool IsTradeContextBusy() {
      #ifdef __MQL4__
      // In MQL4, returns true if a tread for trading
      // is occupied by another Expert Advisor.
      return ::IsTradeContextBusy();
      #else // __MQL5__
      // In MQL5 there is no equivalent function,
      // so checks only the permission to trade.
      return (bool) TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
      #endif
    }

    /**
     * The flag indicates the presence of MQL5.community authorization data in the terminal.
     */
    static bool HasCommunityAccount() {
      return TerminalInfoInteger(TERMINAL_COMMUNITY_ACCOUNT);
    }

    /**
     * Check connection to MQL5 community.
     */
    static bool IsCommunityConnected() {
      return TerminalInfoInteger(TERMINAL_COMMUNITY_CONNECTION);
    }

    /**
     * Get MQL5 community balance.
     */
    static double GetCommunityBalance() {
      return TerminalInfoDouble(TERMINAL_COMMUNITY_BALANCE);
    }

    /**
     * Checks connection to a trade server.
     *
     * @see
     * - https://docs.mql4.com/check/isconnected
     * - https://www.mql5.com/en/docs/constants/environment_state/terminalstatus
     */
    static double IsConnected() {
      return TerminalInfoInteger(TERMINAL_CONNECTED);
    }

    /**
     * Permission to send e-mails using SMTP-server and login, specified in the terminal settings.
     */
    static bool IsEmailEnabled() {
      return TerminalInfoInteger(TERMINAL_EMAIL_ENABLED);
    }

    /**
     * Permission to send reports using FTP-server and login, specified in the terminal settings.
     */
    static bool IsFtpEnabled() {
      return TerminalInfoInteger(TERMINAL_FTP_ENABLED);
    }

    /**
     * Permission to send notifications to smartphone.
     */
    static bool IsNotificationsEnabled() {
      return TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED);
    }

    /**
     * The maximal bars count on the chart.
     */
    static int GetMaxBars() {
      return TerminalInfoInteger(TERMINAL_MAXBARS);
    }

    /**
     * The flag indicates the presence of MetaQuotes ID data to send Push notifications.
     */
    static bool HasMetaQuotesId() {
      return TerminalInfoInteger(TERMINAL_MQID);
    }

    /**
     * Number of the code page of the language installed in the client terminal.
     *
     * @see
     * - https://www.mql5.com/en/docs/constants/io_constants/codepageusage
     */
    static int GetCodePage() {
      return TerminalInfoInteger(TERMINAL_CODEPAGE);
    }

    /**
     * The number of CPU cores in the system.
     */
    static int GetCpuCores() {
      return TerminalInfoInteger(TERMINAL_CPU_CORES);
    }

    /**
     * Free disk space for the Files folder of the terminal in Mb.
     */
    static int GetDiskSpace() {
      return TerminalInfoInteger(TERMINAL_DISK_SPACE);
    }

    /**
     * Physical memory in the system in Mb.
     */
    static int GetPhysicalMemory() {
      return TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL);
    }

    /**
     * Memory available to the process of the terminal in Mb.
     */
    static int GetTotalMemory() {
      return TerminalInfoInteger(TERMINAL_MEMORY_TOTAL);
    }

    /**
     * Free memory of the terminal process in Mb.
     */
    static int GetFreeMemory() {
      return TerminalInfoInteger(TERMINAL_MEMORY_AVAILABLE);
    }

    /**
     * Memory used by the terminal in Mb.
     */
    static int GetUsedMemory() {
      return TerminalInfoInteger(TERMINAL_MEMORY_USED);
    }

    /**
     * The resolution of information display on the screen.
     *
     * It is measured as number of Dots in a line per Inch (DPI).
     * Knowing the parameter value, you can set the size of graphical objects,
     * so that they look the same on monitors with different resolution characteristics.
     */
    static int GetScreenDpi() {
      return TerminalInfoInteger(TERMINAL_SCREEN_DPI);
    }

    /**
     * The last known value of a ping to a trade server in microseconds.
     *
     * One second comprises of one million microseconds.
     */
    static int GetPingLast() {
      return TerminalInfoInteger(TERMINAL_PING_LAST);
    }

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
    static string GetLanguage() {
      return TerminalInfoString(TERMINAL_LANGUAGE);
    }

    /**
     * Returns the name of company owning the client terminal.
     */
    static string GetCompany() {
      return TerminalInfoString(TERMINAL_COMPANY);
    }

    /**
     * Returns the client terminal name.
     */
    static string GetName() {
      return TerminalInfoString(TERMINAL_NAME);
    }

    /**
     * Returns the current working directory.
     *
     * It is usually the directory where the client terminal was launched.
     */
    static string GetPath() {
      return TerminalInfoString(TERMINAL_PATH);
    }

    /**
     * Returns folder in which terminal data are stored.
     */
    static string GetDataPath() {
      return TerminalInfoString(TERMINAL_DATA_PATH);
    }

    /**
     * Returns common path for all of the terminals installed on a computer.
     */
    static string GetCommonPath() {
      return TerminalInfoString(TERMINAL_COMMONDATA_PATH);
    }

    /**
     * Returns folder in which expert files are stored.
     */
    static string GetExpertPath() {
      return GetDataPath() + "\\MQL" + #ifdef __MQL4__ "4" #else "5" #endif + "\\Experts";
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
      bool live = false;

      switch (code) {
        case   0: text = "No error returned."; break;
        case   1: text = "No error returned, but the result is unknown."; break;
        case   2: text = "Common error."; break;
        case   3: text = "Invalid trade parameters."; break;
        case   4: text = "Trade server is busy."; break;
        case   5: text = "Old version of the client terminal,"; break;
        case   6: text = "No connection with trade server."; break;
        case   7: text = "Not enough rights."; break;
        case   8: text = "Too frequent requests."; live = true; break;
        case   9: text = "Malfunctional trade operation (never returned error)."; break;
        case   64: text = "Account disabled."; break;
        case   65: text = "Invalid account."; break;
        case  128: text = "Trade timeout."; live = true; break;
        case  129: text = "Invalid price."; break;
        case  130: text = "Invalid stops."; break;
        case  131: text = "Invalid trade volume."; break;
        case  132: text = "Market is closed."; break;
        case  133: text = "Trade is disabled."; break;
        case  134: text = "Not enough money."; break;
        case  135: text = "Price changed."; live = true; break;
        // --
        // ERR_OFF_QUOTES
        //   1. Off Quotes may be a technical issue.
        //   2. Off Quotes may be due to unsupported orders.
        //      - Trying to partially close a position. For example, attempting to close 0.10 (10k) of a 20k position.
        //      - Placing a micro lot trade. For example, attempting to place a 0.01 (1k) volume trade.
        //      - Placing a trade that is not in increments of 0.10 (10k) volume. For example, attempting to place a 0.77 (77k) trade.
        //      - Adding a stop or limit to a market order before the order executes. For example, setting an EA to place a 0.1 volume (10k) buy market order with a stop loss of 50 pips.
        case  136: text = "Off quotes."; live = true; break;
        case  137: text = "Broker is busy (never returned error)."; live = true; break;
        case  138: text = "Requote."; live = true; break;
        case  139: text = "Order is locked."; break;
        case  140: text = "Long positions only allowed."; break;
        case  141: /* ERR_TOO_MANY_REQUESTS */ text = "Too many requests."; live = true; break;
        case  145: text = "Modification denied because order too close to market."; break;
        case  146: text = "Trade context is busy."; break;
        case  147: text = "Expirations are denied by broker."; break;
                   // ERR_TRADE_TOO_MANY_ORDERS: On some trade servers, the total amount of open and pending orders can be limited. If this limit has been exceeded, no new position will be opened
        case  148: text = "Amount of open and pending orders has reached the limit set by the broker"; break; // ERR_TRADE_TOO_MANY_ORDERS
        case  149: text = "An attempt to open an order opposite to the existing one when hedging is disabled"; break; // ERR_TRADE_HEDGE_PROHIBITED
        case  150: text = "An attempt to close an order contravening the FIFO rule."; break; // ERR_TRADE_PROHIBITED_BY_FIFO
        case 4000: text = "No error (never generated code)."; break;
        case 4001: text = "Wrong function pointer."; break;
        case 4002: text = "Array index is out of range."; break;
        case 4003: text = "No memory for function call stack."; break;
        case 4004: text = "Recursive stack overflow."; break;
        case 4005: text = "Not enough stack for parameter."; break;
        case 4006: text = "No memory for parameter string."; break;
        case 4007: text = "No memory for temp string."; break;
        case 4008: text = "Not initialized string."; break;
        case 4009: text = "Not initialized string in array."; break;
        case 4010: text = "No memory for array\' string."; break;
        case 4011: text = "Too long string."; break;
        case 4012: text = "Remainder from zero divide."; break;
        case 4013: text = "Zero divide."; break;
        case 4014: text = "Unknown command."; break;
        case 4015: text = "Wrong jump (never generated error)."; break;
        case 4016: text = "Not initialized array."; break;
        case 4017: text = "Dll calls are not allowed."; break;
        case 4018: text = "Cannot load library."; break;
        case 4019: text = "Cannot call function."; break;
        case 4020: text = "Expert function calls are not allowed."; break;
        case 4021: text = "Not enough memory for temp string returned from function."; break;
        case 4022: text = "System is busy (never generated error)."; break;
        case 4050: text = "Invalid function parameters count."; break;
        case 4051: text = "Invalid function parameter value."; break;
        case 4052: text = "String function internal error."; break;
        case 4053: text = "Some array error."; break;
        case 4054: text = "Incorrect series array using."; break;
        case 4055: text = "Custom indicator error."; break;
        case 4056: text = "Array are incompatible."; break;
        case 4057: text = "Global variables processing error."; break;
        case 4058: text = "Global variable not found."; break;
        case 4059: text = "Function is not allowed in testing mode."; break;
        case 4060: text = "Function is not confirmed."; break;
        case 4061: text = "Send mail error."; break;
        case 4062: text = "String parameter expected."; break;
        case 4063: text = "Integer parameter expected."; break;
        case 4064: text = "Double parameter expected."; break;
        case 4065: text = "Array as parameter expected."; break;
        case 4066: text = "Requested history data in update state."; break;
        case 4074: /* ERR_NO_MEMORY_FOR_HISTORY */ text = "No memory for history data."; break;
        case 4099: text = "End of file."; break;
        case 4100: text = "Some file error."; break;
        case 4101: text = "Wrong file name."; break;
        case 4102: text = "Too many opened files."; break;
        case 4103: text = "Cannot open file."; break;
        case 4104: text = "Incompatible access to a file."; break;
        case 4105: text = "No order selected."; break;
        case 4106: text = "Unknown symbol."; break;
        case 4107: text = "Invalid stoploss parameter for trade (OrderSend) function."; break;
        case 4108: text = "Invalid ticket."; break;
        case 4109: text = "Trade is not allowed in the expert properties."; break;
        case 4110: text = "Longs are not allowed in the expert properties."; break;
        case 4111: text = "Shorts are not allowed in the expert properties."; break;
        case 4200: text = "Object is already exist."; break;
        case 4201: text = "Unknown object property."; break;
        case 4202: text = "Object is not exist."; break;
        case 4203: text = "Unknown object type."; break;
        case 4204: text = "No object name."; break;
        case 4205: text = "Object coordinates error."; break;
        case 4206: text = "No specified subwindow."; break;
        default:  text = "Unknown error.";
      }
      #ifdef __backtest__ if (live) { ExpertRemove(); } #endif
      return (text);
    }

    /**
     * Get text description based on the uninitialization reason code.
     */
    static string GetUninitReasonText(int reasonCode) {
      string text = "";
      switch(reasonCode) {
        case REASON_PROGRAM: // 0
          text = "EA terminated its operation by calling the ExpertRemove() function.";
          break;
        case REASON_REMOVE: // 1 (implemented for the indicators only)
          text = "Program " + __FILE__ + " has been deleted from the chart.";
          break;
        case REASON_RECOMPILE: // 2 (implemented for the indicators)
          text = "Program " + __FILE__ + " has been recompiled.";
          break;
        case REASON_CHARTCHANGE: // 3
          text = "Symbol or chart period has been changed.";
          break;
        case REASON_CHARTCLOSE: // 4
          text = "Chart has been closed.";
          break;
        case REASON_PARAMETERS: // 5
          text = "Input parameters have been changed by a user.";
          break;
        case REASON_ACCOUNT: // 6
          text = "Another account has been activated or reconnection to the trade server has occurred due to changes in the account settings.";
          break;
        case REASON_TEMPLATE: // 7
          text = "  A new template has been applied to chart.";
          break;
        case REASON_INITFAILED: // 8
          text = "Configuration issue - initialization handler has returned a nonzero value.";
          break;
        case REASON_CLOSE: // 9
          text = "Terminal has been closed.";
          break;
        default:
          text = "Unknown reason.";
          break;
      }
      return text;
    }

};
