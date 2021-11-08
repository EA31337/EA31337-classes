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
#include "ISerializable.h"
#include "MqlTick.h"
#include "SymbolInfo.struct.static.h"

// Defines struct to store symbol data.
struct SymbolInfoEntry
#ifndef __MQL__
    : public ISerializable
#endif
{
  double bid;            // Current Bid price.
  double ask;            // Current Ask price.
  double last;           // Price of the last deal.
  double spread;         // Current spread.
  unsigned long volume;  // Volume for the current last price.
  // Constructor.
  SymbolInfoEntry() : bid(0), ask(0), last(0), spread(0), volume(0) {}
  SymbolInfoEntry(const MqlTick& _tick, const string _symbol = "") {
    bid = _tick.bid;
    ask = _tick.ask;
    last = _tick.last;
    volume = _tick.volume;
    spread = (unsigned int)round((ask - bid) * pow(10, SymbolInfoStatic::SymbolInfoInteger(_symbol, SYMBOL_DIGITS)));
  }
  // Getters
  string ToCSV() { return StringFormat("%g,%g,%g,%g,%d", bid, ask, last, spread, volume); }
// Serializers.
#ifdef __MQL__
  template <>
#endif
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {
  }
  SerializerNodeType Serialize(Serializer& _s);
};

// Defines structure for SymbolInfo properties.
struct SymbolInfoProp {
  double pip_value;          // Pip value.
  unsigned int pip_digits;   // Pip digits (precision).
  unsigned int pts_per_pip;  // Points per pip.
  unsigned int vol_digits;   // Volume digits.
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s);
};

#include "Serializer.mqh"

SerializerNodeType SymbolInfoEntry::Serialize(Serializer& _s) {
  _s.Pass(THIS_REF, "ask", ask);
  _s.Pass(THIS_REF, "bid", bid);
  _s.Pass(THIS_REF, "last", last);
  _s.Pass(THIS_REF, "spread", spread);
  _s.Pass(THIS_REF, "volume", volume);
  return SerializerNodeObject;
}

SerializerNodeType SymbolInfoProp::Serialize(Serializer& _s) {
  _s.Pass(THIS_REF, "pip_value", pip_value);
  _s.Pass(THIS_REF, "pip_digits", pip_digits);
  _s.Pass(THIS_REF, "pts_per_pip", pts_per_pip);
  _s.Pass(THIS_REF, "vol_digits", vol_digits);
  return SerializerNodeObject;
}
