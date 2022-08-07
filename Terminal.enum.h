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
 * Includes Terminal's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Indicator/Indicator.define.h"

// Defines user error enumeration.
enum ENUM_USER_ERR { USER_ERR_INVALID_ARGUMENT };

// Terminal actions.
enum ENUM_TERMINAL_ACTION { TERMINAL_ACTION_CRASH, FINAL_ENUM_TERMINAL_ACTION };

// Terminal conditions.
enum ENUM_TERMINAL_CONDITION { TERMINAL_COND_IS_CONNECTED, FINAL_ENUM_TERMINAL_CONDITION_ENTRY };

#ifndef __MQL__
/**
 * Enumeration for the return codes.
 * @docs
 * https://www.mql5.com/en/docs/basis/function/events
 */
enum ENUM_INIT_RETCODE {
  INIT_SUCCEEDED = 0,         // Successful initialization.
  INIT_FAILED = 1,            // Initialization failed.
  INIT_PARAMETERS_INCORRECT,  // Incorrect set of input parameters.
  INIT_AGENT_NOT_SUITABLE,    // The agent is not suitable for testing.
};
#endif

#ifndef __MQL__

/**
 * Enumeration for the MQL program properties (integer type).
 *
 * @docs
 * - https://www.mql5.com/en/docs/constants/environment_state/mql5_programm_info
 */
enum ENUM_MQL_INFO_INTEGER {
  MQL_DEBUG,            // Indication that the program is running in the debugging mode (bool).
  MQL_DLLS_ALLOWED,     // The permission to use DLL for the given running program (bool).
  MQL_FORWARD,          // Indication that the program is running in the forward testing process (bool).
  MQL_FRAME_MODE,       // Indication that the program is running in gathering optimization result frames mode (bool).
  MQL_LICENSE_TYPE,     // Type of license of the EX module.
  MQL_MEMORY_LIMIT,     // Maximum possible amount of dynamic memory for MQL5 program in MB (int).
  MQL_MEMORY_USED,      // Memory used by MQL5 program in MB (int).
  MQL_OPTIMIZATION,     // Indication that the program is running in the optimization mode (bool).
  MQL_PROFILER,         // Indication that the program is running in the code profiling mode (bool).
  MQL_PROGRAM_TYPE,     // Type of the MQL5 program (ENUM_PROGRAM_TYPE).
  MQL_SIGNALS_ALLOWED,  // The permission to modify the Signals for the given running program (bool).
  MQL_TESTER,           // Indication that the program is running in the tester (bool).
  MQL_TRADE_ALLOWED,    // The permission to trade for the given running program (bool).
  MQL_VISUAL_MODE,      // Indication that the program is running in the visual testing mode (bool).
};

/**
 * Enumeration for the MQL program properties (string type).
 *
 * @docs
 * - https://www.mql5.com/en/docs/constants/environment_state/mql5_programm_info
 */
enum ENUM_MQL_INFO_STRING {
  MQL_PROGRAM_NAME,   // Name of the running mql5-program (string).
  MQL5_PROGRAM_PATH,  // Path for the given running program (string).
};

/**
 * Enumeration for the Terminal properties (double).
 *
 * @docs
 * - https://docs.mql4.com/constants/environment_state/terminalstatus
 * - https://www.mql5.com/en/docs/constants/environment_state/terminalstatus
 */
enum ENUM_TERMINAL_INFO_DOUBLE {
  TERMINAL_COMMUNITY_BALANCE = 0,  // Balance in community account (double).
  TERMINAL_RETRANSMISSION,         // Percentage of resent network packets in the TCP/IP protocol.
};

/**
 * Enumeration for the Terminal properties (integer).
 *
 * @docs
 * - https://docs.mql4.com/constants/environment_state/terminalstatus
 * - https://www.mql5.com/en/docs/constants/environment_state/terminalstatus
 */
