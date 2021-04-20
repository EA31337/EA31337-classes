//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
#include "../Chart.mqh"
#include "../Data.struct.h"
#include "../SerializerConverter.mqh"
#include "../SerializerJSON.mqh"
#include "../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  // Test 1 (DataParamEntry).
  BufferStruct<DataParamEntry> buff_params;

  DataParamEntry pair = {TYPE_STRING, 0, 0, "XLMBTC"};
  DataParamEntry startDate = {TYPE_DATETIME, D'2020.01.01 00:00', 0, ""};
  DataParamEntry endDate = {TYPE_DATETIME, D'2025.03.05 23:23', 0, ""};
  DataParamEntry enable = {TYPE_BOOL, 1, 0, ""};
  DataParamEntry limit = {TYPE_INT, 5, 0, ""};
  DataParamEntry doubleVal = {TYPE_DOUBLE, 0, 7.5, ""};

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
