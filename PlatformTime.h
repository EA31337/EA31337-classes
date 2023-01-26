//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Includes.
#include "DateTime.enum.h"
#include "DateTime.mqh"

/**
 * @file
 * Platform time retrieval.
 */
#ifndef __MQL__
#pragma once

// Includes.
#include <chrono>
#include <ctime>

#include "DateTime.struct.h"
#endif

class PlatformTime {
  static MqlDateTime current_time;
  static long current_timestamp_s;
  static long current_timestamp_ms;

 public:
  static long CurrentTimestamp() { return current_timestamp_s; }
  static long CurrentTimestampMs() { return current_timestamp_ms; }
  static MqlDateTime CurrentTime() { return current_time; }

  void static Tick() {
#ifdef __MQL__
    static long _last_timestamp_ms = 0;

    current_timestamp_s = ::TimeCurrent(current_time);

    current_timestamp_ms = (long)GetTickCount();

    if (_last_timestamp_ms != 0 && current_timestamp_ms < _last_timestamp_ms) {
      // Overflow occured (49.7 days passed).
      // More info: https://docs.mql4.com/common/gettickcount
      current_timestamp_ms += _last_timestamp_ms;
    }

    _last_timestamp_ms = current_timestamp_ms;
#else
    using namespace std::chrono;
    current_timestamp_s = (long)duration_cast<seconds>(system_clock::now().time_since_epoch()).count();
    current_timestamp_ms = (long)duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();

    using namespace std::chrono;
    std::time_t t = std::time(0);
    std::tm* now = std::localtime(&t);
    current_time.day = now->tm_mday;
    current_time.day_of_week = now->tm_wday;
    current_time.day_of_year = now->tm_yday;
    current_time.hour = now->tm_hour;
    current_time.min = now->tm_min;
    current_time.mon = now->tm_mon;
    current_time.sec = now->tm_sec;
    current_time.year = now->tm_year;
#endif
  }
};

MqlDateTime PlatformTime::current_time = {0, 0, 0, 0, 0, 0, 0, 0};
long PlatformTime::current_timestamp_s = 0;
long PlatformTime::current_timestamp_ms = 0;
