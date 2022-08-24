//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of BufferStruct class.
 */

// Includes
#include "../BufferStruct.mqh"
#include "../Data.define.h"
#include "../Data.struct.h"
#include "../Serializer/SerializerConverter.h"
#include "../Serializer/SerializerJSON.h"
#include "../Std.h"
#include "../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  // Test 1 (DataParamEntry).
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
  assertTrueOrFail(buff_params.GetByKey(1) == pair, "Struct value for 'pair' not correct!");
  assertTrueOrFail(buff_params.GetByKey(2) == startDate, "Struct value for 'startDate' not correct!");
  assertTrueOrFail(buff_params.GetByKey(3) == endDate, "Struct value for 'endDate' not correct!");
  assertTrueOrFail(buff_params.GetByKey(4) == enable, "Struct value for 'enable' not correct!");
  assertTrueOrFail(buff_params.GetByKey(5) == limit, "Struct value for 'limit' not correct!");
  assertTrueOrFail(buff_params.GetByKey(6) == doubleVal, "Struct value for 'doubleVal' not correct!");

  // Print("Dict (string): ", buff_params.ToString()); // @fixme: GH-115.

  Print("Dict (JSON): ",
        SerializerConverter::FromObject(buff_params, SERIALIZER_FLAG_SKIP_HIDDEN).ToString<SerializerJson>());

  return (GetLastError() > 0 ? INIT_FAILED : INIT_SUCCEEDED);
}

/**
 * Implements OnTick().
 */
void OnTick() {}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {}
