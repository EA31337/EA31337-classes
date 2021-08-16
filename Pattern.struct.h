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
 * Includes Pattern's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Bar.struct.h"
#include "Pattern.enum.h"
#include "Math.define.h"

// Defines structure for bitwise pattern values.
struct PatternBitwise {
  unsigned int v[];
  // Operator methods.
  unsigned int operator[](const int _index) const { return v[_index]; }
  // Adds new value to the end of the array.
  bool Add(const unsigned int _value) {
    int _new_index = ArrayResize(v, ArraySize(v) + 1) - 1;
    v[_new_index] = _value;
    return _new_index == ArraySize(v) - 1;
  }
  /**
   * Calculates count of each bit.
   *
   * @return
   * Returns array of counts.
   */
  void GetBitCount(short& _depths[]) {
    int _size = sizeof(int) * 8;
    for (int _bi = 0; _bi < _size; _bi++) {
      _depths[_bi] = GetBitCount(_bi);
    }
  }
  /**
   * Calculates count of the selected bit.
   *
   * @param _bi Index of bit to calculate the count for.
   *
   * @return
   * Returns count of bit (how many times it was on).
   * When 0, selected bit was not active across all values.
   * When positive, bit was active for X number of values.
   */
  short GetBitCount(int _bi) {
    // Initialize counter.
    short _count = 0;
    int _size = GetSize();
    for (int _ic = 1; _ic < _size; _ic++) {
      _count += (short)((v[_ic] & (1 << _bi)) != 0);
    }
    return _count;
  }
  /**
   * Calculates depth of selected bit.
   *
   * @param _bi Index of bit to calculate the depth for.
   *
   * @return float
   * Returns depth of bit between -1 and 1.
   */
  float GetBitDepthFloat(int _bi) { return (float)GetBitDepth(_bi) / (float)GetSize(); }
  /**
   * Calculates depth of the selected bit.
   *
   * @param _bi Index of bit to calculate the depth for.
   *
   * @return
   * Returns depth of bit.
   * When 0, selected bit was not active across all values.
   * When positive, bit is active for X number of values.
   * When negative, bit is no longer active since X number of past values.
   */
  short GetBitDepth(int _bi) {
    // Initialize counter.
    short _depth = (short)((v[0] & (1 << _bi)) != 0);
    int _size = GetSize();
    for (int _ic = 1; _ic < _size; _ic++) {
      short _vcurr = (short)((v[_ic] & (1 << _bi)) != 0);
      if (_ic == _depth) {
        if (_vcurr == 0) {
          // When bit stopped being activated, break the loop.
          break;
        }
        _depth = _depth + _vcurr;
      } else if (_vcurr > 0) {
        // Calculates the negative depth.
        // Which is how far back bit was activated.
        _depth = (short)-_ic;
        break;
      }
    }
    // Returns depth.
    return _depth;
  }
  /**
   * Calculates depth of all bits.
   *
   * @return
   * Returns array of depths.
   */
  void GetBitDepth(short& _depths[]) {
    int _size = sizeof(int) * 8;
    for (int _bi = 0; _bi < _size; _bi++) {
      _depths[_bi] = GetBitDepth(_bi);
    }
  }
  // Returns size of array.
  int GetSize() { return ArraySize(v); }
  // Reset array.
  void Reset() { ArrayResize(v, 0); }
};

// Struct for storing 1-candlestick patterns.
struct PatternCandle {
  unsigned int pattern;
  PatternCandle(unsigned int _pattern = 0) : pattern(_pattern) {}
  // Getters.
  unsigned int GetPattern() const { return pattern; }
  // Struct methods for bitwise operations.
  bool CheckPattern(int _flags) const { return (pattern & _flags) != 0; }
  bool CheckPatternsAll(int _flags) const { return (pattern & _flags) == _flags; }
  void AddPattern(int _flags) { pattern |= _flags; }
  void RemovePattern(int _flags) { pattern &= ~_flags; }
  void SetPattern(int _flag, bool _value = true) {
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
    int _size = sizeof(int) * 8;
    for (int i = 0; i < _size; i++) {
      int _value = CheckPattern(1 << i) ? 1 : 0;
      _s.Pass(THIS_REF, (string)(i + 1), _value, SERIALIZER_FIELD_FLAG_DYNAMIC);
    }
    return SerializerNodeObject;
  }
  string ToCSV() { return StringFormat("%s", "todo"); }
};

