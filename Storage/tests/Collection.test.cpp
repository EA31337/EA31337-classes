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
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test C++ compilation of Collection class.
 */

// Includes.
#include "../Collection.h"

// Define classes.
class Stack : public Object {
 public:
  virtual string GetName() = 0;
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

int main(int argc, char **argv) {
  // Define and add items.
  Collection<Stack> *stack = new Collection<Stack>();
  /* @fixme
  stack.Add(new Foo);
  stack.Add(new Bar);
  stack.Add(new Baz);

  // Print the lowest and the highest items.
  Print("Lowest: ", ((Stack *)stack.GetLowest()).GetName());
  Print("Highest: ", ((Stack *)stack.GetHighest()).GetName());
  // Print all items.
  int i;
  for (i = 0; i < stack.GetSize(); i++) {
    Print(i, ": ", ((Stack *)stack.GetByIndex(i)).GetName());
  }
  */

  // Clean up.
  Object::Delete(stack);

  return 0;
}
