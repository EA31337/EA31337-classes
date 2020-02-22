//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
#ifndef JSON_MQH
#define JSON_MQH

// Includes.
#include "Object.mqh"

// Defines.
#define JSON_INDENTATION 2

class JSON
{
public:

  static string Stringify(datetime value, bool includeQuotes = false)
  {
  #ifdef __MQL5__
    return (includeQuotes ? "\"" : "") + TimeToString(value) + (includeQuotes ? "\"" : "");
  #else
    return (includeQuotes ? "\"" : "") + TimeToStr(value) + (includeQuotes ? "\"" : "");
  #endif
  }

  static string Stringify(bool value, bool includeQuotes = false)
  {
    return value ? "true" : "false";
  }

  static string Stringify(int value, bool includeQuotes = false)
  {
    return IntegerToString(value);
  }

  static string Stringify(long value, bool includeQuotes = false)
  {
    return IntegerToString(value);
  }

  static string Stringify(string value, bool includeQuotes = false)
  {
    string output = includeQuotes ? "\"" : "";
  
    for (unsigned short i = 0; i < StringLen(value); ++i)
    {
    #ifdef __MQL5__
      switch (StringGetCharacter(value, i))
    #else
      switch (StringGetChar(value, i))
    #endif
      {
        case '"':
          output += "\\\"";
          break;
        case '/':
          output += "\\/";
          break;
        case '\n':
          output += "\\n";
          break;
        case '\r':
          output += "\\r";
          break;
        case '\t':
          output += "\\t";
          break;
        case '\\':
          output += "\\\\";
          break;
        default:
          #ifdef __MQL5__
            output += ShortToString(StringGetCharacter(value, i));
          #else
            output += ShortToString(StringGetChar(value, i));
          #endif
          break;
      }
    }
    
    return output + (includeQuotes ? "\"" : "");
  }

  static string Stringify(float value, bool includeQuotes = false) {
    return StringFormat("%.6f", value);
  }

  static string Stringify(double value, bool includeQuotes = false) {
    return StringFormat("%.8f", value);
  }

  static string Stringify(Object* _obj, bool includeQuotes = false) {
    return ((Object *)_obj).ToString();
  }

  template <typename T>
  static string Stringify(T value, bool includeQuotes = false)
  {
    return StringFormat("%s", value);
  }

};

#endif