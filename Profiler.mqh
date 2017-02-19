//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
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

// Properties.
#property strict

// Includes.
#include "Collection.mqh"
#include "Timer.mqh"

// Define macros.
#define PROFILER_START \
  static Timer *_timer = new Timer(__FUNCTION__); \
  ((Timer *) Profiler::timers.Get(_timer)).TimerStart();
#define PROFILER_STOP        ((Timer *) Profiler::timers.Get(_timer)).TimerStop();
#define PROFILER_STOP_MAX    ((Timer *) Profiler::timers.Get(_timer)).TimerStop().PrintOnMax(ProfilingMinTime);
#define PROFILER_PRINT(ms)   Print(Profiler::timers.ToString(ms));
#define PROFILER_DEINIT      Profiler::Deinit();

/**
 * Class to provide performance profiler functionality.
 */
class Profiler {

  public:

    // Variables.
    static Collection *timers;
    static ulong min_time;

    /* Class methods */

    /**
     * Class deconstructor.
     */
    void Profiler()  { };
    void ~Profiler() { Deinit(); };
    static void Deinit() { delete Profiler::timers; };
};

// Initialize static global variables.
Collection *Profiler::timers = new Collection("Profiler");
ulong Profiler::min_time = 1;