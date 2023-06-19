//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

// Prevents processing this includes file for the second time.
#ifndef __MQL__
#pragma once

// Includes.
#include <cmath>
#include <sstream>

#include "Storage/String.h"

// Define external global functions.
double NormalizeDouble(double value, int digits) { return std::round(value / digits) * digits; }

string CharToString(unsigned char char_code) {
  std::stringstream ss;
  ss << char_code;
  return ss.str();
}

string DoubleToString(double value, int digits = 8) {
  std::stringstream ss;
  ss << std::setprecision(digits) << value;
  return ss.str();
}

string ShortToString(unsigned short symbol_code) {
  std::stringstream ss;
  ss << (char)symbol_code;
  return ss.str();
}
#endif
