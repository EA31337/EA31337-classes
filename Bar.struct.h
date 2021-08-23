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
#include "ISerializable.h"
#include "Serializer.enum.h"
#include "SerializerNode.enum.h"
#include "Std.h"

/* Struct for storing OHLC values. */
struct BarOHLC
#ifndef __MQL__
    : public ISerializable
#endif
{
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
  BarOHLC(ARRAY_REF(float, _prices), datetime _time = 0) : time(_time) {
    _time = _time == 0 ? TimeCurrent() : _time;
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
  bool GetPivots(ENUM_PP_TYPE _type, float &_pp, float &_r1, float &_r2, float &_r3, float &_r4, float &_s1, float &_s2,
                 float &_s3, float &_s4) {
    float _range = GetRange();
    switch (_type) {
      case PP_CAMARILLA:
        // A set of eight very probable levels which resemble support and resistance values for a current trend.
        _pp = GetPivot();
        _r1 = (float)(close + _range * 1.1 / 12);
        _r2 = (float)(close + _range * 1.1 / 6);
        _r3 = (float)(close + _range * 1.1 / 4);
        _r4 = (float)(close + _range * 1.1 / 2);
        _s1 = (float)(close - _range * 1.1 / 12);
        _s2 = (float)(close - _range * 1.1 / 6);
        _s3 = (float)(close - _range * 1.1 / 4);
        _s4 = (float)(close - _range * 1.1 / 2);
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
  datetime GetTime() { return time; }
  float GetAppliedPrice(ENUM_APPLIED_PRICE _ap) const { return BarOHLC::GetAppliedPrice(_ap, open, high, low, close); }
  float GetBody() const { return close - open; }
  float GetBodyAbs() const { return fabs(close - open); }
  float GetBodyInPct(int _hundreds = 100) const { return GetRange() > 0 ? _hundreds / GetRange() * GetBodyAbs() : 0; }
  float GetChangeInPct(int _hundreds = 100) const { return (close - open) / open * _hundreds; }
  float GetClose() const { return close; }
  float GetHigh() const { return high; }
  float GetLow() const { return low; }
  float GetMaxOC() const { return fmax(open, close); }
  float GetMedian() const { return (high + low) / 2; }
  float GetMinOC() const { return fmin(open, close); }
  float GetOpen() const { return open; }
  float GetPivot() const { return GetTypical(); }
  float GetPivotDeMark() const {
    // If Close < Open Then X = H + 2 * L + C
    // If Close > Open Then X = 2 * H + L + C
    // If Close = Open Then X = H + L + 2 * C
    float _pp = open > close ? (high + (2 * low) + close) / 4 : ((2 * high) + low + close) / 4;
    return open == close ? (high + low + (2 * close)) / 4 : _pp;
  }
  float GetPivotWithOpen() const { return (open + high + low + close) / 4; }
  float GetPivotWithOpen(float _open) const { return (_open + high + low + close) / 4; }
  float GetRange() const { return high - low; }
  float GetRangeChangeInPct(int _hundreds = 100) const {
    return _hundreds - (_hundreds / open * fabs(open - GetRange()));
  }
  float GetRangeInPips(float _ppp) const { return GetRange() / _ppp; }
  float GetTypical() const { return (high + low + close) / 3; }
  float GetWeighted() const { return (high + low + close + close) / 4; }
  float GetWickMin() const { return fmin(GetWickLower(), GetWickUpper()); }
  float GetWickLower() const { return GetMinOC() - low; }
  float GetWickLowerInPct() const { return GetRange() > 0 ? 100 / GetRange() * GetWickLower() : 0; }
  float GetWickMax() const { return fmax(GetWickLower(), GetWickUpper()); }
  float GetWickSum() const { return GetWickLower() + GetWickUpper(); }
  float GetWickUpper() const { return high - GetMaxOC(); }
  float GetWickUpperInPct() const { return GetRange() > 0 ? 100 / GetRange() * GetWickUpper() : 0; }
  short GetType() const { return IsBull() ? 1 : (IsBear() ? -1 : 0); }
  void GetValues(ARRAY_REF(float, _out)) {
    ArrayResize(_out, 4);
    int _index = ArraySize(_out) - 4;
    _out[_index++] = open;
    _out[_index++] = high;
    _out[_index++] = low;
    _out[_index++] = close;
  }
  template <typename T>
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
  string ToCSV() { return StringFormat("%d,%g,%g,%g,%g", time, open, high, low, close); }
};

#include "Serializer.mqh"

/* Method to serialize BarOHLC structure. */
SerializerNodeType BarOHLC::Serialize(Serializer &s) {
  // s.Pass(THIS_REF, "time", TimeToString(time));
  s.Pass(THIS_REF, "open", open, SERIALIZER_FIELD_FLAG_DYNAMIC);
  s.Pass(THIS_REF, "high", high, SERIALIZER_FIELD_FLAG_DYNAMIC);
  s.Pass(THIS_REF, "low", low, SERIALIZER_FIELD_FLAG_DYNAMIC);
  s.Pass(THIS_REF, "close", close, SERIALIZER_FIELD_FLAG_DYNAMIC);
  return SerializerNodeObject;
}

/* Defines struct to store bar entries. */
struct BarEntry {
  BarOHLC ohlc;
  BarEntry() {}
  BarEntry(const BarOHLC &_ohlc) { ohlc = _ohlc; }
  // Struct getters
  BarOHLC GetOHLC() const { return ohlc; }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer &s) {
    s.PassStruct(THIS_REF, "ohlc", ohlc, SERIALIZER_FIELD_FLAG_DYNAMIC);
    return SerializerNodeObject;
  }
  string ToCSV() { return StringFormat("%s", ohlc.ToCSV()); }
};
