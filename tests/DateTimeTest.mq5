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
 * Test functionality of Timer class.
 */

// Includes.
#include "../DateTime.mqh"
#include "../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  // Test OnInit() timer.
  PrintFormat("Testing %s...", __FUNCTION__);
  datetime curr_dt = TimeCurrent();
  DateTime *dt = new DateTime();
  DateTimeEntry entry = dt.GetEntry();
  assertTrueOrFail(curr_dt == entry.GetTimestamp(), "Timestamp not match!");
  entry.SetSeconds(1);
  assertTrueOrFail(entry.GetSeconds() == 1, "Seconds not match!");
  entry.SetValue(DATETIME_SECOND, 2);
  assertTrueOrFail(entry.GetValue(DATETIME_SECOND) == 2, "Seconds not match!");
  entry.SetMinute(1);
  assertTrueOrFail(entry.GetMinute() == 1, "Minute not match!");
  entry.SetValue(DATETIME_MINUTE, 2);
  assertTrueOrFail(entry.GetValue(DATETIME_MINUTE) == 2, "Seconds not match!");
  entry.SetHour(1);
  assertTrueOrFail(entry.GetHour() == 1, "Hour not match!");
  entry.SetValue(DATETIME_HOUR, 2);
  assertTrueOrFail(entry.GetValue(DATETIME_HOUR) == 2, "Hour not match!");
  entry.SetDayOfMonth(1);
  assertTrueOrFail(entry.GetDayOfMonth() == 1, "Day not match!");
  entry.SetValue(DATETIME_DAY, 2);
  assertTrueOrFail(entry.GetValue(DATETIME_DAY) == 2, "Day not match!");
  entry.SetMonth(1);
  assertTrueOrFail(entry.GetMonth() == 1, "Month not match!");
  entry.SetValue(DATETIME_MONTH, 2);
  assertTrueOrFail(entry.GetValue(DATETIME_MONTH) == 2, "Month not match!");
  entry.SetYear(2000);
  assertTrueOrFail(entry.GetYear() == 2000, "Year not match!");
  entry.SetValue(DATETIME_YEAR, 2);
  assertTrueOrFail(entry.GetValue(DATETIME_YEAR) == 2, "Year not match!");
  // Resets datetime to current one.
  dt.Update();
  entry = dt.GetEntry();
  assertTrueOrFail(curr_dt == entry.GetTimestamp(), "Timestamp not match!");
  // Test IsNewMinute() method.
  entry.SetSeconds(1);
  dt.SetEntry(entry);
  assertFalseOrFail(dt.IsNewMinute(false), "IsNewMinute() test failed.");
  entry.SetSeconds(10);
  dt.SetEntry(entry);
  assertFalseOrFail(dt.IsNewMinute(false), "IsNewMinute() test failed.");
  entry.SetSeconds(0);
  dt.SetEntry(entry);
  assertTrueOrFail(dt.IsNewMinute(false), "IsNewMinute() test failed.");
  entry.SetSeconds(1);
  dt.SetEntry(entry);
  assertFalseOrFail(dt.IsNewMinute(false), "IsNewMinute() test failed.");
  delete dt;
  return (GetLastError() == 0 ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements OnTick().
 */
void OnTick() {}

/**
 * Implements OnDeinit().
 */
void OnDeinit(const int reason) {}
