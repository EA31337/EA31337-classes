//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

/**
 * @file
 * Serializer data conversion methods.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

#include "Convert.extern.h"
#include "DateTime.extern.h"
#include "Object.mqh"
#include "Refs.struct.h"

class SerializerConversions {
 public:
  static string ValueToString(datetime value, bool includeQuotes = false, bool escape = true, int _fp_precision = 8) {
#ifndef __MQL4__
    return (includeQuotes ? "\"" : "") + TimeToString(value) + (includeQuotes ? "\"" : "");
#else
    return (includeQuotes ? "\"" : "") + TimeToStr(value) + (includeQuotes ? "\"" : "");
#endif
  }

  static string ValueToString(bool value, bool includeQuotes = false, bool escape = true, int _fp_precision = 8) {
    return string(includeQuotes ? "\"" : "") + (value ? "true" : "false") + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(int value, bool includeQuotes = false, bool escape = true, int _fp_precision = 8) {
    return string(includeQuotes ? "\"" : "") + IntegerToString(value) + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(long value, bool includeQuotes = false, bool escape = true, int _fp_precision = 8) {
    return string(includeQuotes ? "\"" : "") + IntegerToString(value) + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(string value, bool includeQuotes = false, bool escape = true, int _fp_precision = 8) {
    string output = includeQuotes ? "\"" : "";
    unsigned short _char;

    for (unsigned short i = 0; i < StringLen(value); ++i) {
#ifndef __MQL4__
      _char = StringGetCharacter(value, i);
#else
      _char = StringGetChar(value, i);
#endif
      if (escape) {
        switch (_char) {
          case '"':
            output += "\\\"";
            continue;
          case '/':
            output += "\\/";
            continue;
          case '\n':
            if (escape) output += "\\n";
            continue;
          case '\r':
            if (escape) output += "\\r";
            continue;
          case '\t':
            if (escape) output += "\\t";
            continue;
          case '\\':
            if (escape) output += "\\\\";
            continue;
        }
      }

#ifndef __MQL4__
      output += ShortToString(StringGetCharacter(value, i));
#else
      output += ShortToString(StringGetChar(value, i));
#endif
    }

    return output + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(float value, bool includeQuotes = false, bool escape = true, int _fp_precision = 6) {
    return (includeQuotes ? "\"" : "") + StringFormat("%." + IntegerToString(_fp_precision) + "f", value) +
           (includeQuotes ? "\"" : "");
  }

  static string ValueToString(double value, bool includeQuotes = false, bool escape = true, int _fp_precision = 8) {
    return (includeQuotes ? "\"" : "") + StringFormat("%." + IntegerToString(_fp_precision) + "f", value) +
           (includeQuotes ? "\"" : "");
  }

  static string ValueToString(Object& _obj, bool includeQuotes = false, bool escape = true, int _fp_precision = 8) {
    return (includeQuotes ? "\"" : "") + _obj.ToString() + (includeQuotes ? "\"" : "");
  }
  template <typename T>
  static string ValueToString(T value, bool includeQuotes = false, bool escape = true, int _fp_precision = 8) {
    return StringFormat("%s%s%s", (includeQuotes ? "\"" : ""), value, (includeQuotes ? "\"" : ""));
  }
  static string UnescapeString(string value) {
    string output = "";
    unsigned short _char1;
    unsigned short _char2;

    for (unsigned short i = 0; i < StringLen(value); ++i) {
#ifndef __MQL4__
      _char1 = StringGetCharacter(value, i);
      _char2 = (i + 1 < StringLen(value)) ? StringGetCharacter(value, i + 1) : 0;
#else
      _char1 = StringGetChar(value, i);
      _char2 = (i + 1 < StringLen(value)) ? StringGetChar(value, i + 1) : 0;
#endif

      if (_char1 == '\\') {
        switch (_char2) {
          case '"':
            output += "\"";
            i++;
            continue;
          case '/':
            output += "/";
            i++;
            continue;
          case 'n':
            output += "\n";
            i++;
            continue;
          case 'r':
            output += "\r";
            i++;
            continue;
          case 't':
            output += "\t";
            i++;
            continue;
          case '\\':
            output += "\\";
            i++;
            continue;
        }
      }

#ifndef __MQL4__
      output += ShortToString(StringGetCharacter(value, i));
#else
      output += ShortToString(StringGetChar(value, i));
#endif
    }

    return output;
  }
};
