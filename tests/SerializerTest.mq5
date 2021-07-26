//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

#define __debug__

/**
 * @file
 * Test functionality of Serializer class.
 */

// Includes.
#include "../BufferStruct.mqh"
#include "../Chart.mqh"
#include "../Config.mqh"
#include "../Data.struct.h"
#include "../DictStruct.mqh"
#include "../Serializer.mqh"
#include "../SerializerBinary.mqh"
#include "../SerializerCsv.mqh"
#include "../SerializerDict.mqh"
#include "../SerializerJson.mqh"
#include "../SerializerNode.mqh"
#include "../SerializerObject.mqh"
#include "../Test.mqh"

struct SerializableSubEntry {
 public:
  int x;

  int y;

  int dynamic;

  int feature;

  SerializableSubEntry(int _x = 0, int _y = 0, int _dynamic = 0, int _feature = 0)
      : x(_x), y(_y), dynamic(_dynamic), feature(_feature) {}

  SerializerNodeType Serialize(Serializer& s) {
    s.Pass(THIS_REF, "x", x);
    s.Pass(THIS_REF, "y", y);
    s.Pass(THIS_REF, "dynamic", dynamic, SERIALIZER_FIELD_FLAG_DYNAMIC);
    s.Pass(THIS_REF, "feature", feature, SERIALIZER_FIELD_FLAG_FEATURE);
    return SerializerNodeObject;
  }

  SERIALIZER_EMPTY_STUB;
};

struct SerializableInteger {
 public:
  bool _is_set;

  SerializableInteger(bool is_set = false) : _is_set(is_set) {}

  bool IsSet() { return _is_set; }

  SerializerNodeType Serialize(Serializer& s) {
    if (s.IsWriting()) {
      int out = _is_set ? 5 : 0;
      s.Pass(THIS_REF, "", out);
    } else {
      int in;
      s.Pass(THIS_REF, "", in);
      _is_set = in == 5;
    }

    return SerializerNodeValue;
  }

  SERIALIZER_EMPTY_STUB;
};

class SerializableEntry {
 public:
  string a;

  int b;

  SerializableInteger i;

  DictStruct<string, SerializableSubEntry> children;

  SerializableEntry(string _a = "", int _b = 0, int _num_children = 0, bool _is_set = false)
      : a(_a), b(_b), i(_is_set) {
    for (int n = 0; n < _num_children; ++n) {
      SerializableSubEntry s(_num_children, n);
      children.Push(s);
    }
  }

  SerializableEntry(const SerializableEntry& r) {
    a = r.a;
    b = r.b;
    i = r.i;
    children = r.children;
  }

  SerializerNodeType Serialize(Serializer& s) {
    s.SetPrecision(6);
    s.Pass(THIS_REF, "a", a);
    s.Pass(THIS_REF, "b", b);
    s.PassValueObject(this, "i", i);
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
  // Scenario 1: entries is an array of objects containing dictionary of objects containing simple properties.
  DictStruct<int, SerializableEntry> entries;

  SerializableEntry entry1("entry 1", 1, 1, true);
  SerializableEntry entry2("entry 2", 2, 2, true);
  SerializableEntry entry3("entry 3", 3, 3, false);

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

  Print(SerializerConverter::FromObject(entries, SERIALIZER_FLAG_SKIP_HIDDEN)
            .ToString<SerializerJson>(SERIALIZER_FLAG_SKIP_HIDDEN));

  SerializerConverter stub1(
      SerializerConverter::MakeStubObject<DictStruct<int, SerializableEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN, 1, 4));
  Print(SerializerConverter::FromObject(entries, SERIALIZER_FLAG_SKIP_HIDDEN)
            .ToString<SerializerCsv>(SERIALIZER_FLAG_SKIP_HIDDEN, &stub1));

  DictStruct<int, DataParamEntry> buffer_entries;

  DataParamEntry buffer_entry1 = 1.0;
  DataParamEntry buffer_entry2 = 2.0;
  DataParamEntry buffer_entry3 = 3.0;

  buffer_entries.Push(buffer_entry1);
  buffer_entries.Push(buffer_entry2);
  buffer_entries.Push(buffer_entry3);

