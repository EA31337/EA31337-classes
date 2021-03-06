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

/**
 * @file
 * Includes SymbolInfo's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "SerializerNode.mqh"

// Defines struct to store symbol data.
struct SymbolInfoEntry {
  double bid;            // Current Bid price.
  double ask;            // Current Ask price.
  double last;           // Price of the last deal.
  double spread;         // Current spread.
  unsigned long volume;  // Volume for the current last price.
  // Constructor.
  SymbolInfoEntry() : bid(0), ask(0), last(0), spread(0), volume(0) {}
  SymbolInfoEntry(const MqlTick& _tick, const string _symbol = NULL) {
    bid = _tick.bid;
    ask = _tick.ask;
    last = _tick.last;
    volume = _tick.volume;
    spread = SymbolInfo::GetRealSpread(bid, ask, SymbolInfo::GetDigits(_symbol));
  }
  // Getters
  string ToCSV() { return StringFormat("%g,%g,%g,%g,%d", bid, ask, last, spread, volume); }
  // Serializers.
  template <>
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    _s.Pass(this, "ask", ask);
    _s.Pass(this, "bid", bid);
    _s.Pass(this, "last", last);
    _s.Pass(this, "spread", spread);
    _s.Pass(this, "volume", volume);
    return SerializerNodeObject;
  }
};

// Defines structure for SymbolInfo properties.
struct SymbolInfoProp {
  double pip_value;          // Pip value.
  unsigned int pip_digits;   // Pip digits (precision).
  unsigned int pts_per_pip;  // Points per pip.
  unsigned int vol_digits;   // Volume digits.
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    _s.Pass(this, "pip_value", pip_value);
    _s.Pass(this, "pip_digits", pip_digits);
    _s.Pass(this, "pts_per_pip", pts_per_pip);
    _s.Pass(this, "vol_digits", vol_digits);
    return SerializerNodeObject;
  }
};

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
};
#endif
