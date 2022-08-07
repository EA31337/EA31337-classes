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
 * Includes Chart's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward class declaration.
class Class;
struct ChartTf;

// Includes.
#include "Array.mqh"
#include "Bar.struct.h"
#include "Chart.define.h"
#include "Chart.enum.h"
#include "Chart.struct.static.h"
#include "Chart.struct.tf.h"
#include "Serializer.mqh"
#include "SerializerNode.enum.h"
#include "Terminal.define.h"

/* Defines struct to store bar entries. */
struct ChartEntry {
  BarEntry bar;
  // Constructors.
  ChartEntry() {}
  ChartEntry(const BarEntry& _bar) { SetBar(_bar); }
  // Getters.
  BarEntry GetBar() { return bar; }
  string ToCSV() { return StringFormat("%s", bar.ToCSV()); }
  // Setters.
  void SetBar(const BarEntry& _bar) { bar = _bar; }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s);
};

/* Defines struct for chart parameters. */
struct ChartParams {
  long id;
  string symbol;
  ChartTf tf;
  // Copy constructor.
  ChartParams(ChartParams& _cparams) : symbol(_cparams.symbol), tf(_cparams.tf) {}
  // Constructors.
  ChartParams(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _symbol = NULL, long _id = 0)
      : id(_id), symbol(_symbol), tf(_tf){};
  ChartParams(ENUM_TIMEFRAMES_INDEX _tfi, string _symbol = NULL, long _id = 0) : id(_id), symbol(_symbol), tf(_tfi){};
  // Getters.
  template <typename T>
  T Get(ENUM_CHART_PARAM _param) {
    switch (_param) {
      case CHART_PARAM_ID:
        return (T)id;
      case CHART_PARAM_SYMBOL:
        return (T)symbol;
      case CHART_PARAM_TF:
        return (T)tf.GetTf();
      case CHART_PARAM_TFI:
        return (T)tf.GetIndex();
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return (T)WRONG_VALUE;
  }
  ChartTf GetChartTf() const { return tf; }
  // ENUM_TIMEFRAMES GetTf() const { return tf.GetTf(); }
  // ENUM_TIMEFRAMES_INDEX GetTfIndex() const { return tf.GetIndex(); }
  // Setters.
  template <typename T>
  void Set(ENUM_CHART_PARAM _param, T _value) {
    switch (_param) {
      case CHART_PARAM_ID:
        id = (long)_value;
        return;
      case CHART_PARAM_SYMBOL:
        symbol = (string)_value;
        return;
      case CHART_PARAM_TF:
        tf.SetTf((ENUM_TIMEFRAMES)_value);
        return;
      case CHART_PARAM_TFI:
        tf.SetIndex((ENUM_TIMEFRAMES_INDEX)_value);
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  // Serializers.
  SerializerNodeType Serialize(Serializer& s);
} chart_params_defaults(PERIOD_CURRENT, _Symbol);
