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

// Includes.
#include "Bar.struct.h"
#include "Pattern.enum.h"

struct PatternEntry {
  int candle[7];
  // Struct constructor.
  PatternEntry(BarOHLC _ohlc[]) {
    // 2-candle patterns.
    if (ArraySize(_ohlc) > 1) {
      // Body size greater than the previous one.
      SetPattern(PATTERN_2CANDLE_BODY_GT_BODY, _ohlc[0].GetBodyAbs() > _ohlc[1].GetBodyAbs());
      // Close price greater than the previous one.
      SetPattern(PATTERN_2CANDLE_CLOSE_GT_CLOSE, _ohlc[0].close > _ohlc[1].close);
      // Close price greater than previous high.
      SetPattern(PATTERN_2CANDLE_CLOSE_GT_HIGH, _ohlc[0].close > _ohlc[1].high);
      // Close price lower than previous low.
      SetPattern(PATTERN_2CANDLE_CLOSE_LT_LOW, _ohlc[0].close < _ohlc[1].low);
      // High price greater than the previous one.
      SetPattern(PATTERN_2CANDLE_HIGH_GT_HIGH, _ohlc[0].high > _ohlc[1].high);
      // Low price greater than the previous one.
      SetPattern(PATTERN_2CANDLE_LOW_GT_LOW, _ohlc[0].low > _ohlc[1].low);
      // Open price greater than the previous one.
      SetPattern(PATTERN_2CANDLE_OPEN_GT_OPEN, _ohlc[0].open > _ohlc[1].open);
      // Pivot price greater than the previous one (HLC/3).
      SetPattern(PATTERN_2CANDLE_PP_GT_PP, _ohlc[0].GetPivot() > _ohlc[1].GetPivot());
      // Pivot price open is greater than the previous one (OHLC/4).
      SetPattern(PATTERN_2CANDLE_PP_GT_PP_OPEN, _ohlc[0].GetPivot() > _ohlc[1].GetPivotWithOpen(_ohlc[1].open));
      // Range size doubled from the previous one.
      SetPattern(PATTERN_2CANDLE_RANGE_DBL_RANGE, _ohlc[0].GetRange() > _ohlc[1].GetRange() * 2);
      // Range greater than the previous one.
      SetPattern(PATTERN_2CANDLE_RANGE_GT_RANGE, _ohlc[0].GetRange() > _ohlc[1].GetRange());
      // Weighted price is greater than the previous one (OH2C/4).
      SetPattern(PATTERN_2CANDLE_WEIGHTED_GT_WEIGHTED, _ohlc[0].GetWeighted() > _ohlc[1].GetWeighted());
      // Wicks size double from the previous onces.
      SetPattern(PATTERN_2CANDLE_WICKS_DBL_WICKS, _ohlc[0].GetWickSum() > _ohlc[1].GetWickSum() * 2);
      // Wicks size greater than the previous onces.
      SetPattern(PATTERN_2CANDLE_WICKS_DBL_WICKS, _ohlc[0].GetWickSum() > _ohlc[1].GetWickSum());
    }
  }
  // Struct methods for bitwise operations.
  bool CheckPattern(int _flags, int _index) { return (candle[_index] & _flags) != 0; }
  bool CheckPatternsAll(int _flags, int _index) { return (candle[_index] & _flags) == _flags; }
  void AddPattern(int _flags, int _index) { candle[_index] |= _flags; }
  void RemovePattern(int _flags, int _index) { candle[_index] &= ~_flags; }
  void SetPattern(ENUM_BAR_PATTERN _flag, bool _value = true) {
    if (_value) {
      AddPattern(_flag, 0);
    } else {
      RemovePattern(_flag, 0);
    }
  }
  void SetPattern(ENUM_PATTERN_2CANDLE _flag, bool _value = true) {
    if (_value) {
      AddPattern(_flag, 1);
    } else {
      RemovePattern(_flag, 1);
    }
  }
  void SetPattern(ENUM_PATTERN_3CANDLE _flag, bool _value = true) {
    if (_value) {
      AddPattern(_flag, 2);
    } else {
      RemovePattern(_flag, 2);
    }
  }
  void SetPattern(ENUM_PATTERN_4CANDLE _flag, bool _value = true) {
    if (_value) {
      AddPattern(_flag, 3);
    } else {
      RemovePattern(_flag, 3);
    }
  }
  void SetPattern(ENUM_PATTERN_5CANDLE _flag, bool _value = true) {
    if (_value) {
      AddPattern(_flag, 4);
    } else {
      RemovePattern(_flag, 4);
    }
  }
  void SetPattern(ENUM_PATTERN_6CANDLE _flag, bool _value = true) {
    if (_value) {
      AddPattern(_flag, 5);
    } else {
      RemovePattern(_flag, 5);
    }
  }
  void SetPattern(ENUM_PATTERN_7CANDLE _flag, bool _value = true) {
    if (_value) {
      AddPattern(_flag, 6);
    } else {
      RemovePattern(_flag, 6);
    }
  }
  void SetPattern(int _flags, int _index) { candle[_index] = _flags; }
};
