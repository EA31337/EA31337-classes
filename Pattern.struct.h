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
   * Calculates depth of selected bit.
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
    int _size = ArraySize(v);
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
  // Reset array.
  void Reset() { ArrayResize(v, 0); }
};

// Struct for calculating and storing 1-candlestick patterns.
struct PatternCandle1 {
  unsigned int pattern;
  PatternCandle1() : pattern(PATTERN_1CANDLE_NONE) {}
  PatternCandle1(const BarOHLC &_c) : pattern(PATTERN_1CANDLE_NONE) {
    float _body_pct = _c.GetBodyInPct();
    float _crice_chg = _c.GetChangeInPct();
    float _wick_lw_pct = _c.GetWickLowerInPct();
    float _wick_up_pct = _c.GetWickUpperInPct();
    SetPattern(PATTERN_1CANDLE_BEAR, _c.open > _c.close);  // Candle is bearish.
    SetPattern(PATTERN_1CANDLE_BULL, _c.open < _c.close);  // Candle is bullish.
    SetPattern(PATTERN_1CANDLE_BODY_GT_MED, _c.GetMinOC() > _c.GetMedian());
    SetPattern(PATTERN_1CANDLE_BODY_GT_PP, _c.GetMinOC() > _c.GetPivot());
    SetPattern(PATTERN_1CANDLE_BODY_GT_PP_DM, _c.GetMinOC() > _c.GetPivotDeMark());
    SetPattern(PATTERN_1CANDLE_BODY_GT_PP_OPEN, _c.GetMinOC() > _c.GetPivotWithOpen());
    SetPattern(PATTERN_1CANDLE_BODY_GT_WEIGHTED, _c.GetMinOC() > _c.GetWeighted());
    SetPattern(PATTERN_1CANDLE_BODY_GT_WICKS, _c.GetBody() > _c.GetWickSum());
    SetPattern(PATTERN_1CANDLE_CHANGE_GT_02PC, _crice_chg > 0.2);
    SetPattern(PATTERN_1CANDLE_CHANGE_GT_05PC, _crice_chg > 0.5);
    SetPattern(PATTERN_1CANDLE_CLOSE_GT_MED, _c.GetClose() > _c.GetMedian());
    SetPattern(PATTERN_1CANDLE_CLOSE_GT_PP, _c.GetClose() > _c.GetPivot());
    SetPattern(PATTERN_1CANDLE_CLOSE_GT_PP_DM, _c.GetClose() > _c.GetPivotDeMark());
    SetPattern(PATTERN_1CANDLE_CLOSE_GT_PP_OPEN, _c.GetClose() > _c.GetPivotWithOpen());
    SetPattern(PATTERN_1CANDLE_CLOSE_GT_WEIGHTED, _c.GetClose() > _c.GetWeighted());
    SetPattern(PATTERN_1CANDLE_CLOSE_LT_PP, _c.GetClose() < _c.GetPivot());
    SetPattern(PATTERN_1CANDLE_CLOSE_LT_PP_DM, _c.GetClose() < _c.GetPivotDeMark());
    SetPattern(PATTERN_1CANDLE_CLOSE_LT_PP_OPEN, _c.GetClose() < _c.GetPivotWithOpen());
    SetPattern(PATTERN_1CANDLE_CLOSE_LT_WEIGHTED, _c.GetClose() < _c.GetWeighted());
    SetPattern(PATTERN_1CANDLE_HAS_WICK_LW, _wick_lw_pct > 0.1);     // Has lower shadow
    SetPattern(PATTERN_1CANDLE_HAS_WICK_UP, _wick_up_pct > 0.1);     // Has upper shadow
    SetPattern(PATTERN_1CANDLE_IS_DOJI_DRAGON, _wick_lw_pct >= 98);  // Has doji dragonfly pattern (upper)
    SetPattern(PATTERN_1CANDLE_IS_DOJI_GRAVE, _wick_up_pct >= 98);   // Has doji gravestone pattern (lower)
    SetPattern(PATTERN_1CANDLE_IS_HAMMER_INV,
               _wick_up_pct > _body_pct * 2 && _wick_lw_pct < 2);  // Has a lower hammer pattern
    SetPattern(PATTERN_1CANDLE_IS_HAMMER_UP,
               _wick_lw_pct > _body_pct * 2 && _wick_up_pct < 2);                    // Has an upper hammer pattern
    SetPattern(PATTERN_1CANDLE_IS_HANGMAN, _wick_lw_pct > 80 && _wick_lw_pct < 98);  // Has a hanging man pattern
    SetPattern(PATTERN_1CANDLE_IS_LONG_SHADOW_LW, _wick_lw_pct >= 60);               // Has long lower shadow
    SetPattern(PATTERN_1CANDLE_IS_LONG_SHADOW_UP, _wick_up_pct >= 60);               // Has long upper shadow
    SetPattern(PATTERN_1CANDLE_IS_MARUBOZU, _body_pct >= 98);                        // Full body with no or small wicks
    SetPattern(PATTERN_1CANDLE_IS_SHAVEN_LW, _wick_up_pct > 50 && _wick_lw_pct < 2);     // Has a shaven bottom pattern
    SetPattern(PATTERN_1CANDLE_IS_SHAVEN_UP, _wick_lw_pct > 50 && _wick_up_pct < 2);     // Has a shaven head pattern
    SetPattern(PATTERN_1CANDLE_IS_SPINNINGTOP, _wick_lw_pct > 30 && _wick_lw_pct > 30);  // Has a spinning top pattern
  }
  // Getters.
  unsigned int GetPattern() { return pattern; }
  // Struct methods for bitwise operations.
  bool CheckPattern(int _flags) { return (pattern & _flags) != 0; }
  bool CheckPatternsAll(int _flags) { return (pattern & _flags) == _flags; }
  void AddPattern(int _flags) { pattern |= _flags; }
  void RemovePattern(int _flags) { pattern &= ~_flags; }
  void SetPattern(ENUM_PATTERN_1CANDLE _flag, bool _value = true) {
    if (_value) {
      AddPattern(_flag);
    } else {
      RemovePattern(_flag);
    }
  }
  void SetPattern(int _flags) { pattern = _flags; }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}

  SerializerNodeType Serialize(Serializer &_s) {
    int _size = sizeof(int) * 8;
    for (int i = 0; i < _size; i++) {
      int _value = CheckPattern(1 << i) ? 1 : 0;
      _s.Pass(this, (string)(i + 1), _value, SERIALIZER_FIELD_FLAG_DYNAMIC);
    }
    return SerializerNodeObject;
  }
  string ToCSV() { return StringFormat("%s", "todo"); }
};

