//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
 * Includes Chart's static structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Platform.extern.h"
#include "../Terminal.define.h"
#include "Chart.define.h"
#include "Chart.symboltf.h"

/* Defines struct for chart static methods. */
struct ChartStatic {
  /**
   * Returns the number of bars on the specified chart.
   */
  static int iBars(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
#ifdef __MQL4__
    // In MQL4, for the current chart, the information about the amount of bars is in the Bars predefined variable.
    int _bars = ::iBars(_symbol, _tf);
#else  // _MQL5__
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    int _bars = ::Bars(_symbol, _tf);
#endif

    if (_LastError != ERR_NO_ERROR) {
      Print("Error: ", _LastError, " while doing ::[i]Bars in ChartStatic::iBars(", _symbol, ", ", EnumToString(_tf),
            ")");
      DebugBreak();
    }

    return _bars;
  }

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  static int iBarShift(string _symbol, ENUM_TIMEFRAMES _tf, datetime _time, bool _exact = false) {
    int _bar_shift;
#ifdef __MQL4__
    _bar_shift = ::iBarShift(_symbol, _tf, _time, _exact);
    if (_LastError != ERR_NO_ERROR) {
      Print("Error: ", _LastError, " while doing ::iBarShift() in ChartStatic::iBarShift(", _symbol, ", ",
            EnumToString(_tf), ", ", TimeToString(_time), ", ", _exact, ")");
      DebugBreak();
    }
    return _bar_shift;
#else  // __MQL5__
    if (_time == (datetime)0) return (-1);
    ARRAY(datetime, arr);
    datetime _time0;
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    CopyTime(_symbol, _tf, 0, 1, arr);

    if (_LastError != ERR_NO_ERROR) {
      Print("Error: ", _LastError, " while doing 1st CopyTime() in ChartStatic::iBarShift(", _symbol, ", ",
            EnumToString(_tf), ", ", TimeToString(_time), ", ", _exact, ")");
      DebugBreak();
    }

    _time0 = arr[0];
    if (CopyTime(_symbol, _tf, _time, _time0, arr) > 0) {
      if (ArraySize(arr) > 2) {
        _bar_shift = ArraySize(arr) - 1;
      } else {
        _bar_shift = _time < _time0 ? 1 : 0;
      }
    } else {
      _bar_shift = -1;
    }

    if (_LastError != ERR_NO_ERROR) {
      Print("Error: ", _LastError, " while doing 2nd CopyTime in ChartStatic::iBarShift(", _symbol, ", ",
            EnumToString(_tf), ", ", TimeToString(_time), ", ", _exact, ")");
      DebugBreak();
    }
#endif

    return _bar_shift;
  }

