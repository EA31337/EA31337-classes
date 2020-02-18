//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of Dict class.
 */

// Includes.
#include "../Dict.mqh"
#include "../DictObject.mqh"
#include "../Test.mqh"

class X {
public:
  int a;
  
  X () {
  }
    
  X (const X& right) {
    a = right.a;
  }
};

string ToJSON(X& value, const bool stripWhitespaces = false, const unsigned int indentation = 0) {
  return "";
}

/**
 * Implements OnInit().
 */
int OnInit() {
/*
  // Example 1.
  Dict<string, int> dict1;
  dict1.Set("a", 1);
  dict1.Set("bb", 2);
  dict1.Unset("bb");
  dict1.Set("b", 2);
  dict1.Set("c", 33);
  dict1.Set("c", 3);
  assertTrueOrFail(dict1.GetByKey("a") == 1, "Invalid Dict value, expected 1!");
  assertTrueOrFail(dict1.GetByKey("b") == 2, "Invalid Dict value, expected 2!");
  assertTrueOrFail(dict1.GetByKey("c") == 3, "Invalid Dict value, expected 3!");

  // Example 2.
  Dict<int, string> dict2;
  dict2.Set(1, "a");
  dict2.Set(2, "bb");
  dict2.Unset(2);
  dict2.Set(2, "b");
  dict2.Set(3, "cc");
  dict2.Set(3, "c");
  assertTrueOrFail(dict2.GetByKey(1) == "a", "Invalid Dict value, expected 'a'!");
  assertTrueOrFail(dict2.GetByKey(2) == "b", "Invalid Dict value, expected 'b'!");
  assertTrueOrFail(dict2.GetByKey(3) == "c", "Invalid Dict value, expected 'c'!");

  // Example 3. Dictionary of pointers to other dictionaries.
  Dict<int, Dict<int, string>*> dict3;
  dict3.Set(1, &dict2);
  Dict<int, string>* dict2_ref = dict3.GetByKey(1);
  assertTrueOrFail(dict2_ref != NULL, "Dict should return non-NULL pointer to the dict2 object!");
  assertTrueOrFail(dict2_ref.GetByKey(1) == "a", "Incorrect value read from dict2 object. Expected 'a' for key 1!");
  dict2.Set(1, "d");
  assertTrueOrFail(dict2_ref.GetByKey(1) == "d", "Reference to dict2 doesn't point to the dict2 object, but rather to a copy of dict2. It is wrong!");
  dict2_ref.Unset(1);
  assertTrueOrFail(dict2_ref.KeyExists(1) == false, "Dict shouldn't contain key 1 as it was unset!");

  // Example 4. Dictionary of other dictionaries.
  DictObject<int, Dict<int, string>> dict4;
  dict4.Set(1, dict2);
  Dict<int, string>* dict2_ref2 = dict4.GetByKey(1);
  assertTrueOrFail(dict2_ref2 != NULL, "Dict should return non-NULL pointer to the dict2 object!");
  assertTrueOrFail(dict2_ref2.GetByKey(2) == "b", "Incorrect value read from dict2 object. Expected 'b' for key 2!");
  dict2.Set(2, "e");
  assertTrueOrFail(dict2_ref2.GetByKey(2) == "b", "Reference to dict2 points to the same dict2 object as the one passed. It should be copied by value!");
  dict2_ref.Unset(1);
  assertTrueOrFail(dict2_ref.KeyExists(1) == false, "Dict shouldn't contain key 1 as it was unset!");
  dict4.Unset(1);
  assertTrueOrFail(dict4.KeyExists(1) == false, "Dict shouldn't contain key 1 as it was unset!");

  // Example 5. Dictionary ToJSON() method.
  DictObject<int, Dict<int, string>> dict5;
  Dict<int, string> dict5_1;
  dict5_1.Push("c");
  dict5_1.Push("b");
  dict5_1.Push("a");
  Dict<int, string> dict5_2;
  dict5_2.Push("a");
  dict5_2.Push("b");
  dict5_2.Push("c");
  dict5.Set(1, dict5_1);
  dict5.Set(2, dict5_2);
  
  assertTrueOrFail(dict5.ToJSON(true) == "{\"1\":[\"c\",\"b\",\"a\"],\"2\":[\"a\",\"b\",\"c\"]}", "Improper white-space-stripped JSON output!");
  assertTrueOrFail(dict5.ToJSON(false, 2) == "{\n  \"1\": [\n    \"c\",\n    \"b\",\n    \"a\"\n  ],\n  \"2\": [\n    \"a\",\n    \"b\",\n    \"c\"\n  ]\n}", "Improper white-spaced JSON output!");
  
  // Example 6. Enum values as key.
  Dict<ENUM_TIMEFRAMES, string> dict6;
  dict6.Set(PERIOD_M1, "1 min");
  dict6.Set(PERIOD_M5, "5 min");
  assertTrueOrFail(dict6.GetByKey(PERIOD_M1) == "1 min", "Wrongly set Dict key. Expected '1 min' for enum key PERIOD_M1!");
  assertTrueOrFail(dict6.GetByKey(PERIOD_M5) == "5 min", "Wrongly set Dict key. Expected '5 min' for enum key PERIOD_M5!");
  
  // Example 7. Enum values as value.
  Dict<string, int> dict7;
  dict7.Set("1 min", PERIOD_M1);
  dict7.Set("5 min", PERIOD_M5);
  assertTrueOrFail(dict7.GetByKey("1 min") == PERIOD_M1, "Wrongly set Dict key. Expected PERIOD_M1's value for '1 min' key!");
  assertTrueOrFail(dict7.GetByKey("5 min") == PERIOD_M5, "Wrongly set Dict key. Expected PERIOD_M5's value for '5 min' key!");

  // Testing iteration over simple types.  
  Dict<int, string> dict8;
  dict8.Set(1, "One");
  dict8.Set(2, "Two");
  dict8.Set(3, "Three");
  
  Dict<int, string> dict8_found;
  
  for (DictIterator<int, string> iter = dict8.Begin(); iter.IsValid(); ++iter) {
    dict8_found.Set(iter.Key(), iter.Value());
  }
  
  assertTrueOrFail(dict8_found.Size() == 3, "Wrong interator logic. Should iterate over exactly 3 keys (found " + IntegerToString(dict8_found.Size()) + ")!");
  assertTrueOrFail(dict8_found.GetByKey(1) == "One", "Wrong interator logic. Should interate over key 1!");
  assertTrueOrFail(dict8_found.GetByKey(2) == "Two", "Wrong interator logic. Should interate over key 1!");
  assertTrueOrFail(dict8_found.GetByKey(3) == "Three", "Wrong interator logic. Should interate over key 1!");

*/  

  // Testing iteration over class types.
  DictObject<int, Dict<int, string>> dict9;
  Dict<int, string> dict9_a;
  Dict<int, string> dict9_b;
  Dict<int, string> dict9_c;
  dict9_a.Set(1, "One");
  dict9_a.Set(2, "Two");
  dict9_b.Set(3, "Three");
  dict9_b.Set(4, "Four");
  dict9_c.Set(5, "Five");
  dict9_c.Set(6, "Six");
  dict9.Push(dict9_a);
  dict9.Push(dict9_b);
  dict9.Push(dict9_c);
  
  Print(dict9.ToJSON());
  
  for (DictObjectIterator<int, Dict<int, string>> iter = dict9.Begin(); iter.IsValid(); ++iter) {
    iter.Value().Set(10, "Ten");
    Print(iter.Key(), iter.HasKey() ? "(keyed)" : "(not keyed)", ": " + iter.Value().ToJSON());
  }

  return (INIT_SUCCEEDED);
}
