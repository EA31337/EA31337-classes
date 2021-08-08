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
#include "Collection.mqh"
#include "Timer.mqh"

// Defines macros.
#define PROFILER_SET_MIN(ms) Profiler::min_time = ms;
#define PROFILER_START                                \
  static Timer *_timer = NULL;                        \
  _timer = _timer ? _timer : new Timer(__FUNCTION__); \
  ((Timer *)Profiler::timers.Get(_timer)).Start();

#define PROFILER_STOP ((Timer *)Profiler::timers.Get(_timer)).Stop();
#define PROFILER_STOP_PRINT ((Timer *)Profiler::timers.Get(_timer)).Stop().PrintOnMax(Profiler::min_time);
#define PROFILER_PRINT Print(Profiler::timers.ToString(Profiler::min_time));
#define PROFILER_DEINIT Profiler::Deinit();

/**
 * Class to provide performance profiler functionality.
 */
class Profiler {
 public:
  // Variables.
  static Collection<Timer> *timers;
  static ulong min_time;

  /* Class methods */

  /**
   * Class deconstructor.
   */
  Profiler(){};
  ~Profiler() { Deinit(); };
  static void Deinit() { delete Profiler::timers; };
};

// Initialize static global variables.
Collection<Timer> *Profiler::timers = new Collection<Timer>(MQLInfoString(MQL_PROGRAM_NAME));
ulong Profiler::min_time = 1;
