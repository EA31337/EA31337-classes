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
#include "../Chart.mqh"
#include "../Config.mqh"
#include "../DictStruct.mqh"
#include "../Serializer.mqh"
#include "../SerializerCsv.mqh"
#include "../SerializerObject.mqh"
#include "../Test.mqh"

struct SerializableSubEntry {
 public:
  int x;

  int y;

  SerializableSubEntry(int _x = 0, int _y = 0) : x(_x), y(_y) {}

  SerializerNodeType Serialize(Serializer& s) {
    s.Pass(this, "x", x);
    s.Pass(this, "y", y);
    return SerializerNodeObject;
  }

  SERIALIZER_EMPTY_STUB;
};

class SerializableEntry {
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

  void Push(SerializableSubEntry& entry) { children.Push(entry); }

  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {
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

  // ToStringObject() effectively calls SerializerCsv::Stringify() where first
  // argument to Stringify() is always the root node of serializer tree.
  //
  // SerializerConverter::ToStringObject<
  //  SerializerCsv/SerializerJson,
  //  Type of first argument to serializer's Stringify(),
  //  Type of second argument to serializer's Stringify()
  //  >
  //
  // Serializer::MakeStubObject<type of serialized object> (
  //   Serializer flags, e.g., SERIALIZER_FLAG_SKIP_HIDDEN,
  //   Lengths of the nth (1 - 5) "dimensions" of containers
  // )
  //
  // Note that you only have to pass length of dimensions, when your data has
  // no fixed structure, e.g., when you expect two items in the first
  // dimensions of the data, but data has only single item in such dimension.
  //
  // However, if you just want to export what-is in the data, then leave
  // dimension lengths unset or set it to 1.

  SerializerConverter stub1(
      Serializer::MakeStubObject<DictStruct<int, SerializableEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN));
  Print(SerializerConverter::FromObject(entries, SERIALIZER_FLAG_SKIP_HIDDEN)
            .ToString<SerializerCsv>(SERIALIZER_FLAG_SKIP_HIDDEN, &stub1));

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

  SerializerConverter stub2(
      Serializer::MakeStubObject<DictStruct<int, BufferStructEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN));
  Print(SerializerConverter::FromObject(buffer_entries, SERIALIZER_FLAG_SKIP_HIDDEN)
            .ToString<SerializerCsv>(SERIALIZER_FLAG_SKIP_HIDDEN, &stub2));

  DictObject<int, Config> configs1;

  Config config1;

  ConfigEntry pair1 = {TYPE_STRING, 0, 0, "XLMBTC"};
  ConfigEntry startDate1 = {TYPE_DATETIME, D'2020.01.01 00:00', 0, ""};
  ConfigEntry endDate1 = {TYPE_DATETIME, D'2025.03.05 23:23', 0, ""};
  ConfigEntry enable1 = {TYPE_BOOL, 1, 0, ""};
  ConfigEntry limit1 = {TYPE_INT, 5, 0, ""};
  ConfigEntry max1 = {TYPE_DOUBLE, 0, 7.5, ""};

  config1.Set("pair", pair1);
  config1.Set("startDate", startDate1);
  config1.Set("endDate", endDate1);
  config1.Set("enable", enable1);
  config1.Set("limit", limit1);
  config1.Set("max", max1);
  config1.Set("otherPair", "XLMBTC");
  config1.Set("otherStartDate", D'2020.01.01 00:00');
  config1.Set("otherEndDate", D'2025.03.05 23:23');
  config1.Set("otherEnable", true);
  config1.Set("otherLimit", 5);
  config1.Set("otherMax", 7.5);

  Config config2;

  ConfigEntry pair2 = {TYPE_STRING, 0, 0, "PLNBTC"};
  ConfigEntry startDate2 = {TYPE_DATETIME, D'2011.01.01 00:00', 0, ""};
  ConfigEntry endDate2 = {TYPE_DATETIME, D'2015.03.05 23:23', 0, ""};
  ConfigEntry enable2 = {TYPE_BOOL, 3, 0, ""};
  ConfigEntry limit2 = {TYPE_INT, 6, 0, ""};
  ConfigEntry max2 = {TYPE_DOUBLE, 0, 2.1, ""};

  config2.Set("pair", pair2);
  config2.Set("startDate", startDate2);
  config2.Set("endDate", endDate2);
  config2.Set("enable", enable2);
  config2.Set("limit", limit2);
  config2.Set("max", max2);
  config2.Set("otherPair", "XLMBTC");
  config2.Set("otherStartDate", D'2019.01.01 00:00');
  config2.Set("otherEndDate", D'2023.03.05 23:23');
  config2.Set("otherEnable", false);
  config2.Set("otherLimit", 2);
  config2.Set("otherMax", 1.5);

  configs1.Push(config1);
  configs1.Push(config2);

  SerializerConverter::FromObject(configs1).ToFile<SerializerJson>("configs.json");

  SerializerConverter stub3 = Serializer::MakeStubObject<DictObject<int, Config>>();
  SerializerConverter::FromObject(configs1).ToFile<SerializerCsv>("configs.csv", SERIALIZER_CSV_INCLUDE_TITLES, &stub3);

  Print("Imported:");
  DictObject<int, Config> configs2;
  SerializerConverter::FromFile<SerializerJson>("configs.json").ToObject(configs2);

  Print(SerializerConverter::FromObject(configs2).ToString<SerializerJson>());

  Print(SerializerConverter::FromStruct(configs2[1]).ToString<SerializerJson>());

  return INIT_SUCCEEDED;
}
