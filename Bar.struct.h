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
 * Includes Bar's structs.
 */

// Includes.
#include "Bar.enum.h"
#include "SerializerNode.enum.h"

// Struct for storing OHLC values.
struct BarOHLC {
  datetime time;
  float open, high, low, close;
  // Struct constructor.
  BarOHLC() : open(0), high(0), low(0), close(0), time(0){};
  BarOHLC(float _open, float _high, float _low, float _close, datetime _time = 0)
      : time(_time), open(_open), high(_high), low(_low), close(_close) {
    if (_time == 0) {
      _time = TimeCurrent();
    }
  }
  // Struct methods.
  // Getters
  float GetAppliedPrice(ENUM_APPLIED_PRICE _ap) const {
    switch (_ap) {
      case PRICE_CLOSE:
        return close;
      case PRICE_OPEN:
        return open;
      case PRICE_HIGH:
        return high;
      case PRICE_LOW:
        return low;
      case PRICE_MEDIAN:
        return (high + low) / 2;
      case PRICE_TYPICAL:
        return (high + low + close) / 3;
      case PRICE_WEIGHTED:
        return (high + low + close + close) / 4;
      default:
        return open;
    }
  }
  float GetBody() const { return close - open; }
  float GetBodyAbs() const { return fabs(close - open); }
  float GetBodyInPct() const { return GetRange() > 0 ? 100 * GetRange() * GetBodyAbs() : 0; }
  float GetMaxOC() const { return fmax(open, close); }
  float GetMedian() const { return (high + low) / 2; }
  float GetMinOC() const { return fmin(open, close); }
  float GetPivot() const { return (high + low + close) / 3; }
  float GetPivotWithOpen() const { return (open + high + low + close) / 4; }
  float GetPivotWithOpen(float _open) const { return (_open + high + low + close) / 4; }
  float GetRange() const { return high - low; }
  float GetRangeAbs() const { return fabs(high - low); }
  float GetRangeChangeInPct() const { return 100 - (100 / open * fabs(open - GetRange())); }
  float GetRangeInPips(float _ppp) const { return GetRangeAbs() / _ppp; }
  float GetTypical() const { return (high + low + close) / 3; }
  float GetWeighted() const { return (high + low + close + close) / 4; }
  float GetWickMin() const { return fmin(GetWickLower(), GetWickUpper()); }
  float GetWickLower() const { return GetMinOC() - low; }
  float GetWickLowerInPct() const { return GetRange() > 0 ? 100 * GetRange() * GetWickLower() : 0; }
  float GetWickMax() const { return fmax(GetWickLower(), GetWickUpper()); }
  float GetWickSum() const { return GetWickLower() + GetWickUpper(); }
  float GetWickUpper() const { return high - GetMaxOC(); }
  float GetWickUpperInPct() const { return GetRange() > 0 ? 100 * GetRange() * GetWickUpper() : 0; }
  void GetValues(float& _out[]) {
    ArrayResize(_out, 4);
    int _index = ArraySize(_out) - 4;
    _out[_index++] = open;
    _out[_index++] = high;
    _out[_index++] = low;
    _out[_index++] = close;
  }
  // Serializers.
  SerializerNodeType Serialize(Serializer& s) {
    // s.Pass(this, "time", TimeToString(time));
    s.Pass(this, "open", open);
    s.Pass(this, "high", high);
    s.Pass(this, "low", low);
    s.Pass(this, "close", close);
    return SerializerNodeObject;
  }
  // Converters.
  string ToCSV() { return StringFormat("%d,%g,%g,%g,%g", time, open, high, low, close); }
};

// Struct for storing bar shape values.
struct BarShape {
  double body_size;    // Bar's body size (abs).
  double candle_size;  // Bar's candle size (can be negative).
  double head_size;    // Bar's head size.
  double range_size;   // Bar's whole range size comparing to price.
  double tail_size;    // Bar's tail size.
  // Constructor.
  BarShape() : body_size(0), candle_size(0), head_size(0), range_size(0), tail_size(0) {}
  BarShape(double _bsp, double _csp, double _hsp, double _rsp, double _tsp) {
    body_size = _bsp;
    candle_size = _csp;
    head_size = _hsp;
    range_size = _rsp;
    tail_size = _tsp;
  };
  // Getters.
  double GetBodySize() const { return body_size; }
  double GetCandleSize() const { return candle_size; }
  double GetHeadSize() const { return head_size; }
  double GetRangeSize() const { return range_size; }
  double GetTailSize() const { return tail_size; }
  double GetWickMax() const { return fmax(head_size, tail_size); }
  double GetWickMin() const { return fmin(head_size, tail_size); }
  double GetWickSum() const { return head_size + tail_size; }
  void GetValues(double& _out[]) {
    ArrayResize(_out, 5);
    int _index = ArraySize(_out) - 5;
    _out[_index++] = body_size;
    _out[_index++] = candle_size;
    _out[_index++] = head_size;
    _out[_index++] = range_size;
    _out[_index++] = tail_size;
  }
  // Serializers.
  SerializerNodeType Serialize(Serializer& s) {
    // s.Pass(this, "time", TimeToString(time));
    s.Pass(this, "body_size", body_size);
    s.Pass(this, "candle_size", candle_size);
    s.Pass(this, "head_size", head_size);
    s.Pass(this, "range_size", range_size);
    s.Pass(this, "tail_size", tail_size);
    return SerializerNodeObject;
  }
  // Converters.
  string ToCSV() { return StringFormat("%g,%g,%g,%g,%g", body_size, candle_size, head_size, range_size, tail_size); };
};

