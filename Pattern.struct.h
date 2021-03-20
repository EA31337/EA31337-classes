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
  unsigned int pattern[8];
  // Struct constructor.
  PatternEntry(BarOHLC _ohlc[]) {
    // 1-candle patterns.
    BarEntry _candle0(_ohlc[0]);
    pattern[0] = _candle0.pattern.GetPattern();
    // Calculates 2-candle patterns.
    if (ArraySize(_ohlc) > 1) {
      // Two bear candles.
      SetPattern(PATTERN_2CANDLE_BEARS, _ohlc[0].open > _ohlc[0].close && _ohlc[1].open > _ohlc[1].close);
      // Body size is greater than the previous one.
      SetPattern(PATTERN_2CANDLE_BODY_GT_BODY, _ohlc[0].GetBodyAbs() > _ohlc[1].GetBodyAbs());
      // Two bulls candles.
      SetPattern(PATTERN_2CANDLE_BULLS, _ohlc[0].open < _ohlc[0].close && _ohlc[1].open < _ohlc[1].close);
      // Close price is greater than the previous one.
      SetPattern(PATTERN_2CANDLE_CLOSE_GT_CLOSE, _ohlc[0].close > _ohlc[1].close);
      // Close price is greater than previous high.
      SetPattern(PATTERN_2CANDLE_CLOSE_GT_HIGH, _ohlc[0].close > _ohlc[1].high);
      // Close price is lower than previous low.
      SetPattern(PATTERN_2CANDLE_CLOSE_LT_LOW, _ohlc[0].close < _ohlc[1].low);
      // Higher price (open or close) is greater than the previous high.
      SetPattern(PATTERN_2CANDLE_HOC_GT_HIGH, _ohlc[0].GetMaxOC() > _ohlc[1].high);
      // Higher price (open or close) is greater than the previous one.
      SetPattern(PATTERN_2CANDLE_HOC_GT_HOC, _ohlc[0].GetMaxOC() > _ohlc[1].GetMaxOC());
      // High price is greater than the previous one.
      SetPattern(PATTERN_2CANDLE_HIGH_GT_HIGH, _ohlc[0].high > _ohlc[1].high);
      // High is greater than the previous higher price (open or close).
      SetPattern(PATTERN_2CANDLE_HIGH_GT_HOC, _ohlc[0].high > _ohlc[1].GetMaxOC());
      // Lower price (open or close) is lower than the previous one.
      SetPattern(PATTERN_2CANDLE_LOC_LT_LOC, _ohlc[0].GetMinOC() < _ohlc[1].GetMinOC());
      // Lower price (open or close) is lower than the previous low.
      SetPattern(PATTERN_2CANDLE_LOC_LT_LOW, _ohlc[0].GetMinOC() < _ohlc[1].low);
      // Low is lower than the previous lower price (open or close).
      SetPattern(PATTERN_2CANDLE_LOW_LT_LOC, _ohlc[0].low < _ohlc[1].GetMinOC());
      // Low price is lower than the previous one.
      SetPattern(PATTERN_2CANDLE_LOW_LT_LOW, _ohlc[0].low < _ohlc[1].low);
      // Open price is greater than the previous one.
      SetPattern(PATTERN_2CANDLE_OPEN_GT_OPEN, _ohlc[0].open > _ohlc[1].open);
      // Pivot price is greater than the previous one (HLC/3).
      SetPattern(PATTERN_2CANDLE_PP_GT_PP, _ohlc[0].GetPivot() > _ohlc[1].GetPivot());
      // Pivot price open is greater than the previous one (OHLC/4).
      SetPattern(PATTERN_2CANDLE_PP_GT_PP_OPEN, _ohlc[0].GetPivot() > _ohlc[1].GetPivotWithOpen(_ohlc[1].open));
      // Range size doubled from the previous one.
      SetPattern(PATTERN_2CANDLE_RANGE_DBL_RANGE, _ohlc[0].GetRange() > _ohlc[1].GetRange() * 2);
      // Range is greater than the previous one.
      SetPattern(PATTERN_2CANDLE_RANGE_GT_RANGE, _ohlc[0].GetRange() > _ohlc[1].GetRange());
      // Weighted price is greater than the previous one (OH2C/4).
      SetPattern(PATTERN_2CANDLE_WEIGHTED_GT_WEIGHTED, _ohlc[0].GetWeighted() > _ohlc[1].GetWeighted());
      // Size of wicks doubled from the previous onces.
      SetPattern(PATTERN_2CANDLE_WICKS_DBL_WICKS, _ohlc[0].GetWickSum() > _ohlc[1].GetWickSum() * 2);
      // Size of wicks is greater than the previous onces.
      SetPattern(PATTERN_2CANDLE_WICKS_DBL_WICKS, _ohlc[0].GetWickSum() > _ohlc[1].GetWickSum());
    }
    // Calculates 3-candle patterns.
    if (ArraySize(_ohlc) > 2) {
      // Three bear candles.
      SetPattern(PATTERN_3CANDLE_BEARS, CheckPattern(PATTERN_2CANDLE_BEARS, 1) && _ohlc[2].open > _ohlc[2].close);
      // Body size is greater than doubled sum of others.
      SetPattern(PATTERN_3CANDLE_BODY0_DBL_SUM,
                 _ohlc[0].GetBodyAbs() > (_ohlc[1].GetBodyAbs() + _ohlc[2].GetBodyAbs()) * 2);
      // Body size is greater than sum of others.
      SetPattern(PATTERN_3CANDLE_BODY0_GT_SUM, _ohlc[0].GetBodyAbs() > _ohlc[1].GetBodyAbs() + _ohlc[2].GetBodyAbs());
      // Body size decreases.
      SetPattern(PATTERN_3CANDLE_BODY_DEC,
                 _ohlc[0].GetBodyAbs() < _ohlc[1].GetBodyAbs() && _ohlc[1].GetBodyAbs() < _ohlc[2].GetBodyAbs());
      // Body size increases.
      SetPattern(PATTERN_3CANDLE_BODY_INC,
                 _ohlc[0].GetBodyAbs() > _ohlc[1].GetBodyAbs() && _ohlc[1].GetBodyAbs() > _ohlc[2].GetBodyAbs());
      // Three bull candles.
      SetPattern(PATTERN_3CANDLE_BULLS, CheckPattern(PATTERN_2CANDLE_BULLS, 1) && _ohlc[2].open < _ohlc[2].close);
      // Close price decreases.
      SetPattern(PATTERN_3CANDLE_CLOSE_DEC, _ohlc[0].close < _ohlc[1].close && _ohlc[1].close < _ohlc[2].close);
      // Close price increases.
      SetPattern(PATTERN_3CANDLE_CLOSE_INC, _ohlc[0].close > _ohlc[1].close && _ohlc[1].close > _ohlc[2].close);
      // High price lower than low price of 2 bars before.
      SetPattern(PATTERN_3CANDLE_HIGH0_LT_LOW2, _ohlc[0].high < _ohlc[2].low);
      // High price of the middle bar is lower than pivot price.
      SetPattern(PATTERN_3CANDLE_HIGH1_LT_PP, _ohlc[1].high < fmin(_ohlc[0].GetPivot(), _ohlc[2].GetPivot()));
      // High price decreases.
      SetPattern(PATTERN_3CANDLE_HIGH_DEC, _ohlc[0].high < _ohlc[1].high && _ohlc[1].high < _ohlc[2].high);
      // High price increases.
      SetPattern(PATTERN_3CANDLE_HIGH_INC, _ohlc[0].high > _ohlc[1].high && _ohlc[1].high > _ohlc[2].high);
      // Low price is greater than high price of 2 bars before.
      SetPattern(PATTERN_3CANDLE_LOW0_GT_HIGH2, _ohlc[0].low > _ohlc[2].high);
      // Low price of the middle bar is greater than pivot price.
      SetPattern(PATTERN_3CANDLE_LOW1_GT_PP, _ohlc[1].low > fmax(_ohlc[0].GetPivot(), _ohlc[2].GetPivot()));
      // Low price decreases.
      SetPattern(PATTERN_3CANDLE_LOW_DEC, _ohlc[0].low < _ohlc[1].low && _ohlc[1].low < _ohlc[2].low);
      // Low price increases.
      SetPattern(PATTERN_3CANDLE_LOW_INC, _ohlc[0].low > _ohlc[1].low && _ohlc[1].low > _ohlc[2].low);
      // Open price is greater than high price of 2 bars before.
      SetPattern(PATTERN_3CANDLE_OPEN0_GT_HIGH2, _ohlc[0].open > _ohlc[2].high);
      // Open price is lower than low price of 2 bars before.
      SetPattern(PATTERN_3CANDLE_OPEN0_LT_LOW2, _ohlc[0].open < _ohlc[2].low);
      // Open price decreases.
      SetPattern(PATTERN_3CANDLE_OPEN_DEC, _ohlc[0].open < _ohlc[1].open && _ohlc[1].open < _ohlc[2].open);
      // Open price increases.
      SetPattern(PATTERN_3CANDLE_OPEN_INC, _ohlc[0].open > _ohlc[1].open && _ohlc[1].open > _ohlc[2].open);
      // High or low price at peak.
      SetPattern(PATTERN_3CANDLE_PEAK,
                 _ohlc[0].high > fmax(_ohlc[1].high, _ohlc[2].high) || _ohlc[0].low < fmin(_ohlc[1].low, _ohlc[2].low));
      // Pivot point decreases.
      SetPattern(PATTERN_3CANDLE_PP_DEC,
                 _ohlc[0].GetPivot() < _ohlc[1].GetPivot() && _ohlc[1].GetPivot() < _ohlc[2].GetPivot());
      // Pivot point increases.
      SetPattern(PATTERN_3CANDLE_PP_INC,
                 _ohlc[0].GetPivot() > _ohlc[1].GetPivot() && _ohlc[1].GetPivot() > _ohlc[2].GetPivot());
      // Range size is greater than sum of others.
      SetPattern(PATTERN_3CANDLE_RANGE0_GT_SUM, _ohlc[0].GetRange() > (_ohlc[1].GetRange() + _ohlc[2].GetRange()));
      // Range size of middle candle is greater than sum of others.
      SetPattern(PATTERN_3CANDLE_RANGE1_GT_SUM, _ohlc[1].GetRange() > (_ohlc[0].GetRange() + _ohlc[2].GetRange()));
      // Range size decreases.
      SetPattern(PATTERN_3CANDLE_RANGE_DEC,
                 _ohlc[0].GetRange() < _ohlc[1].GetRange() && _ohlc[1].GetRange() < _ohlc[2].GetRange());
      // Range size increases.
      SetPattern(PATTERN_3CANDLE_RANGE_INC,
                 _ohlc[0].GetRange() > _ohlc[1].GetRange() && _ohlc[1].GetRange() > _ohlc[2].GetRange());
      // Size of wicks are greater than doubled sum of others.
      SetPattern(PATTERN_3CANDLE_WICKS0_DBL_SUM,
                 _ohlc[0].GetWickSum() > (_ohlc[1].GetWickSum() + _ohlc[2].GetWickSum()) * 2);
      // Size of wicks are greater than sum of bodies.
      SetPattern(PATTERN_3CANDLE_WICKS0_GT_BODY, _ohlc[0].GetWickSum() > _ohlc[1].GetBodyAbs() + _ohlc[2].GetBodyAbs());
      // Size of wicks are greater than sum of others.
      SetPattern(PATTERN_3CANDLE_WICKS0_GT_SUM, _ohlc[0].GetWickSum() > _ohlc[1].GetWickSum() + _ohlc[2].GetWickSum());
      // Size of middle wicks are greater than doubled sum of bodies.
      SetPattern(PATTERN_3CANDLE_WICKS1_DBL_BODY,
                 _ohlc[1].GetWickSum() > (_ohlc[0].GetBodyAbs() + _ohlc[2].GetBodyAbs()) * 2);
      // Size of middle wicks are greater than sum of bodies.
      SetPattern(PATTERN_3CANDLE_WICKS1_GT_BODY, _ohlc[1].GetWickSum() > _ohlc[0].GetBodyAbs() + _ohlc[2].GetBodyAbs());
    }
  }
  // Struct methods for bitwise operations.
  bool CheckPattern(int _flags, int _index) { return (pattern[_index] & _flags) != 0; }
  bool CheckPatternsAll(int _flags, int _index) { return (pattern[_index] & _flags) == _flags; }
  void AddPattern(int _flags, int _index) { pattern[_index] |= _flags; }
  void RemovePattern(int _flags, int _index) { pattern[_index] &= ~_flags; }
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
  void SetPattern(int _flags, int _index) { pattern[_index] = _flags; }
};
