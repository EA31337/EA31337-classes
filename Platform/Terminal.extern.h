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

// Define external global functions.
#ifndef __MQL__
#pragma once

// Includes.
#include "../Storage/String.h"
#include "Terminal.define.h"
#include "Terminal.enum.h"

extern int GetLastError();
extern string TerminalInfoString(int property_id);
extern void ResetLastError();
string MQLInfoString(int property_id) {
  switch (property_id) {
    case MQL_PROGRAM_NAME:
      return "EA";
    case MQL_PROGRAM_PATH:
      return "";
  }
  return "";
}

int MQLInfoInteger(int property_id) {
  switch (property_id) {
    case MQL_CODEPAGE:
      return CP_ACP;
    case MQL_PROGRAM_TYPE:
      return PROGRAM_EXPERT;
    case MQL_DLLS_ALLOWED:
      return false;
    case MQL_TRADE_ALLOWED:
      return true;
    case MQL_SIGNALS_ALLOWED:
      return true;
    case MQL_DEBUG:
      return true;
    case MQL_PROFILER:
      return false;
    case MQL_TESTER:
      return true;
    case MQL_OPTIMIZATION:
      return true;
    case MQL_VISUAL_MODE:
      return false;
    case MQL_FRAME_MODE:
      return false;
    case MQL_LICENSE_TYPE:
      return LICENSE_FREE;
  }
  return -1;
}

bool _StopFlag = false;

bool IsStopped() { return _StopFlag; }

#endif
