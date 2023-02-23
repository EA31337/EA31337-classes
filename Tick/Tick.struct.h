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
 * MqlTick structure.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../DateTime.extern.h"

#ifndef __MQL__
/**
 * Structure for storing the latest prices of the symbol.
 * @docs
 * https://www.mql5.com/en/docs/constants/structures/mqltick
 */
struct MqlTick {
  datetime time;         // Time of the last prices update.
  double ask;            // Current Ask price.
  double bid;            // Current Bid price.
  double last;           // Price of the last deal (last).
  double volume_real;    // Volume for the current last price with greater accuracy.
  long time_msc;         // Time of a price last update in milliseconds.
  unsigned int flags;    // Tick flags.
  unsigned long volume;  // Volume for the current last price.
  // Default constructor.
  MqlTick() {}

  // Copy constructor.
  MqlTick(const MqlTick &r) {
    time = r.time;
    ask = r.ask;
    bid = r.bid;
    last = r.last;
    volume_real = r.volume_real;
    time_msc = r.time_msc;
    flags = r.flags;
    volume = r.volume;
  }
};
#endif

/**
 * Structure for storing ask and bid prices of the symbol.
 */
template <typename T>
struct TickAB {
  T ask;  // Current Ask price.
  T bid;  // Current Bid price.
  // Struct constructors.
  TickAB(T _ask = 0, T _bid = 0) : ask(_ask), bid(_bid) {}
  TickAB(MqlTick &_tick) : ask((T)_tick.ask), bid((T)_tick.bid) {}
};

struct DoubleTickAB : TickAB<double> {};

/**
 * Structure for storing ask and bid prices of the symbol.
 */
template <typename T>
struct TickTAB : TickAB<T> {
  long time_ms;  // Time of the last prices update.
  // Struct constructors.
  TickTAB(long _time_ms = 0, T _ask = 0, T _bid = 0) : TickAB<T>(_ask, _bid), time_ms(_time_ms) {}
  TickTAB(MqlTick &_tick) : TickAB<T>(_tick), time_ms(_tick.time_msc) {}
  TickTAB(const TickTAB &r) { THIS_REF = r; }

  /**
   * Method used by ItemsHistory.
   */
  long GetTimeMs() { return time_ms; }

  /**
   * Returns time as timestamp (in seconds).
   */
  long GetTimestamp() { return time_ms; }

  /**
   * Method used by ItemsHistory.
   */
  long GetLengthMs() {
    // Ticks have length of 0ms, so next tick could be at least 1ms after the previous tick.
    return 0;
  }
};

struct DoubleTickTAB : TickTAB<double> {};

#ifdef EMSCRIPTEN
#include <emscripten/bind.h>

EMSCRIPTEN_BINDINGS(TickAB) {
  emscripten::value_object<TickAB<double>>("TickAB")
      .field("ask", &TickAB<double>::ask)
      .field("bid", &TickAB<double>::bid);
}

EMSCRIPTEN_BINDINGS(TickTAB) {
  // emscripten::value_object<TickTAB<double>, emscripten::base<TickAB<double>>>("TickTABDouble")
  emscripten::value_object<TickTAB<double>>("TickTAB")
      .field("ask", &TickAB<double>::ask)
      .field("bid", &TickAB<double>::bid)
      .field("time_ms", &TickTAB<double>::time_ms);
}

REGISTER_ARRAY_OF(ArrayTickTABDouble, TickTAB<double>, "TickTABArray");

#endif