// Struct for calculating and storing 1-candlestick patterns.
struct PatternCandle1 : PatternCandle {
  PatternCandle1(unsigned int _pattern = 0) : PatternCandle(_pattern) {}
  PatternCandle1(const BarOHLC& _c) : PatternCandle(PATTERN_1CANDLE_NONE) {
    for (int i = 0; i < sizeof(int) * 8; i++) {
      ENUM_PATTERN_1CANDLE _enum = (ENUM_PATTERN_1CANDLE)(1 << i);
      SetPattern(_enum, CheckPattern(_enum, _c));
    }
  }
  // Calculation methods.
  static bool CheckPattern(ENUM_PATTERN_1CANDLE _enum, const BarOHLC& _c) {
    switch (_enum) {
      case PATTERN_1CANDLE_BEAR:
        // Candle is bearish.
        return _c.IsBear();
      case PATTERN_1CANDLE_BULL:
        // Candle is bullish.
        return _c.IsBull();
      case PATTERN_1CANDLE_BODY_GT_MED:
        // Body is above the median price.
        return _c.GetMinOC() > _c.GetMedian();
      case PATTERN_1CANDLE_BODY_GT_PP:
        // Body is above the pivot price (HLC/3).
        return _c.GetMinOC() > _c.GetPivot();
      case PATTERN_1CANDLE_BODY_GT_PP_DM:
        // Body is above the Tom DeMark pivot price.
        return _c.GetMinOC() > _c.GetPivotDeMark();
      case PATTERN_1CANDLE_BODY_GT_PP_OPEN:
        // Body is above the pivot price (OHLC/4).
        return _c.GetMinOC() > _c.GetPivotWithOpen();
      case PATTERN_1CANDLE_BODY_GT_WEIGHTED:
        // Body is above the weighted price (OH2C/4).
        return _c.GetMinOC() > _c.GetWeighted();
      case PATTERN_1CANDLE_BODY_GT_WICKS:
        // Body is greater than sum of wicks.
        return _c.GetBody() > _c.GetWickSum();
      case PATTERN_1CANDLE_CHANGE_GT_01PC:
        // Price change is greater than 0.1% of the price change.
        return _c.GetChangeInPct() > 0.1;
      case PATTERN_1CANDLE_CHANGE_GT_02PC:
        // Price change is greater than 0.2% of the price change.
        return _c.GetChangeInPct() > 0.2;
      case PATTERN_1CANDLE_CLOSE_GT_MED:
        // Close price is above the median price.
        return _c.GetClose() > _c.GetMedian();
      case PATTERN_1CANDLE_CLOSE_GT_PP:
        // Close price is above the pivot price (HLC/3).
        return _c.GetClose() > _c.GetPivot();
      case PATTERN_1CANDLE_CLOSE_GT_PP_DM:
        // Close price is above the Tom DeMark pivot price.
        return _c.GetClose() > _c.GetPivotDeMark();
      case PATTERN_1CANDLE_CLOSE_GT_PP_OPEN:
        // Close price is above the pivot price (OHLC/4).
        return _c.GetClose() > _c.GetPivotWithOpen();
      case PATTERN_1CANDLE_CLOSE_GT_WEIGHTED:
        // Close price is above the weighted price (OH2C/4).
        return _c.GetClose() > _c.GetWeighted();
      case PATTERN_1CANDLE_CLOSE_LT_PP:
        // Close price is lower the pivot price (HLC/3).
        return _c.GetClose() < _c.GetPivot();
      case PATTERN_1CANDLE_CLOSE_LT_PP_DM:
        // Close price is lower the Tom DeMark pivot price.
        return _c.GetClose() < _c.GetPivotDeMark();
      case PATTERN_1CANDLE_CLOSE_LT_PP_OPEN:
        // Close price is lower the pivot price (OHLC/4).
      case PATTERN_1CANDLE_CLOSE_LT_WEIGHTED:
        // Close price is lower the weighted price (OH2C/4).
        return _c.GetClose() < _c.GetWeighted();
      case PATTERN_1CANDLE_HAS_WICK_LW:
        // Has lower shadow.
        return _c.GetWickLowerInPct() > 2;
      case PATTERN_1CANDLE_HAS_WICK_UP:
        // Has upper shadow.
        return _c.GetWickUpperInPct() > 2;
      case PATTERN_1CANDLE_IS_DOJI_DRAGON:
        // Has doji dragonfly pattern (upper).
        return _c.GetWickLowerInPct() > 95;
      case PATTERN_1CANDLE_IS_DOJI_GRAVE:
        // Has doji gravestone pattern (lower).
        return _c.GetWickUpperInPct() > 95;
      case PATTERN_1CANDLE_IS_HAMMER_INV:
        // Has an inverted hammer (also a shooting star) pattern.
        // A bottom reversal signal.
        return _c.GetWickUpperInPct() > _c.GetBodyInPct() * 2 && _c.GetWickLowerInPct() < 2;
      case PATTERN_1CANDLE_IS_HAMMER_UP:
        // Has an upper hammer pattern.
        // A bullish pattern during a downtrend.
        return _c.GetWickLowerInPct() > _c.GetBodyInPct() * 2 && _c.GetWickUpperInPct() < 2;
      case PATTERN_1CANDLE_IS_HANGMAN:
        // Has a hanging man pattern.
        // A bearish pattern during an uptrend.
        return _c.GetWickLowerInPct() > _c.GetBodyInPct() * 3 && _c.GetWickUpperInPct() < 2;
      case PATTERN_1CANDLE_IS_LONG_SHADOW_LW:
        // Has long lower shadow pattern.
        return _c.GetWickLowerInPct() > 60;
      case PATTERN_1CANDLE_IS_LONG_SHADOW_UP:
        // Has long upper shadow pattern.
        return _c.GetWickUpperInPct() > 60;
      case PATTERN_1CANDLE_IS_MARUBOZU:
        // Has a big body with no or small wicks.
        return _c.GetBodyInPct() > 96;
      case PATTERN_1CANDLE_IS_SHAVEN_LW:
        // Has a shaven bottom (lower) pattern.
        // A bottom reversal signal.
        return _c.GetWickUpperInPct() > 50 && _c.GetWickLowerInPct() < 2;
      case PATTERN_1CANDLE_IS_SHAVEN_UP:
        // Has a shaven head (upper) pattern.
        // A bullish pattern during a downtrend
        // and a bearish pattern during an uptrend.
        return _c.GetWickLowerInPct() > 50 && _c.GetWickUpperInPct() < 2;
      case PATTERN_1CANDLE_IS_SPINNINGTOP:
        // Has a spinning top pattern.
        // A candlestick with a small body.
        // A neutral pattern.
        return _c.GetBodyInPct() < 30 && _c.GetWickLowerInPct() > 20 && _c.GetWickUpperInPct() > 20;
      case PATTERN_1CANDLE_NONE:
      default:
        break;
    }
    return false;
  }
};

