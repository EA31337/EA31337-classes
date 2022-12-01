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

/**
 * @file
 * Includes external declarations related to date and time.
 */
#ifndef __MQL__
#pragma once

// Includes.
#include <time.h>

#include "DateTime.enum.h"
#include "String.mqh"

// Forward declarations.
struct MqlDateTime;

/**
 * MQL's "datetime" type.
 */
class datetime {
  time_t dt;

 public:
  datetime() { dt = 0; }
  datetime(const long& _time) { dt = _time; }
  // datetime(const int& _time);
  bool operator==(const int _time) const = delete;
  bool operator==(const datetime& _time) const { return dt == _time; }
  bool operator<(const int _time) const = delete;
  bool operator>(const int _time) const = delete;
  bool operator<(const datetime& _time) const { return dt < _time; }
  bool operator>(const datetime& _time) const { return dt > _time; }
  operator long() const { return dt; }
};

extern int CopyTime(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count,
                    ARRAY_REF(datetime, time_array));

extern int CopyTime(string symbol_name, ENUM_TIMEFRAMES timeframe, datetime start_time, int count,
                    ARRAY_REF(datetime, time_array));

extern int CopyTime(string symbol_name, ENUM_TIMEFRAMES timeframe, datetime start_time, datetime stop_time,
                    ARRAY_REF(datetime, time_array));

extern datetime StructToTime(MqlDateTime& dt_struct);
extern bool TimeToStruct(datetime dt, MqlDateTime& dt_struct);
extern datetime TimeGMT();
extern datetime TimeGMT(MqlDateTime& dt_struct);
extern datetime TimeTradeServer();
extern datetime TimeTradeServer(MqlDateTime& dt_struct);
extern datetime StringToTime(const string& value);
string TimeToString(datetime value, int mode = TIME_DATE | TIME_MINUTES) {
  /*
  auto now = std::chrono::time_point();
  auto in_time_t = std::chrono::system_clock::to_time_t(now);
  */
  std::stringstream ss;
  ss << __FUNCTION__ << " is not yet implemented!";
  // ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %X");
  return ss.str();
}

template <char... T>
datetime operator"" _D();

#define DATETIME_LITERAL(STR) _D " ## STR ## "

#endif
