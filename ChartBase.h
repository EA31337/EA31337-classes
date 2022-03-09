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
#include "Chart.struct.h"
#include "Chart.symboltf.h"
#include "Dict.mqh"
#include "Refs.mqh"

/**
 * Abstract class used as a base for market prices source.
 */
class ChartBase : public Dynamic {
  // Generic chart params.
  ChartParams cparams;

  ENUM_TIMEFRAMES tf;

  // Time of the last bar per symbol and timeframe.
  Dict<string, datetime> last_bar_time;

  // Index of the current bar per symbol and timeframe.
  Dict<string, int> bar_index;

  // Index of the current tick per symbol and timeframe.
  Dict<string, int> tick_index;

 public:
  /**
   * Constructor.
   */
  ChartBase(ENUM_TIMEFRAMES _tf) : tf(_tf) {}

  /**
   * Return time-frame bound to chart.
   */
  ENUM_TIMEFRAMES GetTf() { return tf; }

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
  bool IsNewBar(CONST_REF_TO(string) _symbol) {
    bool _result = false;
    datetime _bar_time = GetBarTime(_symbol);
    if (GetLastBarTime(_symbol) != _bar_time) {
      SetLastBarTime(_symbol, _bar_time);
      _result = true;
    }
    return _result;
  }

  datetime GetLastBarTime(CONST_REF_TO(string) _symbol) {
    if (last_bar_time.KeyExists(_symbol.Key())) {
      return last_bar_time.GetByKey(_symbol.Key());
    }
    return GetBarTime(_symbol);
  }

  void SetLastBarTime(CONST_REF_TO(string) _symbol, datetime _dt) { last_bar_time.Set(_symbol.Key(), _dt); }

  /**
   * Returns current bar index (incremented every OnTick() if IsNewBar() is true).
   */
  int GetBarIndex(CONST_REF_TO(string) _symbol) {
    if (bar_index.KeyExists(_symbol.Key())) {
      return bar_index.GetByKey(_symbol.Key());
    }
    return 0;
  }

  /**
   * Sets current bar index.
   */
  void SetBarIndex(CONST_REF_TO(string) _symbol, int _bar_index) { bar_index.Set(_symbol.Key(), _bar_index); }

  /**
   * Increases current bar index (used in OnTick()). If there was no bar, the current bar will become 0.
   */
  void IncreaseBarIndex(CONST_REF_TO(string) _symbol) {
    if (bar_index.KeyExists(_symbol.Key())) {
      SetBarIndex(_symbol, GetBarIndex(_symbol) + 1);
    } else {
      SetBarIndex(_symbol, 0);
    }
  }

  /**
   * Returns current tick index (incremented every OnTick()).
   */
  int GetTickIndex(CONST_REF_TO(string) _symbol) {
    if (tick_index.KeyExists(_symbol.Key())) {
      return tick_index.GetByKey(_symbol.Key());
    }
    return 0;
  }

  /**
   * Sets current tick index.
   */
  void SetTickIndex(CONST_REF_TO(string) _symbol, int _tick_index) { tick_index.Set(_symbol.Key(), _tick_index); }

  /**
   * Increases current tick index (used in OnTick()). If there was no tick, the current tick will become 0.
   */
  void IncreaseTickIndex(CONST_REF_TO(string) _symbol) {
    if (tick_index.KeyExists(_symbol.Key())) {
      SetTickIndex(_symbol, GetTickIndex(_symbol) + 1);
    } else {
      SetTickIndex(_symbol, 0);
    }
  }

  /**
   * Acknowledges chart that new tick happened.
   */
  void OnTick(CONST_REF_TO(string) _symbol) {
    IncreaseTickIndex(_symbol);
    if (IsNewBar(_symbol)) {
      IncreaseBarIndex(_symbol);
    }
  }

  /**
   * Returns open price value for the bar of indicated symbol and timeframe.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetOpen(CONST_REF_TO(string) _symbol, int _shift = 0) { return GetPrice(PRICE_OPEN, _symbol, _shift); }

  /**
   * Returns high price value for the bar of indicated symbol and timeframe.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetHigh(CONST_REF_TO(string) _symbol, int _shift = 0) { return GetPrice(PRICE_HIGH, _symbol, _shift); }

  /**
   * Returns low price value for the bar of indicated symbol and timeframe.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetLow(CONST_REF_TO(string) _symbol, int _shift = 0) { return GetPrice(PRICE_LOW, _symbol, _shift); }

  /**
   * Returns close price value for the bar of indicated symbol and timeframe.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetClose(CONST_REF_TO(string) _symbol, int _shift = 0) { return GetPrice(PRICE_CLOSE, _symbol, _shift); }

  /**
   * Return number of symbols available for the chart.
   */
  virtual int GetSymbolsTotal() { return ::SymbolsTotal(true); }

