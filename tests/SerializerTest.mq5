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
 * Test functionality of Serializer class.
 */

// Includes.
#include "../Serializer.mqh"
#include "../SerializerObject.mqh"
#include "../SerializerCsv.mqh"
#include "../DictStruct.mqh"
#include "../Chart.mqh"
#include "../Test.mqh"

class SerializableEntry
{
public:

  string name;

  SerializerNodeType Serialize(Serializer& s) {
    s.Pass(this, "Hello", name);
    
    return SerializerNodeObject;
  }
};


/**
 * Implements Init event handler.
 */
int OnInit() {

  DictStruct<int, ChartEntry> dict1;
  
  ChartEntry entry1, entry2;
  
  dict1.Push(entry1);
  dict1.Push(entry2);
  
  Print(SerializerConverter::FromObject(dict1).ToString<SerializerJson>());
  
  return INIT_SUCCEEDED;
}