// Struct for storing candlestick patterns.
struct BarPattern {
  int pattern;
  BarPattern() : pattern(BAR_TYPE_NONE) {}
  BarPattern(const BarOHLC& _p) {
    double _body_pct = _p.GetBodyInPct();
    double _wick_lw_pct = _p.GetWickLowerInPct();
    double _wick_up_pct = _p.GetWickUpperInPct();
    SetPattern(BAR_TYPE_BEAR, _p.open > _p.close);            // Candle is bearish.
    SetPattern(BAR_TYPE_BULL, _p.open < _p.close);            // Candle is bullish.
    SetPattern(BAR_TYPE_HAS_WICK_LW, _wick_lw_pct > 0.1);     // Has lower shadow
    SetPattern(BAR_TYPE_HAS_WICK_UP, _wick_up_pct > 0.1);     // Has upper shadow
    SetPattern(BAR_TYPE_IS_DOJI_DRAGON, _wick_lw_pct >= 98);  // Has doji dragonfly pattern (upper)
    SetPattern(BAR_TYPE_IS_DOJI_GRAVE, _wick_up_pct >= 98);   // Has doji gravestone pattern (lower)
    SetPattern(BAR_TYPE_IS_HAMMER_INV, _wick_up_pct > _body_pct * 2 && _wick_lw_pct < 2);  // Has a lower hammer pattern
    SetPattern(BAR_TYPE_IS_HAMMER_UP, _wick_lw_pct > _body_pct * 2 && _wick_up_pct < 2);  // Has an upper hammer pattern
    SetPattern(BAR_TYPE_IS_HANGMAN, _wick_lw_pct > 90 && _wick_lw_pct < 98);              // Has a hanging man pattern
    SetPattern(BAR_TYPE_IS_LONG_SHADOW_LW, _wick_lw_pct >= 60);                           // Has long lower shadow
    SetPattern(BAR_TYPE_IS_LONG_SHADOW_UP, _wick_up_pct >= 60);                           // Has long upper shadow
    SetPattern(BAR_TYPE_IS_MARUBOZU, _body_pct >= 98);                            // Full body with no or small wicks
    SetPattern(BAR_TYPE_IS_SHAVEN_LW, _wick_up_pct > 50 && _wick_lw_pct < 2);     // Has a shaven bottom pattern
    SetPattern(BAR_TYPE_IS_SHAVEN_UP, _wick_lw_pct > 50 && _wick_up_pct < 2);     // Has a shaven head pattern
    SetPattern(BAR_TYPE_IS_SPINNINGTOP, _wick_lw_pct > 30 && _wick_lw_pct > 30);  // Has a spinning top pattern
    // Body patterns.
    SetPattern(BAR_TYPE_BODY_GT_MED, _p.GetMinOC() > _p.GetMedian());    // Body is above the median price
    SetPattern(BAR_TYPE_BODY_GT_WICK, _p.GetBody() > _p.GetWickMin());   // Body is higher than each wick
    SetPattern(BAR_TYPE_BODY_GT_WICKS, _p.GetBody() > _p.GetWickSum());  // Body is higher than sum of wicks
    SetPattern(BAR_TYPE_BODY_LT_MED, _p.GetMinOC() < _p.GetMedian());    // Body is below the median price
  }
  // Struct methods for bitwise operations.
  bool CheckPattern(int _flags) { return (pattern & _flags) != 0; }
  bool CheckPatternsAll(int _flags) { return (pattern & _flags) == _flags; }
  void AddPattern(int _flags) { pattern |= _flags; }
  void RemovePattern(int _flags) { pattern &= ~_flags; }
  void SetPattern(ENUM_BAR_PATTERN _flag, bool _value = true) {
    if (_value) {
      AddPattern(_flag);
    } else {
      RemovePattern(_flag);
    }
  }
  void SetPattern(int _flags) { pattern = _flags; }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    _s.Pass(this, "pattern", pattern);
    return SerializerNodeObject;
  }
  string ToCSV() { return StringFormat("%s", "todo"); }
};

// Defines struct to store bar entries.
struct BarEntry {
  BarOHLC ohlc;
  BarPattern pattern;
  BarEntry() {}
  BarEntry(const BarOHLC& _ohlc) { ohlc = _ohlc; }
  // Struct getters
  BarOHLC GetOHLC() { return ohlc; }
  BarPattern GetPattern() { return pattern; }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& s) {
    s.PassStruct(this, "ohlc", ohlc);
    s.PassStruct(this, "pattern", pattern);
    return SerializerNodeObject;
  }
  string ToCSV() { return StringFormat("%s,%s", ohlc.ToCSV(), pattern.ToCSV()); }
};
