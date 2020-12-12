//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
 * Includes Chart's structs.
 */

// Forward class declaration.
class Class;
class Serializer;

// Includes.
#include "Bar.struct.h"
#include "Chart.enum.h"
#include "SerializerNode.enum.h"

// Wrapper struct that returns open time of each bar of the current chart.
// @docs: https://docs.mql4.com/predefined/time
struct ChartBarTime {
 protected:
  string symbol;
  ENUM_TIMEFRAMES tf;

 public:
  ChartBarTime() : symbol(_Symbol), tf(PERIOD_CURRENT) {}
  datetime operator[](const int _shift) const { return Get(symbol, tf, _shift); }
  static datetime Get(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _shift) {
    return Chart::iTime(_symbol, _tf, _shift);
  }
};

// Defines struct to store bar entries.
struct ChartEntry {
  BarEntry bar;
  // Constructors.
  ChartEntry() {}
  ChartEntry(const BarEntry& _bar) { bar = _bar; }
  // Getters.
  BarEntry GetBar() { return bar; }
  string ToCSV() { return StringFormat("%s", bar.ToCSV()); }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    _s.PassStruct(this, "bar", bar);
    return SerializerNodeObject;
  }
};

// Defines struct for chart parameters.
struct ChartParams {
  ENUM_TIMEFRAMES tf;
  ENUM_TIMEFRAMES_INDEX tfi;
  ENUM_PP_TYPE pp_type;
  // Constructor.
  void ChartParams(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : tf(_tf), tfi(Chart::TfToIndex(_tf)), pp_type(PP_CLASSIC){};
  void ChartParams(ENUM_TIMEFRAMES_INDEX _tfi) : tfi(_tfi), tf(Chart::IndexToTf(_tfi)), pp_type(PP_CLASSIC){};
  // Getters.
  ENUM_TIMEFRAMES GetTf() { return tf; }
  // Setters.
  void SetPP(ENUM_PP_TYPE _pp) { pp_type = _pp; }
  void SetTf(ENUM_TIMEFRAMES _tf) {
    tf = _tf;
    tfi = Chart::TfToIndex(_tf);
  };
  // Serializers.
  SerializerNodeType Serialize(Serializer& s) {
    s.PassEnum(this, "tf", tf);
    s.PassEnum(this, "tfi", tfi);
    s.PassEnum(this, "pp_type", pp_type);
    return SerializerNodeObject;
  }
};

// Wrapper struct that returns close prices of each bar of the current chart.
// @docs: https://docs.mql4.com/predefined/close
struct ChartPriceClose {
 protected:
  string symbol;
  ENUM_TIMEFRAMES tf;

 public:
  ChartPriceClose() : symbol(_Symbol), tf(PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol, tf, _shift); }
  static double Get(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _shift) {
    return Chart::iClose(_symbol, _tf, _shift);
  }
};

// Wrapper struct that returns the highest prices of each bar of the current chart.
// @docs: https://docs.mql4.com/predefined/high
struct ChartPriceHigh {
 protected:
  string symbol;
  ENUM_TIMEFRAMES tf;

 public:
  ChartPriceHigh() : symbol(_Symbol), tf(PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol, tf, _shift); }
  static double Get(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _shift) {
    return Chart::iHigh(_symbol, _tf, _shift);
  }
};

// Wrapper struct that returns the lowest prices of each bar of the current chart.
// @docs: https://docs.mql4.com/predefined/low
struct ChartPriceLow {
 protected:
  string symbol;
  ENUM_TIMEFRAMES tf;

 public:
  ChartPriceLow() : symbol(_Symbol), tf(PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol, tf, _shift); }
  static double Get(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _shift) {
    return Chart::iLow(_symbol, _tf, _shift);
  }
};

// Wrapper struct that returns open prices of each bar of the current chart.
// @docs: https://docs.mql4.com/predefined/open
struct ChartPriceOpen {
 protected:
  string symbol;
  ENUM_TIMEFRAMES tf;

 public:
  ChartPriceOpen() : symbol(_Symbol), tf(PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol, tf, _shift); }
  static double Get(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _shift) {
    return Chart::iOpen(_symbol, _tf, _shift);
  }
};
