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
#include "Platform/Chart/Chart.h"
#include "Platform/Platform.h"

/**
 * Class to collect ticks, bars and other data for statistical purposes.
 */
class Stats {
 public:
  uint64 total_bars;
  uint64 total_ticks;
  int curr_period;
  // int custom_int[];
  // double custom_dbl[];

  /**
   * Implements class constructor.
   */
  Stats(void) { Reset(); }

  /**
   * Implements class destructor.
   */
  ~Stats(void) {}

  void Reset() {
    curr_period = Period();
    total_bars = 0;
    total_ticks = 0;
  }

  /**
   * Update stats on tick.
   */
  void OnTick() {
    static int64 _last_bar_time = 0;
    total_ticks++;
    if (_last_bar_time != Platform::Timestamp()) {
      _last_bar_time = Platform::Timestamp();
      total_bars++;
    }
  }

  /**
   * Update stats on deinit.
   */
  void OnDeinit() {}

  /* Getters */

  /**
   * Get number of counted bars.
   */
  uint64 GetTotalBars() { return (total_bars); }

  /**
   * Get number of counted ticks.
   */
  uint64 GetTotalTicks() { return (total_ticks); }

  /**
   * Get number of ticks per bar.
   */
  uint64 GetTicksPerBar() { return (total_bars > 0 ? (total_ticks / total_bars) : 0); }

  /**
   * Get number of ticks per minute.
   */
  uint64 GetTicksPerMin() { return (total_bars > 0 ? (total_ticks / total_bars / curr_period) : 0); }

  /**
   * Get number of ticks per second.
   */
  double GetTicksPerSec() { return round(total_bars > 0 ? (total_ticks / total_bars / curr_period) / 60 : 0); }

  /**
   * Get number of ticks per given time period.
   */
  uint64 GetTicksPerPeriod(int period = PERIOD_H1) { return (GetTicksPerMin() * period); }

  /**
   * Get number of bars per given time period.
   */
  uint64 GetBarsPerPeriod(int period = PERIOD_H1) { return (total_bars / period); }
};
