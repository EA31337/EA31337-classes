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
#include "../BufferStruct.mqh"
#include "../Serializer.mqh"
#include "../SerializerObject.mqh"
#include "../SerializerCsv.mqh"
#include "../DictStruct.mqh"
#include "../Chart.mqh"
#include "../Test.mqh"

struct SerializableSubEntry
{
public:

  int x;
  
  int y;
  
  SerializableSubEntry(int _x = 0, int _y = 0) : x(_x), y(_y) {
  }

  SerializerNodeType Serialize(Serializer& s) {
    s.Pass(this, "x", x);
    s.Pass(this, "y", y);    
    return SerializerNodeObject;
  }

  SERIALIZER_EMPTY_STUB;
};

class SerializableEntry
{
public:

  string a;
  
  int b;
  
  DictStruct<string, SerializableSubEntry> children;
  
  SerializableEntry(string _a = "", int _b = 0, int _num_children = 0) : a(_a), b(_b) {
    for (int i = 0; i < _num_children; ++i) {
      SerializableSubEntry s(_num_children, i);
      children.Push(s);
    }
  }
  
  SerializableEntry(const SerializableEntry& r) {
    a = r.a;
    b = r.b;
    children = r.children;
  }

  SerializerNodeType Serialize(Serializer& s) {
    s.Pass(this, "a", a);
    s.Pass(this, "b", b);
    s.PassObject(this, "children", children);
    
    return SerializerNodeObject;
  }
  
  void Push(SerializableSubEntry& entry) {
    children.Push(entry);
  }
  
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1,int _n4 = 1, int _n5 = 1) {
    SerializableSubEntry _child;
    _child.SerializeStub(_n2, _n3, _n4, _n5);

    while (_n1-- > 0) {
      Push(_child);
    }
  }
};


/**
 * Implements Init event handler.
 */
int OnInit() {

  DictStruct<int, SerializableEntry> entries;

  SerializableEntry entry1("entry 1", 1, 1);
  SerializableEntry entry2("entry 2", 2, 2);
  SerializableEntry entry3("entry 3", 3, 3);
  
  entries.Push(entry1);
  entries.Push(entry2);
  entries.Push(entry3);
    
  Print(SerializerConverter::FromObject(entries).ToStringObject<SerializerCsv, SerializerConverter>(
    Serializer::MakeStubObject<DictStruct<int, SerializableEntry>>(1, 1))
  );
  
  DictStruct<int, BufferStructEntry> buffer_entries;
  
  BufferStructEntry buffer_entry1;
  buffer_entry1.type = TYPE_DOUBLE;
  buffer_entry1.double_value = 1.0;
  
  BufferStructEntry buffer_entry2;
  buffer_entry2.type = TYPE_DOUBLE;
  buffer_entry2.double_value = 2.0;

  BufferStructEntry buffer_entry3;
  buffer_entry3.type = TYPE_DOUBLE;
  buffer_entry3.double_value = 3.0;
  
  buffer_entries.Push(buffer_entry1);
  buffer_entries.Push(buffer_entry2);
  buffer_entries.Push(buffer_entry3);
  
  Print(SerializerConverter::FromObject(buffer_entries).ToStringObject<SerializerCsv, SerializerConverter>(
    Serializer::MakeStubObject<DictStruct<int, BufferStructEntry>>())
  );

  return INIT_SUCCEEDED;
}
