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
class Serializer;

// Includes.
#include "Serializer.mqh"
#include "SerializerJson.mqh"
#include "SerializerCsv.mqh"

// Struct for storing OHLC values.
struct OHLC {
  datetime time;
  double open, high, low, close;
  // Struct constructor.
  OHLC() : open(0), high(0), low(0), close(0), time(0){};
  OHLC(double _open, double _high, double _low, double _close, datetime _time = 0)
      : time(_time), open(_open), high(_high), low(_low), close(_close) {
    if (_time == 0) {
      _time = TimeCurrent();
    }
  }
  // Struct methods.
  // Serializers.
  SerializerNodeType Serialize(Serializer& s) {
    // s.Pass(this, "time", TimeToString(time));
    s.Pass(this, "open", open);
    s.Pass(this, "high", high);
    s.Pass(this, "low", low);
    s.Pass(this, "close", close);
    return SerializerNodeObject;
  }
  string ToCSV() { return StringFormat("%d,%g,%g,%g,%g", time, open, high, low, close); }
};

// Defines struct to store symbol data.
struct ChartEntry {
  OHLC ohlc;
  ChartEntry() {}
  ChartEntry(const OHLC& _ohlc) { ohlc = _ohlc; }
  // Struct getters
  OHLC GetOHLC() { return ohlc; }
  // Serializers.
  SerializerNodeType Serialize(Serializer& s) {
    string _ohlc = SerializerConverter::FromObject(ohlc).ToString<SerializerCsv>();
    s.Pass(this, "ohlc", _ohlc);
    return SerializerNodeObject;
  }
  string ToCSV() { return StringFormat("%s", ohlc.ToCSV()); }
};

// Defines struct for chart parameters.
struct ChartParams {
  ENUM_TIMEFRAMES tf;
  ENUM_TIMEFRAMES_INDEX tfi;
  ENUM_PP_TYPE pp_type;
  // Constructor.
  void ChartParams(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : tf(_tf), tfi(Chart::TfToIndex(_tf)), pp_type(PP_CLASSIC){};
  void ChartParams(ENUM_TIMEFRAMES_INDEX _tfi) : tfi(_tfi), tf(Chart::IndexToTf(_tfi)), pp_type(PP_CLASSIC){};
  void SetPP(ENUM_PP_TYPE _pp) { pp_type = _pp; }
  void SetTf(ENUM_TIMEFRAMES _tf) {
    tf = _tf;
    tfi = Chart::TfToIndex(_tf);
  };
};

// Struct for pivot points.
struct PivotPoints {
  double pp, s1, s2, s3, s4, r1, r2, r3, r4;
};
