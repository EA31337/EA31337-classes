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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once

// Includes.
#include <stdarg.h>

#include <algorithm>
#include <cstring>
#include <iostream>
#include <sstream>
#include <tuple>

#include "../Math/Math.extern.h"
#include "../Platform/Terminal.define.h"
#include "../Std.h"

// Define external global functions.
double StringToDouble(string value) { return std::stod(value); }

string StringTrimLeft(string text) {
  text.erase(text.begin(), std::find_if(text.begin(), text.end(), [](unsigned char ch) { return !std::isspace(ch); }));
  return text;
}

string StringTrimRight(string text) {
  text.erase(std::find_if(text.rbegin(), text.rend(), [](unsigned char ch) { return !std::isspace(ch); }).base(),
             text.end());
  return text;
}

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
int64 StringToInteger(string value) { return std::stol(value); }
string IntegerToString(int64 number, int str_len = 0, unsigned short fill_symbol = ' ') {
  return std::to_string(number);
}

template <class... Args>
std::string StringFormat(std::string f, Args&&... args) {
  int size = snprintf(nullptr, 0, f.c_str(), args...);
  std::string res;
  res.resize(size);
  snprintf(&res[0], size + 1, f.c_str(), args...);
  return res;
}

template <typename Arg, typename... Args>
void PrintTo(std::ostream& out, Arg&& arg, Args&&... args) {
  out << std::forward<Arg>(arg);
  using expander = int[];
  (void)expander{0, (void(out << std::forward<Args>(args)), 0)...};
  out << std::endl;
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

bool StringInit(string& string_var, int new_len = 0, unsigned short character = 0) {
  string_var = string(new_len, (char)character);
  return true;
}

string CharArrayToString(ARRAY_REF(unsigned char, arr), int start = 0, int count = -1, unsigned int codepage = CP_ACP) {
  if (count == -1) count = (arr.size() - start);

  int _end = MathMin(count - start, arr.size());

  string result;
  StringInit(result, count);

  for (int i = 0; i < count; ++i) {
    result[i] = arr[i];
  }

  return result;
}

int StringToCharArray(string text_string, ARRAY_REF(unsigned char, array), int start = 0, int count = -1,
                      unsigned int codepage = CP_ACP) {
  if (count == -1) count = text_string.size();

  for (int i = start; i < MathMin(start + count, (int)text_string.size()); ++i)
    array.push((unsigned char)text_string[i]);

  return array.size();
}

/**
 * It replaces all the found substrings of a string by a set sequence of symbols.
 *
 * @docs
 * - https://www.mql5.com/en/docs/strings/stringreplace
 */
int StringReplace(string& str, const string& find, const string& replacement) {
  int num_replacements = 0;
  for (size_t pos = 0;; pos += replacement.length()) {
    // Locate the substring to replace
    pos = str.find(find, pos);
    if (pos == string::npos) break;
    // Replace by erasing and inserting
    str.erase(pos, find.length());
    str.insert(pos, replacement);
    ++num_replacements;
  }
  return num_replacements;
}

string StringToLower(string str) {
  std::transform(str.begin(), str.end(), str.begin(), [](unsigned char c) { return ::tolower(c); });
  return str;
}

string StringToUpper(string str) {
  std::transform(str.begin(), str.end(), str.begin(), [](unsigned char c) { return ::toupper(c); });
  return str;
}

string EnumToString(ENUM_DATATYPE _value) {
  switch (_value) {
    case TYPE_BOOL:
      return "TYPE_BOOL";
    case TYPE_CHAR:
      return "TYPE_CHAR";
    case TYPE_COLOR:
      return "TYPE_COLOR";
    case TYPE_DATETIME:
      return "TYPE_DATETIME";
    case TYPE_DOUBLE:
      return "TYPE_DOUBLE";
    case TYPE_FLOAT:
      return "TYPE_FLOAT";
    case TYPE_INT:
      return "TYPE_INT";
    case TYPE_LONG:
      return "TYPE_LONG";
    case TYPE_SHORT:
      return "TYPE_SHORT";
    case TYPE_STRING:
      return "TYPE_STRING";
    case TYPE_UCHAR:
      return "TYPE_UCHAR";
    case TYPE_UINT:
      return "TYPE_UINT";
    case TYPE_ULONG:
      return "TYPE_ULONG";
    case TYPE_USHORT:
      return "TYPE_USHORT";
  }

  return "<UNKNOWN TYPE: " + IntegerToString((int)_value) + ">";
}

#endif
