//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
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

// Properties.
#property strict

/**
 * @file
 * Class to provide methods for state checking of the client terminal.
 *
 * @docs
 * - https://docs.mql4.com/chart_operations/chartredraw
 * - https://www.mql5.com/en/docs/chart_operations
 */

/*
 * Class to provide functions that return parameters of the current terminal.
 */
class Terminal {
public:

  /**
   * Returns terminal name.
   */
  static string GetName() {
    return TerminalInfoString(TERMINAL_NAME);
  }

  /**
   * Returns folder from which the terminal is started.
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

  /**
   * Returns language of the terminal
   */
  static string GetLanguage() {
    return TerminalInfoString(TERMINAL_LANGUAGE);
  }

  /**
   * Returns company name.
   */
  static string GetCompany() {
    return TerminalInfoString(TERMINAL_COMPANY);
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

// GetLastError
// IsStopped
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
// IsConnected

  /**
   * Indicates the permission to use DLL files.
   */
  static bool IsDllsAllowed() {
    return MQLInfoInteger(MQL_DLLS_ALLOWED);
  }

  /**
   * Indicates the permission to use external libraries (such as DLL).
   */
  static bool IsLibrariesAllowed() {
    return (bool) MQLInfoInteger(MQL_DLLS_ALLOWED);
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
   * Returns the name of company owning the client terminal.
   */
  static string TerminalCompany() {
    return TerminalInfoString(TERMINAL_COMPANY);
  }

  /**
   * Returns the client terminal name.
   */
  static string TerminalName() {
    return TerminalInfoString(TERMINAL_NAME);
  }

  /**
   * Returns the current working directory.
   *
   * Usually the directory where the client terminal was launched.
   */
  static string TerminalPath() {
    return TerminalInfoString(TERMINAL_PATH);
  }

/*
// @todo:

  TerminalInfoInteger identifiers:

  TERMINAL_BUILD
  The client terminal build number
  int
  TERMINAL_COMMUNITY_ACCOUNT
  The flag indicates the presence of MQL5.community authorization data in the terminal
  bool
  TERMINAL_COMMUNITY_CONNECTION
  Connection to MQL5.community
  bool
  TERMINAL_CONNECTED
  Connection to a trade server
  bool
  TERMINAL_EMAIL_ENABLED
  Permission to send e-mails using SMTP-server and login, specified in the terminal settings
  bool
  TERMINAL_FTP_ENABLED
  Permission to send reports using FTP-server and login, specified in the terminal settings
  bool
  TERMINAL_NOTIFICATIONS_ENABLED
  Permission to send notifications to smartphone
  bool
  TERMINAL_MAXBARS
  The maximal bars count on the chart
  int
  TERMINAL_MQID
  The flag indicates the presence of MetaQuotes ID data to send Push notifications
  bool
  TERMINAL_CODEPAGE
  Number of the code page of the language installed in the client terminal
  int
  TERMINAL_CPU_CORES
  The number of CPU cores in the system
  int
  TERMINAL_DISK_SPACE
  Free disk space for the MQL4\Files folder of the terminal, Mb
  int
  TERMINAL_MEMORY_PHYSICAL
  Physical memory in the system, Mb
  int
  TERMINAL_MEMORY_TOTAL
  Memory available to the process of the terminal , Mb
  int
  TERMINAL_MEMORY_AVAILABLE
  Free memory of the terminal process, Mb
  int
  TERMINAL_MEMORY_USED
  Memory used by the terminal , Mb
  int
  TERMINAL_SCREEN_DPI
  The resolution of information display on the screen is measured as number of Dots in a line per Inch (DPI).
  Knowing the parameter value, you can set the size of graphical objects so that they look the same on monitors with different resolution characteristics.
  int
  TERMINAL_PING_LAST
  The last known value of a ping to a trade server in microseconds. One second comprises of one million microseconds
  int

*/

};
