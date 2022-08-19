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
 * Includes Bar's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward class declaration.
class Serializer;

// Includes.
#include "Bar.enum.h"
#include "Chart.enum.h"
#include "Serializer/Serializable.h"
#include "Serializer/Serializer.enum.h"
#include "Serializer/SerializerNode.enum.h"
#include "Std.h"
#include "Serializer/Serializer.h"

/* Structure for storing OHLC values. */
template <typename T>
struct CandleOHLC
#ifndef __MQL__
    : public Serializable
#endif
{
  T open, high, low, close;

  // Struct constructors.
  CandleOHLC(T _open = 0, T _high = 0, T _low = 0, T _close = 0) : open(_open), high(_high), low(_low), close(_close) {}
  CandleOHLC(ARRAY_REF(T, _prices)) {
    int _size = ArraySize(_prices);
    close = _prices[0];
    open = _prices[_size - 1];
    high = fmax(close, open);
    low = fmin(close, open);
    for (int i = 0; i < _size; i++) {
      high = fmax(high, _prices[i]);
      low = fmin(low, _prices[i]);
    }
  }
  // Struct methods.
  // Getters
  bool GetPivots(ENUM_PP_TYPE _type, T &_pp, T &_r1, T &_r2, T &_r3, T &_r4, T &_s1, T &_s2, T &_s3, T &_s4) {
    T _range = GetRange();
    switch (_type) {
      case PP_CAMARILLA:
        // A set of eight very probable levels which resemble support and resistance values for a current trend.
        _pp = GetPivot();
        _r1 = (T)(close + _range * 1.1 / 12);
        _r2 = (T)(close + _range * 1.1 / 6);
        _r3 = (T)(close + _range * 1.1 / 4);
        _r4 = (T)(close + _range * 1.1 / 2);
        _s1 = (T)(close - _range * 1.1 / 12);
        _s2 = (T)(close - _range * 1.1 / 6);
        _s3 = (T)(close - _range * 1.1 / 4);
        _s4 = (T)(close - _range * 1.1 / 2);
        break;
      case PP_CLASSIC:
        _pp = GetPivot();
        _r1 = (2 * _pp) - low;   // R1 = (H - L) * 1.1 / 12 + C (1.0833)
        _r2 = _pp + _range;      // R2 = (H - L) * 1.1 / 6 + C (1.1666)
        _r3 = _pp + _range * 2;  // R3 = (H - L) * 1.1 / 4 + C (1.25)
        _r4 = _pp + _range * 3;  // R4 = (H - L) * 1.1 / 2 + C (1.5)
        _s1 = (2 * _pp) - high;  // S1 = C - (H - L) * 1.1 / 12 (1.0833)
        _s2 = _pp - _range;      // S2 = C - (H - L) * 1.1 / 6 (1.1666)
        _s3 = _pp - _range * 2;  // S3 = C - (H - L) * 1.1 / 4 (1.25)
        _s4 = _pp - _range * 3;  // S4 = C - (H - L) * 1.1 / 2 (1.5)
        break;
      case PP_FIBONACCI:
        _pp = GetPivot();
        _r1 = (float)(_pp + 0.382 * _range);
        _r2 = (float)(_pp + 0.618 * _range);
        _r3 = _pp + _range;
        _r4 = _r1 + _range;  // ?
        _s1 = (float)(_pp - 0.382 * _range);
        _s2 = (float)(_pp - 0.618 * _range);
        _s3 = _pp - _range;
        _s4 = _s1 - _range;  // ?
        break;
      case PP_FLOOR:
        // Most basic and popular type of pivots used in Forex trading technical analysis.
        _pp = GetPivot();              // Pivot (P) = (H + L + C) / 3
        _r1 = (2 * _pp) - low;         // Resistance (R1) = (2 * P) - L
        _r2 = _pp + _range;            // R2 = P + H - L
        _r3 = high + 2 * (_pp - low);  // R3 = H + 2 * (P - L)
        _r4 = _r3;
        _s1 = (2 * _pp) - high;        // Support (S1) = (2 * P) - H
        _s2 = _pp - _range;            // S2 = P - H + L
        _s3 = low - 2 * (high - _pp);  // S3 = L - 2 * (H - P)
        _s4 = _s3;                     // ?
        break;
      case PP_TOM_DEMARK:
        // Tom DeMark's pivot point (predicted lows and highs of the period).
        _pp = GetPivotDeMark();
        _r1 = (2 * _pp) - low;  // New High = X / 2 - L.
        _r2 = _pp + _range;
        _r3 = _r1 + _range;
        _r4 = _r2 + _range;      // ?
        _s1 = (2 * _pp) - high;  // New Low = X / 2 - H.
        _s2 = _pp - _range;
        _s3 = _s1 - _range;
        _s4 = _s2 - _range;  // ?
        break;
      case PP_WOODIE:
        // Woodie's pivot point are giving more weight to the Close price of the previous period.
        // They are similar to floor pivot points, but are calculated in a somewhat different way.
        _pp = GetWeighted();    // Pivot (P) = (H + L + 2 * C) / 4
        _r1 = (2 * _pp) - low;  // Resistance (R1) = (2 * P) - L
        _r2 = _pp + _range;     // R2 = P + H - L
        _r3 = _r1 + _range;
        _r4 = _r2 + _range;      // ?
        _s1 = (2 * _pp) - high;  // Support (S1) = (2 * P) - H
        _s2 = _pp - _range;      // S2 = P - H + L
        _s3 = _s1 - _range;
        _s4 = _s2 - _range;  // ?
        break;
      default:
        break;
    }
    return _r4 > _r3 && _r3 > _r2 && _r2 > _r1 && _r1 > _pp && _pp > _s1 && _s1 > _s2 && _s2 > _s3 && _s3 > _s4;
  }
  T GetAppliedPrice(ENUM_APPLIED_PRICE _ap) const { return CandleOHLC::GetAppliedPrice(_ap, open, high, low, close); }
  T GetBody() const { return close - open; }
  T GetBodyAbs() const { return fabs(close - open); }
  T GetBodyInPct(int _hundreds = 100) const { return GetRange() > 0 ? _hundreds / GetRange() * GetBodyAbs() : 0; }
  T GetChangeInPct(int _hundreds = 100) const { return (close - open) / open * _hundreds; }
  T GetClose() const { return close; }
  T GetHigh() const { return high; }
  T GetLow() const { return low; }
  T GetMaxOC() const { return fmax(open, close); }
  T GetMedian() const { return (high + low) / 2; }
  T GetMinOC() const { return fmin(open, close); }
  T GetOpen() const { return open; }
  T GetPivot() const { return GetTypical(); }
  T GetPivotDeMark() const {
    // If Close < Open Then X = H + 2 * L + C
    // If Close > Open Then X = 2 * H + L + C
    // If Close = Open Then X = H + L + 2 * C
    T _pp = open > close ? (high + (2 * low) + close) / 4 : ((2 * high) + low + close) / 4;
    return open == close ? (high + low + (2 * close)) / 4 : _pp;
  }
  T GetPivotWithOpen() const { return (open + high + low + close) / 4; }
  T GetPivotWithOpen(float _open) const { return (_open + high + low + close) / 4; }
  T GetRange() const { return high - low; }
  T GetRangeChangeInPct(int _hundreds = 100) const { return _hundreds - (_hundreds / open * fabs(open - GetRange())); }
  T GetRangeInPips(float _ppp) const { return GetRange() / _ppp; }
  T GetTypical() const { return (high + low + close) / 3; }
  T GetWeighted() const { return (high + low + close + close) / 4; }
  T GetWickMin() const { return fmin(GetWickLower(), GetWickUpper()); }
  T GetWickLower() const { return GetMinOC() - low; }
  T GetWickLowerInPct() const { return GetRange() > 0 ? 100 / GetRange() * GetWickLower() : 0; }
  T GetWickMax() const { return fmax(GetWickLower(), GetWickUpper()); }
  T GetWickSum() const { return GetWickLower() + GetWickUpper(); }
  T GetWickUpper() const { return high - GetMaxOC(); }
  T GetWickUpperInPct() const { return GetRange() > 0 ? 100 / GetRange() * GetWickUpper() : 0; }
  short GetType() const { return IsBull() ? 1 : (IsBear() ? -1 : 0); }
  void GetValues(ARRAY_REF(T, _out)) {
    ArrayResize(_out, 4);
    int _index = ArraySize(_out) - 4;
    _out[_index++] = open;
    _out[_index++] = high;
    _out[_index++] = low;
    _out[_index++] = close;
  }
  static T GetAppliedPrice(ENUM_APPLIED_PRICE _ap, T _o, T _h, T _l, T _c) {
    switch (_ap) {
      case PRICE_CLOSE:
        return _c;
      case PRICE_OPEN:
        return _o;
      case PRICE_HIGH:
        return _h;
      case PRICE_LOW:
        return _l;
      case PRICE_MEDIAN:
        return (_h + _l) / 2;
      case PRICE_TYPICAL:
        return (_h + _l + _c) / 3;
      case PRICE_WEIGHTED:
        return (_h + _l + _c + _c) / 4;
      default:
        return _o;
    }
  }
  // State checkers.
  bool IsBear() const { return open > close; }
  bool IsBull() const { return open < close; }
  bool IsValid() const { return high >= low && fmin(open, close) > 0; }
  // Serializers.
  SerializerNodeType Serialize(Serializer &s);
  // Converters.
  string ToCSV() { return StringFormat("%g,%g,%g,%g", open, high, low, close); }
};

