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
extern datetime StringToTime(const string time_string);
extern double StringToDouble(string value);
extern int StringLen(string string_value);
extern long StringToInteger(string value);
extern string IntegerToString(long number, int str_len = 0, ushort fill_symbol = ' ');
extern string StringFormat(string format, ...);
extern string StringSubstr(string string_value, int start_pos, int length = -1);
extern ushort StringGetCharacter(string string_value, int pos);
#endif
