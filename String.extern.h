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

// Prevents processing this includes file for the second time.
#ifndef __MQL__
#pragma once
#include "Std.h"
#include "Terminal.define.h"
#endif

// Define external global functions.
#ifndef __MQL__
double StringToDouble(string value) { return std::stod(value); }

auto StringFind(const string string_value, string match_substring, int start_pos = 0) -> int {
  return string_value.find(match_substring);
}
int StringLen(string string_value) { return string_value.size(); }
int StringSplit(const string& string_value, const unsigned short separator, ARRAY_REF(string, result)) {
  auto start = 0U;
  auto end = string_value.find((char)separator);
  while (end != std::string::npos) {
    result.str().push_back(string_value.substr(start, end - start));
    start = end + 1;  // 1 - size of the separator.
    end = string_value.find((char)separator, start);
  }
  return result.size();
}
long StringToInteger(string value) { return std::stol(value); }
string IntegerToString(long number, int str_len = 0, unsigned short fill_symbol = ' ') {
  return std::to_string(number);
}

string StringFormat(string format, ...);
string StringSubstr(string string_value, int start_pos, int length = -1) {
  return string_value.substr(start_pos, length == -1 ? (string_value.size() - start_pos) : length);
}
unsigned short StringGetCharacter(string string_value, int pos);
int StringToCharArray(string text_string, ARRAY_REF(unsigned char, array), int start = 0, int count = -1,
                      unsigned int codepage = CP_ACP);
#endif
