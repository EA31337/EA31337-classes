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
 * Class to provide generic chart operations.
 */

// Prevents processing this includes file for the second time.
#ifndef __MQL__
#pragma once
#endif

// Includes.
#include "Bar.struct.h"
#include "Chart.enum.h"
#include "Chart.symboltf.h"
#include "Dict.mqh"
#include "Refs.mqh"

/**
 * Abstract class used as a base for market prices source.
 */
class ChartBase : public Dynamic {
  // Generic chart params.
  ChartParams cparams;

  // Time of the last bar per symbol and timeframe.
  Dict<SymbolTf, datetime> last_bar_time;

  // Index of the current bar per symbol and timeframe.
  Dict<SymbolTf, int> bar_index;

  // Index of the current tick per symbol and timeframe.
  Dict<SymbolTf, int> tick_index;

 public:
  /**
   * Gets a chart parameter value.
   */
  template <typename T>
  T Get(ENUM_CHART_PARAM _param) {
    return cparams.Get<T>(_param);
  }

  /**
   * Check if there is a new bar to parse.
   */
  bool IsNewBar(const SymbolTf& _symbol_tf) {
    bool _result = false;
    datetime _bar_time = GetBarTime(_symbol_tf);
    if (GetLastBarTime(_symbol_tf) != _bar_time) {
      SetLastBarTime(_symbol_tf, _bar_time);
      _result = true;
    }
    return _result;
  }

  datetime GetLastBarTime(const SymbolTf& _symbol_tf) {
    if (last_bar_time.KeyExists(_symbol_tf.Key())) {
      return last_bar_time.GetByKey(_symbol_tf.Key());
    }
    return GetBarTime();
  }

  void SetLastBarTime(const SymbolTf& _symbol_tf, datetime _dt) { last_bar_time.Set(_symbol_tf.Key(), _dt); }

  int GetBarIndex(const SymbolTf& _symbol_tf) {
    if (bar_index.KeyExists(_symbol_tf.Key())) {
      return bar_index.GetByKey(_symbol_tf.Key());
    }
    return 0;
  }

  void SetBarIndex(const SymbolTf& _symbol_tf, int _bar_index) { bar_index.Set(_symbol_tf, _bar_index); }

  /**
   * Returns current tick index (incremented every OnTick()).
   */
  unsigned int GetTickIndex() { return tick_index == -1 ? 0 : tick_index; }

  /**
   * Returns current bar index (incremented every OnTick() if IsNewBar() is true).
   */
  unsigned int GetBarIndex() { return bar_index == -1 ? 0 : bar_index; }

  /**
   * Acknowledges chart that new tick happened.
   */
  void OnTick() {
    ++tick_index;
    // @fixit @todo
    // if (last_bar_time != GetBarTime()) {
    //  ++bar_index;
    //}
  }

  /**
   * Returns open price value for the bar of indicated symbol and timeframe.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetOpen(const SymbolTf& _symbol_tf, int _shift = 0) { return GetPrice(PRICE_OPEN, _symbol, _tf); }

  /**
   * Returns high price value for the bar of indicated symbol and timeframe.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetHigh(const SymbolTf& _symbol_tf, int _shift = 0) { return GetPrice(PRICE_HIGH, _symbol, _tf); }

  /**
   * Returns low price value for the bar of indicated symbol and timeframe.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetLow(const SymbolTf& _symbol_tf, int _shift = 0) { return GetPrice(PRICE_LOW, _symbol, _tf); }

  /**
   * Returns close price value for the bar of indicated symbol and timeframe.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetClose(const SymbolTf& _symbol_tf, int _shift = 0) { return GetPrice(PRICE_CLOSE, _symbol, _tf); }

  /**
   * Gets OHLC price values.
   */
  virtual BarOHLC GetOHLC(const SymbolTf& _symbol_tf, int _shift = 0) = 0;

  virtual datetime GetBarTime(const SymbolTf& _symbol_tf, int _shift = 0) = 0;

  /**
   * Returns the current price value given applied price type, symbol and timeframe.
   */
  virtual double GetPrice(ENUM_APPLIED_PRICE _ap, const SymbolTf& _symbol_tf, int _shift = 0) = 0;

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetVolume(const SymbolTf& _symbol_tf, int _shift = 0) = 0;

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  virtual int GetHighest(const SymbolTf& _symbol_tf, int type, int _count = WHOLE_ARRAY, int _start = 0) = 0;

  /**
   * Returns the shift of the minimum value over a specific number of periods depending on type.
   */
  virtual int GetLowest(const SymbolTf& _symbol_tf, int type, int _count = WHOLE_ARRAY, int _start = 0) = 0;

  /**
   * Returns the number of bars on the chart.
   */
  virtual int GetBars(const SymbolTf& _symbol_tf) = 0;

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  virtual int GetBarShift(const SymbolTf& _symbol_tf, datetime _time, bool _exact = false) = 0;

  /**
   * Get peak price at given number of bars.
   *
   * In case of error, check it via GetLastError().
   */
  virtual double GetPeakPrice(const SymbolTf& _symbol_tf, int _bars, int _mode, int _index) = 0;
};
