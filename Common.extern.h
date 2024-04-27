//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
#include "Chart.enum.h"
#include "DateTime.enum.h"

extern void DebugBreak();
// Errors.
extern void SetUserError(unsigned short user_error);
// Exceptions.
extern int NotImplementedException();
// Print-related functions.
template <typename... Args>
extern std::string StringFormat(const std::string& format, Args... args);

template <typename... Args>
extern std::string PrintFormat(const std::string& format, Args... args);

template <typename... Args>
extern void Print(Args... args);

template <typename... Args>
extern void Alert(Args... args);

#endif
