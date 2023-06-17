//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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

// Define external global functions.
#ifndef __MQL__
#pragma once
#include <csignal>
#include <string>

#include "Chart.enum.h"
#include "Storage/DateTime.enum.h"
#include "Platform/Terminal.define.h"

void DebugBreak() {
#ifdef _MSC_VER
  // @see https://learn.microsoft.com/en-us/cpp/intrinsics/debugbreak?view=msvc-170
  __debugbreak();
#else
  raise(SIGTRAP);
#endif
}

int _LastError = 0;

// Errors.
void SetUserError(unsigned short user_error) { _LastError = ERR_USER_ERROR_FIRST + user_error; }
// Exceptions.
extern int NotImplementedException();
// Print-related functions.

#endif
