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
#include "Serializer/Serializable.h"
#include "Std.h"
#include "SymbolInfo.struct.static.h"
#include "Tick/Tick.struct.h"
#include "Serializer/Serializer.h"

// Defines struct to store symbol data.
struct SymbolInfoEntry
#ifndef __MQL__
    : public Serializable
#endif
{
  double bid;            // Current Bid price.
  double ask;            // Current Ask price.
  double last;           // Price of the last deal.
  double spread;         // Current spread.
  unsigned long volume;  // Volume for the current last price.
  // Constructors.
  SymbolInfoEntry() : bid(0), ask(0), last(0), spread(0), volume(0) {}
  SymbolInfoEntry(const MqlTick& _tick, const string _symbol = "") {
    bid = _tick.bid;
    ask = _tick.ask;
    last = _tick.last;
    volume = _tick.volume;
    spread = (unsigned int)round((ask - bid) * pow(10, SymbolInfoStatic::SymbolInfoInteger(_symbol, SYMBOL_DIGITS)));
  }
  // Copy constructor.
  SymbolInfoEntry(const SymbolInfoEntry& _sie) { this = _sie; }
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
  bool initialized;
  double pip_value;          // Pip value.
  unsigned int digits;       // Currency digits? @fixit
  unsigned int pip_digits;   // Pip digits (precision).
  unsigned int pts_per_pip;  // Points per pip.
  unsigned int vol_digits;   // Volume digits.
  double vol_min;            // Minimum volume for a deal.
  double vol_max;            // Maximum volume for a deal.
  double vol_step;           // Minimal volume change step for deal execution.
  double point_size;         // Symbol point value.
  double tick_size;          // Minimal price change.
  double tick_value;         // Calculated tick price for a profitable position.
  double swap_long;          // Swap of the buy order.
  double swap_short;         // Swap of the sell order.
  double margin_initial;  // Initial margin means the amount in the margin currency required for opening an order with
                          // the volume of one lot.
  double margin_maintenance;  // If it is set, it sets the margin amount in the margin currency of the symbol, charged
                              // from one lot.
  int freeze_level;           // Distance to freeze trade operations in points.

  // Constructors.
  SymbolInfoProp() : initialized(false) {}
  SymbolInfoProp(const SymbolInfoProp& _sip) {
    initialized = _sip.initialized;
    pip_value = _sip.pip_value;
    digits = _sip.digits;
    pip_digits = _sip.pip_digits;
    pts_per_pip = _sip.pts_per_pip;
    vol_digits = _sip.vol_digits;
    vol_min = _sip.vol_min;
    vol_max = _sip.vol_max;
    vol_step = _sip.vol_step;
    point_size = _sip.point_size;
    tick_size = _sip.tick_size;
    tick_value = _sip.tick_value;
    swap_long = _sip.swap_long;
    swap_short = _sip.swap_short;
    margin_initial = _sip.margin_initial;
    margin_maintenance = _sip.margin_maintenance;
    freeze_level = _sip.freeze_level;
  }
  // Getters.
  double GetPipValue() { return pip_value; }
  unsigned int GetDigits() { return digits; }
  unsigned int GetPipDigits() { return pip_digits; }
  unsigned int GetPointsPerPip() { return pts_per_pip; }
  unsigned int GetVolumeDigits() { return vol_digits; }
  double GetVolumeMin() { return vol_min; }
  double GetVolumeMax() { return vol_max; }
  double GetVolumeStep() { return vol_step; }
  double GetPointSize() { return point_size; }
  double GetTickSize() { return tick_size; }
  double GetTickValue() { return tick_value; }
  double GetSwapLong() { return swap_long; }
  double GetSwapShort() { return swap_short; }
  double GetMarginInit() { return margin_initial; }
  double GetMarginMaintenance() { return margin_maintenance; }
  int GetFreezeLevel() { return freeze_level; }

  /**
   * Normalize price value.
   *
   * Make sure that the price is a multiple of ticksize.
   */
  double NormalizePrice(double p) {
    // See: http://forum.mql4.com/47988
    // http://forum.mql4.com/43064#515262 zzuegg reports for non-currency DE30:
    // - MarketInfo(chart.symbol,MODE_TICKSIZE) returns 0.5
    // - MarketInfo(chart.symbol,MODE_DIGITS) return 1
    // - Point = 0.1
    // Rare fix when a change in tick size leads to a change in tick value.
    double _result = round(p / GetPointSize()) * GetTickSize();
    _result = NormalizeDouble(_result, GetDigits());
    return _result;
  }

  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s);
};

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
  _s.Pass(THIS_REF, "vol_min", vol_min);
  _s.Pass(THIS_REF, "vol_max", vol_max);
  _s.Pass(THIS_REF, "vol_step", vol_step);
  _s.Pass(THIS_REF, "point_size", point_size);
  _s.Pass(THIS_REF, "tick_size", tick_size);
  _s.Pass(THIS_REF, "tick_value", tick_value);
  _s.Pass(THIS_REF, "swap_long", swap_long);
  _s.Pass(THIS_REF, "swap_short", swap_short);
  _s.Pass(THIS_REF, "margin_initial", margin_initial);
  _s.Pass(THIS_REF, "margin_maintenance", margin_maintenance);
  _s.Pass(THIS_REF, "freeze_level", freeze_level);
  return SerializerNodeObject;
}