  SerializerConverter stub2(
      SerializerConverter::MakeStubObject<DictStruct<int, DataParamEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN));
  Print(SerializerConverter::FromObject(buffer_entries, SERIALIZER_FLAG_SKIP_HIDDEN)
            .ToString<SerializerCsv>(SERIALIZER_FLAG_SKIP_HIDDEN, &stub2));

  DictObject<int, Config> configs1;

  Config config1;

  ConfigEntry pair1 = "XLMBTC";
  ConfigEntry startDate1 = StrToTime("2020.01.01 00:00");
  ConfigEntry endDate1 = StrToTime("2025.03.05 23:23");
  ConfigEntry enable1 = true;
  ConfigEntry limit1 = 5;
  ConfigEntry max1 = 7.5;

  config1.Set("pair", pair1);
  config1.Set("startDate", startDate1);
  config1.Set("endDate", endDate1);
  config1.Set("enable", enable1);
  config1.Set("limit", limit1);
  config1.Set("max", max1);
  config1.Set("otherPair", "XLMBTC");
  config1.Set("otherStartDate", StrToTime("2020.01.01 00:00"));
  config1.Set("otherEndDate", StrToTime("2025.03.05 23:23"));
  config1.Set("otherEnable", true);
  config1.Set("otherLimit", 5);
  config1.Set("otherMax", 7.5);

  Config config2;

  ConfigEntry pair2 = "PLNBTC";
  ConfigEntry startDate2 = StrToTime("2011.01.01 00:00");
  ConfigEntry endDate2 = StrToTime("2015.03.05 23:23");
  ConfigEntry enable2 = true;
  ConfigEntry limit2 = 6;
  ConfigEntry max2 = 2.1;

  config2.Set("pair", pair2);
  config2.Set("startDate", startDate2);
  config2.Set("endDate", endDate2);
  config2.Set("enable", enable2);
  config2.Set("limit", limit2);
  config2.Set("max", max2);
  config2.Set("otherPair", "XLMBTC");
  config2.Set("otherStartDate", StrToTime("2019.01.01 00:00"));
  config2.Set("otherEndDate", StrToTime("2023.03.05 23:23"));
  config2.Set("otherEnable", false);
  config2.Set("otherLimit", 2);
  config2.Set("otherMax", 1.5);

  configs1.Push(config1);
  configs1.Push(config2);

  SerializerConverter::FromObject(configs1).ToFile<SerializerJson>("configs.json");

  SerializerConverter stub3(Serializer::MakeStubObject<DictObject<int, Config>>(0, 1, configs1[0].Size()));
  SerializerConverter::FromObject(configs1).ToFile<SerializerCsv>("configs.csv", SERIALIZER_CSV_INCLUDE_TITLES, &stub3);

  string configs1_json = SerializerConverter::FromObject(configs1).ToString<SerializerJson>();

  Print("config1_json: ", configs1_json);

  Print("configs.json imported json:",
        SerializerConverter::FromFile<SerializerJson>("configs.json").ToString<SerializerJson>());

  DictObject<int, Config> configs2;
  SerializerConverter::FromFile<SerializerJson>("configs.json").ToObject(configs2);

  Print("configs2 to string: ", SerializerConverter::FromObject(configs2).ToString<SerializerJson>());

  Config configs2_1 = configs2[1];

  Print("configs2[1] to string: ", SerializerConverter::FromObject(configs2_1).ToString<SerializerJson>());

  // Scenario 2: entries is a dictionary of objects containing dictionary of objects containing simple properties.
  DictStruct<string, SerializableEntry> entries_map;

  entries_map.Set("one", entry1);
  entries_map.Set("two", entry2);
  entries_map.Set("three", entry3);

  string entries_map_json = SerializerConverter::FromObject(entries_map).ToString<SerializerJson>();
  Print("entries_map json: ", entries_map_json);

  DictStruct<string, SerializableEntry> entries_map_imported;
  SerializerConverter::FromString<SerializerJson>(entries_map_json).ToStruct(entries_map_imported);

  string entries_imported_json = SerializerConverter::FromObject(entries_map_imported).ToString<SerializerJson>();
  Print("entries imported: ", entries_imported_json);

  string configs2_imported = SerializerConverter::FromObject(configs2).ToString<SerializerJson>();
  Print("configs2 imported: ", configs2_imported);

  SerializerConverter stub4(Serializer::MakeStubObject<DictStruct<string, SerializableEntry>>(0, 1, 6));
  SerializerConverter::FromObject(entries_map)
      .ToFile<SerializerCsv>("configs_key.csv", SERIALIZER_CSV_INCLUDE_TITLES_TREE | SERIALIZER_CSV_INCLUDE_KEY,
                             &stub4);

  BufferStruct<DataParamEntry> buff_params;

  DataParamEntry pair = "XLMBTC";
  DataParamEntry startDate = StrToTime("2020.01.01 00:00");
  DataParamEntry endDate = StrToTime("2025.03.05 23:23");
  DataParamEntry enable = true;
  DataParamEntry limit = 5;
  DataParamEntry doubleVal = 7.5;

  buff_params.Add(pair, 1);
  buff_params.Add(startDate, 2);
  buff_params.Add(endDate, 3);
  buff_params.Add(enable, 4);
  buff_params.Add(limit, 5);
  buff_params.Add(doubleVal, 6);

  SerializerConverter stub5 = SerializerConverter::MakeStubObject<BufferStruct<DataParamEntry>>();
  SerializerConverter::FromObject(buff_params)
      .ToFile<SerializerCsv>("buffer_struct.csv", SERIALIZER_CSV_INCLUDE_TITLES_TREE | SERIALIZER_CSV_INCLUDE_KEY,
                             &stub5);

  SerializerConverter::FromObject(buff_params).ToFileBinary<SerializerBinary>("buffer_struct.bin");

  SerializableSubEntry dynamic_feature_entry(1, 2, 3, 4);

  string subentry_none_json =
      SerializerConverter::FromObject(dynamic_feature_entry).ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES);
  string subentry_dynamic_json = SerializerConverter::FromObject(dynamic_feature_entry, SERIALIZER_FLAG_INCLUDE_DYNAMIC)
                                     .ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES);
  string subentry_feature_json = SerializerConverter::FromObject(dynamic_feature_entry, SERIALIZER_FLAG_INCLUDE_FEATURE)
                                     .ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES);
  string subentry_dynamic_feature_json =
      SerializerConverter::FromObject(dynamic_feature_entry,
                                      SERIALIZER_FLAG_INCLUDE_DYNAMIC | SERIALIZER_FLAG_INCLUDE_FEATURE)
          .ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES);

  Print("subentry_none_json = ", subentry_none_json);
  Print("subentry_dynamic_json = ", subentry_dynamic_json);
  Print("subentry_feature_json = ", subentry_feature_json);
  Print("subentry_dynamic_feature_json = ", subentry_dynamic_feature_json);

  assertTrueOrFail(subentry_none_json == "{\"x\":1,\"y\":2,\"dynamic\":3,\"feature\":4}",
                   "Serializer flags not obeyed!");
  assertEqualOrFail(subentry_dynamic_json, "{\"dynamic\":3}", "Serializer flags not obeyed!");
  assertTrueOrFail(subentry_feature_json == "{\"feature\":4}", "Serializer flags not obeyed!");
  assertTrueOrFail(subentry_dynamic_feature_json == "{\"dynamic\":3,\"feature\":4}", "Serializer flags not obeyed!");

  Dict<int, string> todict_1_dst;
  SerializerConverter::FromObject<DictStruct<int, SerializableEntry>>(entries).ToDict<Dict<int, string>, string>(
      todict_1_dst);
  string todict_1_dst_json = SerializerConverter::FromObject<Dict<int, string>>(todict_1_dst)
                                 .ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES);
  assertTrueOrFail(todict_1_dst_json ==
                       "[\"entry 1\",\"1\",\"5\",\"1\",\"0\",\"0\",\"0\",\"entry "
                       "2\",\"2\",\"5\",\"2\",\"0\",\"0\",\"0\",\"2\",\"1\",\"0\",\"0\",\"entry "
                       "3\",\"3\",\"0\",\"3\",\"0\",\"0\",\"0\",\"3\",\"1\",\"0\",\"0\",\"3\",\"2\",\"0\",\"0\"]",
                   "ToDict() invalid output!");

  return INIT_SUCCEEDED;
}
