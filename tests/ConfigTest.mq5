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

/**
 * @file
 * Test functionality of Config class.
 */

// Includes.
#include "../Config.mqh"
#include "../Data.define.h"
#include "../Dict.mqh"
#include "../DictObject.mqh"
#include "../Serializer/SerializerConverter.h"
#include "../Serializer/SerializerCsv.h"
#include "../Serializer/SerializerJson.h"
#include "../Test.mqh"

class Test {
 public:
  int _a, _b;

  Dict<int, int> _ints;

  Test(int a = 0, int b = 0) : _a(a), _b(b) {}

  Test(int a, int b, int& ints[]) : _a(a), _b(b) {
    for (int i = 0; i < ArraySize(ints); ++i) _ints.Push(ints[i]);
  }

  Test(const Test& r) {
    _a = r._a;
    _b = r._b;
    _ints = r._ints;
  }

  SerializerNodeType Serialize(Serializer& s) {
    s.Pass(THIS_REF, "a", _a);
    s.Pass(THIS_REF, "b", _b);
    s.PassStruct(THIS_REF, "ints", _ints);
    return SerializerNodeObject;
  }

  SERIALIZER_EMPTY_STUB;
};

// Global variables.
Config* config;

/**
 * Implements OnInit().
 */
int OnInit() {
  config = new Config();

  ConfigEntry pair = "XLMBTC";
  ConfigEntry startDate = StrToTime("2020.01.01 00:00");
  ConfigEntry endDate = StrToTime("2025.03.05 23:23");
  ConfigEntry enable = true;
  ConfigEntry limit = 5;
  ConfigEntry max = 7.5;

  config.Set("pair", pair);
  config.Set("startDate", startDate);
  config.Set("endDate", endDate);
  config.Set("enable", enable);
  config.Set("limit", limit);
  config.Set("max", max);

  config.Set("otherPair", "XLMBTC");
  config.Set("otherStartDate", StrToTime("2020.01.01 00:00"));
  config.Set("otherEndDate", StrToTime("2025.03.05 23:23"));
  config.Set("otherEnable", true);
  config.Set("otherLimit", 5);
  config.Set("otherMax", 7.5);

  assertTrueOrFail(config.SaveToFile<SerializerJson>("config.json"), "Cannot save config into the file!");
  assertTrueOrFail(config.SaveToFile<SerializerJson>("config-minified.json", 0, SERIALIZER_JSON_NO_WHITESPACES),
                   "Cannot save config into the file!");

  // @todo
  // assertTrueOrFail(config.SaveToFile("config.ini", CONFIG_FORMAT_INI), "Cannot save config into the file!");
  assertTrueOrFail(config.LoadFromFile<SerializerJson>("config.json"), "Cannot load config from the file!");

  Print("There are ", config.Size(), " properites in config.");
  Print("config[\"pair\"].type = \"", EnumToString(config["pair"].type), "\"");
  Print("config[\"pair\"].string_value = \"", config["pair"].string_value, "\"");

  assertTrueOrFail(config.LoadFromFile<SerializerJson>("config-minified.json"), "Cannot save config into the file!");

  // @todo
  // assertTrueOrFail(config.LoadFromFile("config.ini", CONFIG_FORMAT_INI), "Cannot save config into the file!");

  DictObject<int, Config> configs;
  configs.Push(config);
  configs.Push(config);
  configs.Push(config);

  Print("There are ", configs[0].Size(), " properites in configs[0]!");
  Print("configs[0][\"pair\"].type = \"", EnumToString(configs[0]["pair"].type), "\"");
  Print("configs[0][\"pair\"].string_value = \"", configs[0]["pair"].string_value, "\"");

  SerializerConverter stub = SerializerConverter::MakeStubObject<DictObject<int, Config>>(0, 1, configs[0].Size());

  SerializerConverter::FromObject(configs).ToFile<SerializerCsv>("config.csv", SERIALIZER_CSV_INCLUDE_TITLES, &stub);

  SerializerConverter::FromObject(configs, 0).ToFile<SerializerJson>("config_2.json");

  DictObject<int, Config> config_2_imported;

  SerializerConverter::FromFile<SerializerJson>("config_2.json").ToObject(config_2_imported);

  Print("config_2 imported json: ", SerializerConverter::FromObject(config_2_imported).ToString<SerializerJson>());

  return (GetLastError() == 0 ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) { delete config; }
//+------------------------------------------------------------------+