  /**
   * Returns close price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   *
   * @see http://docs.mql4.com/series/iclose
   */
  static double iClose(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) {
#ifdef __MQL4__
    return ::iClose(_symbol, _tf, _shift);  // Same as: Close[_shift]
#else                                       // __MQL5__
    ARRAY(double, _arr);
    ArraySetAsSeries(_arr, true);
    return (_shift >= 0 && CopyClose(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : 0;
#endif
  }

  /**
   * Returns low price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static double iHigh(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _shift = 0) {
#ifdef __MQL4__
    return ::iHigh(_symbol, _tf, _shift);  // Same as: High[_shift]
#else                                      // __MQL5__
    ARRAY(double, _arr);
    ArraySetAsSeries(_arr, true);
    return (_shift >= 0 && CopyHigh(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : 0;
#endif
  }

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  static int iHighest(const SymbolTf& _symbol_tf, int _type = MODE_HIGH, unsigned int _count = WHOLE_ARRAY,
                      int _start = 0) {
#ifdef __MQL4__
    return ::iHighest(_symbol_tf.Symbol(), _symbol_tf.Tf(), _type, _count, _start);
#else  // __MQL5__
    if (_start < 0) return (-1);
    _count = (_count <= 0 ? ChartStatic::iBars(_symbol_tf.Symbol(), _symbol_tf.Tf()) : _count);
    ARRAY(double, arr_d);
    ARRAY(int64, arr_l);
    ARRAY(datetime, arr_dt);
    ArraySetAsSeries(arr_d, true);
    switch (_type) {
      case MODE_OPEN:
        CopyOpen(_symbol_tf.Symbol(), _symbol_tf.Tf(), _start, _count, arr_d);
        break;
      case MODE_LOW:
        CopyLow(_symbol_tf.Symbol(), _symbol_tf.Tf(), _start, _count, arr_d);
        break;
      case MODE_HIGH:
        CopyHigh(_symbol_tf.Symbol(), _symbol_tf.Tf(), _start, _count, arr_d);
        break;
      case MODE_CLOSE:
        CopyClose(_symbol_tf.Symbol(), _symbol_tf.Tf(), _start, _count, arr_d);
        break;
      case MODE_VOLUME:
        ArraySetAsSeries(arr_l, true);
        CopyTickVolume(_symbol_tf.Symbol(), _symbol_tf.Tf(), _start, _count, arr_l);
        return (ArrayMaximum(arr_l, 0, _count) + _start);
      case MODE_TIME:
        ArraySetAsSeries(arr_dt, true);
        CopyTime(_symbol_tf.Symbol(), _symbol_tf.Tf(), _start, _count, arr_dt);
        return (ArrayMaximum(arr_dt, 0, _count) + _start);
      default:
        break;
    }
    return (ArrayMaximum(arr_d, 0, _count) + _start);
#endif
  }

  /**
   * Returns low price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static double iLow(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _shift = 0) {
#ifdef __MQL4__
    return ::iLow(_symbol, _tf, _shift);  // Same as: Low[_shift]
#else                                     // __MQL5__
    ARRAY(double, _arr);
    ArraySetAsSeries(_arr, true);
    return (_shift >= 0 && CopyLow(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : 0;
#endif
  }

  /**
   * Returns the shift of the lowest value over a specific number of periods depending on type.
   */
  static int iLowest(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _type = MODE_LOW,
                     unsigned int _count = WHOLE_ARRAY, int _start = 0) {
#ifdef __MQL4__
    return ::iLowest(_symbol, _tf, _type, _count, _start);
#else  // __MQL5__
    if (_start < 0) return (-1);
    _count = (_count <= 0 ? iBars(_symbol, _tf) : _count);
    ARRAY(double, arr_d);
    ARRAY(int64, arr_l);
    ARRAY(datetime, arr_dt);
    ArraySetAsSeries(arr_d, true);
    switch (_type) {
      case MODE_OPEN:
        CopyOpen(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_LOW:
        CopyLow(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_HIGH:
        CopyHigh(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_CLOSE:
        CopyClose(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_VOLUME:
        ArraySetAsSeries(arr_l, true);
        CopyTickVolume(_symbol, _tf, _start, _count, arr_l);
        return ArrayMinimum(arr_l, 0, _count) + _start;
      case MODE_TIME:
        ArraySetAsSeries(arr_dt, true);
        CopyTime(_symbol, _tf, _start, _count, arr_dt);
        return ArrayMinimum(arr_dt, 0, _count) + _start;
      default:
        break;
    }
    return ArrayMinimum(arr_d, 0, _count) + _start;
#endif
  }

  /**
   * Returns open price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static double iOpen(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _shift = 0) {
#ifdef __MQL4__
    return ::iOpen(_symbol, _tf, _shift);  // Same as: Open[_shift]
#else                                      // __MQL5__
    ARRAY(double, _arr);
    ArraySetAsSeries(_arr, true);
    return (_shift >= 0 && CopyOpen(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : 0;
#endif
  }

  /**
   * Returns the current price value given applied price type.
   */
  static double iPrice(ENUM_APPLIED_PRICE _ap, string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
                       int _shift = 0) {
    double _result = EMPTY_VALUE;
    switch (_ap) {
      // Close price.
      case PRICE_CLOSE:
        _result = ChartStatic::iClose(_symbol, _tf, _shift);
        break;
      // Open price.
      case PRICE_OPEN:
        _result = ChartStatic::iOpen(_symbol, _tf, _shift);
        break;
      // The maximum price for the period.
      case PRICE_HIGH:
        _result = ChartStatic::iHigh(_symbol, _tf, _shift);
        break;
      // The minimum price for the period.
      case PRICE_LOW:
        _result = ChartStatic::iLow(_symbol, _tf, _shift);
        break;
      // Median price: (high + low)/2.
      case PRICE_MEDIAN:
        _result = (ChartStatic::iHigh(_symbol, _tf, _shift) + ChartStatic::iLow(_symbol, _tf, _shift)) / 2;
        break;
      // Typical price: (high + low + close)/3.
      case PRICE_TYPICAL:
        _result = (ChartStatic::iHigh(_symbol, _tf, _shift) + ChartStatic::iLow(_symbol, _tf, _shift) +
                   ChartStatic::iClose(_symbol, _tf, _shift)) /
                  3;
        break;
      // Weighted close price: (high + low + close + close)/4.
      case PRICE_WEIGHTED:
        _result = (ChartStatic::iHigh(_symbol, _tf, _shift) + ChartStatic::iLow(_symbol, _tf, _shift) +
                   ChartStatic::iClose(_symbol, _tf, _shift) + ChartStatic::iClose(_symbol, _tf, _shift)) /
                  4;
        break;
      default:
        break;  // FINAL_APPLIED_PRICE_ENTRY.
    }
    return _result;
  }

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static int64 iVolume(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) {
#ifdef __MQL4__
    ResetLastError();
    int64 _volume = ::iVolume(_symbol, _tf, _shift);  // Same as: Volume[_shift]
    if (_LastError != ERR_NO_ERROR) {
      _volume = EMPTY_VALUE;
      ResetLastError();
    }
    return _volume;
#else  // __MQL5__
    ARRAY(int64, _arr);
    ArraySetAsSeries(_arr, true);
    return (_shift >= 0 && CopyTickVolume(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : 0;
#endif
  }

  /**
   * Returns open time price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static datetime GetBarTime(CONST_REF_TO_SIMPLE(string) _symbol, ENUM_TIMEFRAMES _tf, unsigned int _shift = 0) {
#ifdef __MQL4__
    datetime _time = ::iTime(_symbol, _tf, _shift);  // Same as: Time[_shift]

    if (_LastError != ERR_NO_ERROR) {
      Print("Error: ", _LastError, " while doing ::iTime() in ChartStatic::GetBarTime(", _symbol, ", ",
            EnumToString(_tf), ", ", _shift, ")");
      DebugBreak();
    }
#else  // __MQL5__
    ARRAY(datetime, _arr);
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    // @todo: Improves performance by caching values.

    datetime _time = (_shift >= 0 && ::CopyTime(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : (datetime)0;

    if (_LastError != ERR_NO_ERROR) {
      Print("Error: ", _LastError, " while doing CopyTime() in ChartStatic::GetBarTime(", _symbol, ", ",
            EnumToString(_tf), ", ", _shift, ")");
      DebugBreak();
    }
#endif

    return _time;
  }

  /**
   * Gets Chart ID.
   */
  static int64 ID() { return ::ChartID(); }
};
