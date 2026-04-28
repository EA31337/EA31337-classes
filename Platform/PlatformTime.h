//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Storage/DateTime.enum.h"
#include "../Storage/DateTime.struct.h"
#include "../Storage/DateTime.extern.h"

/**
 * @file
 * Platform time retrieval.
 */
#ifndef __MQL__

// Includes.
#include <chrono>
#include <ctime>

#endif

#include "../Std.h"

// Forward declarations to avoid circular include via Serializer.h -> Convert.basic.h -> DateTime.h -> PlatformTime.h.
class IndicatorBase;
class IndicatorData;

class PlatformTime {
  // Current tick indicator.
  static IndicatorBase* current_tick_indicator;

 public:

  /**
   * Returns current time in seconds since epoch.
   */
  static int64 TimeCurrent();

  /**
   * Returns current time in milliseconds since epoch.
   */
  static int64 CurrentTimestampMs();

  /**
   * Returns current time as MqlDateTime structure.
   */
  static MqlDateTime CurrentTime();

  /**
   * Sets the current indicator. Used to provide current tick time to indicators when they call TimeCurrent() method.
   */
  static void SetCurrentIndicator(IndicatorData* _indi);

  /**
   * Updates current tick time. Should be called on every tick with the tick time in milliseconds since epoch. In MQL,
   * it can be called without parameters as tick time can be retrieved with TimeCurrent() and GetTickCount() functions.
   */
  static void UpdateLastTickTimeMs(int64 tick_time_ms, IndicatorData* _source_indi);
};