  /**
   * Return symbol pair for a given symbol index.
   */
  virtual const string GetSymbolName(int _index) { return ::SymbolName(_index, true); }

  /**
   * Gets OHLC price values.
   */
  virtual BarOHLC GetOHLC(CONST_REF_TO(string) _symbol, int _shift = 0) {
    datetime _time = GetBarTime(_symbol, _shift);
    float _open = 0, _high = 0, _low = 0, _close = 0;
    if (_time > 0) {
      _open = (float)GetOpen(_symbol, _shift);
      _high = (float)GetHigh(_symbol, _shift);
      _low = (float)GetLow(_symbol, _shift);
      _close = (float)GetClose(_symbol, _shift);
    }
    BarOHLC _ohlc(_open, _high, _low, _close, _time);
    return _ohlc;
  }

  virtual datetime GetBarTime(CONST_REF_TO(string) _symbol, int _shift = 0) = 0;

  /**
   * Returns the current price value given applied price type, symbol and timeframe.
   */
  virtual double GetPrice(ENUM_APPLIED_PRICE _ap, CONST_REF_TO(string) _symbol, int _shift = 0) = 0;

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetVolume(CONST_REF_TO(string) _symbol, int _shift = 0) = 0;

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  virtual int GetHighest(CONST_REF_TO(string) _symbol, int type, int _count = WHOLE_ARRAY, int _start = 0) = 0;

  /**
   * Returns the shift of the minimum value over a specific number of periods depending on type.
   */
  virtual int GetLowest(CONST_REF_TO(string) _symbol, int type, int _count = WHOLE_ARRAY, int _start = 0) = 0;

  /**
   * Returns the number of bars on the chart.
   */
  virtual int GetBars(CONST_REF_TO(string) _symbol) = 0;

  /**
   * Returns open time price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual datetime GetTime(CONST_REF_TO(string) _symbol, unsigned int _shift = 0) = 0;

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  virtual int GetBarShift(CONST_REF_TO(string) _symbol, datetime _time, bool _exact = false) = 0;

  /**
   * Get peak price at given number of bars.
   *
   * In case of error, check it via GetLastError().
   */
  virtual double GetPeakPrice(CONST_REF_TO(string) _symbol, int _bars, int _mode, int _index) {
    int _ibar = -1;
    double peak_price = GetOpen(_symbol, 0);
    switch (mode) {
      case MODE_HIGH:
        _ibar = GetHighest(_symbol, MODE_HIGH, bars, index);
        return _ibar >= 0 ? GetHigh(_symbol, _ibar) : false;
      case MODE_LOW:
        _ibar = GetLowest(_symbol, MODE_LOW, bars, index);
        return _ibar >= 0 ? GetLow(_symbol, _ibar) : false;
      default:
        return false;
    }
  }

  /**
   * Gets chart entry.
   *
   * @param
   *   _tf ENUM_TIMEFRAMES Timeframe to use.
   *   _shift unsigned int _shift Shift to use.
   *   _symbol string Symbol to use.
   *
   * @return
   *   Returns ChartEntry struct.
   */
  ChartEntry GetEntry(CONST_REF_TO(string) _symbol, unsigned int _shift = 0) {
    ChartEntry _chart_entry;
    BarOHLC _ohlc = GetOHLC(_symbol, _shift);
    if (_ohlc.open > 0) {
      BarEntry _bar_entry(_ohlc);
      _chart_entry.SetBar(_bar_entry);
    }
    return _chart_entry;
  }

  /* State checking */

  /**
   * Validate whether given timeframe index is valid.
   */
  static bool IsValidTfIndex(ENUM_TIMEFRAMES_INDEX _tfi, string _symbol = NULL) {
    return IsValidTf(ChartTf::IndexToTf(_tfi), _symbol);
  }

  /**
   * Validates whether given timeframe is valid.
   */
  static bool IsValidShift(CONST_REF_TO(string) _symbol, int _shift) { return GetTime(_symbol, _shift) > 0; }

  /**
   * Validates whether given timeframe is valid.
   */
  bool IsValidTf(CONST_REF_TO(string) _symbol) { return GetOpen(CONST_REF_TO(string) _symbol) > 0; }
};