// Struct for calculating and storing 2-candlestick patterns.
struct PatternCandle2 : PatternCandle {
  PatternCandle2(unsigned int _pattern = 0) : PatternCandle(_pattern) {}
  PatternCandle2(const BarOHLC& _c[]) : PatternCandle(PATTERN_2CANDLE_NONE) {
    for (int i = 0; i < sizeof(int) * 8; i++) {
      ENUM_PATTERN_2CANDLE _enum = (ENUM_PATTERN_2CANDLE)(1 << i);
      SetPattern(_enum, CheckPattern(_enum, _c));
    }
  }
  // Calculation methods.
  static bool CheckPattern(ENUM_PATTERN_2CANDLE _enum, const BarOHLC& _c[]) {
    switch (_enum) {
      case PATTERN_2CANDLE_BEARS:
        // Two bear candles.
        return _c[0].IsBear() && _c[1].IsBear();
      case PATTERN_2CANDLE_BODY_GT_BODY:
        // Body size is greater than the previous one.
        return _c[0].GetBodyAbs() > _c[1].GetBodyAbs();
      case PATTERN_2CANDLE_BULLS:
        // Two bulls candles.
        return _c[0].IsBull() && _c[1].IsBull();
      case PATTERN_2CANDLE_CLOSE_GT_CLOSE:
        // Close price is greater than the previous one.
        return _c[0].close > _c[1].close;
      case PATTERN_2CANDLE_CLOSE_GT_HIGH:
        // Close price is greater than previous high.
        return _c[0].close > _c[1].high;
      case PATTERN_2CANDLE_CLOSE_LT_LOW:
        // Close price is lower than previous low.
        return _c[0].close < _c[1].low;
      case PATTERN_2CANDLE_HOC_GT_HIGH:
        // Higher price (open or close) is greater than the previous high.
        return _c[0].GetMaxOC() > _c[1].high;
      case PATTERN_2CANDLE_HOC_GT_HOC:
        // Higher price (open or close) is greater than the previous one.
        return _c[0].GetMaxOC() > _c[1].GetMaxOC();
      case PATTERN_2CANDLE_HIGH_GT_HIGH:
        // High price is greater than the previous one.
        return _c[0].high > _c[1].high;
      case PATTERN_2CANDLE_HIGH_GT_HOC:
        // High is greater than the previous higher price (open or close).
        return _c[0].high > _c[1].GetMaxOC();
      case PATTERN_2CANDLE_LOC_LT_LOC:
        // Lower price (open or close) is lower than the previous one.
        return _c[0].GetMinOC() < _c[1].GetMinOC();
      case PATTERN_2CANDLE_LOC_LT_LOW:
        // Lower price (open or close) is lower than the previous low.
        return _c[0].GetMinOC() < _c[1].low;
      case PATTERN_2CANDLE_LOW_LT_LOC:
        // Low is lower than the previous lower price (open or close).
        return _c[0].low < _c[1].GetMinOC();
      case PATTERN_2CANDLE_LOW_LT_LOW:
        // Low price is lower than the previous one.
        return _c[0].low < _c[1].low;
      case PATTERN_2CANDLE_OPEN_GT_OPEN:
        // Open price is greater than the previous one.
        return _c[0].open > _c[1].open;
      case PATTERN_2CANDLE_PP_GT_PP:
        // Pivot price is greater than the previous one (HLC/3).
        return _c[0].GetPivot() > _c[1].GetPivot();
      case PATTERN_2CANDLE_PP_GT_PP_OPEN:
        // Pivot price open is greater than the previous one (OHLC/4).
        return _c[0].GetPivot() > _c[1].GetPivotWithOpen(_c[1].open);
      case PATTERN_2CANDLE_RANGE_DBL_RANGE:
        // Range size doubled from the previous one.
        return _c[0].GetRange() > _c[1].GetRange() * 2;
      case PATTERN_2CANDLE_RANGE_GT_RANGE:
        // Range is greater than the previous one.
        return _c[0].GetRange() > _c[1].GetRange();
      case PATTERN_2CANDLE_TIME_GAP_DAY:
        // Bars have over 24h gap.
        return (_c[0].time - _c[1].time) > 24 * 60 * 60;
      case PATTERN_2CANDLE_WEIGHTED_GT_WEIGHTED:
        // Weighted price is greater than the previous one (OH2C/4).
        return _c[0].GetWeighted() > _c[1].GetWeighted();
      case PATTERN_2CANDLE_WICKS_DBL_WICKS:
        // Size of wicks doubled from the previous onces.
        return _c[0].GetWickSum() > _c[1].GetWickSum() * 2;
      case PATTERN_2CANDLE_WICKS_GT_WICKS:
        // Size of wicks is greater than the previous onces.
        return _c[0].GetWickSum() > _c[1].GetWickSum();
      // ---
      case PATTERN_2CANDLE_BODY_IN_BODY:
        return !CheckPattern(PATTERN_2CANDLE_HOC_GT_HOC, _c) && !CheckPattern(PATTERN_2CANDLE_LOC_LT_LOC, _c);
      case PATTERN_2CANDLE_BODY_OUT_BODY:
        return CheckPattern(PATTERN_2CANDLE_HOC_GT_HOC, _c) && CheckPattern(PATTERN_2CANDLE_LOC_LT_LOC, _c);
      case PATTERN_2CANDLE_RANGE_IN_RANGE:
        return !CheckPattern(PATTERN_2CANDLE_HIGH_GT_HIGH, _c) && !CheckPattern(PATTERN_2CANDLE_LOW_LT_LOW, _c);
      case PATTERN_2CANDLE_RANGE_OUT_RANGE:
        return CheckPattern(PATTERN_2CANDLE_HIGH_GT_HIGH, _c) && CheckPattern(PATTERN_2CANDLE_LOW_LT_LOW, _c);
      case PATTERN_2CANDLE_BODY_IN_RANGE:
        return !CheckPattern(PATTERN_2CANDLE_HOC_GT_HIGH, _c) && !CheckPattern(PATTERN_2CANDLE_LOC_LT_LOW, _c);
      case PATTERN_2CANDLE_BODY_OUT_RANGE:
        return CheckPattern(PATTERN_2CANDLE_HOC_GT_HIGH, _c) && CheckPattern(PATTERN_2CANDLE_LOC_LT_LOW, _c);
      case PATTERN_2CANDLE_RANGE_IN_BODY:
        return !CheckPattern(PATTERN_2CANDLE_HIGH_GT_HOC, _c) && !CheckPattern(PATTERN_2CANDLE_LOW_LT_LOC, _c);
      case PATTERN_2CANDLE_RANGE_OUT_BODY:
        return CheckPattern(PATTERN_2CANDLE_HIGH_GT_HOC, _c) && CheckPattern(PATTERN_2CANDLE_LOW_LT_LOC, _c);
      case PATTERN_2CANDLE_HARAMI:
        return CheckPattern(PATTERN_2CANDLE_BODY_IN_BODY, _c) && CheckPattern(PATTERN_2CANDLE_RANGE_IN_BODY, _c) &&
               !CheckPattern(PATTERN_2CANDLE_HOC_GT_HOC, _c) && !CheckPattern(PATTERN_2CANDLE_LOC_LT_LOC, _c);
      case PATTERN_2CANDLE_NONE:
      default:
        break;
    }
    return false;
  }
};