// Struct for calculating and storing 2-candlestick patterns.
/*
struct PatternCandle2 {
  unsigned int pattern;
  PatternCandle2() : pattern(PATTERN_1CANDLE_NONE) {}
  PatternCandle2(const BarOHLC& _c[]) : pattern(PATTERN_1CANDLE_NONE) {
  }
};
*/

// Defines structure for pattern entry.
struct PatternEntry {
  unsigned int pattern[8];
  // Struct constructor.
  PatternEntry() {}
  PatternEntry(BarOHLC &_ohlc[]) {
    // 1-candle patterns.
    PatternCandle1 _pattern1(_ohlc[0]);
    pattern[0] = _pattern1.GetPattern();
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
    // Calculates 4-candle patterns.
    if (ArraySize(_ohlc) > 3) {
      // Bearish trend continuation (DUUP).
      SetPattern(PATTERN_4CANDLE_BEAR_CONT,
                 /* Bear 0 cont. */ _ohlc[0].open > _ohlc[0].close &&
                     /* Bear 0 is low */ _ohlc[0].low < _ohlc[3].low &&
                     /* Bear 0 body is large */ CheckPattern(PATTERN_3CANDLE_BODY0_GT_SUM, 2) &&
                     /* Bull 1 */ _ohlc[1].open < _ohlc[1].close &&
                     /* Bull 2 */ _ohlc[2].open < _ohlc[2].close &&
                     /* Bear 3 */ _ohlc[3].open > _ohlc[3].close &&
                     /* Bear 3 is low */ _ohlc[3].low < fmin(_ohlc[2].low, _ohlc[1].low));
      // Bearish trend reversal (UUDD).
      SetPattern(
          PATTERN_4CANDLE_BEAR_REV,
          /* Bear 0 */ _ohlc[0].open > _ohlc[0].close &&
              /* Bear's 0 low is lowest */ _ohlc[0].GetMinOC() < fmin3(_ohlc[1].low, _ohlc[2].low, _ohlc[3].low) &&
              /* Bear 1 */ _ohlc[1].open > _ohlc[1].close &&
              /* Bull 2 */ _ohlc[2].open < _ohlc[2].close &&
              /* Bull 3 */ _ohlc[3].open < _ohlc[3].close);
      // Body size is greater than sum of others.
      SetPattern(PATTERN_4CANDLE_BODY0_GT_SUM,
                 _ohlc[0].GetBodyAbs() > _ohlc[1].GetBodyAbs() + _ohlc[2].GetBodyAbs() + _ohlc[3].GetBodyAbs());
      // Bull trend continuation (UDDU).
      SetPattern(PATTERN_4CANDLE_BULL_CONT,
                 /* Bull 0 cont. */ _ohlc[0].open < _ohlc[0].close &&
                     /* Bull 0 is high */ _ohlc[0].high > _ohlc[3].high &&
                     /* Bull 0 body is large */ CheckPattern(PATTERN_3CANDLE_BODY0_GT_SUM, 2) &&
                     /* Bear 1 */ _ohlc[1].open > _ohlc[1].close &&
                     /* Bear 2 */ _ohlc[2].open > _ohlc[2].close &&
                     /* Bull 3 */ _ohlc[3].open < _ohlc[3].close &&
                     /* Bull 3 is high */ _ohlc[3].high > fmax(_ohlc[2].high, _ohlc[1].high));
      // Bullish trend reversal (DDUU).
      SetPattern(
          PATTERN_4CANDLE_BULL_REV,
          /* Bear 0 */ _ohlc[0].open < _ohlc[0].close &&
              /* Bull's 0 high is highest */ _ohlc[0].GetMaxOC() > fmax3(_ohlc[1].high, _ohlc[2].high, _ohlc[3].high) &&
              /* Bull 1 */ _ohlc[1].open < _ohlc[1].close &&
              /* Bear 2 */ _ohlc[2].open > _ohlc[2].close &&
              /* Bear 3 */ _ohlc[3].open > _ohlc[3].close);

      // Inverted hammer (DD^UU).
      SetPattern(PATTERN_4CANDLE_INV_HAMMER,
                 /* Bull 0 */ _ohlc[0].open < _ohlc[0].close &&
                     /* Bull 1 */ _ohlc[1].open < _ohlc[1].close &&
                     /* Bear 2 */ _ohlc[2].open > _ohlc[2].close &&
                     /* Bear 3 */ _ohlc[3].open > _ohlc[3].close &&
                     /* Upper spike */ fmax(_ohlc[1].GetWickUpper(), _ohlc[2].GetWickUpper()) >
                         _ohlc[0].GetWickSum() + _ohlc[3].GetWickSum());
      // Range size is greater than sum of others.
      SetPattern(PATTERN_4CANDLE_RANGE0_GT_SUM,
                 _ohlc[0].GetRange() > _ohlc[1].GetRange() + _ohlc[2].GetRange() + _ohlc[3].GetRange());
      // Shooting star (UU^DD).
      SetPattern(PATTERN_4CANDLE_SHOOT_STAR,
                 /* Bear 0 */ _ohlc[0].open > _ohlc[0].close &&
                     /* Bear 1 */ _ohlc[1].open > _ohlc[1].close &&
                     /* Bull 2 */ _ohlc[2].open < _ohlc[2].close &&
                     /* Bull 3 */ _ohlc[3].open < _ohlc[3].close &&
                     /* Lower spike */ fmax(_ohlc[1].GetWickLower(), _ohlc[2].GetWickLower()) >
                         _ohlc[0].GetWickSum() + _ohlc[3].GetWickSum());
      // Size of wicks are greater than sum of others.
      SetPattern(PATTERN_4CANDLE_WICKS0_GT_SUM,
                 _ohlc[0].GetWickSum() > _ohlc[1].GetWickSum() + _ohlc[2].GetWickSum() + _ohlc[3].GetWickSum());
      // Sum of wicks are greater than sum of bodies.
      SetPattern(PATTERN_4CANDLE_WICKS_GT_BODY,
                 _ohlc[0].GetWickSum() + _ohlc[1].GetWickSum() + _ohlc[2].GetWickSum() + _ohlc[3].GetWickSum() >
                     _ohlc[0].GetBodyAbs() + _ohlc[1].GetBodyAbs() + _ohlc[2].GetBodyAbs() + _ohlc[3].GetBodyAbs());
      // Sum of upper wicks are greater than lower.
      SetPattern(
          PATTERN_4CANDLE_WICKS_UPPER,
          _ohlc[0].GetWickUpper() + _ohlc[1].GetWickUpper() + _ohlc[2].GetWickUpper() + _ohlc[3].GetWickUpper() >
              _ohlc[0].GetWickLower() + _ohlc[1].GetWickLower() + _ohlc[2].GetWickLower() + _ohlc[3].GetWickLower());
    }
  }
  // Operator methods.
  unsigned int operator[](const int _index) const { return pattern[_index]; }
  // Struct methods for bitwise operations.
  bool CheckPattern(int _flags, int _index) { return (pattern[_index] & _flags) != 0; }
  bool CheckPatternsAll(int _flags, int _index) { return (pattern[_index] & _flags) == _flags; }
  void AddPattern(int _flags, int _index) { pattern[_index] |= _flags; }
  void RemovePattern(int _flags, int _index) { pattern[_index] &= ~_flags; }
  void SetPattern(ENUM_PATTERN_1CANDLE _flag, bool _value = true) {
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
