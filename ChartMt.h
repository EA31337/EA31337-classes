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
#include "ChartBase.h"

/**
 * Meta-trader's native market prices source.
 */
class ChartMt : public ChartBase {
 public:
  // Virtual methods.

  /**
   * Gets OHLC price values.
   */
  virtual BarOHLC GetOHLC(string _symbol, ENUM_TIMEFRAMES _tf, int _shift = 0) override {
    datetime _time = GetBarTime(_symbol, _tf, _shift);
    float _open = 0, _high = 0, _low = 0, _close = 0;
    if (_time > 0) {
      _open = (float)GetOpen(_symbol, _tf, _shift);
      _high = (float)GetHigh(_symbol, _tf, _shift);
      _low = (float)GetLow(_symbol, _tf, _shift);
      _close = (float)GetClose(_symbol, _tf, _shift);
    }
    BarOHLC _ohlc(_open, _high, _low, _close, _time);
    return _ohlc;
  }

  virtual datetime GetBarTime(string _symbol, ENUM_TIMEFRAMES _tf, int _shift = 0) override {
    return ::iTime(_symbol, _tf, _shift);
  }

  /**
   * Returns the current price value given applied price type, symbol and timeframe.
   */
  virtual double GetPrice(ENUM_APPLIED_PRICE _ap, string _symbol, ENUM_TIMEFRAMES _tf, int _shift = 0) override {
    switch (_ap) {
      case PRICE_OPEN:
        return ::iOpen(_symbol, _tf, _shift);
      case PRICE_HIGH:
        return ::iHigh(_symbol, _tf, _shift);
      case PRICE_LOW:
        return ::iLow(_symbol, _tf, _shift);
      case PRICE_CLOSE:
        return ::iClose(_symbol, _tf, _shift);
    }
    Print("Invalid applied price!");
    DebugBreak();
    return 0;
  }

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetVolume(string _symbol, ENUM_TIMEFRAMES _tf, int _shift = 0) override {
    return ::iVolume(_symbol, _tf, _shift);
  }

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  virtual int GetHighest(string _symbol, ENUM_TIMEFRAMES _tf, int type, int _count = WHOLE_ARRAY,
                         int _start = 0) override {
    return ::iHighest(_symbol, _tf, (ENUM_SERIESMODE)type, _count, _start);
  }

  /**
   * Returns the shift of the minimum value over a specific number of periods depending on type.
   */
  virtual int GetLowest(string _symbol, ENUM_TIMEFRAMES _tf, int type, int _count = WHOLE_ARRAY,
                        int _start = 0) override {
    return ::iLowest(_symbol, _tf, (ENUM_SERIESMODE)type, _count, _start);
  }

  /**
   * Returns the number of bars on the chart.
   */
  virtual int GetBars(string _symbol, ENUM_TIMEFRAMES _tf) override {
#ifdef __MQL4__
    // In MQL4, for the current chart, the information about the amount of bars is in the Bars predefined variable.
    return ::iBars(_symbol, _tf);
#else  // _MQL5__
    return ::Bars(_symbol, _tf);
#endif
  }

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  virtual int GetBarShift(string _symbol, ENUM_TIMEFRAMES _tf, datetime _time, bool _exact = false) override {
#ifdef __MQL4__
    return ::iBarShift(_symbol, _tf, _time, _exact);
#else  // __MQL5__
    if (_time < 0) return (-1);
    ARRAY(datetime, arr);
    datetime _time0;
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    CopyTime(_symbol, _tf, 0, 1, arr);
    _time0 = arr[0];
    if (CopyTime(_symbol, _tf, _time, _time0, arr) > 0) {
      if (ArraySize(arr) > 2) {
        return ArraySize(arr) - 1;
      } else {
        return _time < _time0 ? 1 : 0;
      }
    } else {
      return -1;
    }
#endif
  }

  /**
   * Get peak price at given number of bars.
   *
   * In case of error, check it via GetLastError().
   */
  virtual double GetPeakPrice(string _symbol, ENUM_TIMEFRAMES _tf, int _bars, int _mode, int _index) override {
    int _ibar = -1;
    // @todo: Add symbol parameter.
    double _peak_price = GetOpen(_symbol, _tf, 0);
    switch (_mode) {
      case MODE_HIGH:
        _ibar = ChartStatic::iHighest(_symbol, _tf, MODE_HIGH, _bars, _index);
        return _ibar >= 0 ? GetHigh(_symbol, _tf, _ibar) : false;
      case MODE_LOW:
        _ibar = ChartStatic::iLowest(_symbol, _tf, MODE_LOW, _bars, _index);
        return _ibar >= 0 ? GetLow(_symbol, _tf, _ibar) : false;
      default:
        return false;
    }
  }
};