/* Structure for storing OHLC values, number of ticks which formed the candle and both, open and close timestamp of the
 * candle. */
template <typename T>
struct CandleOCTOHLC : CandleOHLC<T> {
  long open_timestamp, close_timestamp;

  // Number of ticks which formed the candle. Also known as volume.
  int volume;

  // Struct constructors.
  CandleOCTOHLC(T _open = 0, T _high = 0, T _low = 0, T _close = 0, long _open_timestamp = -1,
                long _close_timestamp = -1, int _volume = 0)
      : CandleOHLC(_open, _high, _low, _close),
        open_timestamp(_open_timestamp),
        close_timestamp(_close_timestamp),
        volume(_volume) {
    if (_open != 0) {
      volume = 1;
    }
  }

  // Updates OHLC values taking into consideration tick's timestamp.
  void Update(long _timestamp, T _price) {
    if (_timestamp < open_timestamp) {
      open_timestamp = _timestamp;
      open = _price;
    }
    if (_timestamp > close_timestamp) {
      close_timestamp = _timestamp;
      close = _price;
    }
    high = MathMax(high, _price);
    low = MathMin(low, _price);
    // Increasing candle's volume.
    ++volume;
  }

  // Returns timestamp of open price.
  long GetOpenTimestamp() { return open_timestamp; }

