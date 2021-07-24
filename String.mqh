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

// Prevents processing this includes file for the second time.
#ifndef STRING_MQH
#define STRING_MQH

// Includes.
#include "Std.h"

// Defines.
#define NL "\n"   // New line: 0x0A (MQL file functions auto-convert 0x0A to 0x0D0A).
#define TAB "\t"  // Tab: 0x09.

/**
 * Class to provide methods to deal with strings.
 */
class String {
 protected:
  ARRAY(string, strings);
  string dlm;

 public:
  /**
   * Class constructor.
   */
  String(string _string = "") : dlm(",") {
    if (_string != "") Add(_string);
  }

  /**
   * Add a new string.
   */
  bool Add(string _string) {
    uint _size = ArraySize(strings);
    if (ArrayResize(strings, _size + 1, 100)) {
      strings[_size] = _string;
      return true;
    } else {
      return false;
    }
  }

  /**
   * Add a new value.
   */
  bool Add(int _value) { return Add(IntegerToString(_value)); }

  /**
   * Get all arrays to string.
   */
  string ToString() {
    string _res = "";
    for (int i = 0; i < ArraySize(strings); i++) {
      _res += strings[i] + (string)dlm;
    }
    return _res;
  }

  /**
   * Remove separator character from the end of the string.
   */
  static void RemoveSepChar(string& text, string sep) {
    if (StringSubstr(text, StringLen(text) - 1) == sep) text = StringSubstr(text, 0, StringLen(text) - 1);
  }

  /**
   * Print multi-line text.
   */
  static void PrintText(string text) {
    ARRAY(string, _result);
    ushort usep = StringGetCharacter("\n", 0);
    for (int i = StringSplit(text, usep, _result) - 1; i >= 0; i--) {
      Print(_result[i]);
    }
  }

  /**
   * Returns the string copy with changed character in the specified position.
   *
   * @see https://www.mql5.com/en/articles/81
   */
  static string StringSetChar(string string_var, int pos, ushort character) {
#ifdef __MQLBUILD__
#ifdef __MQL4__
    // In MQL4 the character is symbol code in ASCII.
    return ::StringSetChar(string_var, pos, character);
#else  // __MQL5__
    string copy = string_var;
    // In MQL5 the character is symbol code in Unicode.
    StringSetCharacter(copy, pos, character);
    return copy;
#endif
#else  // C++
    printf("@fixme: %s\n", "StringSetChar()");
    return "";
#endif
  }
};
#endif  // STRING_MQH
