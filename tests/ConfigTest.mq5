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
 * Test functionality of Config class.
 */

// Includes.
#include "../Config.mqh"

// Global variables.
Config *config;

/**
 * Implements OnInit().
 */
int OnInit() {
  config = new Config();
  
  ConfigEntry pair      = {TYPE_STRING,   0,                   0, "XLMBTC"};
  ConfigEntry startDate = {TYPE_DATETIME, D'2020.01.01 00:00', 0, ""};
  ConfigEntry endDate   = {TYPE_DATETIME, D'2025.03.05 23:23', 0, ""};
  ConfigEntry enable    = {TYPE_BOOL,     1,                   0, ""};
  ConfigEntry limit     = {TYPE_INT,      5,                   0, ""};
  ConfigEntry max       = {TYPE_DOUBLE,   0,                 7.5, ""};

  config.Set("pair", pair);
  config.Set("startDate", startDate);
  config.Set("endDate", endDate);
  config.Set("enable", enable);
  config.Set("limit", limit);
  config.Set("max", max);
  
  config.Set("otherPair", "XLMBTC");
  config.Set("otherStartDate", D'2020.01.01 00:00');
  config.Set("otherEndDate", D'2025.03.05 23:23');
  config.Set("otherEnable", true);
  config.Set("otherLimit", 5);
  config.Set("otherMax", 7.5);
  
  //config.SaveToFile("bla.txt", CONFIG_FORMAT_JSON_NO_WHITESPACES);
  
  Config config2;
  config2.LoadFromFile("bla.txt", CONFIG_FORMAT_JSON_NO_WHITESPACES);


  return (GetLastError() == 0 ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {
  delete config;
}
