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

// Prevents processing this includes file for the second time.
#ifndef __MQL__
#pragma once
#include "Std.h"
#include "Terminal.define.h"
#endif

// Define external global functions.
#ifndef __MQL__
extern double StringToDouble(string value);
extern int StringFind(string string_value, string match_substring, int start_pos = 0);
extern int StringLen(string string_value);
extern int StringSplit(const string& string_value, const unsigned short separator, ARRAY_REF(string, result));
extern long StringToInteger(string value);
extern string IntegerToString(long number, int str_len = 0, unsigned short fill_symbol = ' ');
extern string StringFormat(string format, ...);
extern string StringSubstr(string string_value, int start_pos, int length = -1);
extern unsigned short StringGetCharacter(string string_value, int pos);
int StringToCharArray(string text_string, ARRAY_REF(unsigned char, array), int start = 0, int count = -1,
                      unsigned int codepage = CP_ACP);
#endif
