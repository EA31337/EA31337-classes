//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of Terminal class.
 */

// Includes.
#include "../Convert.mqh"
#include "../Terminal.mqh"
#include "../Test.mqh"

// Variables.
Terminal *terminal;

/**
 * Implements OnInit().
 */
int OnInit() {
  terminal = new Terminal();
  Print("TERMINAL (OnInit):\n\t\t\t", terminal.ToString("\n\t\t\t"));
  assertTrueOrFail(terminal.IsDllsAllowed(), "DLLs not allowed!");
  assertTrueOrFail(terminal.IsExpertEnabled(), "Expert Advisors not allowed!");
  assertTrueOrFail(terminal.IsLibrariesAllowed(), "Libraries not allowed!");
  assertTrueOrFail(terminal.GetCpuCores() >= 1, "Invalid CPUs!");
  assertTrueOrFail(terminal.GetDiskSpace() >= 1, "Empty disk space");
  assertFalseOrFail(terminal.IsOptimization(), "In optimization mode?!");
  assertTrueOrFail(terminal.IsRealtime(), "Not in realtime?!");
  assertFalseOrFail(terminal.IsTesting(), "In testing mode?!");
  assertFalseOrFail(terminal.IsVisualMode(), "In visual mode?!");
  assertTrueOrFail(terminal.GetFreeMemory() >= 0, "Invalid free memory!");
  assertTrueOrFail(terminal.GetPhysicalMemory() >= 0, "Invalid physical memory!");
  assertTrueOrFail(terminal.GetTotalMemory() >= 0, "Invalid total memory!");
  // assertTrueOrFail(terminal.GetUsedMemory() >= 0, "Invalid used memory!");
  assertTrueOrFail(StringLen(terminal.GetCommonPath()) > 10, "Invalid common path?!");
  assertTrueOrFail(StringLen(terminal.GetDataPath()) > 10, "Invalid data path?!");
  assertTrueOrFail(StringLen(terminal.GetExpertPath()) > 10, "Invalid Expert path?!");
  assertTrueOrFail(StringLen(terminal.GetTerminalPath()) > 10, "Invalid Terminal path?!");
  assertTrueOrFail(Terminal::WindowExpertName() == "TerminalTest", "Invalid EA name!");
  assertTrueOrFail(terminal.GetScreenDpi() >= 0, "Invalid screen DPI?!");
  assertTrueOrFail(terminal.GetBuild() >= 1000, "Invalid Terminal build?!");
  assertTrueOrFail(terminal.GetCodePage() >= 0, "Invalid code page?!");
  assertTrueOrFail(StringLen(terminal.GetCompany()) > 10, "Invalid company name?!");
  assertTrueOrFail(terminal.GetLanguage() == "English", "Invalid language?!");
  assertTrueOrFail(terminal.GetMaxBars() > 0, "Invalid max bars?!");
  assertTrueOrFail(terminal.IsTradeAllowed(), "Trade not allowed!");
  assertFalseOrFail(terminal.IsTradeContextBusy(), "Trade context busy?!");
  // assertTrueOrFail(terminal.CheckPermissionToTrade(), "Not permitted to trade?!");
  assertTrueOrFail(terminal.GetPingLast() >= 0, "Invalid ping?!");
  return (INIT_SUCCEEDED);
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  Print("TERMINAL (OnDeinit):\n\t\t\t", terminal.ToString("\n\t\t\t"));
  Object::Delete(terminal);
}