  // Returns timestamp of close price.
  long GetCloseTimestamp() { return close_timestamp; }
};

/* Structore for storing OHLC values with timestamp. */
template <typename T>
struct CandleTOHLC : CandleOHLC<T> {
  datetime time;
  // Struct constructors.
  CandleTOHLC(datetime _time = 0, T _open = 0, T _high = 0, T _low = 0, T _close = 0)
      : time(_time), CandleOHLC(_open, _high, _low, _close) {}
  // Getters.
  datetime GetTime() { return time; }
  // Serializers.
  SerializerNodeType Serialize(Serializer &s);
  // Converters.
  string ToCSV() { return StringFormat("%d,%g,%g,%g,%g", time, open, high, low, close); }
};

/* Method to serialize CandleEntry structure. */
template <typename T>
SerializerNodeType CandleOHLC::Serialize(Serializer &s) {
  // s.Pass(THIS_REF, "time", TimeToString(time));
  s.Pass(THIS_REF, "open", open, SERIALIZER_FIELD_FLAG_DYNAMIC);
  s.Pass(THIS_REF, "high", high, SERIALIZER_FIELD_FLAG_DYNAMIC);
  s.Pass(THIS_REF, "low", low, SERIALIZER_FIELD_FLAG_DYNAMIC);
  s.Pass(THIS_REF, "close", close, SERIALIZER_FIELD_FLAG_DYNAMIC);
  return SerializerNodeObject;
}

/* Method to serialize CandleEntry structure. */
template <typename T>
SerializerNodeType CandleTOHLC::Serialize(Serializer &s) {
  s.Pass(THIS_REF, "time", time);
  s.Pass(THIS_REF, "open", open, SERIALIZER_FIELD_FLAG_DYNAMIC);
  s.Pass(THIS_REF, "high", high, SERIALIZER_FIELD_FLAG_DYNAMIC);
  s.Pass(THIS_REF, "low", low, SERIALIZER_FIELD_FLAG_DYNAMIC);
  s.Pass(THIS_REF, "close", close, SERIALIZER_FIELD_FLAG_DYNAMIC);
  return SerializerNodeObject;
}
