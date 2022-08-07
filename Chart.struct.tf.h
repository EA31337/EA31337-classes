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
 * Includes Chart's timeframe structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward declarations.
class Serializer;

// Includes.
#include "Chart.enum.h"
#include "SerializerNode.enum.h"
#include "Terminal.define.h"

/* Defines struct for chart timeframe. */
struct ChartTf {
 protected:
  ENUM_TIMEFRAMES tf;
  ENUM_TIMEFRAMES_INDEX tfi;

 public:
  // Constructors.
  ChartTf(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : tf(_tf), tfi(ChartTf::TfToIndex(_tf)){};
  ChartTf(ENUM_TIMEFRAMES_INDEX _tfi) : tfi(_tfi), tf(ChartTf::IndexToTf(_tfi)){};
  ChartTf(const ChartTf& _ctf) : tf(_ctf.tf), tfi(_ctf.tfi){};

  // Struct operators.
  void operator=(ENUM_TIMEFRAMES _tf) { SetTf(_tf); }
  void operator=(ENUM_TIMEFRAMES_INDEX _tfi) { SetIndex(_tfi); }

  /* Getters */

  /**
   * Returns timeframe's period in number of hours.
   */
  double GetInHours() const { return ChartTf::TfToHours(tf); }

  /**
   * Returns timeframe's period in number of minutes.
   */
  double GetInMinutes() const { return ChartTf::TfToMinutes(tf); }

  /**
   * Returns timeframe's period in number of seconds.
   */
  unsigned int GetInSeconds() const { return ChartTf::TfToSeconds(tf); }

  /**
   * Returns chart's timeframe index.
   *
   * @return ENUM_TIMEFRAMES_INDEX
   *   Returns enum representing chart's timeframe index.
   */
  ENUM_TIMEFRAMES_INDEX GetIndex() const { return tfi; }

  /**
   * Returns chart's timeframe value.
   *
   * @return ENUM_TIMEFRAMES
   *   Returns enum representing chart's timeframe value.
   */
  ENUM_TIMEFRAMES GetTf() const { return tf; }

  /**
   * Returns chart's textual represention.
   *
   * @return string
   *   Returns string represention.
   */
  string GetString() const { return TfToString(tf); }

  /* Setters */

  /**
   * Sets chart's timeframe.
   *
   * @param _tf
   *   Timeframe enum.
   */
  void SetTf(ENUM_TIMEFRAMES _tf) {
    tf = _tf;
    tfi = ChartTf::TfToIndex(_tf);
  }

  /**
   * Sets chart's timeframe.
   *
   * @param _tf
   *   Timeframe enum.
   */
  void SetIndex(ENUM_TIMEFRAMES_INDEX _tfi) {
    tf = ChartTf::IndexToTf(_tfi);
    tfi = _tfi;
  }

  /* Static methods */

  /**
   * Converts number of seconds per bar to chart's timeframe.
   *
   * @param _secs
   *   Number of seconds per one bar chart (OHLC).
   *
   * @return ENUM_TIMEFRAMES
   *   Returns enum representing chart's timeframe value.
   */
  static ENUM_TIMEFRAMES SecsToTf(unsigned int _secs = 0) {
    switch (_secs) {
      case 0:
        return PERIOD_CURRENT;
      case 60:
        return PERIOD_M1;  // 1 minute.
      case 60 * 2:
        return PERIOD_M2;  // 2 minutes (non-standard).
      case 60 * 3:
        return PERIOD_M3;  // 3 minutes (non-standard).
      case 60 * 4:
        return PERIOD_M4;  // 4 minutes (non-standard).
      case 60 * 5:
        return PERIOD_M5;  // 5 minutes.
      case 60 * 6:
        return PERIOD_M6;  // 6 minutes (non-standard).
      case 60 * 10:
        return PERIOD_M10;  // 10 minutes (non-standard).
      case 60 * 12:
        return PERIOD_M12;  // 12 minutes (non-standard).
      case 60 * 15:
        return PERIOD_M15;  // 15 minutes.
      case 60 * 20:
        return PERIOD_M20;  // 20 minutes (non-standard).
      case 60 * 30:
        return PERIOD_M30;  // 30 minutes.
      case 60 * 60:
        return PERIOD_H1;  // 1 hour.
      case 60 * 60 * 2:
        return PERIOD_H2;  // 2 hours (non-standard).
      case 60 * 60 * 3:
        return PERIOD_H3;  // 3 hours (non-standard).
      case 60 * 60 * 4:
        return PERIOD_H4;  // 4 hours.
      case 60 * 60 * 6:
        return PERIOD_H6;  // 6 hours (non-standard).
      case 60 * 60 * 8:
        return PERIOD_H8;  // 8 hours (non-standard).
      case 60 * 60 * 12:
        return PERIOD_H12;  // 12 hours (non-standard).
      case 60 * 60 * 24:
        return PERIOD_D1;  // Daily.
      case 60 * 60 * 24 * 7:
        return PERIOD_W1;  // Weekly.
      default:
        break;
    }
    if (_secs >= 60 * 60 * 24 * 28 && _secs <= 60 * 60 * 24 * 31) {
      return PERIOD_MN1;  // Monthly range.
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return PERIOD_CURRENT;
  }

  /**
   * Convert period to proper chart timeframe value.
   *
   * @param
   * _tf ENUM_TIMEFRAMES_INDEX Specify timeframe index enum.
   */
  static ENUM_TIMEFRAMES const IndexToTf(ENUM_TIMEFRAMES_INDEX index) {
    // @todo: Convert it into a loop and using tf constant, see: TfToIndex().
    switch (index) {
      case M1:
        return PERIOD_M1;  // 1 minute.
      case M2:
        return PERIOD_M2;  // 2 minutes (non-standard).
      case M3:
        return PERIOD_M3;  // 3 minutes (non-standard).
      case M4:
        return PERIOD_M4;  // 4 minutes (non-standard).
      case M5:
        return PERIOD_M5;  // 5 minutes.
      case M6:
        return PERIOD_M6;  // 6 minutes (non-standard).
      case M10:
        return PERIOD_M10;  // 10 minutes (non-standard).
      case M12:
        return PERIOD_M12;  // 12 minutes (non-standard).
      case M15:
        return PERIOD_M15;  // 15 minutes.
      case M20:
        return PERIOD_M20;  // 20 minutes (non-standard).
      case M30:
        return PERIOD_M30;  // 30 minutes.
      case H1:
        return PERIOD_H1;  // 1 hour.
      case H2:
        return PERIOD_H2;  // 2 hours (non-standard).
      case H3:
        return PERIOD_H3;  // 3 hours (non-standard).
      case H4:
        return PERIOD_H4;  // 4 hours.
      case H6:
        return PERIOD_H6;  // 6 hours (non-standard).
      case H8:
        return PERIOD_H8;  // 8 hours (non-standard).
      case H12:
        return PERIOD_H12;  // 12 hours (non-standard).
      case D1:
        return PERIOD_D1;  // Daily.
      case W1:
        return PERIOD_W1;  // Weekly.
      case MN1:
        return PERIOD_MN1;  // Monthly.
      default:
        return (ENUM_TIMEFRAMES)-1;
    }
  }

  /**
   * Convert timeframe period to hours.
   *
   * @param
   * _tf ENUM_TIMEFRAMES Specify timeframe enum.
   */
  static double TfToHours(const ENUM_TIMEFRAMES _tf) { return ChartTf::TfToSeconds(_tf) / (60 * 60); }

  /**
   * Convert timeframe constant to index value.
   *
   * @param
   * _tf ENUM_TIMEFRAMES Specify timeframe enum.
   */
  static ENUM_TIMEFRAMES_INDEX TfToIndex(ENUM_TIMEFRAMES _tf) {
    _tf = (_tf == 0 || _tf == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : _tf;
    for (int i = 0; i < ArraySize(TIMEFRAMES_LIST); i++) {
      if (TIMEFRAMES_LIST[i] == _tf) {
        return (ENUM_TIMEFRAMES_INDEX)i;
      }
    }
    return FINAL_ENUM_TIMEFRAMES_INDEX;
  }

  /**
   * Convert timeframe period to minutes.
   *
   * @param
   * _tf ENUM_TIMEFRAMES Specify timeframe enum.
   */
  static double TfToMinutes(const ENUM_TIMEFRAMES _tf) { return ChartTf::TfToSeconds(_tf) / 60; }

  /**
   * Convert timeframe period to seconds.
   *
   * @param
   * _tf ENUM_TIMEFRAMES Specify timeframe enum.
   */
  static unsigned int TfToSeconds(const ENUM_TIMEFRAMES _tf) { return ::PeriodSeconds(_tf); }

  /**
   * Returns text representation of the timeframe constant.
   *
   * @param
   * _tf ENUM_TIMEFRAMES Specify timeframe enum.
   *
   * @return
   * Returns string representation of the timeframe.
   */
  static string TfToString(const ENUM_TIMEFRAMES _tf) {
    switch (_tf) {
      case PERIOD_CURRENT:
        return "Current";
      case PERIOD_M1:
        return "M1";
      case PERIOD_M2:
        return "M2";
      case PERIOD_M3:
        return "M3";
      case PERIOD_M4:
        return "M4";
      case PERIOD_M5:
        return "M5";
      case PERIOD_M6:
        return "M6";
      case PERIOD_M10:
        return "M10";
      case PERIOD_M12:
        return "M12";
      case PERIOD_M15:
        return "M15";
      case PERIOD_M20:
        return "M20";
      case PERIOD_M30:
        return "M30";
      case PERIOD_H1:
        return "H1";
      case PERIOD_H2:
        return "H2";
      case PERIOD_H3:
        return "H3";
      case PERIOD_H4:
        return "H4";
      case PERIOD_H6:
        return "H6";
      case PERIOD_H8:
        return "H8";
      case PERIOD_H12:
        return "H12";
      case PERIOD_D1:
        return "D1";
      case PERIOD_W1:
        return "W1";
      case PERIOD_MN1:
        return "MN1";
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return "Unknown";
  }

  /**
   * Returns text representation of the timeframe index.
   */
  static string IndexToString(const ENUM_TIMEFRAMES_INDEX _tfi) { return TfToString(IndexToTf(_tfi)); }

  // Serializers.
  SerializerNodeType Serialize(Serializer& s);
};

#include "Serializer.mqh"

/* Method to serialize ChartTf structure. */
SerializerNodeType ChartTf::Serialize(Serializer& s) {
  s.PassEnum(THIS_REF, "tf", tf);
  s.PassEnum(THIS_REF, "tfi", tfi);
  return SerializerNodeObject;
}
