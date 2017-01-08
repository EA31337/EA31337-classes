//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                            Copyright 2016, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/*
 * Class to provide methods to deal with strings.
 */
class Strings {
public:

  /**
   * Remove separator character from the end of the string.
   */
  static void RemoveSepChar(string& text, string sep) {
    if (StringSubstr(text, StringLen(text)-1) == sep) text = StringSubstr(text, 0, StringLen(text)-1);
  }

  /**
   * Print multi-line text.
   */
  static void PrintText(string text) {
    string _result[];
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
    #ifdef __MQL4__
    // In MQL4 the character is symbol code in ASCII.
    return ::StringSetChar(string_var, pos, character);
    #else // _MQL5__
    string copy = string_var;
    // In MQL5 the character is symbol code in Unicode.
    StringSetCharacter (copy, pos, character);
    return copy;
    #endif
  }
};