//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
 * Test functionality of Collection class.
 */

// Includes.
#include "../Collection.mqh"
#include "../../Test.mqh"

// Define classes.
class Stack : public Object {
 public:
  virtual string GetName() = NULL;
};
class Foo : public Stack {
 public:
  string GetName() { return "Foo"; };
  double GetWeight() { return 0; };
};
class Bar : public Stack {
 public:
  string GetName() { return "Bar"; };
  double GetWeight() { return 1; };
};
class Baz : public Stack {
 public:
  string GetName() { return "Baz"; };
  double GetWeight() { return 2; };
};

/**
 * Implements OnInit().
 */
int OnInit() {
  // Define and add items.
  Collection<Stack> *stack = new Collection<Stack>();
  stack.Add(new Foo);
  stack.Add(new Bar);
  stack.Add(new Baz);

  // Checks.
  assertTrueOrFail(stack.GetSize() == 3, "Invalid size of the collection!");
  assertTrueOrFail(((Object *)stack.GetLowest()).GetWeight() == 0, "Wrong highest weight!");
  assertTrueOrFail(((Stack *)stack.GetLowest()).GetName() == "Foo", "Wrong name!");
  assertTrueOrFail(((Object *)stack.GetHighest()).GetWeight() == 2, "Wrong highest weight!");
  assertTrueOrFail(((Stack *)stack.GetHighest()).GetName() == "Baz", "Wrong name!");
  assertTrueOrFail(((Stack *)stack.GetByIndex(0)).GetName() == "Foo", "Fail at GetByIndex(0)!");
  assertTrueOrFail(((Stack *)stack.GetByIndex(1)).GetName() == "Bar", "Fail at GetByIndex(0)!");
  assertTrueOrFail(((Stack *)stack.GetByIndex(2)).GetName() == "Baz", "Fail at GetByIndex(0)!");
  // Print the lowest and the highest items.
  Print("Lowest: ", ((Stack *)stack.GetLowest()).GetName());
  Print("Highest: ", ((Stack *)stack.GetHighest()).GetName());
  // Print all items.
  int i;
  for (i = 0; i < stack.GetSize(); i++) {
    Print(i, ": ", ((Stack *)stack.GetByIndex(i)).GetName());
  }

  // Clean up.
  Object::Delete(stack);

  return (INIT_SUCCEEDED);
}