// Struct for calculating and storing 3-candlestick patterns.
struct PatternCandle3 : PatternCandle {
  PatternCandle3(unsigned int _pattern = 0) : PatternCandle(_pattern) {}
  PatternCandle3(const BarOHLC& _c[]) : PatternCandle(PATTERN_3CANDLE_NONE) {
    for (int i = 0; i < sizeof(int) * 8; i++) {
      ENUM_PATTERN_3CANDLE _enum = (ENUM_PATTERN_3CANDLE)(1 << i);
      SetPattern(_enum, CheckPattern(_enum, _c));
    }
  }
  // Calculation methods.
  static bool CheckPattern(ENUM_PATTERN_3CANDLE _enum, const BarOHLC& _c[]) {
    switch (_enum) {
      case PATTERN_3CANDLE_BEARS:
        // Three bear candles.
        return _c[0].IsBear() && _c[1].IsBear() && _c[2].IsBear();
      case PATTERN_3CANDLE_BODY0_DBL_SUM:
        // Body size is greater than doubled sum of others.
        return _c[0].GetBodyAbs() > (_c[1].GetBodyAbs() + _c[2].GetBodyAbs()) * 2;
      case PATTERN_3CANDLE_BODY0_GT_SUM:
        // Body size is greater than sum of others.
        return _c[0].GetBodyAbs() > _c[1].GetBodyAbs() + _c[2].GetBodyAbs();
      case PATTERN_3CANDLE_BODY_DEC:
        // Body size decreases.
        return _c[0].GetBodyAbs() < _c[1].GetBodyAbs() && _c[1].GetBodyAbs() < _c[2].GetBodyAbs();
      case PATTERN_3CANDLE_BODY_INC:
        // Body size increases.
        return _c[0].GetBodyAbs() > _c[1].GetBodyAbs() && _c[1].GetBodyAbs() > _c[2].GetBodyAbs();
      case PATTERN_3CANDLE_BULLS:
        // Three bull candles.
        return _c[0].IsBull() && _c[1].IsBull() && _c[2].IsBull();
      case PATTERN_3CANDLE_CLOSE_DEC:
        // Close price decreases.
        return _c[0].close < _c[1].close && _c[1].close < _c[2].close;
      case PATTERN_3CANDLE_CLOSE_INC:
        // Close price increases.
        return _c[0].close > _c[1].close && _c[1].close > _c[2].close;
      case PATTERN_3CANDLE_HIGH0_LT_LOW2:
        // High price lower than low price of 2 bars before.
        return _c[0].high < _c[2].low;
      case PATTERN_3CANDLE_HIGH1_LT_PP:
        // High price of the middle bar is lower than pivot price.
        return _c[1].high < fmin(_c[0].GetPivot(), _c[2].GetPivot());
      case PATTERN_3CANDLE_HIGH_DEC:
        // High price decreases.
        return _c[0].high < _c[1].high && _c[1].high < _c[2].high;
      case PATTERN_3CANDLE_HIGH_INC:
        // High price increases.
        return _c[0].high > _c[1].high && _c[1].high > _c[2].high;
      case PATTERN_3CANDLE_LOW0_GT_HIGH2:
        // Low price is greater than high price of 2 bars before.
        return _c[0].low > _c[2].high;
      case PATTERN_3CANDLE_LOW1_GT_PP:
        // Low price of the middle bar is greater than pivot price.
        return _c[1].low > fmax(_c[0].GetPivot(), _c[2].GetPivot());
      case PATTERN_3CANDLE_LOW_DEC:
        // Low price decreases.
        return _c[0].low < _c[1].low && _c[1].low < _c[2].low;
      case PATTERN_3CANDLE_LOW_INC:
        // Low price increases.
        return _c[0].low > _c[1].low && _c[1].low > _c[2].low;
      case PATTERN_3CANDLE_OPEN0_GT_HIGH2:
        // Open price is greater than high price of 2 bars before.
        return _c[0].open > _c[2].high;
      case PATTERN_3CANDLE_OPEN0_LT_LOW2:
        // Open price is lower than low price of 2 bars before.
        return _c[0].open < _c[2].low;
      case PATTERN_3CANDLE_OPEN_DEC:
        // Open price decreases.
        return _c[0].open < _c[1].open && _c[1].open < _c[2].open;
      case PATTERN_3CANDLE_OPEN_INC:
        // Open price increases.
        return _c[0].open > _c[1].open && _c[1].open > _c[2].open;
      case PATTERN_3CANDLE_PEAK:
        // High or low price at peak.
        return _c[0].high > fmax(_c[1].high, _c[2].high) || _c[0].low < fmin(_c[1].low, _c[2].low);
      case PATTERN_3CANDLE_PP_DEC:
        // Pivot point decreases.
        return _c[0].GetPivot() < _c[1].GetPivot() && _c[1].GetPivot() < _c[2].GetPivot();
      case PATTERN_3CANDLE_PP_INC:
        // Pivot point increases.
        return _c[0].GetPivot() > _c[1].GetPivot() && _c[1].GetPivot() > _c[2].GetPivot();
      case PATTERN_3CANDLE_RANGE0_GT_SUM:
        // Range size is greater than sum of others.
        return _c[0].GetRange() > (_c[1].GetRange() + _c[2].GetRange());
      case PATTERN_3CANDLE_RANGE1_GT_SUM:
        // Range size of middle candle is greater than sum of others.
        return _c[1].GetRange() > (_c[0].GetRange() + _c[2].GetRange());
      case PATTERN_3CANDLE_RANGE_DEC:
        // Range size decreases.
        return _c[0].GetRange() < _c[1].GetRange() && _c[1].GetRange() < _c[2].GetRange();
      case PATTERN_3CANDLE_RANGE_INC:
        // Range size increases.
        return _c[0].GetRange() > _c[1].GetRange() && _c[1].GetRange() > _c[2].GetRange();
      case PATTERN_3CANDLE_WICKS0_DBL_SUM:
        // Size of wicks are greater than doubled sum of others.
        return _c[0].GetWickSum() > (_c[1].GetWickSum() + _c[2].GetWickSum()) * 2;
      case PATTERN_3CANDLE_WICKS0_GT_BODY:
        // Size of wicks are greater than sum of bodies.
        return _c[0].GetWickSum() > _c[1].GetBodyAbs() + _c[2].GetBodyAbs();
      case PATTERN_3CANDLE_WICKS0_GT_SUM:
        // Size of wicks are greater than sum of others.
        return _c[0].GetWickSum() > _c[1].GetWickSum() + _c[2].GetWickSum();
      case PATTERN_3CANDLE_WICKS1_DBL_BODY:
        // Size of middle wicks are greater than doubled sum of bodies.
        return _c[1].GetWickSum() > (_c[0].GetBodyAbs() + _c[2].GetBodyAbs()) * 2;
      case PATTERN_3CANDLE_WICKS1_GT_BODY:
        // Size of middle wicks are greater than sum of bodies.
        return _c[1].GetWickSum() > _c[0].GetBodyAbs() + _c[2].GetBodyAbs();
      case PATTERN_3CANDLE_NONE:
      default:
        break;
    }
    return false;
  }
};

