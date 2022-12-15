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

// Includes.
#include <stdarg.h>

#include <iostream>
#include <sstream>
#include <tuple>

#include "Std.h"
#include "Terminal.define.h"

// Define external global functions.
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

template <class Tuple, std::size_t N>
struct TuplePrinter {
  static void print(const std::string& fmt, std::ostream& os, const Tuple& t) {
    const size_t idx = fmt.find_last_of('%');
    TuplePrinter<Tuple, N - 1>::print(std::string(fmt, 0, idx), os, t);
    os << std::get<N - 1>(t) << std::string(fmt, idx + 1);
  }
};

template <class Tuple>
struct TuplePrinter<Tuple, 1> {
  static void print(const std::string& fmt, std::ostream& os, const Tuple& t) {
    const size_t idx = fmt.find_first_of('%');
    os << std::string(fmt, 0, idx) << std::get<0>(t) << std::string(fmt, idx + 1);
  }
};

template <typename Arg, typename... Args>
void PrintTo(std::ostream& out, Arg&& arg, Args&&... args) {
  out << std::forward<Arg>(arg);
  using expander = int[];
  (void)expander{0, (void(out << std::forward<Args>(args)), 0)...};
  out << "\n";
  out.flush();
}

template <typename Arg, typename... Args>
void Print(Arg&& arg, Args&&... args) {
  PrintTo(std::cout, arg, args...);
}

template <typename Arg, typename... Args>
void Alert(Arg&& arg, Args&&... args) {
  PrintTo(std::cerr, arg, args...);
}

template <class... Args>
std::string StringFormat(const std::string& fmt, Args&&... args) {
  std::stringstream ss;
  const auto t = std::make_tuple(std::forward<Args>(args)...);
  TuplePrinter<decltype(t), sizeof...(Args)>::print(fmt, ss, t);
  return ss.str();
}

template <class... Args>
void PrintFormat(const std::string& fmt, Args&&... args) {
  std::cout << StringFormat(fmt, args...) << std::endl;
}

string StringSubstr(string string_value, int start_pos, int length = -1) {
  return string_value.substr(start_pos, length == -1 ? (string_value.size() - start_pos) : length);
}
unsigned short StringGetCharacter(string string_value, int pos) {
  if (pos < 0 || pos >= string_value.size()) {
    Alert("Character index out of string boundary! Position passed: ", pos, ", string passed: \"", string_value, "\"");
  }
  return string_value[pos];
}

int StringToCharArray(string text_string, ARRAY_REF(unsigned char, array), int start = 0, int count = -1,
                      unsigned int codepage = CP_ACP);
#endif
