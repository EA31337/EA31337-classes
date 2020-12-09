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
  double open, high, low, close;
  // Struct constructor.
  BarOHLC() : open(0), high(0), low(0), close(0), time(0){};
  BarOHLC(double _open, double _high, double _low, double _close, datetime _time = 0)
      : time(_time), open(_open), high(_high), low(_low), close(_close) {
    if (_time == 0) {
      _time = TimeCurrent();
    }
  }
  // Struct methods.
  // Getters
  void GetValues(double& _out[]) {
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
  double GetBodySize() { return body_size; }
  double GetCandleSize() { return candle_size; }
  double GetHeadSize() { return head_size; }
  double GetRangeSize() { return range_size; }
  double GetTailSize() { return tail_size; }
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
  BarPattern(const BarOHLC& _p, const BarShape& _s) {
    SetPattern(BAR_TYPE_BEAR, _p.open < _p.close);  // Candle is bearish.
    SetPattern(BAR_TYPE_BULL, _p.open > _p.close);  // Candle is bullish.
    // SetPattern(BAR_TYPE_HAS_LONG_SHADOW_LW, @todo); // Has long lower shadow
    // SetPattern(BAR_TYPE_HAS_LONG_SHADOW_UP, @todo); // Has long upper shadow
    // SetPattern(BAR_TYPE_HAS_WICK_BEAR, @todo); // Has lower shadow
    // SetPattern(BAR_TYPE_HAS_WICK_BULL, @todo); // Has upper shadow
    // SetPattern(BAR_TYPE_IS_DOJI_DRAGON, @todo); // Has doji dragonfly pattern (upper)
    // SetPattern(BAR_TYPE_IS_DOJI_GRAVE, @todo); // Has doji gravestone pattern (lower)
    // SetPattern(BAR_TYPE_IS_HAMMER_BEAR, @todo); // Has a lower hammer pattern
    // SetPattern(BAR_TYPE_IS_HAMMER_BULL, @todo); // Has a upper hammer pattern
    // SetPattern(BAR_TYPE_IS_HANGMAN, @todo); // Has a hanging man pattern
    // SetPattern(BAR_TYPE_IS_SPINNINGTOP, @todo); // Has a spinning top pattern
    // SetPattern(BAR_TYPE_IS_SSTAR, @todo); // Has a shooting star pattern
    // Body patterns.
    // double _mid_price = fabs(_p.open - _p.close) / 2;
    // SetPattern(BAR_TYPE_BODY_ABOVE_MID, @todo); // Body is above center
    // SetPattern(BAR_TYPE_BODY_BELOW_MID, @todo); // Body is below center
    // SetPattern(BAR_TYPE_BODY_GT_WICK, @todo); // Body is higher than each wick
    // SetPattern(BAR_TYPE_BODY_GT_WICKS, @todo); // Body is higher than sum of wicks
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
};

// Defines struct to store bar entries.
struct BarEntry {
  BarOHLC ohlc;
  BarShape shape;
  BarPattern pattern;
  BarEntry() {}
  BarEntry(const BarOHLC& _ohlc) { ohlc = _ohlc; }
  BarEntry(const BarOHLC& _ohlc, const BarShape& _shape) : pattern(_ohlc, _shape) {
    ohlc = _ohlc;
    shape = _shape;
  }
  // Struct getters
  BarOHLC GetOHLC() { return ohlc; }
  BarShape GetShape() { return shape; }
  BarPattern GetPattern() { return pattern; }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& s) {
    s.PassStruct(this, "ohlc", ohlc);
    s.PassStruct(this, "shape", shape);
    return SerializerNodeObject;
  }
  string ToCSV() { return StringFormat("%s,%s", ohlc.ToCSV(), shape.ToCSV()); }
};