// Struct for calculating and storing 4-candlestick patterns.
struct PatternCandle4 : PatternCandle {
  PatternCandle4(unsigned int _pattern = 0) : PatternCandle(_pattern) {}
  PatternCandle4(const BarOHLC& _c[]) : PatternCandle(PATTERN_4CANDLE_NONE) {
    for (int i = 0; i < sizeof(int) * 8; i++) {
      ENUM_PATTERN_4CANDLE _enum = (ENUM_PATTERN_4CANDLE)(1 << i);
      SetPattern(_enum, CheckPattern(_enum, _c));
    }
  }
  // Calculation methods.
  static bool CheckPattern(ENUM_PATTERN_4CANDLE _enum, const BarOHLC& _c[]) {
    PatternCandle3 _c3(_c);
    switch (_enum) {
      case PATTERN_4CANDLE_BEARS:
        // Four bear candles.
        return _c[0].IsBear() && _c[1].IsBear() && _c[2].IsBear() && _c[3].IsBear();
      case PATTERN_4CANDLE_BEAR_CONT:
        // Bearish trend continuation (DUUP).
        return
            /* Bear 0 cont. */ _c[0].open > _c[0].close &&
            /* Bear 0 is low */ _c[0].low < _c[3].low &&
            /* Bear 0 body is large */ _c3.CheckPattern(PATTERN_3CANDLE_BODY0_GT_SUM) &&
            /* Bull 1 */ _c[1].open < _c[1].close &&
            /* Bull 2 */ _c[2].open < _c[2].close &&
            /* Bear 3 */ _c[3].open > _c[3].close &&
            /* Bear 3 is low */ _c[3].low < fmin(_c[2].low, _c[1].low);
      case PATTERN_4CANDLE_BEAR_REV:
        // Bearish trend reversal (UUDD).
        return
            /* Bear 0 */ _c[0].open > _c[0].close &&
            /* Bear's 0 low is lowest */ _c[0].GetMinOC() < fmin3(_c[1].low, _c[2].low, _c[3].low) &&
            /* Bear 1 */ _c[1].open > _c[1].close &&
            /* Bull 2 */ _c[2].open < _c[2].close &&
            /* Bull 3 */ _c[3].open < _c[3].close;
      case PATTERN_4CANDLE_BEBU_MIXED:
        // Bears and bulls mixed (not in a row).
        return _c[0].GetType() != _c[1].GetType() && _c[1].GetType() != _c[2].GetType() &&
               _c[2].GetType() != _c[3].GetType();
      case PATTERN_4CANDLE_BODY0_GT_SUM:
        // Body size is greater than sum of others.
        return _c[0].GetBodyAbs() > _c[1].GetBodyAbs() + _c[2].GetBodyAbs() + _c[3].GetBodyAbs();
      case PATTERN_4CANDLE_BODY_DEC:
        // Body size decreases.
        return _c[0].GetBodyAbs() < _c[1].GetBodyAbs() && _c[1].GetBodyAbs() < _c[2].GetBodyAbs() &&
               _c[2].GetBodyAbs() < _c[3].GetBodyAbs();
      case PATTERN_4CANDLE_BODY_INC:
        // Body size increases.
        return _c[0].GetBodyAbs() > _c[1].GetBodyAbs() && _c[1].GetBodyAbs() > _c[2].GetBodyAbs() &&
               _c[2].GetBodyAbs() > _c[3].GetBodyAbs();
      case PATTERN_4CANDLE_BULLS:
        // Four bull candles.
        return _c[0].IsBull() && _c[1].IsBull() && _c[2].IsBull() && _c[3].IsBull();
      case PATTERN_4CANDLE_BULL_CONT:
        // Bull trend continuation (UDDU).
        return
            /* Bull 0 cont. */ _c[0].open < _c[0].close &&
            /* Bull 0 is high */ _c[0].high > _c[3].high &&
            /* Bull 0 body is large */ _c3.CheckPattern(PATTERN_3CANDLE_BODY0_GT_SUM) &&
            /* Bear 1 */ _c[1].open > _c[1].close &&
            /* Bear 2 */ _c[2].open > _c[2].close &&
            /* Bull 3 */ _c[3].open < _c[3].close &&
            /* Bull 3 is high */ _c[3].high > fmax(_c[2].high, _c[1].high);
      case PATTERN_4CANDLE_BULL_REV:
        // Bullish trend reversal (DDUU).
        return
            /* Bear 0 */ _c[0].open < _c[0].close &&
            /* Bull's 0 high is highest */ _c[0].GetMaxOC() > fmax3(_c[1].high, _c[2].high, _c[3].high) &&
            /* Bull 1 */ _c[1].open < _c[1].close &&
            /* Bear 2 */ _c[2].open > _c[2].close &&
            /* Bear 3 */ _c[3].open > _c[3].close;
      case PATTERN_4CANDLE_CLOSE_DEC:
        // Close price decreases.
        return _c[0].close < _c[1].close && _c[1].close < _c[2].close && _c[2].close < _c[3].close;
      case PATTERN_4CANDLE_CLOSE_INC:
        // Close price increases.
        return _c[0].close > _c[1].close && _c[1].close > _c[2].close && _c[2].close > _c[3].close;
      case PATTERN_4CANDLE_HIGH_DEC:
        // High price decreases.
        return _c[0].high < _c[1].high && _c[1].high < _c[2].high && _c[2].high < _c[3].high;
      case PATTERN_4CANDLE_HIGH_INC:
        // High price increases.
        return _c[0].high > _c[1].high && _c[1].high > _c[2].high && _c[2].high > _c[3].high;
      case PATTERN_4CANDLE_INV_HAMMER:
        // Inverted hammer (DD^UU).
        return
            /* Bull 0 */ _c[0].open < _c[0].close &&
            /* Bull 1 */ _c[1].open < _c[1].close &&
            /* Bear 2 */ _c[2].open > _c[2].close &&
            /* Bear 3 */ _c[3].open > _c[3].close &&
            /* Upper spike */ fmax(_c[1].GetWickUpper(), _c[2].GetWickUpper()) >
                _c[0].GetWickSum() + _c[3].GetWickSum();
      case PATTERN_4CANDLE_LOW_DEC:
        // Low price decreases.
        return _c[0].low < _c[1].low && _c[1].low < _c[2].low && _c[2].low < _c[3].low;
      case PATTERN_4CANDLE_LOW_INC:
        // Low price increases.
        return _c[0].low > _c[1].low && _c[1].low > _c[2].low && _c[2].low > _c[3].low;
      case PATTERN_4CANDLE_OPEN_DEC:
        // Open price decreases.
        return _c[0].open < _c[1].open && _c[1].open < _c[2].open && _c[2].open < _c[3].open;
      case PATTERN_4CANDLE_OPEN_INC:
        // Open price increases.
        return _c[0].open > _c[1].open && _c[1].open > _c[2].open && _c[2].open > _c[3].open;
      case PATTERN_4CANDLE_PEAK:
        // High or low price at peak.
        return _c[0].high > fmax(fmax(_c[1].high, _c[2].high), _c[3].high) ||
               _c[0].low < fmin(fmin(_c[1].low, _c[2].low), _c[3].low);
      case PATTERN_4CANDLE_PP_DEC:
        // Pivot point decreases.
        return _c[0].GetPivot() < _c[1].GetPivot() && _c[1].GetPivot() < _c[2].GetPivot() &&
               _c[2].GetPivot() < _c[3].GetPivot();
      case PATTERN_4CANDLE_PP_INC:
        // Pivot point increases.
        return _c[0].GetPivot() > _c[1].GetPivot() && _c[1].GetPivot() > _c[2].GetPivot() &&
               _c[2].GetPivot() > _c[3].GetPivot();
      case PATTERN_4CANDLE_RANGE0_GT_SUM:
        // Range size is greater than sum of others.
        return _c[0].GetRange() > _c[1].GetRange() + _c[2].GetRange() + _c[3].GetRange();
      case PATTERN_4CANDLE_RANGE_DEC:
        // Range size decreases.
        return _c[0].GetRange() < _c[1].GetRange() && _c[1].GetRange() < _c[2].GetRange() &&
               _c[2].GetRange() < _c[3].GetRange();
      case PATTERN_4CANDLE_RANGE_INC:
        // Range size increases.
        return _c[0].GetRange() > _c[1].GetRange() && _c[1].GetRange() > _c[2].GetRange() &&
               _c[2].GetRange() > _c[3].GetRange();
      case PATTERN_4CANDLE_SHOOT_STAR:
        // Shooting star (UU^DD).
        return
            /* Bear 0 */ _c[0].open > _c[0].close &&
            /* Bear 1 */ _c[1].open > _c[1].close &&
            /* Bull 2 */ _c[2].open < _c[2].close &&
            /* Bull 3 */ _c[3].open < _c[3].close &&
            /* Lower spike */ fmax(_c[1].GetWickLower(), _c[2].GetWickLower()) >
                _c[0].GetWickSum() + _c[3].GetWickSum();
      case PATTERN_4CANDLE_TIME_GAPS:
        // Bar time is consistent (no time gaps).
        return (_c[0].time - _c[1].time) / 120 != (_c[1].time - _c[2].time) / 120 ||
               (_c[1].time - _c[2].time) / 120 != (_c[2].time - _c[3].time) / 120;
      case PATTERN_4CANDLE_WICKS0_GT_SUM:
        // Size of wicks are greater than sum of others.
        return _c[0].GetWickSum() > _c[1].GetWickSum() + _c[2].GetWickSum() + _c[3].GetWickSum();
      case PATTERN_4CANDLE_WICKS_DEC:
        // Size of wicks increases.
        return _c[0].GetWickSum() < _c[1].GetWickSum() && _c[1].GetWickSum() < _c[2].GetWickSum() &&
               _c[2].GetWickSum() < _c[3].GetWickSum();
      case PATTERN_4CANDLE_WICKS_GT_BODY:
        // Sum of wicks are greater than sum of bodies.
        return _c[0].GetWickSum() + _c[1].GetWickSum() + _c[2].GetWickSum() + _c[3].GetWickSum() >
               _c[0].GetBodyAbs() + _c[1].GetBodyAbs() + _c[2].GetBodyAbs() + _c[3].GetBodyAbs();
      case PATTERN_4CANDLE_WICKS_INC:
        // Size of wicks increases.
        return _c[0].GetWickSum() > _c[1].GetWickSum() && _c[1].GetWickSum() > _c[2].GetWickSum() &&
               _c[2].GetWickSum() > _c[3].GetWickSum();
      case PATTERN_4CANDLE_WICKS_UPPER:
        // Sum of upper wicks are greater than lower.
        return _c[0].GetWickUpper() + _c[1].GetWickUpper() + _c[2].GetWickUpper() + _c[3].GetWickUpper() >
               _c[0].GetWickLower() + _c[1].GetWickLower() + _c[2].GetWickLower() + _c[3].GetWickLower();
      case PATTERN_4CANDLE_NONE:
      default:
        break;
    }
    return false;
  }
};