enum ENUM_TERMINAL_INFO_INTEGER {
  TERMINAL_BOTTOM,                 // The bottom coordinate of the terminal relative to the virtual screen (int).
  TERMINAL_BUILD,                  // The client terminal build number (int).
  TERMINAL_CODEPAGE,               // Number of the code page of the language installed in the client terminal (int).
  TERMINAL_COMMUNITY_ACCOUNT,      // The flag indicates the presence of community account authorization data (bool).
  TERMINAL_COMMUNITY_CONNECTION,   // Connection to community account (bool).
  TERMINAL_CONNECTED,              // Connection to a trade server (bool).
  TERMINAL_CPU_CORES,              // The number of CPU cores in the system (int).
  TERMINAL_DISK_SPACE,             // Free disk space (in MB) for the MQL Files folder of the terminal (agent).
  TERMINAL_DLLS_ALLOWED,           // Permission to use DLL (bool).
  TERMINAL_EMAIL_ENABLED,          // Permission to send e-mails using SMTP-server and login (bool).
  TERMINAL_FTP_ENABLED,            // Permission to send reports using FTP-server and login (bool).
  TERMINAL_KEYSTATE_CAPSLOCK,      // State of the "CapsLock" key (int).
  TERMINAL_KEYSTATE_CONTROL,       // State of the "Ctrl" key (int).
  TERMINAL_KEYSTATE_DELETE,        // State of the "Delete" key (int).
  TERMINAL_KEYSTATE_DOWN,          // State of the "Down arrow" key (int).
  TERMINAL_KEYSTATE_END,           // State of the "End" key (int).
  TERMINAL_KEYSTATE_ENTER,         // State of the "Enter" key (int).
  TERMINAL_KEYSTATE_ESCAPE,        // State of the "Escape" key (int).
  TERMINAL_KEYSTATE_HOME,          // State of the "Home" key (int).
  TERMINAL_KEYSTATE_INSERT,        // State of the "Insert" key (int).
  TERMINAL_KEYSTATE_LEFT,          // State of the "Left arrow" key (int).
  TERMINAL_KEYSTATE_MENU,          // State of the "Windows" key (int).
  TERMINAL_KEYSTATE_NUMLOCK,       // State of the "NumLock" key (int).
  TERMINAL_KEYSTATE_PAGEDOWN,      // State of the "PageDown" key (int).
  TERMINAL_KEYSTATE_PAGEUP,        // State of the "PageUp" key (int).
  TERMINAL_KEYSTATE_RIGHT,         // State of the "Right arrow" key (int).
  TERMINAL_KEYSTATE_SCRLOCK,       // State of the "ScrollLock" key (int).
  TERMINAL_KEYSTATE_SHIFT,         // State of the "Shift" key (int).
  TERMINAL_KEYSTATE_TAB,           // State of the "Tab" key (int).
  TERMINAL_KEYSTATE_UP,            // State of the "Up arrow" key (int).
  TERMINAL_LEFT,                   // The left coordinate of the terminal relative to the virtual screen (int).
  TERMINAL_MAXBARS,                // The maximal bars count on the chart (int).
  TERMINAL_MEMORY_AVAILABLE,       // Free memory of the terminal (agent) process, MB (int).
  TERMINAL_MEMORY_PHYSICAL,        // Physical memory in the system, MB (int).
  TERMINAL_MEMORY_TOTAL,           // Memory available (in MB) to the process of the terminal (agent) (int).
  TERMINAL_MEMORY_USED,            // Memory used by the terminal (agent), MB (int).
  TERMINAL_MQID,                   // The flag indicates the presence of MQL ID data for Push notifications (bool).
  TERMINAL_NOTIFICATIONS_ENABLED,  // Permission to send notifications to smartphone (bool).
  TERMINAL_OPENCL_SUPPORT,         // The version of the supported OpenCL (int).
  TERMINAL_PING_LAST,              // The last known value of a ping (in micro ms) to a trade server in microseconds.
  TERMINAL_RIGHT,                  // The right coordinate of the terminal relative to the virtual screen (int).
  TERMINAL_SCREEN_DPI,             // The resolution of information display on the screen (DPI) (int).
  TERMINAL_SCREEN_HEIGHT,          // Terminal height (int).
  TERMINAL_SCREEN_LEFT,            // The left coordinate of the virtual screen (int).
  TERMINAL_SCREEN_TOP,             // The top coordinate of the virtual screen (int).
  TERMINAL_SCREEN_WIDTH,           // Terminal width (int).
  TERMINAL_TOP,                    // The top coordinate of the terminal relative to the virtual screen (int).
  TERMINAL_TRADE_ALLOWED,          // Permission to trade (bool).
  TERMINAL_VPS,                    // Indication that the terminal is launched on the VPS (bool).
  TERMINAL_X64,                    // Indication of the "64-bit terminal" (bool).
};

/**
 * Enumeration for the Terminal properties (string).
 *
 * @docs
 * - https://docs.mql4.com/constants/environment_state/terminalstatus
 * - https://www.mql5.com/en/docs/constants/environment_state/terminalstatus
 */
enum ENUM_TERMINAL_INFO_STRING {
  TERMINAL_COMMONDATA_PATH,  // Common path for all of the terminals installed on a computer (string).
  TERMINAL_COMPANY,          // Company name (string).
  TERMINAL_DATA_PATH,        // Folder in which terminal data are stored (string).
  TERMINAL_LANGUAGE,         // Language of the terminal (string).
  TERMINAL_NAME,             // Terminal name (string).
  TERMINAL_PATH,             // Folder from which the terminal is started (string).
};

/**
 * Uninitialization reason codes are returned by the UninitializeReason() function.
 *
 * @docs
 * - https://www.mql5.com/en/docs/constants/namedconstants/uninit
 */
enum ENUM_UNINIT_REASON {
  REASON_PROGRAM = 0,
  REASON_REMOVE = 1,
  REASON_RECOMPILE = 2,
  REASON_CHARTCHANGE = 3,
  REASON_CHARTCLOSE = 4,
  REASON_PARAMETERS = 5,
  REASON_ACCOUNT = 6,
  REASON_TEMPLATE = 7,
  REASON_INITFAILED = 8,
  REASON_CLOSE = 9,
};
#endif
