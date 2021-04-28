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
 * Test functionality of Redis class.
 */

// Includes.
#include "../Redis.mqh"
#include "../Socket.mqh"
#include "../Test.mqh"

// Properties.
#property strict

/**
 * Implements OnInit().
 */
int OnInit() {
  Redis redis("localhost", 6379, false);

  assertTrueOrFail(redis.Ping(), "Redis should have said \"PONG\"!");

  redis.Delete("unknown");
  redis.Delete("known");
  redis.Delete("number1");

  assertTrueOrFail(redis.GetString("unknown") == NULL, "GetString for \"unknown\" key should return NULL!");

  redis.SetString("known", "5", 1000);
  assertTrueOrFail(redis.GetString("known") == "5", "GetString for \"known\" key should return \"5\"!");

  Sleep(1100);
  assertTrueOrFail(redis.GetString("known") == NULL, "\"known\" key should expire after 1000ms!");

  redis.Increment("number1", 2);
  assertTrueOrFail(redis.GetString("number1") == "2", "GetString for \"number1\" key should return \"2\"!");
  redis.Decrement("number1", 2);
  assertTrueOrFail(redis.GetString("number1") == "0", "GetString for \"number1\" key should return \"0\"!");

  redis.Publish("chat", "hello world");
  redis.Publish("chat", "hello again!");

  return (INIT_SUCCEEDED);
}