// Struct for calculating and storing 4-candlestick patterns.
struct PatternCandle5 : PatternCandle {
  PatternCandle5(unsigned int _pattern = 0) : PatternCandle(_pattern) {}
  PatternCandle5(const BarOHLC& _c[]) : PatternCandle(PATTERN_5CANDLE_NONE) {
    for (int i = 0; i < sizeof(int) * 8; i++) {
      ENUM_PATTERN_5CANDLE _enum = (ENUM_PATTERN_5CANDLE)(1 << i);
      SetPattern(_enum, CheckPattern(_enum, _c));
    }
  }
  // Calculation methods.
  static bool CheckPattern(ENUM_PATTERN_5CANDLE _enum, const BarOHLC& _c[]) {
    switch (_enum) {
      case PATTERN_5CANDLE_BODY0_DIFF_PEAK:
        // Diff of the last two bodies is at a peak.
        return fabs(_c[1].GetBody() - _c[0].GetBody()) >
               fmax(fabs(_c[4].GetBody() - _c[3].GetBody()), fabs(_c[2].GetBody() - _c[1].GetBody()));
      case PATTERN_5CANDLE_BODY0_GT_SUM:
        // Body size is greater than sum of others.
        return _c[0].GetBody() > _c[1].GetBody() + _c[2].GetBody() + _c[3].GetBody() + _c[4].GetBody();
      case PATTERN_5CANDLE_CLOSE0_DIFF_PEAK:
        // Diff of the last two closes is at a peak.
        return fabs(_c[1].close - _c[0].close) > fmax(fabs(_c[4].close - _c[3].close), fabs(_c[2].close - _c[1].close));
      case PATTERN_5CANDLE_CLOSE0_PEAK:
        // Latest close is at a peak.
        return _c[0].close > fmax(fmax(fmax(_c[1].close, _c[2].close), _c[3].close), _c[4].close) ||
               _c[0].close < fmin(fmin(fmin(_c[1].close, _c[2].close), _c[3].close), _c[4].close);
      case PATTERN_5CANDLE_CLOSE2_PEAK:
        // Middle close is at a peak.
        return _c[2].close > fmax(fmax(fmax(_c[1].close, _c[0].close), _c[3].close), _c[4].close) ||
               _c[2].close < fmin(fmin(fmin(_c[1].close, _c[0].close), _c[3].close), _c[4].close);
      case PATTERN_5CANDLE_HIGH0_DIFF_PEAK:
        // Diff of the last two highs is at a peak.
        return fabs(_c[1].high - _c[0].high) > fmax(fabs(_c[4].high - _c[3].high), fabs(_c[2].high - _c[1].high));
      case PATTERN_5CANDLE_HIGH0_PEAK:
        // Latest high is at a peak.
        return _c[0].high > fmax(fmax(fmax(_c[1].high, _c[2].high), _c[3].high), _c[4].high);
      case PATTERN_5CANDLE_HIGH2_PEAK:
        // Middle high is at a peak.
        return _c[2].high > fmax(fmax(fmax(_c[1].high, _c[0].high), _c[3].high), _c[4].high);
      case PATTERN_5CANDLE_HORN_BOTTOMS:
        // Double bottom (1 & 3).
        return _c[1].low < fmin(fmin(_c[0].low, _c[2].low), _c[4].low) ||
               _c[3].low < fmin(fmin(_c[0].low, _c[2].low), _c[4].low);
      case PATTERN_5CANDLE_HORN_TOPS:
        // Double top (1 & 3).
        return _c[1].high > fmax(fmax(_c[0].high, _c[2].high), _c[4].high) ||
               _c[3].high > fmax(fmax(_c[0].high, _c[2].high), _c[4].high);
      case PATTERN_5CANDLE_LINE_STRIKE:
        // 4 bulls or bears, and line strike opposite.
        return (_c[0].GetType() != _c[1].GetType() && _c[1].GetType() == _c[2].GetType() &&
                _c[2].GetType() == _c[3].GetType() && _c[3].GetType() == _c[4].GetType()) &&
               CheckPattern(PATTERN_5CANDLE_CLOSE0_PEAK, _c);
      case PATTERN_5CANDLE_LOW0_DIFF_PEAK:
        // Diff of the last two lows is at a peak.
        return fabs(_c[1].low - _c[0].low) > fmax(fabs(_c[4].low - _c[3].low), fabs(_c[2].low - _c[1].low));
      case PATTERN_5CANDLE_LOW0_PEAK:
        // Latest low is at a peak.
        return _c[0].low < fmin(fmin(fmin(_c[1].low, _c[2].low), _c[3].low), _c[4].low);
      case PATTERN_5CANDLE_LOW2_PEAK:
        // Middle low is at a peak.
        return _c[2].low < fmin(fmin(fmin(_c[1].low, _c[0].low), _c[3].low), _c[4].low);
      case PATTERN_5CANDLE_MAT_HOLD:
        // Mat hold (bear/bull continuation pattern).
        // Also called the Rising three methods.
        // Middle candles are of the same type, two other are opposite.
        return (_c[1].GetType() == _c[2].GetType() && _c[2].GetType() == _c[3].GetType() &&
                _c[0].GetType() == _c[4].GetType() && _c[0].GetType() != _c[1].GetType()) &&
               CheckPattern(PATTERN_5CANDLE_CLOSE0_PEAK, _c) && CheckPattern(PATTERN_5CANDLE_OPEN4_PEAK, _c);
      case PATTERN_5CANDLE_OPEN0_DIFF_PEAK:
        // Diff of the last two opens is at a peak.
        return fabs(_c[1].open - _c[0].open) > fmax(fabs(_c[4].open - _c[3].open), fabs(_c[2].open - _c[1].open));
      case PATTERN_5CANDLE_OPEN0_PEAK:
        // Latest open is at a peak.
        return _c[0].open > fmax(fmax(fmax(_c[1].open, _c[2].open), _c[3].open), _c[4].open) ||
               _c[0].open < fmin(fmin(fmin(_c[1].open, _c[2].open), _c[3].open), _c[4].open);
      case PATTERN_5CANDLE_OPEN2_PEAK:
        // Middle open is at a peak.
        return _c[2].open > fmax(fmax(fmax(_c[1].open, _c[0].open), _c[3].open), _c[4].open) ||
               _c[2].open < fmin(fmin(fmin(_c[1].open, _c[0].open), _c[3].open), _c[4].open);
      case PATTERN_5CANDLE_OPEN4_PEAK:
        // Last open is at a peak.
        return _c[4].open > fmax(fmax(fmax(_c[1].open, _c[0].open), _c[3].open), _c[2].open) ||
               _c[4].open < fmin(fmin(fmin(_c[1].open, _c[0].open), _c[3].open), _c[2].open);
      case PATTERN_5CANDLE_PP0_DIFF_PEAK:
        // Diff of the last two pivots is at a peak.
        return fabs(_c[1].GetPivot() - _c[0].GetPivot()) >
               fmax(fabs(_c[4].GetPivot() - _c[3].GetPivot()), fabs(_c[2].GetPivot() - _c[1].GetPivot()));
      case PATTERN_5CANDLE_PP0_PEAK:
        // Latest pivot is at a peak.
        return _c[0].GetPivot() >
                   fmax(fmax(fmax(_c[1].GetPivot(), _c[2].GetPivot()), _c[3].GetPivot()), _c[4].GetPivot()) ||
               _c[0].GetPivot() <
                   fmin(fmin(fmin(_c[1].GetPivot(), _c[2].GetPivot()), _c[3].GetPivot()), _c[4].GetPivot());
      case PATTERN_5CANDLE_PP2_PEAK:
        // Middle pivot is at a peak.
        return _c[2].GetPivot() >
                   fmax(fmax(fmax(_c[1].GetPivot(), _c[0].GetPivot()), _c[3].GetPivot()), _c[4].GetPivot()) ||
               _c[2].GetPivot() <
                   fmin(fmin(fmin(_c[1].GetPivot(), _c[0].GetPivot()), _c[3].GetPivot()), _c[4].GetPivot());
      case PATTERN_5CANDLE_PP_DEC:
        // Pivot point decreases.
        return _c[0].GetPivot() < _c[1].GetPivot() && _c[1].GetPivot() < _c[2].GetPivot() &&
               _c[2].GetPivot() < _c[3].GetPivot() && _c[3].GetPivot() < _c[4].GetPivot();
      case PATTERN_5CANDLE_PP_DEC_INC:
        // Pivot point decreases then increases.
        return _c[3].GetPivot() < _c[4].GetPivot() && _c[0].GetPivot() > _c[1].GetPivot();
      case PATTERN_5CANDLE_PP_INC:
        // Pivot point increases.
        return _c[0].GetPivot() > _c[1].GetPivot() && _c[1].GetPivot() > _c[2].GetPivot() &&
               _c[2].GetPivot() > _c[3].GetPivot() && _c[3].GetPivot() > _c[4].GetPivot();
      case PATTERN_5CANDLE_PP_INC_DEC:
        // Pivot point increases then decreases.
        return _c[3].GetPivot() > _c[4].GetPivot() && _c[0].GetPivot() < _c[1].GetPivot();
      case PATTERN_5CANDLE_RANGE0_DIFF_PEAK:
        // Diff of the last two ranges is at a peak.
        return fabs(_c[1].GetRange() - _c[0].GetRange()) >
               fmax(fabs(_c[4].GetRange() - _c[3].GetRange()), fabs(_c[2].GetRange() - _c[1].GetRange()));
      case PATTERN_5CANDLE_RANGE0_GT_SUM:
        // Range size is greater than sum of others.
        return _c[0].GetRange() > _c[1].GetRange() + _c[2].GetRange() + _c[3].GetRange() + _c[4].GetRange();
      case PATTERN_5CANDLE_REVERSAL:
        // Reversal pattern.
        // Two candles of the same types (bears or bulls), then three opposite.
        // Three candles of the same types (bears or bulls), then two opposite.
        return (_c[0].GetType() == _c[1].GetType() && _c[2].GetType() == _c[3].GetType() &&
                _c[3].GetType() == _c[4].GetType() && _c[1].GetType() != _c[2].GetType()) ||
               (_c[0].GetType() == _c[1].GetType() && _c[1].GetType() == _c[2].GetType() &&
                _c[3].GetType() == _c[4].GetType() && _c[2].GetType() != _c[3].GetType());
      case PATTERN_5CANDLE_WICKS0_DIFF_PEAK:
        // Diff of the last two ranges is at a peak.
        return fabs(_c[1].GetWickSum() - _c[0].GetWickSum()) >
               fmax(fabs(_c[4].GetWickSum() - _c[3].GetWickSum()), fabs(_c[2].GetWickSum() - _c[1].GetWickSum()));
      case PATTERN_5CANDLE_WICKS0_PEAK:
        // Latest wick sizes are at a peak.
        return _c[0].GetWickSum() >
                   fmax(fmax(fmax(_c[1].GetWickSum(), _c[2].GetWickSum()), _c[3].GetWickSum()), _c[4].GetWickSum()) ||
               _c[0].GetWickSum() <
                   fmin(fmin(fmin(_c[1].GetWickSum(), _c[2].GetWickSum()), _c[3].GetWickSum()), _c[4].GetWickSum());
      case PATTERN_5CANDLE_WICKS2_PEAK:
        // Middle wick sizes are at a peak.
        return _c[2].GetWickSum() >
                   fmax(fmax(fmax(_c[1].GetWickSum(), _c[0].GetWickSum()), _c[3].GetWickSum()), _c[4].GetWickSum()) ||
               _c[2].GetWickSum() <
                   fmin(fmin(fmin(_c[1].GetWickSum(), _c[0].GetWickSum()), _c[3].GetWickSum()), _c[4].GetWickSum());
      case PATTERN_5CANDLE_NONE:
        return false;
    }
    return false;
  }
};

