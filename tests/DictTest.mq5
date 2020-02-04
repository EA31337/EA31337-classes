//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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
#include "../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
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
  //delete dict1; // @fixme

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
  //delete dict2; // @fixme

  // Example 3. Dictionary of pointers to other dictionaries.
  Dict<int, Dict<int, string>*> dict3;
  dict3.Set(1, &dict2);
  Dict<int, string>* dict2_ref = dict3.GetByKey(1);
  assertTrueOrFail(dict2_ref != NULL, "Dict should return non-NULL pointer to the dict2 object!");
  assertTrueOrFail(dict2_ref.GetByKey(1) == "a", "Incorrect value read from dict2 object. Expected 'a' for key 1!");
  dict2.Set(1, "d");
  assertTrueOrFail(dict2_ref.GetByKey(1) == "d", "Reference to dict2 doesn't point to the dict2 object, but rather to a copy of dict2. It is wrong!");
  dict2_ref.Unset(1);
  assertTrueOrFail(dict2_ref.KeyExists(1) == false, "Dict should'nt contain key 1 as it was unset!");

  // Example 3. Dictionary of other dictionaries.
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

  return (INIT_SUCCEEDED);
}