// Struct for calculating and storing 4-candlestick patterns.
struct PatternCandle6 : PatternCandle {
  PatternCandle6(unsigned int _pattern = 0) : PatternCandle(_pattern) {}
  PatternCandle6(const BarOHLC& _c[]) : PatternCandle(PATTERN_6CANDLE_NONE) {
    for (int i = 0; i < sizeof(int) * 8; i++) {
      ENUM_PATTERN_6CANDLE _enum = (ENUM_PATTERN_6CANDLE)(1 << i);
      SetPattern(_enum, CheckPattern(_enum, _c));
    }
  }
  // Calculation methods.
  static bool CheckPattern(ENUM_PATTERN_6CANDLE _enum, const BarOHLC& _c[]) {
    switch (_enum) {
      case PATTERN_6CANDLE_NONE:
        return false;
    }
    return false;
  }
};

// Struct for calculating and storing 4-candlestick patterns.
struct PatternCandle7 : PatternCandle {
  PatternCandle7(unsigned int _pattern = 0) : PatternCandle(_pattern) {}
  PatternCandle7(const BarOHLC& _c[]) : PatternCandle(PATTERN_7CANDLE_NONE) {
    for (int i = 0; i < sizeof(int) * 8; i++) {
      ENUM_PATTERN_7CANDLE _enum = (ENUM_PATTERN_7CANDLE)(1 << i);
      SetPattern(_enum, CheckPattern(_enum, _c));
    }
  }
  // Calculation methods.
  static bool CheckPattern(ENUM_PATTERN_7CANDLE _enum, const BarOHLC& _c[]) {
    switch (_enum) {
      case PATTERN_7CANDLE_NONE:
        return false;
    }
    return false;
  }
};

// Struct for calculating and storing 4-candlestick patterns.
struct PatternCandle8 : PatternCandle {
  PatternCandle8(unsigned int _pattern = 0) : PatternCandle(_pattern) {}
  PatternCandle8(const BarOHLC& _c[]) : PatternCandle(PATTERN_8CANDLE_NONE) {
    for (int i = 0; i < sizeof(int) * 8; i++) {
      ENUM_PATTERN_8CANDLE _enum = (ENUM_PATTERN_8CANDLE)(1 << i);
      SetPattern(_enum, CheckPattern(_enum, _c));
    }
  }
  // Calculation methods.
  static bool CheckPattern(ENUM_PATTERN_8CANDLE _enum, const BarOHLC& _c[]) {
    switch (_enum) {
      case PATTERN_8CANDLE_NONE:
        return false;
    }
    return false;
  }
};

// Struct for calculating and storing 4-candlestick patterns.
struct PatternCandle9 : PatternCandle {
  PatternCandle9(unsigned int _pattern = 0) : PatternCandle(_pattern) {}
  PatternCandle9(const BarOHLC& _c[]) : PatternCandle(PATTERN_9CANDLE_NONE) {
    for (int i = 0; i < sizeof(int) * 8; i++) {
      ENUM_PATTERN_9CANDLE _enum = (ENUM_PATTERN_9CANDLE)(1 << i);
      SetPattern(_enum, CheckPattern(_enum, _c));
    }
  }
  // Calculation methods.
  static bool CheckPattern(ENUM_PATTERN_9CANDLE _enum, const BarOHLC& _c[]) {
    switch (_enum) {
      case PATTERN_9CANDLE_NONE:
        return false;
    }
    return false;
  }
};

// Struct for calculating and storing 4-candlestick patterns.
struct PatternCandle10 : PatternCandle {
  PatternCandle10(unsigned int _pattern = 0) : PatternCandle(_pattern) {}
  PatternCandle10(const BarOHLC& _c[]) : PatternCandle(PATTERN_10CANDLE_NONE) {
    for (int i = 0; i < sizeof(int) * 8; i++) {
      ENUM_PATTERN_10CANDLE _enum = (ENUM_PATTERN_10CANDLE)(1 << i);
      SetPattern(_enum, CheckPattern(_enum, _c));
    }
  }
  // Calculation methods.
  static bool CheckPattern(ENUM_PATTERN_10CANDLE _enum, const BarOHLC& _c[]) {
    switch (_enum) {
      case PATTERN_10CANDLE_NONE:
        return false;
    }
    return false;
  }
};

// Defines structure for pattern entry.
struct PatternEntry {
  PatternCandle1 pattern1;
  PatternCandle2 pattern2;
  PatternCandle3 pattern3;
  PatternCandle4 pattern4;
  PatternCandle5 pattern5;
  PatternCandle6 pattern6;
  PatternCandle7 pattern7;
  PatternCandle8 pattern8;
  PatternCandle9 pattern9;
  PatternCandle10 pattern10;
  // Struct constructor.
  PatternEntry()
      : pattern1(0),
        pattern2(0),
        pattern3(0),
        pattern4(0),
        pattern5(0),
        pattern6(0),
        pattern7(0),
        pattern8(0),
        pattern9(0),
        pattern10(0) {}
  PatternEntry(BarOHLC& _c[])
      : pattern1(_c[0]),
        pattern2(_c),
        pattern3(_c),
        pattern4(_c),
        pattern5(_c),
        pattern6(_c),
        pattern7(_c),
        pattern8(_c),
        pattern9(_c),
        pattern10(_c) {}
  // Operator methods.
  unsigned int operator[](const int _index) const {
    switch (_index) {
      case 1:
        return pattern1.GetPattern();
      case 2:
        return pattern2.GetPattern();
      case 3:
        return pattern3.GetPattern();
      case 4:
        return pattern4.GetPattern();
      case 5:
        return pattern5.GetPattern();
      case 6:
        return pattern6.GetPattern();
      case 7:
        return pattern7.GetPattern();
      case 8:
        return pattern8.GetPattern();
      case 9:
        return pattern9.GetPattern();
      case 10:
        return pattern10.GetPattern();
    }
    return 0;
  }
};
